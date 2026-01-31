# Resolution Order and State Transitions

**Purpose**: Define the exact order of operations for the Phalanx game engine turn resolution. Players submit orders simultaneously; this document specifies how those orders resolve.

---

## System Integration

Three subsystems interact during resolution:

| System | Responsibility | Spec |
|--------|----------------|------|
| **Force** | Calculate strength from base + formation + support | force/ |
| **Grouping** | Groups (pre-game), phalanx declaration, atomic balking | group/ |
| **Combat** | Dislodge resolution, damage application, retreats | combat/ |

---

## Order Model

Orders exist at three levels with strict precedence: **Individual > Phalanx > Group**.

### Order Precedence

| Level | Definition | Set When |
|-------|------------|----------|
| **Individual** | Single unit order | During order phase |
| **Phalanx** | Declared phalanx order (atomic) | During order phase |
| **Group** | Pre-defined group order | During order phase |

When expanding orders, higher precedence wins. An individual order overrides any phalanx or group order for that unit. A phalanx order overrides the group order for units in that phalanx.

### Groups (Pre-Game)

Groups are created during the pre-game planning stage and are **fixed for the entire battle**. Players cannot create, modify, or dissolve groups mid-battle.

```elixir
# Group definition (pre-game)
@type group :: %{
  id: String.t(),
  positions: MapSet.t({integer(), integer()}),  # Fixed at battle start
  owner: :red | :purple
}
```

### Phalanx Declaration

Phalanxes are **explicitly declared** during the order phase. Requirements:
1. All units must belong to the **same group** (phalanxes cannot span groups)
2. All units must be **adjacent** (connected component)
3. All units must have the **same rotation**

```elixir
# Phalanx declaration (order phase)
@type phalanx_declaration :: %{
  positions: MapSet.t({integer(), integer()}),  # Subset of a single group
  move: atom() | nil,                            # :east, :west, etc. or nil for hold
  rotation: atom() | nil                         # :clockwise, :counterclockwise, or nil
}
```

### Order Input Structure

```elixir
# Complete order input
@type player_orders :: %{
  individual_orders: [%{position: {integer(), integer()}, move: atom(), rotation: atom()}],
  phalanx_orders: [phalanx_declaration()],
  group_orders: [%{group_id: String.t(), move: atom(), rotation: atom()}]
}
```

### Order Expansion

Orders are expanded to per-unit orders using precedence:

```elixir
def expand_orders(player_orders, groups) do
  # Start with group orders (lowest precedence)
  base_orders = expand_group_orders(player_orders.group_orders, groups)

  # Override with phalanx orders
  with_phalanx = apply_phalanx_orders(base_orders, player_orders.phalanx_orders)

  # Override with individual orders (highest precedence)
  apply_individual_orders(with_phalanx, player_orders.individual_orders)
end
```

---

## Groups vs Phalanxes

| Concept | When Created | Purpose | Requirements |
|---------|--------------|---------|--------------|
| **Group** | Pre-game (fixed) | Organizational unit, order convenience | Same owner only |
| **Phalanx** | Order phase (declared) | Formation bonuses, atomic movement | Within single group + adjacent + same rotation |

**Key distinctions**:
- Groups are **fixed** at battle start; phalanxes are **declared** each turn
- Phalanxes can only form **within a single group** (cannot span groups)
- Individual orders **override** phalanx orders, which **override** group orders

See `group/` spec for full details.

---

## Phase Overview

```
PHASE 1: SNAPSHOT
    Capture turn-start state

PHASE 2: ORDER EXPANSION
    Expand orders using precedence (Individual > Phalanx > Group), validate, populate holds

PHASE 3: PHALANX VALIDATION
    Validate declared phalanxes (within single group, adjacent, same rotation)

PHASE 4: CONFLICT DETECTION
    Find contested hexes, identify collision types

PHASE 5: SUPPORT CALCULATION
    Build support graph, mark cut supports (using conflict info)

PHASE 6: STRENGTH CALCULATION
    Compute force for each combatant (includes phalanx bonuses)

PHASE 7: COMBAT RESOLUTION
    Determine winners/losers, apply phalanx all-or-nothing balking

PHASE 8: MOVEMENT EXECUTION
    Move winners, hold losers

PHASE 9: DAMAGE & RETREAT
    Apply damage, execute retreats, handle cascade deaths

PHASE 10: ROTATION APPLICATION
    Apply rotation orders

PHASE 11: ENERGY & CLEANUP
    Update energy, remove dead units, increment turn
```

---

## Phase 1: SNAPSHOT

### Purpose
Capture immutable state for calculation consistency. All subsequent phases reference this snapshot.

### Inputs
- Current game state: `%{units: map(), turn: int, ...}`

### Processing

```elixir
def snapshot(state) do
  %{
    units: deep_copy(state.units),  # Position -> Unit map
    turn: state.turn
  }
end
```

### Outputs
- `snapshot.units`: Immutable unit positions/states
- `snapshot.turn`: Turn number

### Notes
Phalanxes are detected in Phase 3 after orders are expanded. User groups (for ordering convenience) are validated in Phase 2.

---

## Phase 2: ORDER EXPANSION

### Purpose
Expand orders using precedence (Individual > Phalanx > Group), validate moves, populate holds.

### Inputs
- Player-submitted orders: `%{individual_orders: [...], phalanx_orders: [...], group_orders: [...]}`
- `snapshot.units`
- Pre-defined `groups` (fixed at battle start)

### Processing

```elixir
def expand_and_validate_orders(player_orders, snapshot, groups, map_dimensions) do
  player_orders
  |> expand_with_precedence(groups, snapshot.units)
  |> reject_invalid_moves(snapshot.units, map_dimensions)
  |> populate_holds(snapshot.units)
end
```

**Step 2.1: Expand with Precedence**
Apply orders in precedence order: Group (lowest) → Phalanx → Individual (highest).

```elixir
def expand_with_precedence(player_orders, groups, units) do
  # Start empty
  orders = %{}

  # Layer 1: Group orders (lowest precedence)
  orders = Enum.reduce(player_orders.group_orders, orders, fn group_order, acc ->
    group = Enum.find(groups, &(&1.id == group_order.group_id))
    Enum.reduce(group.positions, acc, fn pos, inner_acc ->
      if Map.has_key?(units, pos) do
        Map.put(inner_acc, pos, %Order{
          position: pos,
          move: group_order.move,
          rotation: group_order.rotation,
          source: :group
        })
      else
        inner_acc
      end
    end)
  end)

  # Layer 2: Phalanx orders (override group)
  orders = Enum.reduce(player_orders.phalanx_orders, orders, fn phalanx_order, acc ->
    Enum.reduce(phalanx_order.positions, acc, fn pos, inner_acc ->
      Map.put(inner_acc, pos, %Order{
        position: pos,
        move: phalanx_order.move,
        rotation: phalanx_order.rotation,
        source: :phalanx,
        phalanx_id: phalanx_order.id
      })
    end)
  end)

  # Layer 3: Individual orders (highest precedence, override all)
  Enum.reduce(player_orders.individual_orders, orders, fn ind_order, acc ->
    Map.put(acc, ind_order.position, %Order{
      position: ind_order.position,
      move: ind_order.move,
      rotation: ind_order.rotation,
      source: :individual
    })
  end)
end
```

**Step 2.2: Reject Invalid Moves**
Per-unit validation. If a unit cannot make the ordered move (rotation constraints, map bounds), convert to hold.

```elixir
def reject_invalid_moves(orders, units, map_dimensions) do
  Enum.map(orders, fn {pos, order} ->
    unit = Map.get(units, pos)
    case Moves.move(map_dimensions, pos, unit.rotation, order.move) do
      {:ok, _} -> {pos, order}
      {:error, _} -> {pos, %{order | move: nil}}
    end
  end)
  |> Map.new()
end
```

**Step 2.3: Populate Holds**
Units without orders get null orders (hold in place).

```elixir
def populate_holds(orders, units) do
  units
  |> Map.keys()
  |> Enum.reduce(orders, fn pos, acc ->
    Map.put_new(acc, pos, Order.null_order(pos))
  end)
end
```

### Outputs
- `validated_orders`: Map of position -> validated order (per-unit)
- Each order includes `source` field (`:group`, `:phalanx`, or `:individual`)

### Edge Cases
- **Individual order overrides phalanx**: Unit moves independently, breaking phalanx atomicity for that unit
- **Order for dead unit**: Ignored (position not in units map)
- **Order for enemy unit**: Rejected (can only order own units)
- **Unit can't make move**: That unit holds; for phalanx orders, may trigger all-or-nothing balk (see Phase 3)
- **Rotation-only order**: Valid (move = nil)

---

## Phase 3: PHALANX VALIDATION

### Purpose
Validate explicitly declared phalanxes. Phalanxes are player-declared, NOT auto-detected.

### Inputs
- `validated_orders` from Phase 2 (includes phalanx_id on relevant orders)
- `snapshot.units`
- Pre-defined `groups` (fixed at battle start)

### Phalanx Requirements

A valid phalanx declaration must satisfy:
1. **Single group**: All units belong to the same pre-defined group
2. **Adjacent**: All units form a connected component (no gaps)
3. **Same rotation**: All units have identical rotation
4. **Same movement**: All units have same movement order (from phalanx order)

### Processing

```elixir
def validate_phalanxes(phalanx_orders, orders, units, groups) do
  Enum.map(phalanx_orders, fn phalanx_order ->
    positions = phalanx_order.positions

    # Check 1: All positions in same group
    group_ids = positions
      |> Enum.map(fn pos -> find_group_for_position(pos, groups) end)
      |> Enum.uniq()
    same_group? = length(group_ids) == 1 and hd(group_ids) != nil

    # Check 2: All positions adjacent (connected component)
    adjacent? = is_connected_component?(positions)

    # Check 3: All same rotation
    rotations = positions |> Enum.map(&Map.get(units, &1).rotation) |> Enum.uniq()
    same_rotation? = length(rotations) == 1

    if same_group? and adjacent? and same_rotation? do
      {:valid, %Phalanx{
        id: phalanx_order.id,
        positions: positions,
        rotation: hd(rotations),
        color: Map.get(units, hd(Enum.to_list(positions))).color,
        move: phalanx_order.move
      }}
    else
      {:invalid, phalanx_order, %{
        same_group: same_group?,
        adjacent: adjacent?,
        same_rotation: same_rotation?
      }}
    end
  end)
end

def find_group_for_position(pos, groups) do
  Enum.find_value(groups, fn group ->
    if MapSet.member?(group.positions, pos), do: group.id
  end)
end

def is_connected_component?(positions) do
  # Flood-fill from first position, check if all positions reached
  [start | _] = Enum.to_list(positions)
  reachable = flood_fill(MapSet.new([start]), positions)
  MapSet.equal?(reachable, positions)
end
```

### Outputs
- `phalanxes`: List of validated `%Phalanx{id, positions, rotation, color, move}`
- Invalid phalanx declarations are rejected; units fall back to group orders

### Key Points
- **Explicit declaration**: Phalanxes are player-declared, NOT auto-detected from board state
- **Single group constraint**: Phalanxes can only form within a single pre-defined group
- **Minimum size**: 2 units (single unit cannot be a phalanx)
- **Used for**: Formation bonuses (Phase 6) and all-or-nothing balking (Phase 7)

---

## Phase 4: CONFLICT DETECTION

### Purpose
Identify all contested hexes and classify conflict types.

### Inputs
- `validated_orders`
- `snapshot.units`

### Processing

```elixir
def detect_conflicts(orders, units) do
  # Step 1: Compute all unit movements
  movements = compute_movements(orders, units)
  # movements: list of {origin, destination, unit}

  # Step 2: Group by destination
  by_destination = Enum.group_by(movements, fn {_origin, dest, _unit} -> dest end)

  # Step 3: Identify conflicts
  conflicts = Enum.flat_map(by_destination, fn {dest, contestants} ->
    cond do
      # Single unit moving to empty hex - no conflict
      length(contestants) == 1 and !Map.has_key?(units, dest) ->
        []

      # Multiple units targeting same hex - destination conflict
      length(contestants) > 1 ->
        [{:destination_conflict, dest, contestants}]

      # Single attacker vs defender
      length(contestants) == 1 ->
        [{origin, _, attacker}] = contestants
        defender_pos = dest
        [{:attack, origin, defender_pos, attacker}]

      true ->
        []
    end
  end)

  # Step 4: Detect swaps (A->B, B->A)
  swap_conflicts = detect_swaps(movements)

  # Step 5: Detect cycles (A->B->C->A)
  cycle_conflicts = detect_cycles(movements)

  conflicts ++ swap_conflicts ++ cycle_conflicts
end

def detect_swaps(movements) do
  movements
  |> Enum.flat_map(fn {origin_a, dest_a, unit_a} ->
    movements
    |> Enum.filter(fn {origin_b, dest_b, _} ->
      origin_a == dest_b and origin_b == dest_a and origin_a != origin_b
    end)
    |> Enum.map(fn {origin_b, _, unit_b} ->
      {:swap_conflict, origin_a, origin_b, unit_a, unit_b}
    end)
  end)
  |> Enum.uniq()
end
```

### Outputs
- `conflicts`: List of conflict tuples with type and participants

### Conflict Types

| Type | Detection | Resolution |
|------|-----------|------------|
| `destination_conflict` | 2+ units target same hex | Compare strengths |
| `attack` | 1 unit targets enemy-occupied hex | Attacker vs defender strength |
| `swap_conflict` | A->B and B->A | Both balk (no force comparison) |
| `cycle_conflict` | A->B->C->A | All in cycle balk |

---

## Phase 5: SUPPORT CALCULATION

### Purpose
Build support graph and mark cut supports. Runs after conflict detection so we know which supporters are under attack.

### Inputs
- `validated_orders`
- `snapshot.units`
- `phalanxes` from Phase 3
- `conflicts` from Phase 4

### Key Distinction

| Bonus Type | Source | Can Be Cut? |
|------------|--------|-------------|
| **Formation bonus** | Adjacent allies in same declared phalanx | **NEVER** |
| **Pushing support** | Ally behind pushing same direction, NOT in same phalanx | **YES** |

### Processing

```elixir
def calculate_supports(orders, units, phalanxes, conflicts) do
  # Step 1: Build pushing support graph (non-phalanx support only)
  pushing_supports = build_pushing_support_graph(orders, units, phalanxes)

  # Step 2: Extract attacks from conflicts
  attacks = extract_attacks(conflicts)

  # Step 3: Mark pushing supports as cut if supporter is targeted by enemy
  targeted_units = attacks |> Enum.map(& &1.target_pos) |> MapSet.new()

  cut_supports = pushing_supports
    |> Map.keys()
    |> MapSet.new()
    |> MapSet.intersection(targeted_units)

  %{
    pushing_supports: pushing_supports,
    cut_supports: cut_supports
  }
end

def build_pushing_support_graph(orders, units, phalanxes) do
  # Find supporters who are NOT in the same phalanx as the supported unit
  Enum.reduce(orders, %{}, fn {pos, order}, acc ->
    if order.move do
      supporters = find_supporters(pos, order.move, orders, units)
        |> Enum.reject(fn supporter_pos ->
          # Exclude supporters in same phalanx - those provide formation bonus, not pushing support
          same_phalanx?(pos, supporter_pos, phalanxes)
        end)
      Map.put(acc, pos, supporters)
    else
      acc
    end
  end)
end

def same_phalanx?(pos_a, pos_b, phalanxes) do
  Enum.any?(phalanxes, fn phalanx ->
    MapSet.member?(phalanx.positions, pos_a) and MapSet.member?(phalanx.positions, pos_b)
  end)
end

def extract_attacks(conflicts) do
  # Extract attack conflicts (enemy targeting enemy-occupied hex)
  Enum.flat_map(conflicts, fn
    {:attack, attacker_pos, defender_pos, _} -> [%{attacker: attacker_pos, target_pos: defender_pos}]
    _ -> []
  end)
end
```

**Support cutting rule**:
Support is cut when the supporter is targeted by an enemy attack. Unlike Diplomacy, friendly units cannot cut support for their own team.

### Outputs
- `pushing_supports`: Map of position -> list of non-phalanx supporter positions
- `cut_supports`: MapSet of positions whose pushing support is nullified

### Edge Cases
- **Phalanx under attack**: A and C in phalanx. D attacks C. A still gets formation bonus from C.
- **Mixed phalanx + support**: A gets formation bonus from C (in phalanx) + pushing support from S (not in phalanx). If S attacked, A loses pushing support but keeps formation bonus.
- **Friendly movement**: Unit moving toward ally does NOT cut that ally's support (unlike Diplomacy)

---

## Phase 6: STRENGTH CALCULATION

### Purpose
Compute combat strength for each unit involved in a conflict.

### Inputs
- `conflicts` from Phase 4
- `snapshot.units`
- `supports` and `cut_supports` from Phase 5
- `phalanxes` from Phase 3

### Processing

**Strength Formula**:

```
Attacker Strength = Base + ValidSupport + FormationBonus
Defender Strength = Base + FormationBonus
```

Where:
- `Base = 1`
- `ValidSupport = count of supporting allies not in cut_supports (max +2)`
- `FormationBonus = side_allies + rear_allies` — no cap; side limited to 2 by geometry, rear unlimited

**Note**: Flanking does NOT affect strength. It affects DAMAGE (see Phase 8).

```elixir
def calculate_strength(pos, attack_direction, role, snapshot, support_data) do
  unit = Map.get(snapshot.units, pos)

  base = 1

  # Formation bonus from 2D phalanx (side + rear allies)
  # CRITICAL: Formation bonus requires BOTH same rotation AND same movement direction
  # No cap: side is limited to 2 by geometry, rear is unlimited (but deep = flankable)
  my_order = Map.get(validated_orders, pos)
  %{side: side_allies, rear: rear_allies} = count_formation_allies(pos, unit, snapshot.units, validated_orders)
  formation_bonus = side_allies + rear_allies

  case role do
    :attacker ->
      # Count valid (non-cut) supports
      supporters = Map.get(support_data.supports, pos, [])
      valid_supporters = Enum.reject(supporters, &MapSet.member?(support_data.cut_supports, &1))
      support_bonus = min(length(valid_supporters), 2)

      # NOTE: Flanking does NOT affect strength—only damage (Phase 8)
      base + support_bonus + formation_bonus

    :defender ->
      # Defenders don't get support bonus (not pushing)
      base + formation_bonus
  end
end
```

**Formation Bonus** (2D phalanx):
A declared phalanx is two-dimensional—both ranks (side-by-side) and files (front-to-back) contribute.

- **Side allies**: +1 per side neighbor in the phalanx (max 2 by geometry—left and right)
- **Rear allies**: +1 per rear ally in the phalanx (no cap—deep formations are powerful but flankable)

CRITICAL: Formation bonuses only apply to units in the same **declared** phalanx. Adjacent units not in the same declared phalanx do not provide formation bonuses.

**Self-balancing**: A 10-deep column has +9 formation bonus from depth but can be destroyed by a single flanking attack. No artificial cap needed.

### Outputs
- `strengths`: Map of position -> computed strength

### Edge Cases
- **Supported attacker with cut support**: Support doesn't count
- **Defender in formation**: Keeps all formation bonuses regardless of attack direction
- **Isolated unit**: Strength = 1 (base only)

---

## Phase 7: COMBAT RESOLUTION

### Purpose
Determine winners and losers for each conflict.

### Inputs
- `conflicts` from Phase 4
- `strengths` from Phase 6
- `phalanxes` from Phase 3 (explicitly declared phalanxes for all-or-nothing balking)

### Processing

```elixir
def resolve_conflicts(conflicts, strengths, phalanxes) do
  # First pass: resolve individual conflicts
  individual_results = Enum.map(conflicts, fn conflict ->
    resolve_single_conflict(conflict, strengths)
  end)

  # Second pass: apply all-or-nothing rule for declared phalanxes (atomic movement)
  apply_phalanx_all_or_nothing(individual_results, phalanxes)
end

def resolve_single_conflict(conflict, strengths) do
  case conflict do
    {:swap_conflict, pos_a, pos_b, _, _} ->
      # Swaps always result in mutual balk
      [{pos_a, :balk}, {pos_b, :balk}]

    {:cycle_conflict, positions} ->
      # Cycles always result in all balking
      Enum.map(positions, &{&1, :balk})

    {:attack, attacker_positions, defender_pos, _attackers} when is_list(attacker_positions) ->
      # COMBINED ATTACK: Multiple allies attacking same hex
      # Forces ADD together; first ordered unit is LEAD
      combined_str = attacker_positions
        |> Enum.map(&Map.get(strengths, &1))
        |> Enum.sum()
      defender_str = Map.get(strengths, defender_pos)

      if combined_str > defender_str do
        # Combined attack wins - lead moves in, others hold
        [lead_pos | other_positions] = attacker_positions  # First in list is lead
        lead_result = {lead_pos, :move}
        other_results = Enum.map(other_positions, &{&1, :hold})
        defender_result = {defender_pos, :dislodged}
        [lead_result | other_results] ++ [defender_result]
      else
        # Combined attack fails - all attackers balk
        attacker_results = Enum.map(attacker_positions, &{&1, :balk})
        attacker_results ++ [{defender_pos, :hold}]
      end

    {:attack, attacker_pos, defender_pos, _attacker} ->
      # Single attacker case
      attacker_str = Map.get(strengths, attacker_pos)
      defender_str = Map.get(strengths, defender_pos)

      cond do
        attacker_str > defender_str ->
          # Attacker wins, defender dislodged
          [{attacker_pos, :move}, {defender_pos, :dislodged}]

        true ->
          # Tie or defender wins - attacker balks, defender holds
          [{attacker_pos, :balk}, {defender_pos, :hold}]
      end

    {:destination_conflict, _dest, contestants} ->
      # Multiple attackers to same hex
      # Find highest strength
      sorted = contestants
        |> Enum.map(fn {pos, _, _} -> {pos, Map.get(strengths, pos)} end)
        |> Enum.sort_by(&elem(&1, 1), :desc)

      [{winner_pos, max_str} | rest] = sorted

      # Check for ties at max
      ties = Enum.filter(rest, fn {_, str} -> str == max_str end)

      if length(ties) > 0 do
        # Multiple units tied for highest - all balk
        Enum.map(contestants, fn {pos, _, _} -> {pos, :balk} end)
      else
        # Clear winner
        winner_result = {winner_pos, :move}
        loser_results = Enum.map(rest, fn {pos, _} -> {pos, :balk} end)
        [winner_result | loser_results]
      end
  end
end
```

**All-or-Nothing Rule for Declared Phalanxes** (atomic movement):

Uses `phalanxes` from Phase 3 (explicitly declared). If ANY member of a declared phalanx would balk, the ENTIRE phalanx balks.

**This is ALL-OR-NOTHING, not majority rule.** A single blocked unit stops the entire phalanx.

Note: This applies to explicitly declared phalanxes only. Units not in a declared phalanx resolve independently.

```elixir
def apply_phalanx_all_or_nothing(results, phalanxes) do
  results_map = Map.new(results)

  Enum.reduce(phalanxes, results_map, fn phalanx, acc ->
    # Check if ANY phalanx member would balk
    any_balk = phalanx.positions
      |> Enum.any?(&(Map.get(acc, &1) == :balk))

    if any_balk do
      # ALL-OR-NOTHING: If any balk, entire phalanx balks
      Enum.reduce(phalanx.positions, acc, fn pos, inner_acc ->
        # Convert any :move to :balk
        current = Map.get(inner_acc, pos)
        if current == :move do
          Map.put(inner_acc, pos, :balk)
        else
          inner_acc
        end
      end)
    else
      acc
    end
  end)
end
```

### Outputs
- `resolution_results`: Map of position -> {:move | :balk | :dislodged | :hold}

### Edge Cases
- **Defender was moving away**: Still resolved as combat (attack intercepts)
- **Multiple attackers, one wins**: Winner gets the hex, others balk
- **Dislodged unit in phalanx**: Does NOT trigger phalanx-wide dislodge (phalanxes only affect movement balking)
- **Single unit blocked in phalanx**: Entire phalanx balks (all-or-nothing)
- **Individual order overrides phalanx**: Unit with individual order is not part of phalanx atomicity

---

## Phase 8: MOVEMENT EXECUTION

### Purpose
Apply movement results to game state.

### Inputs
- `resolution_results` from Phase 7
- `validated_orders` from Phase 2
- Current game state

### Processing

```elixir
def execute_movements(state, results, orders) do
  # Process in order: first remove from origins, then add to destinations
  # This prevents position conflicts during update

  moving_units = results
    |> Enum.filter(fn {_pos, result} -> result == :move end)
    |> Enum.map(fn {pos, _} -> {pos, Map.get(orders, pos)} end)

  # Build new units map
  new_units = Enum.reduce(moving_units, state.units, fn {origin, order}, acc ->
    unit = Map.get(acc, origin)
    {:ok, destination} = Moves.move(state.map_dimensions, origin, unit.rotation, order.move)

    acc
    |> Map.delete(origin)
    |> Map.put(destination, unit)
  end)

  %{state | units: new_units}
end
```

### Outputs
- Updated game state with new unit positions

### Edge Cases
- **Move to hex vacated this turn**: Allowed (simultaneous resolution)
- **Chain movement** (A->B, B->C where B leaves): Works correctly due to order-independent update

---

## Phase 9: DAMAGE & RETREAT

### Purpose
Apply combat damage, execute retreats, handle death.

### Inputs
- `resolution_results` from Phase 7
- `validated_orders` (to determine attack directions)
- Game state after Phase 8

### Processing

**Damage Rules**:

Damage stacks: dislodge costs 1 HP, plus angle-based bonus damage.

| Attack Angle | Angle Bonus | Total on Dislodge |
|--------------|-------------|-------------------|
| Frontal (front 2 edges) | +0 (shields block) | 1 HP |
| Flank (middle 2 edges) | +1 | 2 HP |
| Rear (back 2 edges) | +2 | 3 HP |

Damage IS additive: dislodge penalty + angle bonus.

```elixir
def apply_damage_and_retreats(state, results, orders, snapshot) do
  dislodged_units = results
    |> Enum.filter(fn {_pos, result} -> result == :dislodged end)
    |> Enum.map(fn {pos, _} -> pos end)

  # Calculate damage for each dislodged unit
  damage_map = Enum.reduce(dislodged_units, %{}, fn pos, acc ->
    attacker_info = find_attacker(pos, orders, snapshot)
    damage = calculate_damage(pos, attacker_info, snapshot)
    Map.put(acc, pos, damage)
  end)

  # Apply damage
  state_after_damage = Enum.reduce(damage_map, state, fn {pos, damage}, acc ->
    # Note: pos is the original position (pre-dislodge)
    # Unit hasn't moved yet from original position in this phase
    update_unit_health(acc, pos, -damage)
  end)

  # Execute retreats
  execute_retreats(state_after_damage, dislodged_units, orders, snapshot)
end

def calculate_damage(defender_pos, attacker_info, snapshot) do
  defender = Map.get(snapshot.units, defender_pos)

  # Damage is purely angle-based
  attack_direction = attacker_info.direction
  angle = angle_between(attack_direction, defender.rotation)

  case classify_angle(angle) do
    :front -> 0  # Shields block frontal attacks
    :flank -> 1
    :rear -> 2
  end
end
```

**Retreat Resolution**:

```elixir
def execute_retreats(state, dislodged_positions, orders, snapshot) do
  # Compute standoff hexes (hexes where conflicts resulted in ties)
  standoff_hexes = compute_standoff_hexes(snapshot)

  Enum.reduce(dislodged_positions, state, fn original_pos, acc ->
    unit = Map.get(acc.units, original_pos)

    if unit && unit.health > 0 do
      attacker_pos = find_attacker_position(original_pos, orders)
      valid_retreats = valid_retreat_hexes(acc, original_pos, attacker_pos, standoff_hexes)

      if Enum.empty?(valid_retreats) do
        # No valid retreat - unit destroyed
        %{acc | units: Map.delete(acc.units, original_pos)}
      else
        # Deterministic retreat: same direction as attack, fallback to adjacent backward
        retreat_hex = select_retreat_hex(valid_retreats, attack_direction, unit.rotation)
        %{acc | units: acc.units
          |> Map.delete(original_pos)
          |> Map.put(retreat_hex, unit)
        }
      end
    else
      # Unit died from damage - already removed or will be in cleanup
      acc
    end
  end)
end

def valid_retreat_hexes(state, defender_pos, attacker_positions, standoff_hexes) do
  # attacker_positions is now a list (supports multiple attackers)
  all_adjacent = Moves.all_neighbors(defender_pos)

  all_adjacent
  |> Enum.filter(fn {direction, hex} ->
    # Must be AWAY from all attackers (opposite direction from each attack)
    away_from_all_attackers?(defender_pos, hex, attacker_positions) &&
    # Not a standoff hex
    !MapSet.member?(standoff_hexes, hex) &&
    # Not occupied
    !Map.has_key?(state.units, hex) &&
    # On the map
    on_map?(hex, state.map_dimensions)
  end)
  |> Enum.map(&elem(&1, 1))  # Get positions only
end

# Helper: check if retreat_hex is away from all attacker positions
def away_from_all_attackers?(defender_pos, retreat_hex, attacker_positions) do
  Enum.all?(attacker_positions, fn attacker_pos ->
    # Retreat hex is in same direction as attack; fallback to adjacent backward
    attack_direction = direction_from_hex(attacker_pos, defender_pos)
    retreat_direction = direction_from_hex(defender_pos, retreat_hex)
    is_opposite_direction?(attack_direction, retreat_direction)
  end)
end
```

### Outputs
- State with updated health values
- State with units in retreat positions
- Dead units removed

### Edge Cases
- **No valid retreat**: Unit destroyed
- **Retreat into hex vacated by another retreat**: Allowed (retreats processed sequentially)
- **Multiple dislodges**: Each resolved independently

---

## Phase 10: ROTATION APPLICATION

### Purpose
Apply rotation orders (per MECHANICS.md: "rotation is applied after the attack").

### Inputs
- `validated_orders` from Phase 2
- Game state after Phase 9

### Processing

```elixir
def apply_rotations(state, orders) do
  new_units = Enum.reduce(orders, state.units, fn {original_pos, order}, acc ->
    # Find unit's current position (may have moved)
    current_pos = find_current_position(original_pos, orders, state)
    unit = Map.get(acc, current_pos)

    if unit && order.rotation do
      new_rotation = apply_rotation(unit.rotation, order.rotation)
      Map.put(acc, current_pos, %{unit | rotation: new_rotation})
    else
      acc
    end
  end)

  %{state | units: new_units}
end

def apply_rotation(current, :clockwise), do: rem(current + 60, 360)
def apply_rotation(current, :counterclockwise) do
  new = current - 60
  if new < 0, do: new + 360, else: new
end
```

### Outputs
- State with updated rotations

### Edge Cases
- **Rotation on balked unit**: Does NOT apply (orders are atomic - if move fails, rotation fails)
- **Rotation on hold order**: DOES apply (no movement to fail)
- **Rotation on dead unit**: Skipped (unit not in map)

---

## Phase 11: ENERGY & CLEANUP

### Purpose
Update energy, handle energy-death, remove dead units, increment turn.

### Inputs
- `validated_orders` from Phase 2
- `resolution_results` from Phase 7
- Game state after Phase 10

### Processing

**Energy Rules** (from MECHANICS.md, clarified):

| Action | Energy Change |
|--------|---------------|
| Move forward | -1 |
| Move backward | 0 |
| Hold (not attacked) | +1 |
| Hold (attacked) | 0 |
| 0 energy at turn end | **TBD** (see Open Questions) |

```elixir
def apply_energy_and_cleanup(state, orders, results) do
  state
  |> update_energy(orders, results)
  |> apply_zero_energy_penalty()
  |> remove_dead_units()
  |> increment_turn()
end

def update_energy(state, orders, results, attacked_positions) do
  new_units = Enum.reduce(state.units, state.units, fn {pos, unit}, acc ->
    order = find_order_for_unit(pos, orders)
    result = Map.get(results, pos, :hold)
    was_attacked = MapSet.member?(attacked_positions, pos)

    energy_delta = cond do
      result == :balk -> 0  # Attempted move but failed
      (result == :hold || order.move == nil) and not was_attacked -> 1  # Held, not attacked
      (result == :hold || order.move == nil) and was_attacked -> 0  # Held but attacked
      is_forward_move?(order.move, unit.rotation) -> -1
      true -> 0  # Backward move
    end

    new_energy = max(0, min(unit.energy + energy_delta, 3))  # Cap at 3
    Map.put(acc, pos, %{unit | energy: new_energy})
  end)

  %{state | units: new_units}
end

# NOTE: Zero-energy penalty is TBD. Placeholder implementation below.
# Alternatives: can't receive orders, reduced strength, etc.
def apply_zero_energy_penalty(state) do
  new_units = Enum.reduce(state.units, state.units, fn {pos, unit}, acc ->
    if unit.energy == 0 do
      # PLACEHOLDER: -1 HP penalty. May change based on design decision.
      Map.put(acc, pos, %{unit | health: unit.health - 1})
    else
      acc
    end
  end)

  %{state | units: new_units}
end

def remove_dead_units(state) do
  new_units = state.units
    |> Enum.filter(fn {_pos, unit} -> unit.health > 0 end)
    |> Map.new()

  %{state | units: new_units}
end

def increment_turn(state) do
  %{state | turn: state.turn + 1}
end
```

### Outputs
- Final game state for turn

---

## Complete Pseudocode

```elixir
defmodule Phalanx.Engine.Combat do
  @behaviour Phalanx.Engine

  @impl Phalanx.Engine
  def execute_orders(state, player_orders, groups) do
    # player_orders: %{individual_orders: [...], phalanx_orders: [...], group_orders: [...]}
    # groups: pre-defined groups (fixed at battle start)

    # PHASE 1: SNAPSHOT
    snapshot = %{
      units: state.units,
      turn: state.turn
    }

    # PHASE 2: ORDER EXPANSION
    # Expand with precedence (Individual > Phalanx > Group), validate moves, populate holds
    validated_orders =
      player_orders
      |> expand_with_precedence(groups, snapshot.units)
      |> reject_invalid_moves(snapshot.units, state.map_dimensions)
      |> populate_holds(snapshot.units)

    # PHASE 3: PHALANX VALIDATION
    # Validate explicitly declared phalanxes (within single group, adjacent, same rotation)
    phalanxes = validate_phalanxes(player_orders.phalanx_orders, validated_orders, snapshot.units, groups)

    # PHASE 4: CONFLICT DETECTION
    conflicts = detect_conflicts(validated_orders, snapshot.units)

    # PHASE 5: SUPPORT CALCULATION
    support_data = calculate_supports(validated_orders, snapshot.units, phalanxes, conflicts)

    # PHASE 6: STRENGTH CALCULATION
    strengths = calculate_all_strengths(conflicts, snapshot, support_data, phalanxes)

    # PHASE 7: COMBAT RESOLUTION
    results = resolve_conflicts(conflicts, strengths, phalanxes)

    # PHASE 8: MOVEMENT EXECUTION
    state_after_moves = execute_movements(state, results, validated_orders)

    # PHASE 9: DAMAGE & RETREAT
    state_after_combat = apply_damage_and_retreats(
      state_after_moves,
      results,
      validated_orders,
      snapshot
    )

    # PHASE 10: ROTATION APPLICATION
    state_after_rotation = apply_rotations(state_after_combat, validated_orders)

    # PHASE 11: ENERGY & CLEANUP
    final_state = apply_energy_and_cleanup(
      state_after_rotation,
      validated_orders,
      results
    )

    final_state
  end
end
```

---

## Critical Invariants

1. **Snapshot Immutability**: All calculations reference turn-start state, never mid-resolution state
2. **Simultaneous Resolution**: No order has priority over another; all resolve "at once"
3. **Strength > Defense**: Strictly greater required for dislodge; ties favor defender
4. **Support Cutting**: Enemy attack on supporter cuts support (friendly movement does not)
5. **Rotation Timing**: Combat uses pre-rotation facing; rotation applies after combat
6. **Phalanx Atomicity**: Declared phalanxes balk/move together; ALL-OR-NOTHING (if any balk, all balk)
7. **Retreat Priority**: Retreating unit has priority over moving unit for destination
8. **Order Precedence**: Individual > Phalanx > Group (higher precedence overrides lower)
9. **Group Fixity**: Groups are fixed at battle start; cannot be modified mid-battle
10. **Phalanx Scope**: Phalanxes can only form within a single group

---

## Cascade Behavior Summary

| Event | Triggers | Does NOT Trigger |
|-------|----------|------------------|
| Balk in phalanx | Entire phalanx balks (all-or-nothing) | Damage, retreat |
| Dislodge | Damage, retreat | Phalanx-wide balk |
| Failed retreat | Death | Additional cascades |
| Zero energy | **TBD** (penalty undecided) | Depends on design decision |

---

## Interaction Matrix

| System A | System B | Interaction |
|----------|----------|-------------|
| Phalanx | Movement | Atomic movement, all-or-nothing balking |
| Phalanx | Combat | Declared phalanxes provide formation bonuses; dislodge does not cascade |
| Phalanx | Group | Phalanxes can only form within single group |
| Force | Combat | Strength determines dislodge outcome |
| Force | Phalanx | Formation bonus from declared phalanx members |
| Combat | Retreat | Dislodge triggers retreat phase |
| Combat | Damage | Dislodge + angle determines damage |
| Energy | Combat | Zero energy penalty (TBD) |
| Order | Precedence | Individual > Phalanx > Group |

---

## Open Questions Resolved

| Question | Decision |
|----------|----------|
| Order model | Three levels: Individual > Phalanx > Group. Higher precedence overrides lower. |
| Group creation | Groups are created in pre-game planning stage, fixed for entire battle |
| Phalanx declaration | Explicitly declared during order phase, not auto-detected |
| Phalanx scope | Phalanxes can only form within a single group |
| Phalanx balking | All-or-nothing: if ANY member balks, entire phalanx balks (not majority rule) |
| Atomic movement | Applies to declared phalanxes only |
| Defender reaction | Passive; defender strength calculated but doesn't "attack back" |
| Multiple attackers (same team) | Forces ADD together; first-ordered unit is "lead" and moves in |
| Retreat direction | Any adjacent empty hex except attack-origin and standoff hexes |
| Support chain | Cut only affects direct supporter, not downstream |
| Rotation timing | Pre-rotation facing for all combat calculations |
| Combined attacking force | YES - friendly attackers combine force; resolved as single combat |
