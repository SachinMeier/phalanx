# 2026-01-26: Unified Phalanx Engine

**Author**:
**Approved By**:

---

## 1. What's the problem you're trying to solve?

**Casual**: Units occupy a hex grid. They move, they rotate, they collide. When collisions occur, both units halt. No winner, no loser, no blood. The game needs a combat engine that calculates force from formation, detects phalanx groups, resolves who wins contested hexes, and applies damage to the defeated.

**Formal**:

1. `Engine.Diplomacy` treats all collisions as mutual balk; no dislodgement occurs
2. Unit health (currently 3) is never modified
3. No force calculation exists (base strength, formation bonuses, flanking)
4. No phalanx detection exists (adjacent same-facing allies)
5. No atomic movement for grouped units
6. No majority-rule balking for formations
7. No retreat system for dislodged units
8. No energy system for attrition

**Out of Scope**:

* **Win/loss conditions**: Victory logic sits above combat
* **Unit types**: All units are identical hoplites
* **Map objectives**: Capture points, king-of-the-hill mechanics
* **Fog of war**: Full visibility assumed

---

## 2. What's the simplest solution to solve the problem?

Three systems work in sequence:

```
         ┌─────────────────────────────────────────────────────┐
         │                    TURN START                       │
         │  Snapshot state, detect phalanx groups              │
         └─────────────────────┬───────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────┐
         │                    GROUPING                         │
         │  Validate orders, enforce atomic movement           │
         │  Mixed orders within group → all hold               │
         └─────────────────────┬───────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────┐
         │                     FORCE                           │
         │  Calculate strength for each combatant              │
         │  Base + Formation + Support + Flanking              │
         └─────────────────────┬───────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────┐
         │                    COMBAT                           │
         │  Compare strengths, determine winners               │
         │  Apply majority-rule for groups                     │
         │  Execute moves, apply damage, process retreats      │
         └─────────────────────┬───────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────┐
         │                   TURN END                          │
         │  Apply rotations, update energy, cleanup            │
         └─────────────────────────────────────────────────────┘
```

The main parts of the solution are:

1. **Grouping module**: Detect phalanx formations via flood-fill on same-color, same-rotation adjacency
2. **Force module**: Calculate strength from base + side cohesion + depth + support + flanking
3. **Combat module**: Resolve conflicts, execute movements, apply damage, handle retreats
4. **Engine.Combat**: Orchestrate the 10-phase resolution algorithm

---

## 3. Which key code changes do you need to make (files, type/fn/service signatures)?

+++ #### Unit

Extract unit struct from inline maps. Add health, energy, damage helpers.

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

  @spec new(name :: String.t(), color :: String.t()) :: t()
  @spec apply_damage(unit :: t(), amount :: integer()) :: t()
  @spec apply_energy_delta(unit :: t(), delta :: integer()) :: t()
  @spec alive?(unit :: t()) :: boolean()
end
```

+++

+++ #### Group

Represents a detected phalanx formation. Ephemeral; recomputed each turn.

`lib/phalanx/group.ex`

```elixir
defmodule Phalanx.Group do
  @type t :: %__MODULE__{
    positions: MapSet.t({integer(), integer()}),
    rotation: integer(),
    color: String.t()
  }

  defstruct [:positions, :rotation, :color]

  @spec size(group :: t()) :: non_neg_integer()
end
```

+++

+++ #### Grouping

Detection and validation for phalanx formations.

`lib/phalanx/grouping.ex`

```elixir
defmodule Phalanx.Grouping do
  @spec detect_groups(units :: map()) :: [Phalanx.Group.t()]
  # Flood-fill on same-color, same-rotation adjacency
  # Returns groups with 2+ members; isolated units have no group

  @spec enforce_group_movement(orders :: map(), groups :: [Phalanx.Group.t()]) :: map()
  # If group members have mixed movement directions, convert all to holds
end
```

+++

+++ #### Force

Pure functions for strength calculation.

`lib/phalanx/force.ex`

```elixir
defmodule Phalanx.Force do
  @base_strength 1
  @max_side_bonus 2
  @max_rear_bonus 2
  @max_support_bonus 2

  @type position :: {integer(), integer()}
  @type direction_class :: :front | :flank | :rear

  @spec calculate_attack_strength(
    state :: Phalanx.Game.t(),
    attacker_pos :: position(),
    defender_pos :: position(),
    support_data :: map()
  ) :: integer()

  @spec calculate_defense_strength(
    state :: Phalanx.Game.t(),
    defender_pos :: position()
  ) :: integer()

  @spec count_side_allies(pos :: position(), unit :: map(), units :: map()) :: integer()
  @spec count_rear_allies(pos :: position(), unit :: map(), units :: map()) :: integer()
  @spec flanking_bonus(attack_direction :: atom(), defender_rotation :: integer()) :: integer()
  @spec classify_direction(unit_rotation :: integer(), neighbor_direction :: atom()) :: direction_class()
end
```

+++

+++ #### Combat.Support

Support relationship calculation with cutting logic.

`lib/phalanx/combat/support.ex`

```elixir
defmodule Phalanx.Combat.Support do
  @type position :: {integer(), integer()}

  @spec calculate_supports(orders :: map(), units :: map()) :: %{position() => [position()]}
  # Returns map of defender position => list of supporter positions
  # Cut supports have empty lists
  #
  # Unit A supports Unit B if:
  # - A is adjacent to B
  # - A moves in same direction as B
  # - A's move direction points toward B
  # - A and B are same color
  #
  # Support is cut when A is attacked

  @spec find_supporters(pos :: position(), direction :: atom(), orders :: map(), units :: map()) :: [position()]
end
```

+++

+++ #### Combat.Conflict

Conflict detection and classification.

`lib/phalanx/combat/conflict.ex`

```elixir
defmodule Phalanx.Combat.Conflict do
  @type position :: {integer(), integer()}
  @type conflict ::
    {:destination_conflict, position(), list()}
    | {:attack, position(), position(), map()}
    | {:swap_conflict, position(), position(), map(), map()}
    | {:cycle_conflict, [position()]}

  @spec detect_conflicts(orders :: map(), units :: map(), map_dimensions :: tuple()) :: [conflict()]
  @spec detect_swaps(movements :: list()) :: [conflict()]
  @spec detect_cycles(movements :: list()) :: [conflict()]
end
```

+++

+++ #### Combat.Resolution

Combat outcome determination.

`lib/phalanx/combat/resolution.ex`

```elixir
defmodule Phalanx.Combat.Resolution do
  @type position :: {integer(), integer()}
  @type result :: :move | :balk | :dislodged

  @spec resolve_conflicts(
    conflicts :: list(),
    strengths :: map(),
    groups :: [Phalanx.Group.t()]
  ) :: %{position() => result()}
  # Results:
  # - :move     Attacker who won; moves to target hex
  # - :balk     Attacker who lost or tied; stays in place
  # - :dislodged  Defender who lost; must retreat

  @spec apply_majority_rule(results :: map(), groups :: [Phalanx.Group.t()]) :: map()
  # If majority of group balks, convert all :move to :balk
end
```

+++

+++ #### Combat.Retreat

Retreat hex calculation and execution.

`lib/phalanx/combat/retreat.ex`

```elixir
defmodule Phalanx.Combat.Retreat do
  @type position :: {integer(), integer()}

  @spec valid_retreats(
    state :: Phalanx.Game.t(),
    defender_pos :: position(),
    attacker_pos :: position(),
    standoff_hexes :: MapSet.t(position())
  ) :: [position()]

  @spec execute_retreats(
    state :: Phalanx.Game.t(),
    dislodged :: [position()],
    orders :: map()
  ) :: Phalanx.Game.t()
end
```

+++

+++ #### Combat.Damage

Damage calculation based on attack angle and movement state.

`lib/phalanx/combat/damage.ex`

```elixir
defmodule Phalanx.Combat.Damage do
  @spec calculate_damage(
    defender_rotation :: integer(),
    attack_from :: atom(),
    dislodged? :: boolean(),
    defender_moving_counterparallel? :: boolean()
  ) :: integer()
  # Returns total HP lost by defender
  #
  # Damage sources (additive):
  # - Dislodged: 1 HP
  # - Attacked from flank: 1 HP
  # - Attacked from rear: 2 HP
  # - Moving non-counterparallel when attacked: 1 HP
end
```

+++

+++ #### Moves (extension)

Add neighbor enumeration and direction helpers.

`lib/phalanx/moves.ex`

```elixir
defmodule Phalanx.Moves do
  # Existing functions...

  @spec all_neighbors(position :: {integer(), integer()}) :: [{atom(), {integer(), integer()}}]
  # Returns list of {direction, neighbor_position} for all 6 hex directions

  @spec opposite_direction(direction :: atom()) :: atom()
  @spec direction_from_hex(from :: position(), to :: position()) :: atom()
end
```

+++

+++ #### Engine.Combat

New engine implementation orchestrating all phases.

`lib/phalanx/engine/engine_combat.ex`

```elixir
defmodule Phalanx.Engine.Combat do
  @behaviour Phalanx.Engine

  @impl Phalanx.Engine
  @spec execute_orders(state :: Phalanx.Game.t(), orders :: map()) :: Phalanx.Game.t()

  # Internal phase functions:
  @spec snapshot(state :: Phalanx.Game.t()) :: map()
  @spec validate_orders(orders :: map(), snapshot :: map(), map_dimensions :: tuple()) :: map()
  @spec calculate_all_strengths(conflicts :: list(), snapshot :: map(), support_data :: map()) :: map()
  @spec execute_movements(state :: Phalanx.Game.t(), results :: map(), orders :: map()) :: Phalanx.Game.t()
  @spec apply_damage_and_retreats(state :: Phalanx.Game.t(), results :: map(), orders :: map(), snapshot :: map()) :: Phalanx.Game.t()
  @spec apply_rotations(state :: Phalanx.Game.t(), orders :: map()) :: Phalanx.Game.t()
  @spec apply_energy_and_cleanup(state :: Phalanx.Game.t(), orders :: map(), results :: map()) :: Phalanx.Game.t()
end
```

+++

---

## 4. Resolution Algorithm

Ten phases execute in strict order. All phases reference the turn-start snapshot for calculation consistency.

### Phase 1: SNAPSHOT

Capture immutable state. Detect phalanx groups.

| Input | Output |
|-------|--------|
| `state.units` | `snapshot.units` (deep copy) |
| | `snapshot.groups` (list of Group) |
| | `snapshot.turn` |

### Phase 2: ORDER VALIDATION

Validate orders, populate holds, enforce group movement.

| Step | Action |
|------|--------|
| 2.1 | Populate holds for units without orders |
| 2.2 | Reject moves invalid for rotation |
| 2.3 | Reject moves to ally-occupied hex |
| 2.4 | Enforce group movement (mixed directions → all hold) |

### Phase 3: SUPPORT CALCULATION

Build support graph, identify cut supports.

| Condition | Effect |
|-----------|--------|
| A adjacent to B, same direction, same color | A supports B |
| A is attacked | A's support is cut |

### Phase 4: CONFLICT DETECTION

Identify contested hexes and classify conflict types.

| Type | Detection | Resolution |
|------|-----------|------------|
| `destination_conflict` | 2+ units target same hex | Compare strengths |
| `attack` | 1 unit targets enemy-occupied hex | Attacker vs defender |
| `swap_conflict` | A→B and B→A | Both balk |
| `cycle_conflict` | A→B→C→A | All balk |

### Phase 5: STRENGTH CALCULATION

Compute force for each combatant.

**Attacker Strength**:
```
Base(1) + Formation(0-4) + Support(0-2) + Flanking(0-2)
```

**Defender Strength**:
```
Base(1) + Formation(0-4)
```

| Bonus | Source | Cap |
|-------|--------|-----|
| Side cohesion | Adjacent allies, same facing | +2 |
| Depth | Rear ally, same facing | +2 |
| Support | Allies pushing same direction | +2 |
| Flanking | Attack from flank (+1) or rear (+2) | +2 |

### Phase 6: COMBAT RESOLUTION

Determine winners and losers.

| Condition | Outcome |
|-----------|---------|
| Attacker > Defender | Attacker wins (:move), defender loses (:dislodged) |
| Attacker <= Defender | Attacker loses (:balk), defender stays in place |
| Multiple attackers tied for highest | All attackers :balk |

**Majority Rule**: If majority of group would balk, all group members balk.

### Phase 7: MOVEMENT EXECUTION

Apply movement results to game state. Remove from origins, add to destinations.

### Phase 8: DAMAGE & RETREAT

| Damage Source | HP Lost |
|---------------|---------|
| Dislodged | -1 |
| Attacked from flank | -1 |
| Attacked from rear | -2 |
| Moving non-counterparallel when attacked | -1 |

**Retreat Rules**:
- Any adjacent empty hex
- Except attacker's origin hex
- Except standoff hexes
- No valid retreat → unit destroyed

### Phase 9: ROTATION APPLICATION

Apply rotation orders. Uses post-combat positions; units that balked still rotate.

### Phase 10: ENERGY & CLEANUP

| Action | Energy Change |
|--------|---------------|
| Move forward | -1 |
| Move backward | 0 |
| Hold (not attacked) | +1 |
| Hold (attacked) | 0 |
| Balk | 0 |

Zero energy at turn end: -1 HP.

Remove dead units. Increment turn counter.

---

## 5. State Changes by Phase

| Phase | Reads | Writes |
|-------|-------|--------|
| 1 Snapshot | `state.units` | `snapshot` (ephemeral) |
| 2 Validation | `snapshot`, `orders` | `validated_orders` |
| 3 Support | `validated_orders`, `snapshot.units` | `support_data` |
| 4 Conflicts | `validated_orders`, `snapshot.units` | `conflicts` |
| 5 Strength | `conflicts`, `snapshot`, `support_data` | `strengths` |
| 6 Resolution | `conflicts`, `strengths`, `snapshot.groups` | `results` |
| 7 Movement | `results`, `validated_orders`, `state` | `state.units` |
| 8 Damage/Retreat | `results`, `validated_orders`, `snapshot`, `state` | `state.units` |
| 9 Rotation | `validated_orders`, `state` | `state.units` |
| 10 Energy | `validated_orders`, `results`, `state` | `state.units`, `state.turn` |

---

## 6. Complete Examples

### Example 1: Head-On Collision (Tie)

```
Before:
  R>     X     <P
(1,1)  (2,1)  (3,1)

Orders:
  R: move E
  P: move W

After:
  R>     X     <P
(1,1)  (2,1)  (3,1)
```

### Example 2: Supported Attack

```
Before:
R1> R2> -- <D
(0,1)(1,1)  (2,1)

Orders:
  R1: move E
  R2: move E
  D: hold

After:
    R1> R2>    D
   (1,1)(2,1)  (3,1)

D: -1 HP (dislodged)
```

### Example 3: Flanking Attack

```
Before:
       R>
      (2,0)
        \
        SW
         v
        D>
       (2,1)

Orders:
  R: move SW
  D: hold

After:
       [empty]
        R>
       (2,1)

D: -2 HP (dislodged + flank), retreated
```

### Example 4: Phalanx Majority Balk

```
Before:
R1> R2> R3> [P]
(0,1)(1,1)(2,1)(3,1)

Orders:
  All R: move E
  P: hold

After:
R1> R2> R3> [P]
(0,1)(1,1)(2,1)(3,1)
```

### Example 5: Support Cutting

```
Before:
    P1>
   (2,0)
     |
    SW
     v
R2> → R1> → <D
(0,1) (1,1)  (2,1)

Orders:
  R1: move E
  R2: move E
  P1: move SW
  D: hold

After:
R1 at (1,1), D at (2,1)
P1 at (1,1), R2 dislodged
```

---

## 7. What's the PR roadmap?

1. **PR #1: Unit struct and helpers**
   1. Extract `Phalanx.Unit` module from inline maps
   2. Add `apply_damage/2`, `apply_energy_delta/2`, `alive?/1`
   3. Update `Phalanx.Helpers.default_units/0` to use struct
   4. Update `Phalanx.Game` type to use `%Unit{}`

2. **PR #2: Moves extension**
   1. Add `all_neighbors/1` to enumerate hex neighbors
   2. Add `opposite_direction/1`, `direction_from_hex/2`
   3. Tests for all 6 directions and rotations

3. **PR #3: Grouping system**
   1. Create `Phalanx.Group` struct
   2. Implement `Phalanx.Grouping.detect_groups/1` with flood-fill
   3. Implement `enforce_group_movement/2`
   4. Tests for group detection (same color, same rotation, adjacency)

4. **PR #4: Force calculation**
   1. Create `Phalanx.Force` module
   2. Implement `classify_direction/2` for front/flank/rear
   3. Implement `count_side_allies/3`, `count_rear_allies/3`
   4. Implement `calculate_attack_strength/4`, `calculate_defense_strength/2`
   5. Implement `flanking_bonus/2`
   6. Tests for formation scenarios, bonus caps

5. **PR #5: Combat support module**
   1. Create `Phalanx.Combat.Support`
   2. Implement `calculate_supports/2` with support graph
   3. Implement support cutting logic
   4. Tests for support relationships and cutting

6. **PR #6: Conflict detection**
   1. Create `Phalanx.Combat.Conflict`
   2. Implement `detect_conflicts/3`
   3. Implement `detect_swaps/1`, `detect_cycles/1`
   4. Tests for all conflict types

7. **PR #7: Combat resolution**
   1. Create `Phalanx.Combat.Resolution`
   2. Implement `resolve_conflicts/3` with strength comparison
   3. Implement `apply_majority_rule/2`
   4. Tests for winner determination, ties, majority rule

8. **PR #8: Damage and retreat**
   1. Create `Phalanx.Combat.Damage`
   2. Create `Phalanx.Combat.Retreat`
   3. Implement angle-based damage calculation
   4. Implement retreat hex validation and execution
   5. Tests for damage stacking, retreat selection, death on no retreat

9. **PR #9: Engine integration**
   1. Create `Phalanx.Engine.Combat`
   2. Implement 10-phase resolution algorithm
   3. Wire up all combat modules
   4. Integration tests for complete turn resolution

10. **PR #10: Energy and rotation**
    1. Add energy tracking to Unit
    2. Implement energy update logic (forward -1, backward 0, hold +1 if not attacked)
    3. Implement zero-energy penalty (-1 HP)
    4. Apply rotation after combat
    5. Cleanup: remove dead units, increment turn

11. **PR #11: Config switch and UI**
    1. Add config option: `:engine, Phalanx.Engine.Combat`
    2. Display health on unit SVG
    3. Display energy bar

---

## 8. What are open questions?

1. **Retreat selection**: Random selection from valid hexes, or player choice? Random is simpler; player choice requires async retreat phase.

---

## References

For detailed design rationale, see:

- `plans/spec-260126-force/spec.md` (Force Calculation)
- `plans/spec-260126-group/spec.md` (Grouping Mechanics)
- `plans/spec-260126-combat/spec.md` (Combat Resolution)
- `plans/spec-260126-combat/resolution-order.md` (10-Phase Algorithm)
- `plans/spec-260126-force/design-decisions-summary.md` (Final Decisions)
- `plans/spec-260126-combat/test-scenarios.md` (44 Test Cases)
