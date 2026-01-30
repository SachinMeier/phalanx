# Resolution Order and State Transitions

**Purpose**: Define the exact order of operations for the Phalanx game engine turn resolution. Players submit orders simultaneously; this document specifies how those orders resolve.

---

## System Integration

Three subsystems interact during resolution:

| System | Responsibility | Spec |
|--------|----------------|------|
| **Force** | Calculate strength from base + formation + support | spec-260126-force |
| **Grouping** | Detect phalanxes, enforce atomic movement, majority-rule balking | spec-260126-group |
| **Combat** | Dislodge resolution, damage application, retreats | spec-260126-combat |

---

## Phase Overview

```
PHASE 1: SNAPSHOT
    Capture turn-start state, detect groups

PHASE 2: ORDER VALIDATION
    Validate orders, reject invalid, detect group movement violations

PHASE 3: SUPPORT CALCULATION
    Identify support relationships, mark cut supports

PHASE 4: CONFLICT DETECTION
    Find contested hexes, identify collision types

PHASE 5: STRENGTH CALCULATION
    Compute force for each combatant

PHASE 6: COMBAT RESOLUTION
    Determine winners/losers for each conflict

PHASE 7: MOVEMENT EXECUTION
    Move winners, hold losers

PHASE 8: DAMAGE & RETREAT
    Apply damage, execute retreats, handle cascade deaths

PHASE 9: ROTATION APPLICATION
    Apply rotation orders

PHASE 10: ENERGY & CLEANUP
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
    units: deep_copy(state.units),           # Position -> Unit map
    groups: Grouping.detect_groups(state.units),  # List of Group structs
    turn: state.turn
  }
end
```

**Group detection algorithm** (flood-fill):
1. For each unvisited unit position:
   - Create new group with unit's color and rotation
   - BFS/DFS to find all adjacent same-color, same-rotation units
   - Add all found positions to group
   - Mark all as visited
2. Return list of groups (min size 2; isolated units have no group)

### Outputs
- `snapshot.units`: Immutable unit positions/states
- `snapshot.groups`: List of `%Group{positions: MapSet, rotation: int, color: string}`

### Edge Cases
- **Empty board**: Return empty groups list
- **All isolated**: Return empty groups list (groups require 2+ units)
- **Mixed colors adjacent**: Separate groups per color

---

## Phase 2: ORDER VALIDATION

### Purpose
Reject impossible orders, enforce group movement rules, populate holds.

### Inputs
- Player-submitted orders: `%{position => %Order{move: atom, rotation: atom}}`
- `snapshot.units`
- `snapshot.groups`

### Processing

```elixir
def validate_orders(orders, snapshot) do
  orders
  |> populate_holds(snapshot.units)
  |> reject_invalid_moves(snapshot.units)
  |> reject_friendly_fire(snapshot.units)
  |> enforce_group_movement(snapshot.groups)
end
```

**Step 2.1: Populate Holds**
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

**Step 2.2: Reject Invalid Moves**
Movement must be legal per rotation constraints and map bounds.

```elixir
def reject_invalid_moves(orders, units) do
  Enum.map(orders, fn {pos, order} ->
    unit = Map.get(units, pos)
    case Moves.move(map_dimensions, pos, unit.rotation, order.move) do
      {:ok, _} -> {pos, order}
      {:error, _} -> {pos, Order.null_order(pos)}
    end
  end)
  |> Map.new()
end
```

**Step 2.3: Reject Friendly Fire**
Cannot target hex occupied by ally.

```elixir
def reject_friendly_fire(orders, units) do
  Enum.map(orders, fn {pos, order} ->
    unit = Map.get(units, pos)
    destination = compute_destination(pos, order.move)
    target_unit = Map.get(units, destination)

    if target_unit && target_unit.color == unit.color do
      {pos, Order.null_order(pos)}  # Convert to hold
    else
      {pos, order}
    end
  end)
  |> Map.new()
end
```

**Step 2.4: Enforce Group Movement**
All units in a group must share the same movement direction (or all hold).

```elixir
def enforce_group_movement(orders, groups) do
  Enum.reduce(groups, orders, fn group, acc ->
    group_orders = Enum.map(group.positions, &Map.get(acc, &1))
    movement_directions = group_orders |> Enum.map(& &1.move) |> Enum.uniq()

    if length(movement_directions) > 1 do
      # Mixed orders - entire group holds
      Enum.reduce(group.positions, acc, fn pos, inner_acc ->
        Map.put(inner_acc, pos, Order.null_order(pos))
      end)
    else
      acc
    end
  end)
end
```

### Outputs
- `validated_orders`: Map of position -> validated order

### Edge Cases
- **Order for dead unit**: Ignored (position not in units map)
- **Order for enemy unit**: Ignored (can only order own units)
- **Rotation-only order**: Valid (move = nil, rotation = :clockwise/:counterclockwise)

---

## Phase 3: SUPPORT CALCULATION

### Purpose
Identify pushing support relationships and mark supports cut by attacks.

### Inputs
- `validated_orders`
- `snapshot.units`

### Processing

**Definition**: Unit A supports Unit B if:
1. A is adjacent to B
2. A is moving in the same direction as B
3. A's move direction points toward B's position
4. A and B are same color

```elixir
def calculate_supports(orders, units) do
  # Step 1: Build support graph
  supports = build_support_graph(orders, units)

  # Step 2: Identify all attacks (movements into enemy-occupied hexes)
  attacks = identify_attacks(orders, units)

  # Step 3: Mark supports as cut if supporter is targeted
  targeted_units = attacks |> Enum.map(& &1.target_pos) |> MapSet.new()

  %{
    supports: supports,
    cut_supports: MapSet.intersection(Map.keys(supports) |> MapSet.new(), targeted_units)
  }
end

def build_support_graph(orders, units) do
  # For each moving unit, find adjacent allies moving same direction behind them
  Enum.reduce(orders, %{}, fn {pos, order}, acc ->
    if order.move do
      supporters = find_supporters(pos, order.move, orders, units)
      Map.put(acc, pos, supporters)
    else
      acc
    end
  end)
end
```

**Support cutting rule** (from MECHANICS.md): "support is nulled if the supporting unit is attacked"

Any attack targeting the supporter cuts the support, regardless of attack outcome.

### Outputs
- `supports`: Map of position -> list of supporter positions
- `cut_supports`: MapSet of positions whose support is nullified

### Edge Cases
- **Chain support**: A supports B supports C. If A is attacked, A's support to B is cut. B can still support C if B is not attacked.
- **Self-attack impossible**: Cannot attack own units (filtered in Phase 2)

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

## Phase 5: STRENGTH CALCULATION

### Purpose
Compute combat strength for each unit involved in a conflict.

### Inputs
- `conflicts` from Phase 4
- `snapshot.units`
- `supports` and `cut_supports` from Phase 3
- `snapshot.groups`

### Processing

**Strength Formula** (from Force spec, using F2 with attacker bonus):

```
Attacker Strength = Base + ValidSupport + min(FormationBonus, 4) + FlankingBonus
Defender Strength = Base + min(FormationBonus, 4)
```

Where:
- `Base = 1`
- `ValidSupport = count of supporting allies not in cut_supports (max +2)`
- `FormationBonus = side_cohesion + depth_bonus`
- `FlankingBonus = +1 (flank attack) or +2 (rear attack)`

```elixir
def calculate_strength(pos, attack_direction, role, snapshot, support_data) do
  unit = Map.get(snapshot.units, pos)

  base = 1

  # Formation bonus (side cohesion + depth)
  side_bonus = count_side_allies(pos, unit, snapshot.units)
  rear_bonus = count_rear_allies(pos, unit, snapshot.units)
  formation_bonus = min(side_bonus + min(rear_bonus, 2), 4)

  case role do
    :attacker ->
      # Count valid (non-cut) supports
      supporters = Map.get(support_data.supports, pos, [])
      valid_supporters = Enum.reject(supporters, &MapSet.member?(support_data.cut_supports, &1))
      support_bonus = min(length(valid_supporters), 2)

      # Flanking bonus based on attack angle
      flanking_bonus = calculate_flanking_bonus(attack_direction, unit, snapshot.units, pos)

      base + support_bonus + formation_bonus + flanking_bonus

    :defender ->
      # Defenders don't get support bonus (not pushing)
      # Defenders keep formation bonus regardless of attack direction
      base + formation_bonus
  end
end

def calculate_flanking_bonus(attack_direction, target_unit, units, target_pos) do
  attack_angle = angle_between(attack_direction, target_unit.rotation)

  cond do
    # Frontal: attack from target's front 60-degree arc
    attack_angle in [0, 60] -> 0
    # Rear: attack from target's back 60-degree arc
    attack_angle in [180] -> 2
    # Flank: everything else (120, 240, 300)
    true -> 1
  end
end
```

**Side Cohesion** (from Grouping spec):
Count adjacent allies with identical rotation in side positions (4 possible).

**Depth Bonus** (from Force spec):
Count allies directly behind (1 position) with identical rotation. Max +2 cap on rear allies counted.

### Outputs
- `strengths`: Map of position -> computed strength

### Edge Cases
- **Supported attacker with cut support**: Support doesn't count
- **Defender in formation**: Keeps all formation bonuses regardless of attack direction
- **Isolated unit**: Strength = 1 (base only)

---

## Phase 6: COMBAT RESOLUTION

### Purpose
Determine winners and losers for each conflict.

### Inputs
- `conflicts` from Phase 4
- `strengths` from Phase 5
- `snapshot.groups`

### Processing

```elixir
def resolve_conflicts(conflicts, strengths, groups) do
  # First pass: resolve non-group conflicts
  individual_results = Enum.map(conflicts, fn conflict ->
    resolve_single_conflict(conflict, strengths)
  end)

  # Second pass: apply majority rule for groups
  apply_majority_rule(individual_results, groups)
end

def resolve_single_conflict(conflict, strengths) do
  case conflict do
    {:swap_conflict, pos_a, pos_b, _, _} ->
      # Swaps always result in mutual balk
      [{pos_a, :balk}, {pos_b, :balk}]

    {:cycle_conflict, positions} ->
      # Cycles always result in all balking
      Enum.map(positions, &{&1, :balk})

    {:attack, attacker_pos, defender_pos, _attacker} ->
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

**Majority Rule for Groups** (from Grouping spec):

```elixir
def apply_majority_rule(results, groups) do
  results_map = Map.new(results)

  Enum.reduce(groups, results_map, fn group, acc ->
    # Count how many group members would balk
    balks = group.positions
      |> Enum.filter(&(Map.get(acc, &1) == :balk))
      |> length()

    total = MapSet.size(group.positions)

    if balks > total / 2 do
      # Majority balk - entire group balks
      Enum.reduce(group.positions, acc, fn pos, inner_acc ->
        # Convert any :move to :balk
        if Map.get(inner_acc, pos) == :move do
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
- **Dislodged unit in group**: Does NOT trigger group-wide dislodge (groups only affect movement balking)

---

## Phase 7: MOVEMENT EXECUTION

### Purpose
Apply movement results to game state.

### Inputs
- `resolution_results` from Phase 6
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

## Phase 8: DAMAGE & RETREAT

### Purpose
Apply combat damage, execute retreats, handle death.

### Inputs
- `resolution_results` from Phase 6
- `validated_orders` (to determine attack directions)
- Game state after Phase 7

### Processing

**Damage Rules** (from MECHANICS.md):

| Condition | HP Lost |
|-----------|---------|
| Dislodged | -1 |
| Attacked from flank | -1 |
| Attacked from rear | -2 |
| Attacked while moving non-counterparallel | -1 |

Damage stacks.

```elixir
def apply_damage_and_retreats(state, results, orders, snapshot) do
  dislodged_units = results
    |> Enum.filter(fn {_pos, result} -> result == :dislodged end)
    |> Enum.map(fn {pos, _} -> pos end)

  # Calculate damage for each dislodged unit
  damage_map = Enum.reduce(dislodged_units, %{}, fn pos, acc ->
    attacker_info = find_attacker(pos, orders, snapshot)
    damage = calculate_damage(pos, attacker_info, orders, snapshot)
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

def calculate_damage(defender_pos, attacker_info, orders, snapshot) do
  defender = Map.get(snapshot.units, defender_pos)
  defender_order = Map.get(orders, defender_pos)

  damage = 1  # Base dislodge damage

  # Add flanking damage
  attack_direction = attacker_info.direction
  angle = angle_between(attack_direction, defender.rotation)

  damage = damage + case classify_angle(angle) do
    :front -> 0
    :flank -> 1
    :rear -> 2
  end

  # Add non-counterparallel movement penalty
  if defender_order.move && !counterparallel?(defender_order.move, attack_direction) do
    damage + 1
  else
    damage
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
        # Random retreat selection
        retreat_hex = Enum.random(valid_retreats)
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

def valid_retreat_hexes(state, defender_pos, attacker_pos, standoff_hexes) do
  all_adjacent = Moves.all_neighbors(defender_pos)

  all_adjacent
  |> Enum.map(&elem(&1, 1))  # Get positions only
  |> Enum.filter(fn hex ->
    # Not the hex attack came from
    hex != attacker_pos &&
    # Not a standoff hex
    !MapSet.member?(standoff_hexes, hex) &&
    # Not occupied
    !Map.has_key?(state.units, hex) &&
    # On the map
    on_map?(hex, state.map_dimensions)
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

## Phase 9: ROTATION APPLICATION

### Purpose
Apply rotation orders (per MECHANICS.md: "rotation is applied after the attack").

### Inputs
- `validated_orders` from Phase 2
- Game state after Phase 8

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
- **Rotation on balked unit**: Still applies (only movement was cancelled)
- **Rotation on dead unit**: Skipped (unit not in map)

---

## Phase 10: ENERGY & CLEANUP

### Purpose
Update energy, handle energy-death, remove dead units, increment turn.

### Inputs
- `validated_orders` from Phase 2
- `resolution_results` from Phase 6
- Game state after Phase 9

### Processing

**Energy Rules** (from MECHANICS.md, clarified):

| Action | Energy Change |
|--------|---------------|
| Move forward | -1 |
| Move backward | 0 |
| Hold (not attacked) | +1 |
| Hold (attacked) | 0 |
| 0 energy at turn end | -1 health |

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

def apply_zero_energy_penalty(state) do
  new_units = Enum.reduce(state.units, state.units, fn {pos, unit}, acc ->
    if unit.energy == 0 do
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
  def execute_orders(state, player_orders) do
    # PHASE 1: SNAPSHOT
    snapshot = %{
      units: state.units,
      groups: Grouping.detect_groups(state.units),
      turn: state.turn
    }

    # PHASE 2: ORDER VALIDATION
    validated_orders =
      player_orders
      |> Helpers.populate_hold_orders(snapshot.units)
      |> reject_invalid_moves(snapshot.units, state.map_dimensions)
      |> reject_friendly_fire(snapshot.units)
      |> enforce_group_movement(snapshot.groups)

    # PHASE 3: SUPPORT CALCULATION
    support_data = calculate_supports(validated_orders, snapshot.units)

    # PHASE 4: CONFLICT DETECTION
    conflicts = detect_conflicts(validated_orders, snapshot.units)

    # PHASE 5: STRENGTH CALCULATION
    strengths = calculate_all_strengths(conflicts, snapshot, support_data)

    # PHASE 6: COMBAT RESOLUTION
    results = resolve_conflicts(conflicts, strengths, snapshot.groups)

    # PHASE 7: MOVEMENT EXECUTION
    state_after_moves = execute_movements(state, results, validated_orders)

    # PHASE 8: DAMAGE & RETREAT
    state_after_combat = apply_damage_and_retreats(
      state_after_moves,
      results,
      validated_orders,
      snapshot
    )

    # PHASE 9: ROTATION APPLICATION
    state_after_rotation = apply_rotations(state_after_combat, validated_orders)

    # PHASE 10: ENERGY & CLEANUP
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
4. **Support Cutting**: Any attack on supporter cuts support, regardless of outcome
5. **Rotation Timing**: Combat uses pre-rotation facing; rotation applies after combat
6. **Group Atomicity**: Groups balk/move together; majority rule determines outcome
7. **Retreat Priority**: Retreating unit has priority over moving unit for destination

---

## Cascade Behavior Summary

| Event | Triggers | Does NOT Trigger |
|-------|----------|------------------|
| Balk in group | Possible group-wide balk (if majority) | Damage, retreat |
| Dislodge | Damage, retreat | Group-wide balk |
| Failed retreat | Death | Additional cascades |
| Zero energy | -1 HP | Immediate death check (happens in cleanup) |

---

## Interaction Matrix

| System A | System B | Interaction |
|----------|----------|-------------|
| Grouping | Movement | Atomic movement, majority-rule balking |
| Grouping | Combat | Groups affect balk threshold, not dislodge |
| Force | Combat | Strength determines dislodge outcome |
| Force | Grouping | Formation bonus from same-facing allies |
| Combat | Retreat | Dislodge triggers retreat phase |
| Combat | Damage | Dislodge + angle determines damage |
| Energy | Combat | Zero energy = attrition damage |

---

## Open Questions Resolved

| Question | Decision |
|----------|----------|
| Defender reaction | Passive; defender strength calculated but doesn't "attack back" |
| Multiple attackers | Separate resolution; each must beat defender independently |
| Retreat direction | Any adjacent empty hex except attack-origin and standoff hexes |
| Support chain | Cut only affects direct supporter, not downstream |
| Rotation timing | Pre-rotation facing for all combat calculations |
| Combined attacking force | NO - each attack resolved separately against defender |
