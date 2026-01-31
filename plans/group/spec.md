# [2026-01-31]: Groups and Phalanx Mechanics

**Author**:
**Approved By**:

---

## 1. What's the problem you're trying to solve?

**Casual**: Players need to organize their army before battle (groups) and form tactical formations during battle (phalanxes). These are two separate concerns at different phases of the game.

**Formal**:

1. No mechanism for players to organize units into command groups before battle
2. No mechanism for players to declare phalanx formations during battle
3. No strength bonus calculation based on phalanx formation
4. No atomic movement for phalanxes

**Historical context**: Before a battle, generals assigned units to divisions (left flank, center, right flank, reserves). During the battle, units within a division could form phalanx—locking shields and advancing as one. Forming a phalanx was a deliberate tactical commitment, not an emergent property.

**Out of Scope**:

* **Combat damage resolution**: Separate concern (see `combat/spec.md`)
* **Energy system**: Orthogonal mechanic (see `energy-system.md`)
* **Win/loss conditions**: Game-level concern

---

## 2. What's the simplest solution to solve the problem?

### Two Separate Concepts

| Concept | When Created | Persistence | Scope | Order Behavior |
|---------|--------------|-------------|-------|----------------|
| **Group** | Pre-game planning stage | Fixed for entire battle | Organizational | Non-atomic (each unit independent) |
| **Phalanx** | During battle | Until broken/disbanded | Within single group only | Atomic (all-or-nothing) |

**Key distinction**:
- Group = organizational (command structure, "my left flank")
- Phalanx = tactical (physical formation, "shields locked")

### Game Flow

```
1. Players join game
2. Game starts → PLANNING STAGE
   - Players assign units to groups
   - No movement, no combat
   - Both players click "Ready"
3. BATTLE STAGE begins
   - Groups are fixed (no reorganization)
   - Players issue orders to groups, phalanxes, or individual units
   - Players can form/disband phalanxes within groups
```

### Design Decisions

**Groups (pre-game planning)**:
* Created during planning stage before battle starts
* Fixed for the entire battle—no reorganization mid-battle
* A unit belongs to exactly one group (or is ungrouped)
* No adjacency or rotation requirements—scattered units can be grouped
* Orders to a group are distributed to all members
* Non-atomic execution: each unit executes independently
* Purely organizational—no mechanical bonuses

**Phalanxes (during battle)**:
* Explicitly declared by player during battle ("Form Phalanx" order)
* Can only form within a single group (cross-group phalanxes not allowed)
* Requirements: adjacent positions + same rotation (facing)
* Minimum size: 2 units
* Confer formation bonuses (+1 strength per adjacent phalanx member)
* Move atomically (all-or-nothing balking)
* Persist until disbanded or broken (member killed, forced apart)

**Ungrouped Units**:
* Valid state—some units may be independent "reserves"
* Cannot form phalanxes (phalanx requires group membership)
* Must be ordered individually

**Formation Bonuses**:
* Apply only to phalanx members (not loose units in a group)
* +1 strength per adjacent ally in same phalanx
* Side allies: max 2 by geometry (1 per side)
* Rear ally: max 1 (directly behind)
* Maximum possible bonus: +5 (surrounded by same-facing phalanx members)

**Deathball Prevention**:
* All phalanx members must share the same rotation
* A 7-hex cluster facing east is vulnerable to flanking from north/south
* The rotation requirement naturally creates exposed flanks

### Order Precedence

Orders can target groups, phalanxes, or individual units. When multiple orders apply:

**Precedence: Individual > Phalanx > Group**

| Situation | Result |
|-----------|--------|
| Group order only | All members receive order, execute independently (loose) or atomically (phalanx members) |
| Phalanx order | Phalanx members follow phalanx order, ignoring group order |
| Individual order on loose unit | Unit follows individual order, ignoring group order |
| Individual order on phalanx member | Unit leaves phalanx, follows individual order |

**Example**:
```
Group A: [Unit 1 (loose), Unit 2 (loose), Phalanx X (Units 3, 4)]

Orders:
  Group A: move east
  Phalanx X: move west
  Unit 2: rotate clockwise

Result:
  Unit 1: moves east (group order)
  Unit 2: rotates clockwise (individual order overrides)
  Units 3, 4: move west atomically (phalanx order overrides group)
```

### Phalanx Lifecycle

**Formation**:
1. Player selects 2+ units within the same group
2. Units must be adjacent and share the same rotation
3. Player issues "Form Phalanx" command
4. Phalanx is created and persists in game state

**Breaking**:
* **Voluntary disband**: Player issues "Disband" order
* **Member death**: Phalanx shrinks; if only 1 unit remains, phalanx dissolves
* **Individual order**: Unit receiving individual order leaves phalanx
* **Forced separation**: If combat/movement forces units apart, phalanx breaks

**Phalanx State**:
* Stored in game state with: member positions, shared rotation, owning group
* Orders to phalanx apply to all members atomically

### Phalanx Shape Examples

All of these are valid phalanxes (assuming all units in same group, adjacent, same facing):

```
Line (3 wide):        Column (3 deep):      Block (2x2):         L-shape:
[A][B][C]             [A]                   [A][B]               [A][B]
                      [B]                   [C][D]               [C]
                      [C]

Diagonal:             Irregular:
   [A]                [A][B]
  [B]                    [C][D]
 [C]                        [E]
```

The requirement is: **same group** + **connected** + **same facing**. Shape is irrelevant.

---

## 3. Which key code changes do you need to make?

+++ #### Group

Represents a player-defined organizational group. Created in planning stage.

`lib/phalanx/group.ex`

```elixir
defmodule Phalanx.Group do
  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    color: String.t(),  # owning player
    unit_positions: MapSet.t({integer(), integer()})
  }

  defstruct [:id, :name, :color, :unit_positions]

  @spec member?(group :: t(), position :: {integer(), integer()}) :: boolean()

  @spec size(group :: t()) :: non_neg_integer()
end
```

+++

+++ #### Phalanx

Represents an explicitly declared phalanx formation within a group.

`lib/phalanx/phalanx.ex`

```elixir
defmodule Phalanx.Phalanx do
  @type t :: %__MODULE__{
    id: String.t(),
    group_id: String.t(),  # must belong to a group
    positions: MapSet.t({integer(), integer()}),
    rotation: integer()  # shared facing (all members must match)
  }

  defstruct [:id, :group_id, :positions, :rotation]

  @spec size(phalanx :: t()) :: non_neg_integer()

  @spec member?(phalanx :: t(), position :: {integer(), integer()}) :: boolean()
end
```

+++

+++ #### Formation

Phalanx formation and validation logic.

`lib/phalanx/formation.ex`

```elixir
defmodule Phalanx.Formation do
  @doc """
  Validate that selected units can form a phalanx.
  Requirements: all in same group, adjacent, same rotation.
  """
  @spec validate_phalanx_formation(
    positions :: [tuple()],
    groups :: [Phalanx.Group.t()],
    units :: map()
  ) :: :ok | {:error, atom()}

  @doc """
  Create a new phalanx from validated positions.
  """
  @spec form_phalanx(
    positions :: [tuple()],
    group :: Phalanx.Group.t(),
    units :: map()
  ) :: {:ok, Phalanx.Phalanx.t()} | {:error, atom()}

  @doc """
  Disband a phalanx. Members become loose units within their group.
  """
  @spec disband_phalanx(phalanx :: Phalanx.Phalanx.t()) :: :ok

  @doc """
  Remove a unit from a phalanx. If phalanx drops below 2, dissolve it.
  """
  @spec remove_member(
    phalanx :: Phalanx.Phalanx.t(),
    position :: tuple()
  ) :: {:ok, Phalanx.Phalanx.t()} | :dissolved

  @doc """
  Calculate formation strength bonus for a unit.
  Returns count of adjacent allies in same phalanx.
  Only applies to phalanx members.
  """
  @spec formation_bonus(
    phalanxes :: [Phalanx.Phalanx.t()],
    position :: tuple(),
    units :: map()
  ) :: non_neg_integer()
end
```

+++

+++ #### GroupOrder

Order targeting a group. Distributed to all members.

`lib/phalanx/orders/group_order.ex`

```elixir
defmodule Phalanx.Orders.GroupOrder do
  @type t :: %__MODULE__{
    group_id: String.t(),
    move: atom() | nil,
    rotation: atom() | nil
  }

  defstruct [:group_id, :move, :rotation]
end
```

+++

+++ #### PhalanxOrder

Order targeting a phalanx. Executed atomically.

`lib/phalanx/orders/phalanx_order.ex`

```elixir
defmodule Phalanx.Orders.PhalanxOrder do
  @type t :: %__MODULE__{
    phalanx_id: String.t(),
    move: atom() | nil,
    rotation: atom() | nil  # all members rotate together
  }

  defstruct [:phalanx_id, :move, :rotation]
end
```

+++

+++ #### Order Expansion

Expand group/phalanx orders to unit orders with precedence.

`lib/phalanx/orders/expansion.ex`

```elixir
defmodule Phalanx.Orders.Expansion do
  @doc """
  Expand all orders (group, phalanx, individual) to per-unit orders.
  Applies precedence: Individual > Phalanx > Group.
  Returns map of position => order.
  """
  @spec expand_orders(
    group_orders :: [Phalanx.Orders.GroupOrder.t()],
    phalanx_orders :: [Phalanx.Orders.PhalanxOrder.t()],
    unit_orders :: [Phalanx.Order.t()],
    groups :: [Phalanx.Group.t()],
    phalanxes :: [Phalanx.Phalanx.t()]
  ) :: %{tuple() => Phalanx.Order.t()}
end
```

+++

+++ #### Game State Updates

Add groups and phalanxes to game state.

`lib/phalanx/game.ex`

```elixir
defmodule Phalanx.Game do
  # Add to existing struct:
  #   groups: [Phalanx.Group.t()]
  #   phalanxes: [Phalanx.Phalanx.t()]
  #   stage: :planning | :battle

  @doc """
  Transition from planning stage to battle stage.
  Locks group assignments.
  """
  @spec start_battle(game :: t()) :: {:ok, t()} | {:error, atom()}
end
```

+++

---

## 4. What's the PR roadmap?

1. **PR #1: Game stages**
   1. Add `:planning` and `:battle` stages to game state
   2. Implement stage transition logic
   3. Tests for stage flow

2. **PR #2: Group management**
   1. `Phalanx.Group` struct
   2. Create/modify groups during planning stage
   3. Lock groups when battle starts
   4. Tests for group CRUD and stage constraints

3. **PR #3: Phalanx formation**
   1. `Phalanx.Phalanx` struct
   2. `Formation.validate_phalanx_formation/3`
   3. `Formation.form_phalanx/3`
   4. Tests for: same group requirement, adjacency, rotation matching

4. **PR #4: Order expansion**
   1. Group and phalanx order structs
   2. `Orders.Expansion.expand_orders/5` with precedence
   3. Tests for precedence rules

5. **PR #5: Phalanx atomic movement**
   1. Phalanx-aware balking (all-or-nothing)
   2. Integration with engine conflict resolution
   3. Tests for atomic behavior

6. **PR #6: Formation bonuses**
   1. `Formation.formation_bonus/3`
   2. Integration with strength calculation
   3. Tests for bonus calculation

7. **PR #7: Phalanx lifecycle**
   1. Disband order handling
   2. Auto-dissolution on member death
   3. Breaking on individual orders
   4. Tests for all lifecycle events

---

## 5. What are open questions?

1. **Planning stage duration**: Timer-based or both-players-ready?

2. **Group names**: Player-assigned or auto-generated (Group A, Group B)?

3. **Phalanx formation cost**: Should forming a phalanx cost energy? This would add commitment weight.

4. **Rotation within phalanx**: When a phalanx rotates, all members rotate. Should this be instant or cost energy?
