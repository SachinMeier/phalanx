# [2026-01-26]: Grouping Mechanics for Phalanx Engine

**Author**:
**Approved By**:

---

## 1. What's the problem you're trying to solve?

**Casual**: Units fight alone. They should gain strength when standing shoulder-to-shoulder with allies facing the same way. That is a phalanx.

**Formal**:

1. No mechanism to detect adjacent friendly units with aligned facing
2. No strength bonus calculation based on formation
3. No atomic movement for grouped units (MECHANICS.md: "Units in a phalanx move atomically")
4. No majority-rule balking for formations (MECHANICS.md: "A phalanx is only dislodged if a majority of its members would be dislodged")

Note on terminology: "dislodged" in MECHANICS.md refers to movement balking, not HP damage. When a unit's move is blocked by conflict, it balks. A phalanx balks only if the majority of its members would balk individually.

**Out of Scope**:

* **Combat damage resolution**: Separate concern. This spec covers grouping detection and strength bonuses only.
* **Energy system**: Orthogonal mechanic. Groups affect movement atomicity, not energy costs.
* **Support mechanics (unit behind pushing)**: Related but distinct. +1 strength for rear support is a separate calculation.
* **Win/loss conditions**: Game-level concern, not formation mechanics.

---

## 2. What's the simplest solution to solve the problem?

### Design Decisions

* **Grouping Model**: Implicit. Groups computed each turn from board state. No new state or orders.
* **Movement Atomicity**: Majority Rule. If majority of group would balk, all balk. Per MECHANICS.md.
* **Same Direction Movement**: Required. Mixed orders within a group are invalid; the group holds.
* **Group Detection Timing**: Turn start, before orders execute. Rotation orders do not affect current-turn grouping.
* **Minimum Group Size**: 2 units. Two adjacent same-facing allies form a phalanx.
* **Diagonal Formations**: Allowed. Any adjacency with same facing counts.

---

### The main parts of the solution are:

1. **Group detection module**: Given unit positions and rotations, compute connected components of same-color, same-facing units
2. **Strength calculation**: Base 1 + count of same-facing adjacent allies
3. **Majority-rule balking**: During conflict resolution, count would-balk units per group; if majority, all balk

---

## 3. Which key code changes do you need to make (files, type/fn/service signatures)?

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
end
```

+++

+++ #### Grouping

Detection and strength calculation for phalanx formations.

`lib/phalanx/grouping.ex`

```elixir
defmodule Phalanx.Grouping do
  @doc """
  Detect all phalanx groups from current unit positions.
  Flood-fill algorithm on same-color, same-rotation adjacency.
  """
  @spec detect_groups(units :: map()) :: [Phalanx.Group.t()]
  def detect_groups(units)

  @doc """
  Calculate phalanx strength bonus for a unit.
  Returns count of same-facing adjacent allies.
  """
  @spec formation_strength(units :: map(), position :: {integer(), integer()}) :: non_neg_integer()
  def formation_strength(units, position)
end
```

+++

+++ #### Engine.Diplomacy (modified)

Add group-aware majority-rule balking to existing conflict resolution.

`lib/phalanx/engine/engine_diplomacy.ex`

```elixir
defmodule Phalanx.Engine.Diplomacy do
  # Existing functions unchanged, add:

  @doc """
  Apply majority-rule balking for phalanx groups.
  For each group, count members in conflict_units.
  If majority would balk, add all group members to balk set.
  """
  @spec apply_majority_rule_balks(
    conflict_units :: MapSet.t(),
    groups :: [Phalanx.Group.t()]
  ) :: MapSet.t()
  def apply_majority_rule_balks(conflict_units, groups)

  @doc """
  Validate that grouped units share movement direction.
  Returns orders with invalid group movements converted to holds.
  """
  @spec enforce_group_movement(
    orders :: map(),
    groups :: [Phalanx.Group.t()]
  ) :: map()
  def enforce_group_movement(orders, groups)
end
```

+++

+++ #### Moves (modified)

Add neighbor enumeration.

`lib/phalanx/moves.ex`

```elixir
defmodule Phalanx.Moves do
  # Existing functions unchanged, add:

  @doc """
  Get all 6 neighbor positions for a hex, regardless of unit rotation.
  Returns list of {position, direction} tuples.
  Uses existing oddr_offset_neighbor/4 internally.
  """
  @spec all_hex_neighbors({integer(), integer()}) :: [{{integer(), integer()}, atom()}]
  def all_hex_neighbors(position)
end
```

+++

---

## 4. What's the PR roadmap?

1. PR #1: Neighbor enumeration
   1. `Moves.all_hex_neighbors/1` function
   2. Tests for even/odd row neighbor math

2. PR #2: Group detection
   1. `Phalanx.Group` struct
   2. `Grouping.detect_groups/1` with flood-fill algorithm
   3. Tests for line detection, no false positives for different rotations/colors

3. PR #3: Formation strength
   1. `Grouping.formation_strength/2` counting adjacent allies
   2. Tests for line positions, isolated units

4. PR #4: Majority-rule balking
   1. `Engine.Diplomacy.apply_majority_rule_balks/2` function
   2. `Engine.Diplomacy.enforce_group_movement/2` function
   3. Integrate into `execute_orders/2`: detect groups at turn start, enforce same direction, apply majority rule to conflicts
   4. Tests for majority threshold (2/3 balk = all balk, 1/3 balk = none balk), mixed movement rejection

---

## 5. What are open questions?

None. All design decisions resolved in Section 2.
