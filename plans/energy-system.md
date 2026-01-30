# 2026-01-27: Energy System

**Author**: [Claude Opus 4.5]
**Approved By**:

---

## 1. What's the problem you're trying to solve?

**Casual**: Units can march forever. No fatigue. A player could send their phalanx on a 20-turn forced march with no consequence. Real soldiers tire. Phalanx needs attrition that rewards defensive play and punishes reckless aggression.

**Formal**:

1. Units have no resource limiting sustained movement
2. No reward exists for holding position (defensive stance)
3. Aggressive pursuit carries no cost beyond exposure to counterattack
4. No exhaustion mechanic creates tension between advance and conservation
5. `Phalanx.Helpers.default_units/0` includes health (3) but no energy field

**From MECHANICS.md**:
- "Moving Forward = -1 E"
- "Moving backward = 0 E"
- "Holding = +1 E" (clarified: only if not attacked)
- "Having 0 E = -1 Health"
- Units start with 3 Energy

**Out of Scope**:
* **Combat damage**: Handled by Combat spec
* **Force calculation**: Handled by Force spec
* **Group movement**: Handled by Grouping spec
* **Terrain effects on energy**: Future work

---

## 2. What's the simplest solution to solve the problem?

The main parts of the solution are:

1. **Energy field**: Add `energy` to unit struct, initialized to 3
2. **Energy delta calculation**: Determine energy change based on action
3. **Phase 10 integration**: Apply energy changes after all movement/combat resolves
4. **Zero-energy penalty**: -1 HP when ending turn at 0 energy
5. **Energy cap**: Prevent infinite accumulation

---

### Design Decisions

#### A. Energy Cap (Maximum)

| Option | Value | Pros | Cons |
|--------|-------|------|------|
| **3 (recommended)** | 3 | Matches health. Simple mental model. 3 turns of holding to recover from 3 turns of marching. | Limited recovery buffer. |
| 5 | 5 | Larger buffer rewards extended defensive play. | Asymmetric with health. Harder to track. Encourages turtling. |
| Unlimited | No cap | Simplest rule. Rewards patience. | Degenerate "hold for 20 turns, march 20 turns" strategy. |

**Recommendation**: Cap at 3. Symmetric with health. Creates a 3-turn exhaustion cycle: 3 consecutive forward moves = zero energy = HP loss next turn.

---

#### B. Forward Movement Cost

| Option | Cost | Pros | Cons |
|--------|------|------|------|
| **-1 (recommended)** | -1 | Per MECHANICS.md. 3 moves before exhaustion. Predictable. | May feel restrictive for aggressive players. |
| -2 | -2 | Faster exhaustion. More tactical weight to each advance. | Only 1.5 moves before exhaustion; too punishing. |

**Recommendation**: -1 per forward movement. Matches MECHANICS.md. Three consecutive advances deplete energy.

---

#### C. Backward Movement Cost

A unit retreating or stepping backward should not gain energy (it's still exertion), but should cost less than advancing.

| Option | Cost | Pros | Cons |
|--------|------|------|------|
| **0 (recommended)** | 0 | Per MECHANICS.md. Retreating is neutral. Encourages tactical withdrawal over exhausting chase. | No penalty for constant oscillation. |
| -1 | -1 | All movement costs energy. Simpler rule. | Punishes defensive repositioning. Makes retreat as costly as attack. |
| +1 | +1 | Retreating is restful? | Counterintuitive. Rewards fleeing. |

**Recommendation**: 0 cost for backward movement. Per MECHANICS.md. Retreat is neutral; you neither gain nor lose.

---

#### D. Forward vs Backward Definition

A hex grid has 6 directions. "Forward" must be defined relative to unit facing.

For a unit with rotation R (facing direction):
- **Front direction**: The hex directly in front (1 hex)
- **Front-adjacent directions**: The two hexes at 60-degree angles forward (2 hexes)
- **Rear-adjacent directions**: The two hexes at 60-degree angles backward (2 hexes)
- **Rear direction**: The hex directly behind (1 hex)

Movement constraint: Units can only move to 4 of 6 hexes (based on rotation, per `Phalanx.Moves.@allowed_moves`).

| Rotation | Allowed Moves | Forward (costly) | Backward (free) |
|----------|---------------|------------------|-----------------|
| 0 | E, SE, W, NW | E, SE | W, NW |
| 60 | NE, NW, SE, SW | NE, SE | NW, SW |
| 120 | NE, E, W, SW | NE, E | W, SW |

Pattern: A move is "forward" if it has a component in the facing direction. A move is "backward" if it has a component away from facing.

| Option | Definition | Pros | Cons |
|--------|------------|------|------|
| **Split by angle (recommended)** | Forward = 2 front-facing allowed moves. Backward = 2 rear-facing allowed moves. | Clear. 50/50 split. Matches intuition. | Requires direction classification helper. |
| All movement costs | Every move = -1 | Simplest. | Contradicts MECHANICS.md. Too punishing. |
| Only direct front | Only the 1 hex directly ahead costs energy | Very narrow definition. | Most "forward" moves become free. Exploitable. |

**Recommendation**: Split the 4 allowed moves evenly: 2 forward (cost energy), 2 backward (free).

**Classification formula**:

```elixir
def is_forward_move?(move_direction, unit_rotation) do
  front_idx = rotation_to_front_direction_index(unit_rotation)
  move_idx = direction_to_idx(move_direction)

  # Front directions are within 60 degrees of facing
  # For front_idx, "forward" includes front_idx-1, front_idx, front_idx+1 (mod 6)
  # But we can only move to 4 hexes, and exactly 2 will be forward

  angle_diff = abs(move_idx - front_idx)
  angle_diff = min(angle_diff, 6 - angle_diff)  # Handle wraparound

  angle_diff <= 1  # 0 or 60 degrees from facing = forward
end
```

---

#### E. Rotation Cost

| Option | Cost | Pros | Cons |
|--------|------|------|------|
| **0 (recommended)** | 0 | Rotation is "free." Encourages tactical repositioning. Keeps focus on movement energy. | Pure rotation could be exploited to stall while recovering. |
| -1 | -1 | All actions cost something. | Punishes defensive posture adjustment. Makes rotation feel wasteful. |

**Recommendation**: 0 cost for rotation. Rotation-only orders (no movement) count as "holding" and grant +1 energy, but only if not attacked. If attacked, no energy change. This rewards defensive stance adjustments while preventing free recovery under fire.

---

#### F. Holding Benefit

| Option | Benefit | Pros | Cons |
|--------|---------|------|------|
| **+1 if not attacked (recommended)** | +1 (if not attacked), 0 (if attacked) | Recovers 1 energy only when not under attack. Takes 3 holds to fully recover from 3 advances. | May encourage passive play, but attack negates benefit. |
| +2 | +2 | Faster recovery. More forgiving. | Too easy to recover. Reduces energy pressure. |
| 0 | 0 | Holding is neutral. | No reward for defensive play. Only movement matters. |

**Recommendation**: +1 energy for holding, but only if the unit is not attacked (regardless of attack outcome). Creates symmetric recovery: 3 holds to recover from 3 forward moves. Being attacked negates the recovery benefit, making sustained defense under pressure more costly.

---

#### G. Balk Behavior

When a unit attempts to move but balks (blocked by conflict), what happens to energy?

| Option | Effect | Pros | Cons |
|--------|--------|------|------|
| **No change (recommended)** | 0 | Balk is involuntary; no reward, no punishment. | Slight luck factor (balked = accidentally conserved). |
| -1 (as if moved) | -1 | Attempted action costs energy regardless of success. | Punishes unlucky units. Feels unfair. |
| +1 (as if held) | +1 | Didn't move = held = recovery. | Rewards aggression that gets blocked. Perverse incentive. |

**Recommendation**: No energy change on balk. The unit tried to move but couldn't; it's a wash.

---

#### H. Zero-Energy Penalty Timing

When does the -1 HP for 0 energy apply?

| Option | Timing | Pros | Cons |
|--------|--------|------|------|
| **Turn end (recommended)** | After energy update in Phase 10 | Clear. One check per turn. Unit sees 0 energy warning before taking damage next turn. | Unit at 1 energy moving forward hits 0, takes damage same turn. |
| Turn start | Before orders | Gives player a turn to hold and recover. | Confusing. "I had 0 energy, why am I dead?" ordering issues. |
| On action attempt | When unit tries to move at 0 energy | Lets units hold at 0 energy without penalty. Only movement at 0 costs. | More complex. What about rotation? |

**Recommendation**: Turn end. Per the resolution order (Phase 10), check energy after all updates. If 0, apply -1 HP. This means a unit at 1 energy that moves forward will hit 0 and take damage that same turn.

**Clarification**: Units CAN act at 0 energy. They just take 1 HP damage at turn end if they remain at 0. A unit at 0 energy that holds will end the turn at 1 energy (no damage). A unit at 0 energy that moves forward will end at 0 energy (impossible to go negative) and take 1 HP.

---

#### I. Energy Minimum

| Option | Floor | Pros | Cons |
|--------|-------|------|------|
| **0 (recommended)** | 0 | Can't go negative. Simple floor. | None. |
| Negative allowed | -N | Could model "energy debt." | Overcomplicated. Negative numbers confusing in UI. |

**Recommendation**: Floor at 0. Energy cannot go below 0.

---

#### J. Energy and Combat

Does combat affect energy?

| Option | Effect | Pros | Cons |
|--------|--------|------|------|
| **No (recommended)** | Combat is separate | Energy = movement stamina. Combat = separate system. Simpler. | Combat feels "free." |
| Attacking costs energy | -1 for attack | Adds another resource drain for aggression. | Movement that results in attack already costs energy. Double-dipping. |
| Being attacked costs energy | -1 for being hit | Adds exhaustion from combat. | Punishes defenders. Compounds with damage. |

**Recommendation**: Combat does not directly affect energy for attackers. Forward movement into attack costs energy because it's forward movement, not because it's an attack. However, **being attacked negates holding energy recovery**: a unit that holds but is attacked gets 0 energy change instead of +1. This makes sustained defense under pressure more costly and prevents turtling.

---

#### K. Dislodgement and Energy

Does being dislodged affect energy?

| Option | Effect | Pros | Cons |
|--------|--------|------|------|
| **No (recommended)** | Dislodge has no energy effect | Dislodge already costs HP. Simpler. | — |
| -1 energy on dislodge | -1 | Compounds punishment for losing combat. | Too harsh. Already taking HP damage and forced retreat. |
| Energy set to 0 | 0 | Dislodged units are exhausted. | Very harsh. Could cascade to HP loss. |

**Recommendation**: Dislodgement does not affect energy. The HP damage and forced retreat are sufficient consequences.

---

#### L. Group Energy

Do groups share energy? Does group movement cost differ?

| Option | Effect | Pros | Cons |
|--------|--------|------|------|
| **Individual (recommended)** | Each unit tracks own energy | Simple. Units in formation can have varying exhaustion. Weaker links in chain. | — |
| Shared pool | Group has combined energy | Simplifies tracking. Group rises and falls together. | Completely different mechanic. What happens when groups merge/split? |
| Group discount | Group movement costs less (-0.5 per unit?) | Rewards formation movement. | Fractional energy. Complex. |

**Recommendation**: Individual energy tracking. Groups are for atomic movement and majority-rule balking, not resource sharing.

---

## 3. Which key code changes do you need to make?

+++ #### Unit (modification)

Add energy field to unit.

`lib/phalanx/unit.ex`

```elixir
defmodule Phalanx.Unit do
  @type t :: %__MODULE__{
    name: String.t(),
    health: integer(),
    energy: integer(),
    rotation: integer(),
    color: String.t()
  }

  defstruct [:name, :health, :energy, :rotation, :color]

  @default_health 3
  @default_energy 3
  @max_energy 3

  @spec new(name :: String.t(), color :: String.t()) :: t()
  def new(name, color) do
    %__MODULE__{
      name: name,
      health: @default_health,
      energy: @default_energy,
      rotation: 60,  # Default facing
      color: color
    }
  end

  @spec apply_damage(unit :: t(), amount :: integer()) :: t()
  def apply_damage(unit, amount) do
    %{unit | health: max(0, unit.health - amount)}
  end

  @spec apply_energy_delta(unit :: t(), delta :: integer()) :: t()
  def apply_energy_delta(unit, delta) do
    new_energy = unit.energy + delta
    %{unit | energy: max(0, min(new_energy, @max_energy))}
  end

  @spec alive?(unit :: t()) :: boolean()
  def alive?(unit), do: unit.health > 0
end
```

+++

+++ #### Helpers (modification)

Update default units to include energy.

`lib/phalanx/helpers.ex`

```elixir
def default_units() do
  %{
    {3,2} => %{name: "Y", health: 3, energy: 3, rotation: 240, color: "red"},
    {4,2} => %{name: "U", health: 3, energy: 3, rotation: 240, color: "red"},
    # ... etc
  }
end
```

+++

+++ #### Energy (new module)

Pure functions for energy calculation.

`lib/phalanx/energy.ex`

```elixir
defmodule Phalanx.Energy do
  @moduledoc """
  Energy calculation for unit actions.
  """

  @max_energy 3
  @min_energy 0

  @doc """
  Calculate energy delta for a unit's turn.

  Returns integer: positive for recovery, negative for expenditure.
  """
  @spec calculate_delta(
    order :: Phalanx.Order.t(),
    unit :: map(),
    resolution_result :: atom(),
    was_attacked :: boolean()
  ) :: integer()
  def calculate_delta(order, unit, resolution_result, was_attacked) do
    cond do
      resolution_result == :balk ->
        # Attempted move but blocked - no change
        0

      order.move == nil and not was_attacked ->
        # Hold (possibly with rotation) = recovery, but only if not attacked
        1

      order.move == nil and was_attacked ->
        # Hold but was attacked = no recovery
        0

      is_forward_move?(order.move, unit.rotation) ->
        # Forward movement costs energy
        -1

      true ->
        # Backward movement is free
        0
    end
  end

  @doc """
  Determine if a movement direction is "forward" relative to unit facing.

  Forward means within 60 degrees of facing direction.
  """
  @spec is_forward_move?(direction :: atom(), rotation :: integer()) :: boolean()
  def is_forward_move?(nil, _rotation), do: false
  def is_forward_move?(direction, rotation) do
    front_idx = rotation_to_front_index(rotation)
    move_idx = direction_to_idx(direction)

    angle_diff = abs(move_idx - front_idx)
    angle_diff = min(angle_diff, 6 - angle_diff)

    angle_diff <= 1
  end

  @doc """
  Apply energy delta to unit, respecting bounds.
  """
  @spec apply_delta(unit :: map(), delta :: integer()) :: map()
  def apply_delta(unit, delta) do
    new_energy = unit.energy + delta
    clamped = new_energy |> max(@min_energy) |> min(@max_energy)
    %{unit | energy: clamped}
  end

  @doc """
  Apply zero-energy penalty. Returns updated unit with -1 HP if at 0 energy.
  """
  @spec apply_zero_penalty(unit :: map()) :: map()
  def apply_zero_penalty(%{energy: 0, health: hp} = unit) do
    %{unit | health: max(0, hp - 1)}
  end
  def apply_zero_penalty(unit), do: unit

  # Direction index: E=0, NE=1, NW=2, W=3, SW=4, SE=5
  defp direction_to_idx(:east), do: 0
  defp direction_to_idx(:northeast), do: 1
  defp direction_to_idx(:northwest), do: 2
  defp direction_to_idx(:west), do: 3
  defp direction_to_idx(:southwest), do: 4
  defp direction_to_idx(:southeast), do: 5

  # Rotation to front direction index
  # 60  -> NE (idx 1)
  # 120 -> E  (idx 0)
  # 180 -> SE (idx 5)
  # 240 -> SW (idx 4)
  # 300 -> W  (idx 3)
  # 0   -> NW (idx 2)
  defp rotation_to_front_index(60), do: 1
  defp rotation_to_front_index(120), do: 0
  defp rotation_to_front_index(180), do: 5
  defp rotation_to_front_index(240), do: 4
  defp rotation_to_front_index(300), do: 3
  defp rotation_to_front_index(0), do: 2
end
```

+++

+++ #### Engine.Combat (Phase 10 modification)

Integrate energy into Phase 10.

`lib/phalanx/engine/engine_combat.ex`

```elixir
# In Phase 10: ENERGY & CLEANUP

def apply_energy_and_cleanup(state, orders, results) do
  state
  |> update_energy(orders, results)
  |> apply_zero_energy_penalty()
  |> remove_dead_units()
  |> increment_turn()
end

defp update_energy(state, orders, results) do
  new_units = Enum.reduce(state.units, state.units, fn {pos, unit}, acc ->
    # Find order for this unit's original position
    order = find_order_for_current_unit(pos, orders, state)
    result = Map.get(results, pos, :hold)

    delta = Energy.calculate_delta(order, unit, result)
    updated_unit = Energy.apply_delta(unit, delta)

    Map.put(acc, pos, updated_unit)
  end)

  %{state | units: new_units}
end

defp apply_zero_energy_penalty(state) do
  new_units = Enum.reduce(state.units, state.units, fn {pos, unit}, acc ->
    updated_unit = Energy.apply_zero_penalty(unit)
    Map.put(acc, pos, updated_unit)
  end)

  %{state | units: new_units}
end
```

+++

---

## 4. Energy Decision Table

Summary of all energy effects:

| Action | Energy Delta | Notes |
|--------|--------------|-------|
| Forward movement (successful) | -1 | 2 of 4 allowed directions |
| Forward movement (balked) | 0 | Attempted but blocked |
| Backward movement (successful) | 0 | 2 of 4 allowed directions |
| Backward movement (balked) | 0 | Attempted but blocked |
| Hold (no movement, not attacked) | +1 | Recovery |
| Hold (no movement, attacked) | 0 | No recovery under fire |
| Rotation only (not attacked) | +1 | Counts as hold |
| Rotation only (attacked) | 0 | No recovery under fire |
| Dislodged | 0 | No energy effect |
| Turn end at 0 energy | -1 HP | Exhaustion damage |

---

## 5. Strategic Implications

### Exhaustion Cycle

3 consecutive forward moves = 0 energy. If player continues aggressing:
- Turn 4 forward move: 0 energy at turn end = -1 HP
- Turn 5 forward move: 0 energy at turn end = -1 HP
- Turn 6 forward move: 0 energy at turn end = -1 HP = unit dies (started at 3 HP)

**Maximum uninterrupted aggression**: 6 turns before death (assuming no combat damage).

### Recovery Cycle

To recover from 0 energy to 3 energy: hold for 3 turns.

### Tactical Implications

1. **Pursuit Limits**: Chasing a retreating enemy costs energy. Pursuer may become exhausted. Defender can turn and counterattack.

2. **Oscillation Penalty**: Forward-backward-forward = -1, 0, -1 = net -2 per two turns. Constant maneuvering depletes energy.

3. **Formation Advantage**: A phalanx holding position gains energy (+1/turn) while not under attack, while enemy advances and loses energy (-1/turn). However, once engaged (attacked), defenders no longer gain energy from holding. This creates windows where disengaging to recover is valuable.

4. **Exhaustion Attacks**: Probe attack, retreat, wait for pursuit, turn and fight when enemy is exhausted.

5. **Staggered Advance**: Alternate units advancing and holding to maintain energy across the line.

### Balance Analysis

| Strategy | Energy Profile | Strengths | Weaknesses |
|----------|----------------|-----------|------------|
| All-out attack | Depletes in 3 turns | Fast advance | Vulnerable if stopped |
| Cautious advance | Move-hold-move | Sustainable | Slow |
| Defensive hold (not engaged) | +1/turn to cap | Energy advantage | Cedes ground, loses benefit when attacked |
| Retreat | 0 cost | Preserves energy | Cedes ground |

The system favors **measured aggression**. Pure attack exhausts units. Pure defense gains energy but loses position. Optimal play involves alternating advance and consolidation.

---

## 6. UI Integration

### Energy Display

Each unit should display current energy alongside health.

Options:
1. **Number overlay**: "3/3" below unit (HP/Energy)
2. **Bar indicators**: Health bar + energy bar
3. **Color gradient**: Unit color fades as energy drops
4. **Icon state**: Different soldier stance at low energy

**Recommendation**: Number overlay. Simple. Matches existing health display pattern.

### Low Energy Warning

Units at 1 energy (one move from exhaustion) should show visual warning.

Units at 0 energy (taking attrition damage) should show critical state.

---

## 7. Edge Cases

### Units Cannot Go Negative

A unit at 0 energy that moves forward stays at 0, takes -1 HP. Energy floor is 0.

### Units Cannot Exceed Cap

A unit at 3 energy that holds (and is not attacked) stays at 3. Cap is 3. If attacked while holding, energy stays at 3 (no change).

### Retreating Units

A dislodged unit's retreat is involuntary movement. Energy effect = 0 (not forward movement by choice).

### Group Movement

Each unit in a group calculates energy independently. A group where half the units are at 1 energy and half at 3 energy will have some units at 0 and some at 2 after a forward move.

### Balk in Group

If a group balks due to majority rule, all units in the group get 0 energy change (balk effect).

### Rotation During Movement

If a unit moves forward AND rotates, the move determines energy cost (-1 for forward). Rotation is "free."

---

## 8. What's the PR roadmap?

1. **PR #1: Unit energy field**
   1. Add `energy` field to unit struct (default 3)
   2. Update `Phalanx.Helpers.default_units/0`
   3. Update unit type spec

2. **PR #2: Energy module**
   1. Create `Phalanx.Energy` module
   2. Implement `is_forward_move?/2` with direction classification
   3. Implement `calculate_delta/3`
   4. Implement `apply_delta/2` with bounds
   5. Implement `apply_zero_penalty/1`
   6. Unit tests for all energy scenarios

3. **PR #3: Engine integration**
   1. Add `update_energy/3` to Phase 10
   2. Add `apply_zero_energy_penalty/1` to Phase 10
   3. Ensure dead units from energy damage are removed
   4. Integration tests: 3-turn exhaustion, recovery cycle, zero-energy death

4. **PR #4: UI display**
   1. Add energy to unit rendering
   2. Low energy visual warning
   3. Zero energy critical state

---

## 9. Test Scenarios

### Scenario 1: Three-Turn Exhaustion

Setup: Unit at (3,2), energy 3, rotation 240 (facing SW).

| Turn | Action | Energy Before | Delta | Energy After | HP |
|------|--------|---------------|-------|--------------|-----|
| 1 | Move SW | 3 | -1 | 2 | 3 |
| 2 | Move SW | 2 | -1 | 1 | 3 |
| 3 | Move SW | 1 | -1 | 0 | 3 (then -1 penalty) = 2 |
| 4 | Move SW | 0 | -1 → 0 (floor) | 0 | 2 (then -1 penalty) = 1 |
| 5 | Move SW | 0 | 0 | 0 | 1 (then -1 penalty) = 0 = dead |

**Expected**: Unit dies at end of turn 5.

### Scenario 2: Recovery Cycle (Not Attacked)

Setup: Unit at (5,5), energy 0, rotation 60. **No enemies attacking this unit.**

| Turn | Action | Attacked? | Energy Before | Delta | Energy After | HP |
|------|--------|-----------|---------------|-------|--------------|-----|
| 1 | Hold | No | 0 | +1 | 1 | 3 (no penalty) |
| 2 | Hold | No | 1 | +1 | 2 | 3 |
| 3 | Hold | No | 2 | +1 | 3 | 3 |

**Expected**: Full recovery in 3 turns when not under attack.

### Scenario 2b: Holding Under Attack (No Recovery)

Setup: Defender D at (5,5), energy 1, rotation 60. Attacker A at (4,5), attacking D.

| Turn | D's Action | Attacked? | D's Energy Before | Delta | D's Energy After |
|------|------------|-----------|-------------------|-------|------------------|
| 1 | Hold | Yes | 1 | 0 | 1 |
| 2 | Hold | Yes | 1 | 0 | 1 |
| 3 | Hold | Yes | 1 | 0 | 1 |

**Expected**: No energy recovery when attacked, regardless of attack outcome. D must disengage (move away) to recover energy.

### Scenario 3: Backward Movement

Setup: Unit at (5,5), energy 2, rotation 60 (facing NE). Moving NW or SW is backward.

| Turn | Action | Delta | Energy After |
|------|--------|-------|--------------|
| 1 | Move NW | 0 | 2 |
| 2 | Move NW | 0 | 2 |

**Expected**: Backward movement is free; energy unchanged.

### Scenario 4: Balk Preserves Energy

Setup: Two units at (4,5) and (5,5), both facing E and trying to move E. Conflict.

| Turn | Action | Result | Delta | Energy After |
|------|--------|--------|-------|--------------|
| 1 | Move E | Balk | 0 | 3 |

**Expected**: Neither gains nor loses energy on balk.

### Scenario 5: Mixed Group Energy

Setup: Group of 2 units. Unit A at energy 2, Unit B at energy 3. Group moves forward.

| Unit | Energy Before | Delta | Energy After |
|------|---------------|-------|--------------|
| A | 2 | -1 | 1 |
| B | 3 | -1 | 2 |

**Expected**: Each unit tracks energy independently within group.

---

## 10. Open Questions

None. All design decisions resolved.

---

## Appendix A: Direction Classification Reference

For each rotation, the 4 allowed moves split 2 forward / 2 backward:

| Rotation | Facing | Allowed Moves | Forward (-1) | Backward (0) |
|----------|--------|---------------|--------------|--------------|
| 0 | NW | E, SE, W, NW | NW, W? or E, NW? | See calc |
| 60 | NE | NE, NW, SE, SW | NE, SE | NW, SW |
| 120 | E | NE, E, W, SW | NE, E | W, SW |
| 180 | SE | E, SE, W, NW | E, SE | W, NW |
| 240 | SW | NE, E, W, SW | SW, W | NE, E |
| 300 | W | NE, NW, SE, SW | NW, SW | NE, SE |

**Derivation**: Front direction index +/- 1 (mod 6) = forward moves. Rear direction index +/- 1 (mod 6) = backward moves. Since only 4 directions are allowed (not front or rear directly), all 4 are either forward-adjacent or backward-adjacent.

Actually, let's re-examine the movement constraints from `Phalanx.Moves`:

```elixir
@allowed_moves %{
  0 => [:east, :southeast, :west, :northwest],
  60 => [:northeast, :northwest, :southeast, :southwest],
  120 => [:northeast, :east, :west, :southwest],
}
```

For rotation 0 (facing NW, index 2):
- Front (NW, index 2) - not in allowed moves
- Front-adjacent: NE (index 1), W (index 3)
- Rear (SE, index 5) - not in allowed moves
- Rear-adjacent: E (index 0), SW (index 4)

Allowed: E, SE, W, NW

Wait, this doesn't match. Let me reconsider.

The rotation in Phalanx appears to be different from "facing direction." Looking at the default units:
- Red units at row 2 have rotation 240
- Purple units at row 7 have rotation 60

These face each other (60 and 240 are opposites). So rotation 60 = facing toward the enemy = toward higher row numbers = SE direction.

Let me revise:

| Rotation | Facing Direction |
|----------|-----------------|
| 0 | E |
| 60 | SE |
| 120 | SW |
| 180 | W |
| 240 | NW |
| 300 | NE |

This maps rotation to the direction the unit is "pointing."

For rotation 60 (facing SE):
- Allowed moves: NE, NW, SE, SW
- Forward (toward SE): SE, NE (SE is direct, NE is 60 degrees off)
- Backward (away from SE): NW, SW (NW is direct back, SW is 60 degrees off)

Wait, SW and NE are both 60 degrees from the SE-NW axis. Let me think about this differently.

The allowed moves constraint is orthogonal to facing. It limits movement to 4 of 6 directions for gameplay reasons (can't move directly forward or backward, only diagonally).

For energy cost:
- If facing SE (rotation 60), moving SE would be "directly forward" but that's NOT in the allowed moves
- Moving NE or SW (the two directions 60 degrees from facing) are the closest to forward/backward

Given the constraint that direct forward/backward are not allowed:
- The two "forward-ish" moves are NE and SE (NE is 60 degrees clockwise from SE; wait no)

Let me map this more carefully:

Direction indices (from Moves.ex):
- E = 0
- NE = 1
- NW = 2
- W = 3
- SW = 4
- SE = 5

For rotation 60, if the unit faces SE (index 5):
- Allowed: NE(1), NW(2), SE(5), SW(4)

Actually SE IS in the allowed moves. So direct forward IS allowed for rotation 60.

Let me re-read the code:
```elixir
@allowed_moves %{
  0 => [:east, :southeast, :west, :northwest],
  60 => [:northeast, :northwest, :southeast, :southwest],
  120 => [:northeast, :east, :west, :southwest],
}
```

For rotation 60, allowed = NE, NW, SE, SW.

If facing is SE (which makes sense for rotation 60):
- SE = directly forward
- NE = 60 degrees clockwise from forward
- NW = directly backward (opposite of SE)
- SW = 60 degrees counterclockwise from forward

So the classification:
- Forward (toward facing): SE, NE
- Backward (away from facing): NW, SW

This makes the split clean: 2 forward, 2 backward.

Final table:

| Rotation | Facing | Forward Moves (-1) | Backward Moves (0) |
|----------|--------|-------------------|-------------------|
| 0 | E | E, SE | W, NW |
| 60 | SE | SE, NE | NW, SW |
| 120 | SW | SW, W | NE, E |
| 180 | W | W, NW | E, SE |
| 240 | NW | NW, NE | SE, SW |
| 300 | NE | NE, E | SW, W |

Hmm, let me verify rotation 0:
- Allowed: E, SE, W, NW
- Facing E means forward = E, and 60 degrees from E is NE and SE
- NE is not allowed, so forward = E, SE
- Backward = W, NW (W is directly back, NW is 60 degrees from back)

Yes, this is consistent.
