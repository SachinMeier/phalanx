# Engine Architecture

Modular, independently testable components. Each module is a **pure function** (or close to it) that can be tested in isolation.

---

## Design Principles

1. **Pure functions**: Modules take inputs, return outputs. No side effects.
2. **Explicit dependencies**: No module reaches into global state.
3. **Independent testing**: Each module has its own test file with no engine integration required.
4. **Composition over orchestration**: Engine.Combat composes modules; it doesn't contain logic.

---

## Module Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Engine.Combat                                      │
│                    (orchestrator - no logic, only composition)               │
└───────────────────────────────────────────┬─────────────────────────────────┘
                                            │
        ┌───────────────────────────────────┼───────────────────────────────────┐
        │               │               │               │               │       │
        ▼               ▼               ▼               ▼               ▼       ▼
   ┌─────────┐   ┌───────────┐   ┌─────────┐   ┌──────────────┐   ┌─────────┐
   │Grouping │   │ Strength  │   │ Combat. │   │   Combat.    │   │ Combat. │
   │         │   │           │   │ Support │   │   Conflict   │   │Resolution│
   └────┬────┘   └─────┬─────┘   └────┬────┘   └──────┬───────┘   └────┬────┘
        │              │              │               │                │
        │              │              │               │                │
        ▼              ▼              ▼               ▼                ▼
   ┌─────────┐   ┌─────────┐   ┌─────────────┐   ┌─────────────┐
   │  Group  │   │  Moves  │   │Combat.Damage│   │Combat.Retreat│
   └─────────┘   │(extended)│   └─────────────┘   └─────────────┘
                 └─────────┘

   ┌─────────┐
   │  Unit   │  (data struct, used by all)
   └─────────┘
```

---

## Module Catalog

### Data Structures

| Module | File | Purpose | Dependencies |
|--------|------|---------|--------------|
| `Unit` | `lib/phalanx/unit.ex` | Unit struct with health, energy, rotation | None |
| `Group` | `lib/phalanx/group.ex` | Organizational group (created in planning stage, fixed for battle) | None |
| `Phalanx` | `lib/phalanx/phalanx.ex` | Tactical formation (declared during battle, within single group) | None |
| `Order` | `lib/phalanx/order.ex` | Order struct (position, move, rotation) | None |
| `GroupOrder` | `lib/phalanx/orders/group_order.ex` | Order targeting a group | None |
| `PhalanxOrder` | `lib/phalanx/orders/phalanx_order.ex` | Order targeting a phalanx (atomic) | None |

### Logic Modules

| Module | File | Purpose | Dependencies |
|--------|------|---------|--------------|
| `Moves` | `lib/phalanx/moves.ex` | Hex math, neighbor calculation, direction helpers | None |
| `Formation` | `lib/phalanx/formation.ex` | Phalanx validation, creation, bonus calculation | `Moves`, `Phalanx`, `Group` |
| `Orders.Expansion` | `lib/phalanx/orders/expansion.ex` | Expand group/phalanx orders to unit orders | `Group`, `Phalanx` |
| `Strength` | `lib/phalanx/strength.ex` | Strength calculation (base + formation + flanking) | `Moves`, `Phalanx` |
| `Combat.Support` | `lib/phalanx/combat/support.ex` | Support graph, cutting logic | `Moves` |
| `Combat.Conflict` | `lib/phalanx/combat/conflict.ex` | Detect conflicts (destination, swap, cycle) | `Moves` |
| `Combat.Resolution` | `lib/phalanx/combat/resolution.ex` | Determine winners/losers, phalanx atomic balking | `Phalanx` |
| `Combat.Damage` | `lib/phalanx/combat/damage.ex` | Angle-based damage calculation | `Moves` |
| `Combat.Retreat` | `lib/phalanx/combat/retreat.ex` | Valid retreat hexes, retreat execution | `Moves` |

### Orchestrator

| Module | File | Purpose | Dependencies |
|--------|------|---------|--------------|
| `Engine.Combat` | `lib/phalanx/engine/combat.ex` | 13-phase turn resolution | All modules |

---

## Module Contracts

Each module exposes pure functions with explicit input/output types.

### Formation

```elixir
# lib/phalanx/formation.ex

@doc "Validate that selected units can form a phalanx"
@spec validate_phalanx_formation(
  positions :: [pos],
  groups :: [Group.t()],
  units :: %{pos => Unit.t()}
) :: :ok | {:error, reason}
# Checks: all in same group, adjacent, same rotation

@doc "Create a new phalanx from validated positions"
@spec form_phalanx(
  positions :: [pos],
  group :: Group.t(),
  units :: %{pos => Unit.t()}
) :: {:ok, Phalanx.t()} | {:error, reason}

@doc "Remove a unit from a phalanx (on death or individual order)"
@spec remove_member(phalanx :: Phalanx.t(), position :: pos) :: {:ok, Phalanx.t()} | :dissolved

@doc "Calculate formation strength bonus for a unit"
@spec formation_bonus(
  phalanxes :: [Phalanx.t()],
  position :: pos,
  units :: %{pos => Unit.t()}
) :: non_neg_integer()
# Returns count of adjacent allies in SAME PHALANX (not just same facing)
# Loose units always return 0
```

**Test file**: `test/phalanx/formation_test.exs`

**Test scenarios**:
- Valid formation: 3 adjacent same-facing units in same group → phalanx created
- Invalid: units from different groups → error
- Invalid: units not adjacent → error
- Invalid: units with different rotations → error
- Bonus: phalanx member with 2 neighbors in phalanx → +2
- Bonus: loose unit adjacent to phalanx → +0 (not a member)
- Remove member: phalanx of 3 loses 1 → phalanx of 2
- Remove member: phalanx of 2 loses 1 → dissolved

---

### Strength

```elixir
# lib/phalanx/strength.ex

@doc "Calculate attacker strength for a conflict"
@spec calculate_attack_strength(
  attacker_pos :: pos,
  defender_pos :: pos,
  units :: %{pos => Unit.t()},
  phalanxes :: [Phalanx.t()],
  support_data :: support_data()
) :: integer()

@doc "Calculate defender strength"
@spec calculate_defense_strength(
  defender_pos :: pos,
  units :: %{pos => Unit.t()},
  phalanxes :: [Phalanx.t()]
) :: integer()

@doc "Count adjacent phalanx members providing formation bonus"
@spec count_phalanx_neighbors(
  pos :: pos,
  phalanxes :: [Phalanx.t()]
) :: non_neg_integer()
# Returns count of adjacent allies in SAME declared phalanx
# Loose units always return 0

@doc "Classify attack direction relative to defender facing"
@spec classify_direction(
  defender_rotation :: integer(),
  attack_from :: atom()
) :: :front | :flank | :rear

@doc "Calculate flanking bonus for attack angle"
@spec flanking_bonus(attack_from :: atom(), defender_rotation :: integer()) :: integer()
```

**Test file**: `test/phalanx/strength_test.exs`

**Test scenarios**:
- Isolated unit (not in phalanx) → strength 1
- Phalanx member with one neighbor in same phalanx → strength 2
- Phalanx member with two neighbors (full line) → strength 3
- Phalanx member with rear ally in same phalanx → strength 2 (+1 from depth)
- 3-deep phalanx column → middle unit gets +2
- Loose unit adjacent to phalanx member → strength 1 (no bonus, not in phalanx)
- Flanking attack → +1 bonus
- Rear attack → +2 bonus
- Two adjacent units same facing, NOT in a phalanx → no formation bonus

---

### Combat.Support

```elixir
# lib/phalanx/combat/support.ex

@doc "Build support graph: who supports whom"
@spec calculate_supports(
  orders :: %{pos => Order.t()},
  units :: %{pos => Unit.t()},
  groups :: [Group.t()]
) :: %{pos => [pos]}

@doc "Identify which supports are cut by enemy attacks"
@spec find_cut_supports(
  supports :: %{pos => [pos]},
  conflicts :: [conflict()]
) :: MapSet.t(pos)

@doc "Find supporters for a specific unit"
@spec find_supporters(
  pos :: pos,
  direction :: atom(),
  orders :: %{pos => Order.t()},
  units :: %{pos => Unit.t()}
) :: [pos]
```

**Test file**: `test/phalanx/combat/support_test.exs`

**Test scenarios**:
- Unit A behind unit B, same direction → A supports B
- Unit A behind unit B, different direction → no support
- Supporter under attack → support cut
- Supporter attacked by defender being supported → support NOT cut

---

### Combat.Conflict

```elixir
# lib/phalanx/combat/conflict.ex

@type conflict ::
  {:destination_conflict, pos, [{pos, pos, Unit.t()}]}
  | {:attack, pos | [pos], pos}
  | {:swap_conflict, pos, pos}
  | {:cycle_conflict, [pos]}

@doc "Detect all conflicts from orders"
@spec detect_conflicts(
  orders :: %{pos => Order.t()},
  units :: %{pos => Unit.t()},
  map_dimensions :: {integer(), integer()}
) :: [conflict()]

@doc "Detect position swap attempts"
@spec detect_swaps(movements :: [{pos, pos, Unit.t()}]) :: [conflict()]

@doc "Detect movement cycles"
@spec detect_cycles(movements :: [{pos, pos, Unit.t()}]) :: [conflict()]
```

**Test file**: `test/phalanx/combat/conflict_test.exs`

**Test scenarios**:
- Two units target same empty hex → destination conflict
- Unit targets enemy-occupied hex → attack conflict
- A→B and B→A → swap conflict
- A→B→C→A → cycle conflict
- Same-team units target same hex → combined attack (not destination conflict)

---

### Combat.Resolution

```elixir
# lib/phalanx/combat/resolution.ex

@type result :: :move | :balk | :hold | :dislodged

@doc "Resolve all conflicts to movement results"
@spec resolve_conflicts(
  conflicts :: [conflict()],
  strengths :: %{pos => integer()},
  phalanxes :: [Phalanx.t()]
) :: %{pos => result()}

@doc "Apply all-or-nothing atomic movement for phalanxes"
@spec apply_phalanx_atomic_movement(
  results :: %{pos => result()},
  phalanxes :: [Phalanx.t()]
) :: %{pos => result()}
# If ANY phalanx member balks, ALL members balk
```

**Test file**: `test/phalanx/combat/resolution_test.exs`

**Test scenarios**:
- Attacker strength > defender → attacker moves, defender dislodged
- Attacker strength = defender → attacker balks
- Attacker strength < defender → attacker balks
- Combined attack (2 units) vs defender → forces add
- Phalanx: 1 of 3 members blocked → all 3 balk (all-or-nothing)
- Phalanx: all members unblocked → all move
- Loose units in group: 1 blocked → others still move (non-atomic)
- Swap → both balk regardless of strength

---

### Combat.Damage

```elixir
# lib/phalanx/combat/damage.ex

@doc "Calculate damage from attack angle"
@spec calculate_damage(
  defender_rotation :: integer(),
  attack_from :: atom()
) :: integer()
```

**Test file**: `test/phalanx/combat/damage_test.exs`

**Test scenarios**:
- Frontal attack → 0 damage
- Flank attack → 1 damage
- Rear attack → 2 damage
- All 6 attack directions × all 6 rotations = 36 combinations

---

### Combat.Retreat

```elixir
# lib/phalanx/combat/retreat.ex

@doc "Find valid retreat hexes for dislodged unit"
@spec valid_retreats(
  defender_pos :: pos,
  attacker_positions :: [pos],
  units :: %{pos => Unit.t()},
  standoff_hexes :: MapSet.t(pos),
  map_dimensions :: {integer(), integer()}
) :: [pos]

@doc "Execute retreats for all dislodged units"
@spec execute_retreats(
  dislodged :: [pos],
  units :: %{pos => Unit.t()},
  attacker_map :: %{pos => [pos]},
  standoff_hexes :: MapSet.t(pos),
  map_dimensions :: {integer(), integer()}
) :: %{pos => Unit.t()}
```

**Test file**: `test/phalanx/combat/retreat_test.exs`

**Test scenarios**:
- Single attacker → retreat must be away from attacker
- Multiple attackers → retreat must be away from ALL attackers
- Standoff hex → not valid retreat
- Occupied hex → not valid retreat
- Edge of map → constrained options
- No valid retreat → unit destroyed

---

## Engine.Combat: The Orchestrator

```elixir
# lib/phalanx/engine/combat.ex

defmodule Phalanx.Engine.Combat do
  @behaviour Phalanx.Engine

  alias Phalanx.{Formation, Strength, Unit, Group, Phalanx}
  alias Phalanx.Orders.Expansion
  alias Phalanx.Combat.{Support, Conflict, Resolution, Damage, Retreat}

  @impl true
  def execute_orders(state, group_orders, phalanx_orders, unit_orders) do
    # Phase 1: Snapshot
    snapshot = snapshot(state)

    # Phase 2: Order Expansion (Group/Phalanx → Unit orders)
    # Precedence: Individual > Phalanx > Group
    expanded_orders = Expansion.expand_orders(
      group_orders,
      phalanx_orders,
      unit_orders,
      state.groups,
      state.phalanxes
    )

    # Phase 3: Conflict Detection
    conflicts = Conflict.detect_conflicts(
      expanded_orders,
      snapshot.units,
      state.map_dimensions
    )

    # Phase 4: Support Calculation
    support_data = Support.calculate_supports(
      expanded_orders,
      snapshot.units,
      conflicts
    )

    # Phase 5: Strength Calculation (uses phalanx membership for bonuses)
    strengths = calculate_all_strengths(
      conflicts,
      snapshot,
      state.phalanxes,
      support_data
    )

    # Phase 6: Combat Resolution
    results = Resolution.resolve_conflicts(
      conflicts,
      strengths,
      state.phalanxes  # for atomic movement
    )

    # Phase 7: Movement Execution
    state = execute_movements(state, results, expanded_orders)

    # Phase 8: Damage & Retreat
    state = apply_damage_and_retreats(state, results, expanded_orders, snapshot)

    # Phase 9: Rotation
    state = apply_rotations(state, expanded_orders)

    # Phase 10: Phalanx Lifecycle (update phalanxes for deaths, movements)
    state = update_phalanxes(state)

    # Phase 11: Energy & Cleanup
    state = apply_energy_and_cleanup(state, expanded_orders, results)

    state
  end
end
```

**The orchestrator contains NO logic.** It only:
1. Calls modules in sequence
2. Passes outputs from one phase as inputs to the next

---

## File Structure

```
lib/phalanx/
├── unit.ex                    # Unit struct
├── group.ex                   # Group struct (organizational, pre-game)
├── phalanx.ex                 # Phalanx struct (tactical, during battle)
├── order.ex                   # Order struct (existing)
├── moves.ex                   # Hex math (existing, extended)
├── formation.ex               # Phalanx creation, validation, bonuses
├── strength.ex                # Strength calculation
├── orders/
│   ├── group_order.ex         # Order targeting a group
│   ├── phalanx_order.ex       # Order targeting a phalanx
│   └── expansion.ex           # Expand group/phalanx orders to unit orders
├── combat/
│   ├── support.ex             # Support graph
│   ├── conflict.ex            # Conflict detection
│   ├── resolution.ex          # Winner determination, atomic movement
│   ├── damage.ex              # Damage calculation
│   └── retreat.ex             # Retreat logic
└── engine/
    ├── diplomacy.ex           # Existing simple engine
    └── combat.ex              # New combat engine

test/phalanx/
├── unit_test.exs
├── group_test.exs
├── phalanx_test.exs
├── moves_test.exs
├── formation_test.exs
├── strength_test.exs
├── orders/
│   └── expansion_test.exs
├── combat/
│   ├── support_test.exs
│   ├── conflict_test.exs
│   ├── resolution_test.exs
│   ├── damage_test.exs
│   └── retreat_test.exs
└── engine/
    └── combat_test.exs        # Integration tests only
```

---

## Testing Strategy

### Unit Tests (per module)

Each module has its own test file. Tests use **minimal fixtures** - just enough state to test that module.

Example: Testing `Strength.count_phalanx_neighbors/2`:

```elixir
# test/phalanx/strength_test.exs

describe "count_phalanx_neighbors/2" do
  test "returns 0 for unit not in any phalanx" do
    phalanxes = []
    assert Strength.count_phalanx_neighbors({2, 2}, phalanxes) == 0
  end

  test "returns 1 for phalanx member with one neighbor in same phalanx" do
    phalanx = %Phalanx{
      id: "p1",
      positions: MapSet.new([{2, 2}, {3, 2}]),
      rotation: 0
    }
    phalanxes = [phalanx]

    assert Strength.count_phalanx_neighbors({2, 2}, phalanxes) == 1
  end

  test "returns 0 for loose unit adjacent to phalanx" do
    # Unit at {1, 2} is NOT in the phalanx, even though adjacent
    phalanx = %Phalanx{
      id: "p1",
      positions: MapSet.new([{2, 2}, {3, 2}]),
      rotation: 0
    }
    phalanxes = [phalanx]

    assert Strength.count_phalanx_neighbors({1, 2}, phalanxes) == 0
  end
end
```

### Integration Tests (Engine.Combat only)

`test/phalanx/engine/combat_test.exs` tests full turn resolution with complete game states. These are **scenario tests** from `plans/combat/test-scenarios.md`.

---

## Why This Architecture?

1. **Debuggability**: When something breaks, you know which module to check.
2. **Confidence**: Each module is exhaustively tested in isolation.
3. **Iteration**: Change strength calculation without touching retreat logic.
4. **Clarity**: New developers understand one module at a time.
5. **Parallelism**: Multiple developers can work on different modules.

---

## Implementation Order

Build and test bottom-up:

1. `Unit` - data struct (trivial)
2. `Group` - data struct (organizational groups)
3. `Phalanx` - data struct (tactical formations)
4. `Moves` extensions - hex math helpers
5. `Formation` - phalanx creation, validation, bonus calculation
6. `Orders.Expansion` - expand group/phalanx orders to unit orders
7. `Strength` - strength calculation (uses phalanx membership)
8. `Combat.Support` - support graph
9. `Combat.Conflict` - conflict detection
10. `Combat.Damage` - damage calculation
11. `Combat.Retreat` - retreat logic
12. `Combat.Resolution` - winner determination, atomic phalanx movement
13. `Engine.Combat` - orchestration + integration tests

Each PR adds one module with its tests. No PR depends on unmerged code.
