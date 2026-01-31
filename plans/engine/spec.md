# 2026-01-26: Unified Phalanx Engine

**Author**:
**Approved By**:

---

## 1. What's the problem you're trying to solve?

**Casual**: Units occupy a hex grid. They move, they rotate, they collide. When collisions occur, both units halt. No winner, no loser, no blood. The game needs a combat engine that calculates strength from formation, validates declared phalanxes, resolves who wins contested hexes, and applies damage to the defeated.

**Formal**:

1. `Engine.Diplomacy` treats all collisions as mutual balk; no dislodgement occurs
2. Unit health (currently 3) is never modified
3. No strength calculation exists (base strength, formation bonuses, flanking)
4. No phalanx validation exists (player-declared formations within groups)
5. No atomic movement for phalanx units
6. No all-or-nothing balking for phalanxes
7. No retreat system for dislodged units
8. No energy system for attrition

**Out of Scope**:

* **Unit types**: All units are identical hoplites
* **Map objectives**: Capture points, king-of-the-hill mechanics
* **Fog of war**: Full visibility assumed

---

## 2. What's the simplest solution to solve the problem?

Three systems work in sequence:

```
         ┌─────────────────────────────────────────────────────────────┐
         │                    PRE-GAME PLANNING                        │
         │  Players create groups (fixed for entire battle)            │
         └─────────────────────────────────────────────────────────────┘

         ┌─────────────────────────────────────────────────────────────┐
         │                    TURN START                               │
         │  Snapshot state                                             │
         └─────────────────────┬───────────────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────────────┐
         │                    ORDER EXPANSION                          │
         │  Individual > Phalanx > Group precedence                    │
         │  Expand orders to unit-level                                │
         └─────────────────────┬───────────────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────────────┐
         │                     STRENGTH                                   │
         │  Calculate strength for each combatant                      │
         │  Base + Formation (declared phalanx only)                   │
         └─────────────────────┬───────────────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────────────┐
         │                    COMBAT                                   │
         │  Compare strengths, determine winners                       │
         │  Apply all-or-nothing for phalanxes                         │
         │  Execute moves, apply damage, process retreats              │
         └─────────────────────┬───────────────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────────────┐
         │                   PHALANX LIFECYCLE                         │
         │  Update phalanxes after deaths/movement                     │
         └─────────────────────┬───────────────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────────────┐
         │                   WIN CONDITION CHECK                       │
         │  Check if game has ended (elimination, objectives, etc.)    │
         └─────────────────────┬───────────────────────────────────────┘
                               ▼
         ┌─────────────────────────────────────────────────────────────┐
         │                   TURN END                                  │
         │  Apply rotations, update energy, cleanup                    │
         └─────────────────────────────────────────────────────────────┘
```

**Game Stages**: The game has two stages:
- `:planning` - Players create groups before battle begins. Groups are fixed organizational units.
- `:battle` - Combat occurs. Groups cannot be modified. Phalanxes can be formed/broken within groups.

**Order Model**: Orders follow precedence: Individual > Phalanx > Group. Players can issue orders at any level. Phalanxes are explicitly declared via "Form Phalanx" command during battle, not auto-detected.

**Game Mode**: Set at game creation time, not during battle. Determines win conditions and any asymmetric rules.

The main parts of the solution are:

1. **Group management**: Groups created in planning stage, fixed during battle
2. **Phalanx declaration**: Players explicitly form phalanxes within groups during battle
3. **Order expansion**: Apply precedence rules, expand to unit-level orders
4. **Strength module**: Calculate strength from base + phalanx bonus (declared phalanxes only)
5. **Combat module**: Resolve conflicts, apply all-or-nothing phalanx balking, execute movements, apply damage, handle retreats
6. **Phalanx lifecycle**: Update phalanxes when members die or formation breaks
7. **Win condition check**: Determine if game has ended based on game mode
8. **Engine.Combat**: Orchestrate the resolution algorithm

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

Represents an organizational unit created in pre-game planning. Fixed for the entire battle.

`lib/phalanx/group.ex`

```elixir
defmodule Phalanx.Group do
  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    color: String.t(),
    unit_positions: MapSet.t({integer(), integer()})
  }

  defstruct [:id, :name, :color, :unit_positions]

  @spec new(id :: String.t(), name :: String.t(), color :: String.t(), positions :: list()) :: t()
  @spec size(group :: t()) :: non_neg_integer()
  @spec contains_position?(group :: t(), position :: {integer(), integer()}) :: boolean()
end
```

+++

+++ #### Phalanx

Represents an explicitly declared phalanx within a single group.

`lib/phalanx/phalanx.ex`

```elixir
defmodule Phalanx.Phalanx do
  @type t :: %__MODULE__{
    id: String.t(),
    group_id: String.t(),
    positions: MapSet.t({integer(), integer()}),
    rotation: integer()
  }

  defstruct [:id, :group_id, :positions, :rotation]

  @spec size(phalanx :: t()) :: non_neg_integer()
  @spec contains_position?(phalanx :: t(), position :: {integer(), integer()}) :: boolean()
end
```

+++

+++ #### Orders.Expansion

Order precedence and expansion logic.

`lib/phalanx/orders/expansion.ex`

```elixir
defmodule Phalanx.Orders.Expansion do
  @moduledoc """
  Expands high-level orders to unit-level orders using precedence:
  Individual > Phalanx > Group
  """

  @type position :: {integer(), integer()}
  @type unit_order :: %{move: atom() | nil, rotation: atom() | nil}

  @spec expand_orders(
    individual_orders :: %{position() => unit_order()},
    phalanx_orders :: %{String.t() => unit_order()},
    group_orders :: %{String.t() => unit_order()},
    phalanxes :: [Phalanx.Phalanx.t()],
    groups :: [Phalanx.Group.t()]
  ) :: %{position() => unit_order()}
  # Returns unit-level orders for every unit
  # Precedence: Individual overrides Phalanx overrides Group

  @spec distribute_group_order(
    group :: Phalanx.Group.t(),
    order :: unit_order(),
    phalanxes :: [Phalanx.Phalanx.t()]
  ) :: %{position() => unit_order()}
  # Distributes group order to members
  # Non-atomic for loose units, atomic treatment for phalanx members
end
```

+++

+++ #### Grouping

Group validation and phalanx management.

`lib/phalanx/grouping.ex`

```elixir
defmodule Phalanx.Grouping do
  @spec validate_group(group :: Phalanx.Group.t(), units :: map()) ::
    :ok | {:error, atom()}
  # Validates ownership only (same player owns all units in group)

  @spec validate_phalanx_formation(
    positions :: [position()],
    group :: Phalanx.Group.t(),
    units :: map()
  ) :: :ok | {:error, atom()}
  # Validates:
  # - All positions belong to the specified group
  # - All units have same rotation
  # - All positions are adjacent (connected component)

  @spec form_phalanx(
    positions :: [position()],
    group_id :: String.t(),
    units :: map(),
    existing_phalanxes :: [Phalanx.Phalanx.t()]
  ) :: {:ok, Phalanx.Phalanx.t()} | {:error, atom()}
  # Creates a new phalanx from the given positions
  # Removes positions from any existing phalanxes

  @spec break_phalanx(phalanx_id :: String.t(), phalanxes :: [Phalanx.Phalanx.t()]) ::
    [Phalanx.Phalanx.t()]
  # Removes the specified phalanx

  @spec update_phalanxes_after_deaths(
    phalanxes :: [Phalanx.Phalanx.t()],
    dead_positions :: MapSet.t(position())
  ) :: [Phalanx.Phalanx.t()]
  # Removes dead units from phalanxes
  # Dissolves phalanxes that become non-adjacent or size < 2
end
```

+++

+++ #### Strength

Pure functions for strength calculation.

`lib/phalanx/strength.ex`

```elixir
defmodule Phalanx.Strength do
  @base_strength 1
  @max_support_bonus 2  # Pushing support cap (not formation)

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

  # Formation bonus = +1 per adjacent unit in SAME DECLARED PHALANX
  # Loose units get NO formation bonus
  # Side: max 2 by geometry (left + right neighbors)
  # Rear: no cap (deep formations are powerful but flankable)
  @spec count_formation_allies(
    pos :: position(),
    phalanxes :: [Phalanx.Phalanx.t()],
    units :: map()
  ) :: %{side: integer(), rear: integer()}

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
    phalanxes :: [Phalanx.Phalanx.t()]
  ) :: %{position() => result()}
  # Results:
  # - :move     Attacker who won; moves to target hex
  # - :balk     Attacker who lost or tied; stays in place
  # - :dislodged  Defender who lost; must retreat

  @spec apply_phalanx_atomic_movement(
    results :: map(),
    phalanxes :: [Phalanx.Phalanx.t()]
  ) :: map()
  # All-or-nothing rule: if ANY member of a phalanx would balk,
  # ALL members of that phalanx balk. Convert all :move to :balk.
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

+++ #### Game State

Updated game state with groups, phalanxes, and stage.

`lib/phalanx/game.ex`

```elixir
defmodule Phalanx.Game do
  @type t :: %__MODULE__{
    id: String.t(),
    status: atom(),
    stage: :planning | :battle,
    turn: integer(),
    players: [Player.t()],
    units: %{{integer(), integer()} => Unit.t()},
    groups: [Phalanx.Group.t()],
    phalanxes: [Phalanx.Phalanx.t()],
    game_mode: Phalanx.GameMode.t(),
    mode_state: map(),
    winner: atom() | nil,
    map_dimensions: {integer(), integer()}
  }

  defstruct [:id, :status, :stage, :turn, :players, :units, :groups, :phalanxes, :game_mode, :mode_state, :winner, :map_dimensions]
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
  @spec expand_orders(orders :: map(), state :: Phalanx.Game.t()) :: map()
  @spec validate_orders(orders :: map(), snapshot :: map(), map_dimensions :: tuple()) :: map()
  @spec calculate_all_strengths(conflicts :: list(), snapshot :: map(), support_data :: map()) :: map()
  @spec execute_movements(state :: Phalanx.Game.t(), results :: map(), orders :: map()) :: Phalanx.Game.t()
  @spec apply_damage_and_retreats(state :: Phalanx.Game.t(), results :: map(), orders :: map(), snapshot :: map()) :: Phalanx.Game.t()
  @spec update_phalanx_lifecycle(state :: Phalanx.Game.t(), dead_positions :: MapSet.t()) :: Phalanx.Game.t()
  @spec check_win_condition(state :: Phalanx.Game.t()) ::
    {:continue} | {:winner, atom()} | {:draw}
  @spec apply_rotations(state :: Phalanx.Game.t(), orders :: map()) :: Phalanx.Game.t()
  @spec apply_energy_and_cleanup(state :: Phalanx.Game.t(), orders :: map(), results :: map()) :: Phalanx.Game.t()
end
```

+++

---

## 4. Resolution Algorithm

Thirteen phases execute in strict order. All phases reference the turn-start snapshot for calculation consistency.

### Phase 1: SNAPSHOT

Capture immutable state.

| Input | Output |
|-------|--------|
| `state.units` | `snapshot.units` (deep copy) |
| `state.phalanxes` | `snapshot.phalanxes` (deep copy) |
| `state.groups` | `snapshot.groups` (deep copy) |
| | `snapshot.turn` |

### Phase 2: ORDER EXPANSION

Expand high-level orders to unit orders using precedence rules.

| Step | Action |
|------|--------|
| 2.1 | Collect individual orders (highest precedence) |
| 2.2 | Collect phalanx orders, expand to member positions |
| 2.3 | Collect group orders, expand to member positions |
| 2.4 | Apply precedence: Individual > Phalanx > Group |
| 2.5 | Populate holds for units without orders |

**Precedence**: Individual orders override phalanx orders, which override group orders.

**Distribution**:
- Group orders distribute to all members
- For loose units (not in a phalanx): non-atomic treatment
- For phalanx members: atomic treatment (all-or-nothing)

### Phase 3: ORDER VALIDATION

Validate expanded unit orders.

| Step | Action |
|------|--------|
| 3.1 | Reject moves invalid for unit's rotation/bounds |
| 3.2 | Invalid orders become holds |

### Phase 4: CONFLICT DETECTION

Identify contested hexes and classify conflict types.

| Type | Detection | Resolution |
|------|-----------|------------|
| `destination_conflict` | 2+ units target same hex | Compare strengths |
| `attack` | 1 unit targets enemy-occupied hex | Attacker vs defender |
| `swap_conflict` | A->B and B->A | Both balk |
| `cycle_conflict` | A->B->C->A | All balk |

### Phase 5: SUPPORT CALCULATION

Build support graph, identify cut supports.

**Support relationships**:
| Condition | Effect |
|-----------|--------|
| A adjacent to B, same direction, same color | A supports B |
| A moves alongside B (same direction) | A supports B |
| A moves behind B (pushing) | A supports B |
| A and B attack same hex | Combined attack (forces add) |

**Support cutting**:
Support is cut when the supporter is targeted by an enemy attack. Friendly movement does not cut support.

### Phase 6: STRENGTH CALCULATION

Compute strength for each combatant.

**Attacker Strength**:
```
Base(1) + Formation + Support(0-2)
```

**Defender Strength**:
```
Base(1) + Formation
```

| Bonus | Source | Cap |
|-------|--------|-----|
| Formation | +1 per adjacent ally in SAME DECLARED PHALANX | None |
| -- Side allies | Left and right neighbors in same phalanx | +2 max (geometry) |
| -- Rear allies | Behind the unit in same phalanx | No cap |
| Support | Allies pushing same direction (not in same phalanx) | +2 |

**CRITICAL**: Formation bonuses apply ONLY to units in the SAME declared phalanx. Loose units (not in any phalanx) get NO formation bonus, regardless of adjacent allies.

**Damage** (NOT strength -- flanking affects damage only). Damage stacks:

| Source | HP Lost |
|--------|---------|
| Dislodge | 1 HP |
| Frontal angle bonus | +0 (shields block) |
| Flank angle bonus | +1 |
| Rear angle bonus | +2 |

**Total on dislodge**: Frontal = 1 HP, Flank = 2 HP, Rear = 3 HP.

**Key distinction**: Strength determines WHO wins. Dislodge costs 1 HP; angle adds bonus damage.

**Self-balancing**: Deep formations have massive pushing power but are vulnerable to flanking attacks that deal heavy damage.

### Phase 7: COMBAT RESOLUTION

Determine winners and losers.

**Combined Attack Rule**: When multiple allies attack the same enemy hex, their forces ADD together against the defender. First unit ordered to attack that hex is the "lead" and moves in upon victory.

| Condition | Outcome |
|-----------|---------|
| Combined Attackers > Defender | Lead attacker wins (:move), other attackers hold, defender (:dislodged) |
| Combined Attackers <= Defender | All attackers (:balk), defender stays in place |
| Multiple enemies attack same hex | Each enemy's attack resolves separately |

**Lead unit**: First unit ordered to attack the hex. Upon combined victory, only the lead moves in.

**All-or-Nothing Rule for Phalanxes**: When a phalanx moves, if ANY member would balk, ALL members balk. This applies to declared phalanxes only.

### Phase 8: MOVEMENT EXECUTION

Apply movement results to game state. Remove from origins, add to destinations.

### Phase 9: DAMAGE & RETREAT

| Damage Source | HP Lost |
|---------------|---------|
| Dislodged | -1 |
| Attacked from flank | -1 |
| Attacked from rear | -2 |
| Moving non-counterparallel when attacked | -1 |

**Retreat Rules**:
- Must be AWAY from the attacker(s) (opposite direction from attack)
- Adjacent empty hex only
- Except standoff hexes
- If multiple attackers: must be away from ALL attackers
- Random selection from valid options
- No valid retreat -> unit destroyed

### Phase 10: PHALANX LIFECYCLE

Update phalanxes after combat.

| Step | Action |
|------|--------|
| 10.1 | Remove dead unit positions from phalanxes |
| 10.2 | Check adjacency of remaining members |
| 10.3 | Dissolve phalanxes that are no longer connected |
| 10.4 | Dissolve phalanxes with fewer than 2 members |

### Phase 11: WIN CONDITION CHECK

Check if game has ended based on the game mode's win condition.

| Step | Action |
|------|--------|
| 11.1 | Get win condition from game.game_mode |
| 11.2 | Call GameMode.check_win_condition(state) |
| 11.3 | If {:winner, team_id}, set state.winner and state.status = :finished |
| 11.4 | If {:draw}, set state.winner = :draw and state.status = :finished |
| 11.5 | If {:continue}, proceed to turn end |

**Condition-specific checks**:

| Condition | Check |
|-----------|-------|
| :elimination | Any team with 0 units loses |
| :rout | Team below threshold of starting units loses |
| :turn_limit | On max turn, compare scores |
| :objective_control | Team controlling required objectives wins |

**Asymmetric conditions**: For modes like siege, each team may have a different win condition. Check both independently.

### Phase 12: ROTATION APPLICATION

Apply rotation orders. Uses post-combat positions. **Orders are atomic**: units that balked do NOT rotate. Only units with successful moves or hold orders rotate.

### Phase 13: ENERGY & CLEANUP

| Action | Energy Change |
|--------|---------------|
| Move forward | -1 |
| Move backward | 0 |
| Hold (not attacked) | +1 |
| Hold (attacked) | 0 |
| Balk | 0 |

**Zero energy penalty**: See Open Questions - not yet decided.

Remove dead units. Increment turn counter.

---

## 5. State Changes by Phase

| Phase | Reads | Writes |
|-------|-------|--------|
| 1 Snapshot | `state.units`, `state.phalanxes`, `state.groups` | `snapshot` (ephemeral) |
| 2 Order Expansion | `snapshot`, `individual_orders`, `phalanx_orders`, `group_orders` | `expanded_orders` |
| 3 Validation | `expanded_orders`, `snapshot.units` | `validated_orders` |
| 4 Conflicts | `validated_orders`, `snapshot.units` | `conflicts` |
| 5 Support | `validated_orders`, `snapshot.units`, `conflicts` | `support_data` |
| 6 Strength | `conflicts`, `snapshot`, `support_data`, `snapshot.phalanxes` | `strengths` |
| 7 Resolution | `conflicts`, `strengths`, `snapshot.phalanxes` | `results` |
| 8 Movement | `results`, `validated_orders`, `state` | `state.units` |
| 9 Damage/Retreat | `results`, `validated_orders`, `snapshot`, `state` | `state.units` |
| 10 Phalanx Lifecycle | `state.phalanxes`, dead positions | `state.phalanxes` |
| 11 Win Check | `state.units`, `state.game_mode`, `state.mode_state` | `state.winner`, `state.status` |
| 12 Rotation | `validated_orders`, `state` | `state.units` |
| 13 Energy | `validated_orders`, `results`, `state` | `state.units`, `state.turn` |

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

### Example 4: Phalanx All-or-Nothing Balk

```
Before:
R1> R2> R3> [P]
(0,1)(1,1)(2,1)(3,1)

All R units are in a declared phalanx.

Orders:
  Phalanx: move E
  P: hold

After:
R1> R2> R3> [P]
(0,1)(1,1)(2,1)(3,1)

R3 would balk (blocked by P), so ALL phalanx members balk.
```

### Example 5: Support Cutting

```
Before:
    P1>
   (2,0)
     |
    SW
     v
R2> -> R1> -> <D
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

### Example 6: Loose Units vs Phalanx

```
Before:
R1> R2> R3>    <D
(0,1)(1,1)(2,1) (3,1)

R1, R2, R3 are in the same GROUP but NOT in a phalanx (loose units).

Orders:
  Group: move E
  D: hold

After:
    R1> R2> R3><D
   (1,1)(2,1)(3,1)(3,1)

R1 and R2 move. R3 balks (blocked by D).
Loose units do NOT trigger all-or-nothing rule.
R1, R2, R3 get NO formation bonus (not in a phalanx).
```

### Example 7: Form Phalanx Command

```
Before (during battle):
R1> R2> R3>
(0,1)(1,1)(2,1)

All units are in Group "Alpha", no phalanx declared.

Command: Form Phalanx with R1, R2, R3

Validation:
- All positions in same group: YES
- All units same rotation: YES (all facing E)
- All positions adjacent: YES (connected)

Result: Phalanx created with id="phalanx-1", group_id="alpha", positions={(0,1),(1,1),(2,1)}
```

---

## 7. What's the PR roadmap?

1. **PR #1: Unit struct and helpers**
   1. Extract `Phalanx.Unit` module from inline maps
   2. Add `apply_damage/2`, `apply_energy_delta/2`, `alive?/1`
   3. Update `Phalanx.Helpers.default_units/0` to use struct
   4. Update `Phalanx.Game` type to use `%Unit{}`

2. **PR #2: Group and Phalanx structs**
   1. Create `Phalanx.Group` struct with id, name, color, unit_positions
   2. Create `Phalanx.Phalanx` struct with id, group_id, positions, rotation
   3. Update `Phalanx.Game` to include groups, phalanxes, stage fields

3. **PR #3: Moves extension**
   1. Add `all_neighbors/1` to enumerate hex neighbors
   2. Add `opposite_direction/1`, `direction_from_hex/2`
   3. Tests for all 6 directions and rotations

4. **PR #4: Grouping system**
   1. Create `Phalanx.Grouping` module
   2. Implement `validate_group/2` (ownership validation)
   3. Implement `validate_phalanx_formation/3` (adjacency, rotation, group membership)
   4. Implement `form_phalanx/4`, `break_phalanx/2`
   5. Implement `update_phalanxes_after_deaths/2`
   6. Tests for phalanx lifecycle

5. **PR #5: Order expansion**
   1. Create `Phalanx.Orders.Expansion` module
   2. Implement `expand_orders/5` with precedence rules
   3. Implement `distribute_group_order/3`
   4. Tests for precedence and distribution

6. **PR #6: Strength calculation**
   1. Create `Phalanx.Strength` module
   2. Implement `classify_direction/2` for front/flank/rear
   3. Implement `count_formation_allies/3` (phalanx-only bonuses)
   4. Implement `calculate_attack_strength/4`, `calculate_defense_strength/2`
   5. Implement `flanking_bonus/2`
   6. Tests for formation scenarios, bonus caps

7. **PR #7: Combat support module**
   1. Create `Phalanx.Combat.Support`
   2. Implement `calculate_supports/2` with support graph
   3. Implement support cutting logic
   4. Tests for support relationships and cutting

8. **PR #8: Conflict detection**
   1. Create `Phalanx.Combat.Conflict`
   2. Implement `detect_conflicts/3`
   3. Implement `detect_swaps/1`, `detect_cycles/1`
   4. Tests for all conflict types

9. **PR #9: Combat resolution**
   1. Create `Phalanx.Combat.Resolution`
   2. Implement `resolve_conflicts/3` with strength comparison
   3. Implement `apply_phalanx_atomic_movement/2` (all-or-nothing)
   4. Tests for winner determination, ties, all-or-nothing rule

10. **PR #10: Damage and retreat**
    1. Create `Phalanx.Combat.Damage`
    2. Create `Phalanx.Combat.Retreat`
    3. Implement angle-based damage calculation
    4. Implement retreat hex validation and execution
    5. Tests for damage stacking, retreat selection, death on no retreat

11. **PR #11: Engine integration**
    1. Create `Phalanx.Engine.Combat`
    2. Implement 13-phase resolution algorithm
    3. Wire up all combat modules
    4. Integration tests for complete turn resolution

12. **PR #12: Energy and rotation**
    1. Add energy tracking to Unit
    2. Implement energy update logic (forward -1, backward 0, hold +1 if not attacked)
    3. Implement zero-energy penalty (-1 HP)
    4. Apply rotation after combat
    5. Cleanup: remove dead units, increment turn

13. **PR #13: Config switch and UI**
    1. Add config option: `:engine, Phalanx.Engine.Combat`
    2. Display health on unit SVG
    3. Display energy bar
    4. Add "Form Phalanx" UI command

---

## 8. What are open questions?

1. **Retreat selection**: Random selection from valid hexes, or player choice? Random is simpler; player choice requires async retreat phase.

2. **Planning stage UI**: How do players create groups before battle? Drag-select? Named group interface?

3. **Phalanx formation UI**: How do players issue "Form Phalanx" command during battle? Select units + button? Hotkey?

---

## References

For detailed design rationale, see:

- `plans/strength/spec.md` (Strength Calculation)
- `plans/group/spec.md` (Grouping Mechanics)
- `plans/combat/spec.md` (Combat Resolution)
- `plans/combat/resolution-order.md` (Resolution Algorithm)
- `plans/strength/design-decisions-summary.md` (Final Decisions)
- `plans/combat/test-scenarios.md` (Test Cases)
