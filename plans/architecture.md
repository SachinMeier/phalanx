# Phalanx Code Architecture

This document defines the code structure for the Phalanx game engine, domain models, and map system.

## Design Goals

1. **Granular testability**: Every module contains pure functions testable in isolation
2. **Composability**: Small modules compose into larger systems
3. **Extensibility**: Team/player model supports future 2v2, 3v3 modes
4. **Simplicity**: One unit type, sparse map representation, thin orchestrators

---

## Directory Structure

```
lib/phalanx/
├── application.ex              # OTP bootstrap
├── dynamic_supervisor.ex       # Game process supervisor
│
├── game.ex                     # GenServer: state + broadcasts
├── game/
│   └── queries.ex              # Player/team/unit lookup functions
│
├── team.ex                     # Team struct
├── player.ex                   # Player struct
├── unit.ex                     # Unit struct
├── order.ex                    # Order struct
│
├── hex.ex                      # Hex properties struct
├── map.ex                      # Map struct + queries
├── map/
│   ├── builder.ex              # Fluent builder DSL
│   └── parser.ex               # ASCII parser (optional)
├── maps.ex                     # Predefined map catalog
│
├── game_mode.ex                # GameMode struct
├── game_modes.ex               # Predefined game modes catalog
│
├── moves.ex                    # Movement validation
│
└── engine/
    ├── types.ex                # Shared type definitions
    ├── pipeline.ex             # Thin orchestrator (13 phases)
    │
    ├── phase/
    │   ├── snapshot.ex         # 1: Capture turn-start state
    │   ├── order_expansion.ex  # 2: Expand group/phalanx orders (precedence)
    │   ├── order_validation.ex # 3: Validate expanded orders
    │   ├── conflict_detection.ex# 4: Identify contested hexes
    │   ├── support.ex          # 5: Support graph + cutting
    │   ├── strength.ex         # 6: Calculate combat strength (phalanx bonuses)
    │   ├── resolution.ex       # 7: Determine winners/losers, atomic movement
    │   ├── movement.ex         # 8: Execute moves
    │   ├── damage.ex           # 9: Apply damage + retreats
    │   ├── phalanx_lifecycle.ex# 10: Update phalanxes after deaths
    │   ├── win_condition.ex    # 11: Check win conditions
    │   ├── rotation.ex         # 12: Apply rotations
    │   └── energy.ex           # 13: Energy + cleanup
    │
    └── hex/
        ├── direction.ex        # Direction classification
        └── neighbors.ex        # Neighbor enumeration

lib/phalanx_web/
├── live/
│   └── game.ex                 # Main game LiveView
├── components/
│   └── hex.ex                  # Hex grid rendering
└── ...
```

---

## Part 1: Domain Models

### Team

Alliance group. Players on the same team are allies (no friendly fire).

```elixir
defmodule Phalanx.Team do
  @type id :: :team_a | :team_b

  @type t :: %__MODULE__{
    id: id(),
    name: String.t()
  }

  defstruct [:id, :name]

  def team_a, do: %__MODULE__{id: :team_a, name: "Team A"}
  def team_b, do: %__MODULE__{id: :team_b, name: "Team B"}
end
```

### Player

A user session that controls units of one color.

```elixir
defmodule Phalanx.Player do
  @type t :: %__MODULE__{
    token: String.t(),
    name: String.t(),
    color: String.t(),       # "red", "purple", "blue", etc.
    team_id: Phalanx.Team.id()
  }

  defstruct [:token, :name, :color, :team_id]
end
```

### Unit

A game piece on the board.

```elixir
defmodule Phalanx.Unit do
  @type t :: %__MODULE__{
    name: String.t(),        # Display letter (Y, U, I, etc.)
    color: String.t(),       # Matches Player.color
    health: integer(),
    energy: integer(),
    rotation: integer()      # 0, 60, 120, 180, 240, 300
  }

  defstruct [:name, :color, :health, :energy, :rotation]
end
```

### Relationships

```
Team (1) ----< (N) Player (1) ----< (N) Unit
  |                   |                  |
team_id            color              color
```

- Team has many Players via `player.team_id`
- Player has many Units via `unit.color == player.color`

### Query Functions

```elixir
defmodule Phalanx.Game.Queries do
  @doc "Can this player control this unit?"
  def can_control?(game, player_token, unit) do
    case get_player(game, player_token) do
      %{color: color} -> unit.color == color
      nil -> false
    end
  end

  @doc "Are two units allies (same team)?"
  def allies?(game, unit_a, unit_b) do
    get_unit_team(game, unit_a) == get_unit_team(game, unit_b)
  end

  @doc "Get all colors controlled by a team"
  def team_colors(game, team_id) do
    game.players
    |> Enum.filter(&(&1.team_id == team_id))
    |> Enum.map(& &1.color)
  end
end
```

### Game State Examples

**1v1 Game:**
```elixir
%Game{
  teams: [Team.team_a(), Team.team_b()],
  players: [
    %Player{token: "abc", name: "Alice", color: "red", team_id: :team_a},
    %Player{token: "xyz", name: "Bob", color: "purple", team_id: :team_b}
  ]
}
```

**2v2 Game:**
```elixir
%Game{
  teams: [Team.team_a(), Team.team_b()],
  players: [
    %Player{token: "p1", name: "Alice", color: "red", team_id: :team_a},
    %Player{token: "p2", name: "Bob", color: "orange", team_id: :team_a},
    %Player{token: "p3", name: "Carol", color: "purple", team_id: :team_b},
    %Player{token: "p4", name: "Dave", color: "blue", team_id: :team_b}
  ]
}
```

In 2v2: Alice and Bob are allies. Their units (red + orange) get formation bonuses together. Neither can control the other's units.

---

## Part 2: Map System

> **Note**: Terrain is **future work**. V1 uses a uniform flat grid where all hexes are identical.
> See `plans/engine/terrain-system.md` for future terrain plans.

### Map Struct (V1 - Simplified)

For V1, the map is simply dimensions and spawn points. All hexes are passable and uniform.

```elixir
defmodule Phalanx.Map do
  @type position :: {non_neg_integer(), non_neg_integer()}

  @type t :: %__MODULE__{
    name: atom(),
    width: pos_integer(),
    height: pos_integer(),
    spawn_points: %{team_id() => [position()]}
  }

  defstruct name: :unnamed, width: 10, height: 10, spawn_points: %{}

  # Queries
  def in_bounds?(map, {x, y}), do: x >= 0 and x < map.width and y >= 0 and y < map.height
  def spawn_points(map, team), do: Map.get(map.spawn_points, team, [])
end
```

### Predefined Maps (V1)

```elixir
defmodule Phalanx.Maps do
  def get(:open_field), do: open_field()
  def list, do: [:open_field]

  def open_field do
    %Phalanx.Map{
      name: :open_field,
      width: 10,
      height: 10,
      spawn_points: %{
        team_a: [{3, 2}, {4, 2}, {5, 2}, {6, 2}, {7, 2}],
        team_b: [{3, 7}, {4, 7}, {5, 7}, {6, 7}, {7, 7}]
      }
    }
  end
end
```

### Future: Terrain Types

| Type | Passable | Formation | Status |
|------|----------|-----------|--------|
| `:plains` | Yes | Normal | **V1** (default, all hexes) |
| `:impassable` | No | N/A | Future |
| `:rough` | Yes | Breaks | Future |
| `:elevated` | Yes | Normal | Future |

See `plans/engine/terrain-system.md` for detailed terrain design (future work).

---

## Part 3: Engine Architecture

### Design Principles

1. **Pure functions**: Every phase is a pure function with explicit inputs/outputs
2. **Single responsibility**: One module per phase
3. **Composable data flow**: Output of phase N is input to phase N+1
4. **Testable atoms**: The smallest meaningful unit is independently testable

### Shared Types

```elixir
defmodule Phalanx.Engine.Types do
  @type position :: {non_neg_integer(), non_neg_integer()}
  @type direction :: :east | :west | :northeast | :northwest | :southeast | :southwest

  @type phalanx :: %{
    positions: MapSet.t(position()),
    rotation: non_neg_integer(),
    color: String.t(),
    move: direction() | nil
  }

  @type conflict ::
    {:destination_conflict, position(), [position()]}
    | {:attack, position(), position()}
    | {:swap, position(), position()}
    | {:cycle, [position()]}

  @type combat_result :: :move | :balk | :dislodged | :hold

  @type snapshot :: %{units: map(), turn: non_neg_integer()}
  @type support_data :: %{pushing: map(), cut: MapSet.t()}
  @type strengths :: %{position() => non_neg_integer()}
  @type results :: %{position() => combat_result()}
end
```

### Phase Modules

Each phase is independently testable with pure functions.

#### Phase 1: Snapshot

```elixir
defmodule Phalanx.Engine.Phase.Snapshot do
  @spec capture(game_state :: map()) :: Types.snapshot()
  def capture(game_state)
  # Deep copy units to guarantee immutability
end
```

#### Phase 2: Order Validation

```elixir
defmodule Phalanx.Engine.Phase.OrderValidation do
  @spec run(group_orders, snapshot, map_dimensions) :: %{position() => order()}
  def run(group_orders, snapshot, map_dimensions)

  # Atomic functions
  def validate_ownership(group_order, units)
  def expand_group_to_units(group_order)
  def validate_move(order, unit, map_dimensions)
  def populate_holds(orders, units)
end
```

#### Phase 3: Phalanx Detection

```elixir
defmodule Phalanx.Engine.Phase.PhalanxValidation do
  @spec validate(phalanxes, groups, units) :: {:ok, [Types.phalanx()]} | {:error, reason}
  def validate(phalanxes, groups, units)

  # Atomic functions
  def group_by_formation_key(orders, units)  # {color, rotation, move}
  def find_connected_components(positions)   # Flood-fill
  def positions_adjacent?(pos_a, pos_b)
end
```

#### Phase 4: Conflict Detection

```elixir
defmodule Phalanx.Engine.Phase.ConflictDetection do
  @spec detect(orders, units, map_dimensions) :: [Types.conflict()]
  def detect(orders, units, map_dimensions)

  # Atomic functions
  def compute_movements(orders, units, map_dimensions)
  def group_by_destination(movements)
  def classify_conflict(destination, origins, units)
  def detect_swaps(movements)
  def detect_cycles(movements)
end
```

#### Phase 5: Support

```elixir
defmodule Phalanx.Engine.Phase.Support do
  @spec calculate(orders, units, phalanxes, conflicts) :: Types.support_data()
  def calculate(orders, units, phalanxes, conflicts)

  # Atomic functions
  def find_pushing_supporters(position, move_direction, orders, units)
  def in_same_phalanx?(pos_a, pos_b, phalanxes)
  def extract_attack_targets(conflicts)
  def mark_cut_supports(pushing, targeted)
end
```

#### Phase 6: Strength

```elixir
defmodule Phalanx.Engine.Phase.Strength do
  @base_strength 1
  @max_support_bonus 2

  @spec calculate_all(conflicts, snapshot, orders, support_data, phalanxes) :: Types.strengths()
  def calculate_all(conflicts, snapshot, orders, support_data, phalanxes)

  # Atomic functions
  def calculate_attacker_strength(position, snapshot, orders, support_data, phalanxes)
  def calculate_defender_strength(position, snapshot, orders, phalanxes)
  def count_formation_allies(position, unit, units, orders)  # {side: n, rear: n}
  def count_valid_supporters(position, support_data)
end
```

#### Phase 7: Resolution

```elixir
defmodule Phalanx.Engine.Phase.Resolution do
  @spec resolve(conflicts, strengths, phalanxes) :: Types.results()
  def resolve(conflicts, strengths, phalanxes)

  # Atomic functions
  def resolve_single_conflict(conflict, strengths)
  def resolve_attack(attacker_pos, defender_pos, strengths)
  def resolve_destination_conflict(destination, origins, strengths)
  def apply_phalanx_atomic_movement(results, phalanxes)
end
```

#### Phase 8: Movement

```elixir
defmodule Phalanx.Engine.Phase.Movement do
  @spec execute(game_state, results, orders) :: map()
  def execute(game_state, results, orders)

  # Atomic functions
  def collect_successful_moves(results, orders)
  def apply_movements(units, movements)
end
```

#### Phase 9: Damage

```elixir
defmodule Phalanx.Engine.Phase.Damage do
  @spec apply(game_state, results, orders, snapshot) :: map()
  def apply(game_state, results, orders, snapshot)

  # Atomic functions
  def calculate_damage(defender_rotation, attack_direction)  # 0/1/2
  def classify_attack_angle(defender_rotation, attack_direction)  # :front/:flank/:rear
  def find_valid_retreats(game_state, defender_pos, attacker_pos, standoffs)
  def execute_retreat(game_state, dislodged_pos, retreat_hex)
  def apply_damage_to_unit(unit, damage)
end
```

#### Phase 10: Phalanx Lifecycle

```elixir
defmodule Phalanx.Engine.Phase.PhalanxLifecycle do
  @spec update(game_state, dead_positions) :: map()
  def update(game_state, dead_positions)

  # Atomic functions
  def remove_dead_from_phalanxes(phalanxes, dead_positions)
  def check_adjacency(phalanx)
  def dissolve_broken_phalanxes(phalanxes)
end
```

#### Phase 11: Win Condition

```elixir
defmodule Phalanx.Engine.Phase.WinCondition do
  @spec check(game_state) :: {:continue} | {:winner, atom()} | {:draw}
  def check(game_state)

  # Atomic functions
  def check_elimination(game_state)
  def check_rout(game_state, threshold)
  def check_objective(game_state, required_turns)
  def count_team_units(game_state, team_id)
end
```

#### Phase 12: Rotation

```elixir
defmodule Phalanx.Engine.Phase.Rotation do
  @spec apply(game_state, orders) :: map()
  def apply(game_state, orders)

  # Atomic functions
  def apply_rotation(current, :clockwise)        # +60 mod 360
  def apply_rotation(current, :counterclockwise) # -60 mod 360
end
```

#### Phase 13: Energy

```elixir
defmodule Phalanx.Engine.Phase.Energy do
  @max_energy 3

  @spec finalize(game_state, orders, results, attacks) :: map()
  def finalize(game_state, orders, results, attacks)

  # Atomic functions
  def calculate_energy_delta(order, result, was_attacked, unit_rotation)
  def is_forward_move?(move_direction, unit_rotation)
  def apply_zero_energy_penalty(units)
  def remove_dead_units(units)
  def increment_turn(game_state)
end
```

### Pipeline Orchestrator

Thin composition only. All logic lives in phase modules.

```elixir
defmodule Phalanx.Engine.Pipeline do
  @behaviour Phalanx.Engine

  alias Phalanx.Engine.Phase.{
    Snapshot, OrderValidation, PhalanxDetection, ConflictDetection,
    Support, Strength, Resolution, Movement, Damage, PhalanxLifecycle,
    WinCondition, Rotation, Energy
  }

  @impl true
  def execute_orders(game_state, user_group_orders) do
    snapshot = Snapshot.capture(game_state)
    orders = OrderValidation.run(user_group_orders, snapshot, game_state.map)
    phalanxes = PhalanxDetection.detect(orders, snapshot.units)
    conflicts = ConflictDetection.detect(orders, snapshot.units, game_state.map)
    support_data = Support.calculate(orders, snapshot.units, phalanxes, conflicts)
    strengths = Strength.calculate_all(conflicts, snapshot, orders, support_data, phalanxes)
    results = Resolution.resolve(conflicts, strengths, phalanxes)

    attacks = Support.extract_attack_targets(conflicts)

    game_state
    |> Movement.execute(results, orders)
    |> Damage.apply(results, orders, snapshot)
    |> Rotation.apply(orders)
    |> Energy.finalize(orders, results, attacks)
  end
end
```

### Hex Utilities

```elixir
defmodule Phalanx.Engine.Hex.Direction do
  def opposite(:east), do: :west
  def opposite(:northeast), do: :southwest
  # ...
  def direction_from_positions(from, to)
  def classify_relative_to_facing(rotation, direction)  # :front/:flank/:rear
  def rotation_to_facing_direction(rotation)
end

defmodule Phalanx.Engine.Hex.Neighbors do
  def all(position)  # [{direction, position}, ...]
  def in_direction(position, direction)
  def adjacent?(pos_a, pos_b)
end
```

### Data Flow

```
game_state, orders
    │
    ▼
[Snapshot] ──────────────────────────────────────────────▶ snapshot
    │
    ▼
[OrderExpansion] ─────────────────────────────────────────▶ expanded orders (precedence applied)
    │
    ▼
[OrderValidation] ───────────────────────────────────────▶ validated orders
    │
    ▼
[PhalanxValidation] ─────────────────────────────────────▶ validated phalanxes (from game state)
    │
    ▼
[ConflictDetection] ─────────────────────────────────────▶ conflicts
    │
    ▼
[Support] ───────────────────────────────────────────────▶ support_data
    │
    ▼
[Strength] ──────────────────────────────────────────────▶ strengths
    │
    ▼
[Resolution] ────────────────────────────────────────────▶ results
    │
    ▼
[Movement] ──────────────────────────────────────────────▶ state_1
    │
    ▼
[Damage] ────────────────────────────────────────────────▶ state_2
    │
    ▼
[Rotation] ──────────────────────────────────────────────▶ state_3
    │
    ▼
[Energy] ────────────────────────────────────────────────▶ final_state
```

---

## Part 4: Updated Game Struct

```elixir
defmodule Phalanx.Game do
  @type t :: %__MODULE__{
    id: String.t(),
    status: :lobby | :playing | :finished,
    turn: non_neg_integer(),
    teams: [Phalanx.Team.t()],
    players: [Phalanx.Player.t()],
    units: %{Phalanx.Map.position() => Phalanx.Unit.t()},
    map: Phalanx.Map.t(),

    # Game Mode fields
    game_mode: atom(),           # :elimination_standard, :siege_basic, etc.
    mode_state: map(),           # Runtime state for win condition tracking
    winner: nil | :team_a | :team_b | :draw,
    starting_unit_counts: %{team_a: integer(), team_b: integer()}  # For rout calculation
  }

  defstruct [:id, :status, :turn, :teams, :players, :units, :map,
             :game_mode, :mode_state, :winner, :starting_unit_counts]
end
```

---

## Part 5: Game Mode System

### GameMode Struct

Defines win conditions and team configuration for a game variant.

```elixir
defmodule Phalanx.GameMode do
  @type win_condition ::
    :elimination           # Destroy all enemy units
    | :rout                # Enemy loses N% of starting units
    | :objective           # Control victory hexes

  @type t :: %__MODULE__{
    id: atom(),
    name: String.t(),
    win_conditions: [win_condition()],
    rout_threshold: float() | nil,     # e.g., 0.5 for 50%
    objective_turns: integer() | nil,  # Turns to hold objective
    max_turns: integer() | nil         # Turn limit (nil = unlimited)
  }

  defstruct [:id, :name, :win_conditions, :rout_threshold, :objective_turns, :max_turns]

  @spec check_win_condition(Phalanx.Game.t()) :: {:continue} | {:winner, Phalanx.Team.id()} | {:draw}
  def check_win_condition(game)
  # Evaluates all win_conditions for the game's mode
  # Returns first satisfied condition or :continue
end
```

### GameModes Catalog

Predefined game modes, similar to Maps catalog.

```elixir
defmodule Phalanx.GameModes do
  def get(:elimination_standard), do: elimination_standard()
  def get(:siege_basic), do: siege_basic()
  def list, do: [:elimination_standard, :siege_basic]

  def elimination_standard do
    %GameMode{
      id: :elimination_standard,
      name: "Standard Elimination",
      win_conditions: [:elimination],
      rout_threshold: nil,
      objective_turns: nil,
      max_turns: nil
    }
  end

  def siege_basic do
    %GameMode{
      id: :siege_basic,
      name: "Siege",
      win_conditions: [:objective, :elimination],
      rout_threshold: nil,
      objective_turns: 3,
      max_turns: 30
    }
  end
end
```

### Win Condition Check

Called at the end of each turn in the engine pipeline.

```elixir
defmodule Phalanx.GameMode do
  def check_win_condition(%{game_mode: mode_id} = game) do
    mode = GameModes.get(mode_id)
    check_conditions(game, mode.win_conditions, mode)
  end

  defp check_conditions(game, [:elimination | rest], mode) do
    case check_elimination(game) do
      {:winner, team} -> {:winner, team}
      :continue -> check_conditions(game, rest, mode)
    end
  end

  defp check_conditions(game, [:rout | rest], mode) do
    case check_rout(game, mode.rout_threshold) do
      {:winner, team} -> {:winner, team}
      :continue -> check_conditions(game, rest, mode)
    end
  end

  defp check_conditions(game, [:objective | rest], mode) do
    case check_objective(game, mode.objective_turns) do
      {:winner, team} -> {:winner, team}
      :continue -> check_conditions(game, rest, mode)
    end
  end

  defp check_conditions(_game, [], _mode), do: {:continue}

  defp check_elimination(game) do
    team_a_units = count_team_units(game, :team_a)
    team_b_units = count_team_units(game, :team_b)

    cond do
      team_a_units == 0 and team_b_units == 0 -> {:draw}
      team_a_units == 0 -> {:winner, :team_b}
      team_b_units == 0 -> {:winner, :team_a}
      true -> :continue
    end
  end
end
```

### Pipeline Integration

The win condition check runs after the Energy phase.

```elixir
defmodule Phalanx.Engine.Pipeline do
  def execute_orders(game_state, user_group_orders) do
    # ... existing phases ...

    final_state =
      game_state
      |> Movement.execute(results, orders)
      |> Damage.apply(results, orders, snapshot)
      |> Rotation.apply(orders)
      |> Energy.finalize(orders, results, attacks)

    # Check win condition
    case GameMode.check_win_condition(final_state) do
      {:continue} ->
        final_state

      {:winner, team_id} ->
        %{final_state | status: :finished, winner: team_id}

      {:draw} ->
        %{final_state | status: :finished, winner: :draw}
    end
  end
end
```

### Mode State Tracking

For objective-based modes, `mode_state` tracks progress.

```elixir
# Example mode_state for siege mode
%{
  objective_control: %{
    team_a: 2,  # Team A has held objectives for 2 turns
    team_b: 0
  }
}
```

**Note**: Game mode selection is not exposed to the frontend initially. The backend hardcodes `:elimination_standard` on game creation.

---

## Testing Strategy

| Module | Test approach |
|--------|---------------|
| `Snapshot` | Verify deep copy, immutability |
| `OrderValidation` | Test each atomic function separately |
| `PhalanxDetection` | Test grouping, flood-fill on various layouts |
| `ConflictDetection` | Test each conflict type independently |
| `Support` | Test supporter finding, phalanx exclusion, cutting |
| `Strength` | Test formation counting, support bonus, caps |
| `Resolution` | Test each conflict type, atomic phalanx movement |
| `Movement` | Test position updates |
| `Damage` | Test angle classification, damage, retreats |
| `Rotation` | Test clockwise/counterclockwise math |
| `Energy` | Test delta calculation, penalty, cleanup |
| `Pipeline` | Integration tests with full scenarios |

**Key**: Each atomic function is testable with constructed map inputs. No mocks needed.

---

## Migration Path

1. Add new structs: `Team`, `Unit`, `Hex`, `Map`
2. Add `Map.Builder`, `Maps` catalog
3. Update `Player` with `team_id` field
4. Update `Game` struct with `teams`, `map` fields
5. Add `Game.Queries` module
6. Create engine phase modules (one at a time, bottom-up)
7. Wire up `Pipeline` as new engine implementation
8. Update config to use `Pipeline` instead of `Diplomacy`
9. Remove old `Engine.Diplomacy`

---

## Estimated Module Sizes

| Module | LOC |
|--------|-----|
| `team.ex` | ~15 |
| `player.ex` | ~15 |
| `unit.ex` | ~15 |
| `hex.ex` | ~30 |
| `map.ex` | ~80 |
| `map/builder.ex` | ~50 |
| `maps.ex` | ~60 |
| `game_mode.ex` | ~80 |
| `game_modes.ex` | ~40 |
| `game/queries.ex` | ~40 |
| `engine/types.ex` | ~60 |
| `engine/pipeline.ex` | ~50 |
| `engine/phase/*` | ~800 total |
| `engine/hex/*` | ~90 |
| **Total new code** | ~1425 |

Small modules. Easy to understand. Easy to test.

---

## Part 6: Project Breakdown

### Project 1: Domain Models

**Goal**: Establish Team/Player/Unit hierarchy with query functions.

| Feature | Description |
|---------|-------------|
| 1.1 Team struct | `id`, `name` fields; `team_a/0`, `team_b/0` constructors |
| 1.2 Player struct | Add `team_id` and `color` fields to existing struct |
| 1.3 Unit struct | Extract unit map to proper struct with `color`, `health`, `energy`, `rotation` |
| 1.4 Game.Queries | `can_control?/3`, `allies?/3`, `team_colors/2`, `get_player/2`, `get_player_by_color/2` |
| 1.5 Update Game struct | Add `teams` field, update `players` to use new Player struct |
| 1.6 Migrate existing code | Update all references to old unit maps and player structs |

**Dependencies**: None (foundational)

---

### Project 2: Map System

**Goal**: Replace `map_dimensions` tuple with Map struct. V1 uses flat uniform grid (terrain is future work).

| Feature | Description |
|---------|-------------|
| 2.1 Map struct | `name`, `width`, `height`, `spawn_points` fields |
| 2.2 Map queries | `in_bounds?/2`, `spawn_points/2` |
| 2.3 Maps catalog | Predefined maps: `:open_field` (single map for V1) |
| 2.4 Update Moves module | Accept `Map.t()` instead of `{width, height}` tuple |
| 2.5 Update Game struct | Replace `map_dimensions` with `map` field |
| 2.6 Update Helpers | Use `Maps.get(:open_field)` for default game setup |

**Note**: Terrain (impassable, rough, elevated) is future work. See `plans/engine/terrain-system.md`.

**Dependencies**: None (can be done parallel to Project 1)

---

### Project 3: Hex Utilities

**Goal**: Extract reusable hex grid math from Moves module into engine utilities.

| Feature | Description |
|---------|-------------|
| 3.1 Hex.Neighbors | `all/1` (returns all 6 neighbors), `in_direction/2`, `adjacent?/2` |
| 3.2 Hex.Direction | `opposite/1`, `direction_from_positions/2`, `classify_relative_to_facing/2`, `rotation_to_facing_direction/1` |
| 3.3 Refactor Moves | Use new Hex utilities internally |

**Dependencies**: None (foundational for engine)

---

### Project 4: Engine Types & Snapshot

**Goal**: Establish shared types and immutable snapshot capture.

| Feature | Description |
|---------|-------------|
| 4.1 Engine.Types | Define `position`, `direction`, `phalanx`, `conflict`, `combat_result`, `snapshot`, `support_data`, `strengths`, `results` types |
| 4.2 Phase.Snapshot | `capture/1` - deep copy game state for immutable reference |

**Dependencies**: Project 1 (Unit struct), Project 2 (Map struct)

---

### Project 5: Order Validation Phase

**Goal**: Validate user orders, expand groups to per-unit orders, populate holds.

| Feature | Description |
|---------|-------------|
| 5.1 validate_ownership | Check all positions in group belong to same player |
| 5.2 expand_group_to_units | Convert one group order to list of per-unit orders |
| 5.3 validate_move | Check move is legal for unit's rotation and map bounds |
| 5.4 populate_holds | Add null orders for units without explicit orders |
| 5.5 run/3 | Compose above functions into phase |

**Dependencies**: Project 2 (Map queries), Project 3 (Hex utilities), Project 4 (Types)

---

### Project 6: Phalanx Formation Phase

**Goal**: Validate and manage explicitly declared phalanxes (within groups, adjacent, same rotation).

| Feature | Description |
|---------|-------------|
| 6.1 group_by_formation_key | Group positions by `{color, rotation, move_direction}` |
| 6.2 positions_adjacent? | Check if two hex positions share an edge |
| 6.3 find_connected_components | Flood-fill to find clusters of adjacent positions |
| 6.4 detect/2 | Compose above; filter to min size 2 |

**Dependencies**: Project 3 (Hex.Neighbors), Project 4 (Types)

---

### Project 7: Conflict Detection Phase

**Goal**: Identify all contested hexes (attacks, destination conflicts, swaps, cycles).

| Feature | Description |
|---------|-------------|
| 7.1 compute_movements | Calculate `{origin, destination}` for all orders with moves |
| 7.2 group_by_destination | Group movements by target hex |
| 7.3 classify_conflict | Determine conflict type for each contested hex |
| 7.4 detect_swaps | Find A→B, B→A patterns |
| 7.5 detect_cycles | Find A→B→C→A patterns (3+ units) |
| 7.6 detect/3 | Compose above into full conflict list |

**Dependencies**: Project 2 (Map queries), Project 3 (Hex utilities), Project 4 (Types)

---

### Project 8: Support Phase

**Goal**: Build pushing support graph and mark cut supports.

| Feature | Description |
|---------|-------------|
| 8.1 find_pushing_supporters | Find allies behind position moving same direction |
| 8.2 in_same_phalanx? | Check if two positions are in same declared phalanx |
| 8.3 extract_attack_targets | Get all positions being attacked from conflicts |
| 8.4 mark_cut_supports | Identify supporters who are themselves under attack |
| 8.5 calculate/4 | Compose above into support_data struct |

**Dependencies**: Project 6 (Phalanx detection), Project 7 (Conflict detection)

---

### Project 9: Strength Phase

**Goal**: Calculate combat strength (base + formation + support).

| Feature | Description |
|---------|-------------|
| 9.1 count_formation_allies | Count side allies (max 2) and rear allies (no cap) |
| 9.2 count_valid_supporters | Count pushing supporters minus cut ones (max 2) |
| 9.3 calculate_attacker_strength | Base + formation + support |
| 9.4 calculate_defender_strength | Base + formation (no support) |
| 9.5 calculate_all/5 | Calculate strengths for all combatants |

**Dependencies**: Project 6 (Phalanx detection), Project 8 (Support data)

---

### Project 10: Resolution Phase

**Goal**: Compare strengths, determine winners/losers, apply phalanx atomic movement.

| Feature | Description |
|---------|-------------|
| 10.1 resolve_attack | Strictly greater wins; ties favor defender |
| 10.2 resolve_destination_conflict | Highest strength wins; ties = all balk |
| 10.3 resolve_swap | Both units compare strengths |
| 10.4 resolve_cycle | All units in cycle balk |
| 10.5 apply_phalanx_atomic_movement | If ANY phalanx member balks, entire phalanx balks |
| 10.6 resolve/3 | Compose above into results map |

**Dependencies**: Project 6 (Phalanx detection), Project 9 (Strengths)

---

### Project 11: Movement Phase

**Goal**: Execute successful moves, update unit positions.

| Feature | Description |
|---------|-------------|
| 11.1 collect_successful_moves | Filter results for `:move` outcomes |
| 11.2 apply_movements | Update units map with new positions |
| 11.3 execute/3 | Compose above |

**Dependencies**: Project 10 (Resolution results)

---

### Project 12: Damage & Retreat Phase

**Goal**: Apply damage based on attack angle, execute retreats.

| Feature | Description |
|---------|-------------|
| 12.1 classify_attack_angle | Determine `:front`, `:flank`, or `:rear` from rotation and attack direction |
| 12.2 calculate_damage | Front=0, flank=1, rear=2 |
| 12.3 find_valid_retreats | Find empty hexes away from attacker, not standoff hexes |
| 12.4 execute_retreat | Move dislodged unit or destroy if no valid retreat |
| 12.5 apply_damage_to_unit | Subtract damage from health |
| 12.6 apply/4 | Compose above |

**Dependencies**: Project 3 (Hex.Direction), Project 10 (Resolution results)

---

### Project 13: Rotation Phase

**Goal**: Apply rotation orders to units with successful moves or hold orders. Orders are atomic: balked units do NOT rotate.

| Feature | Description |
|---------|-------------|
| 13.1 apply_rotation | `:clockwise` = +60 mod 360, `:counterclockwise` = -60 mod 360 |
| 13.2 apply/2 | Apply rotations to all units with rotation orders |

**Dependencies**: Project 4 (Snapshot - for original orders)

---

### Project 14: Energy Phase

**Goal**: Update energy, apply zero-energy penalty, remove dead units.

| Feature | Description |
|---------|-------------|
| 14.1 is_forward_move? | Check if move direction is "forward" relative to facing |
| 14.2 calculate_energy_delta | Forward=-1, backward=0, hold(not attacked)=+1, hold(attacked)=0 |
| 14.3 apply_zero_energy_penalty | TBD: -1 HP or reduced strength |
| 14.4 remove_dead_units | Filter out units with health <= 0 |
| 14.5 increment_turn | Bump turn counter |
| 14.6 finalize/4 | Compose above into final state |

**Dependencies**: Project 3 (Hex.Direction), Project 10 (Resolution results)

---

### Project 15: Pipeline Integration

**Goal**: Wire all phases together into single `execute_orders/2` function.

| Feature | Description |
|---------|-------------|
| 15.1 Engine.Pipeline | Implement `Phalanx.Engine` behaviour |
| 15.2 Phase composition | Call phases 1-13 in sequence, passing outputs as inputs |
| 15.3 Config switch | Update config to use Pipeline instead of Diplomacy |
| 15.4 Remove old engine | Delete `Engine.Diplomacy` after migration |

**Dependencies**: Projects 4-14 (all phases)

---

### Project 16: Integration Tests

**Goal**: End-to-end scenarios validating full engine pipeline.

| Feature | Description |
|---------|-------------|
| 16.1 Basic movement | Units move without conflict |
| 16.2 Destination conflicts | Multiple units target same hex |
| 16.3 Attack scenarios | Attacker vs defender strength comparison |
| 16.4 Phalanx formation | Formation bonuses apply correctly |
| 16.5 Support mechanics | Pushing support adds strength, cutting works |
| 16.6 Flanking damage | Attack angle affects damage dealt |
| 16.7 Retreat mechanics | Dislodged units retreat correctly |
| 16.8 Atomic movement | Phalanx balks when ANY member would balk |
| 16.9 Energy system | Energy changes per move type |
| 16.10 Edge cases | Swaps, cycles, combined attacks, no valid retreat |

**Dependencies**: Project 15 (Pipeline)

---

### Project 17: LiveView Updates

**Goal**: Update UI to work with new domain models and engine.

| Feature | Description |
|---------|-------------|
| 17.1 Update hex rendering | Pass Map struct to hex component |
| 17.2 Update order collection | Use new Order struct |
| 17.3 Player control validation | Use `can_control?/3` for input validation |
| 17.4 Team display | Show team affiliation in UI |
| 17.5 Energy display | Show unit energy in hex |

**Note**: Terrain rendering is future work. V1 uses uniform flat grid.

**Dependencies**: Projects 1, 2, 15

---

### Project 18: Game Flow Updates

**Goal**: Update lobby, join, and game lifecycle to support new model.

| Feature | Description |
|---------|-------------|
| 18.1 Map selection | Allow map choice when creating game |
| 18.2 Team assignment | Assign players to teams on join |
| 18.3 Color assignment | Assign unique color to each player |
| 18.4 Ready system | Players mark ready, game starts when all ready |
| 18.5 Win condition | Detect when one team has no units or controls victory hexes |

**Dependencies**: Projects 1, 2, 17

---

### Project 19: Game Mode System

**Goal**: Define game modes with configurable win conditions.

| Feature | Description |
|---------|-------------|
| 19.1 GameMode struct | Define game mode type with `id`, `name`, `win_conditions`, thresholds |
| 19.2 GameModes catalog | Predefined modes: `:elimination_standard`, `:siege_basic` |
| 19.3 check_win_condition/1 | Evaluate win conditions, return `{:continue}`, `{:winner, team}`, or `{:draw}` |
| 19.4 Game struct updates | Add `game_mode`, `mode_state`, `winner`, `starting_unit_counts` fields |
| 19.5 Pipeline integration | Call win condition check after Energy phase |
| 19.6 Default mode | Hardcode `:elimination_standard` on game creation |

**Dependencies**: Projects 1, 2

**Note**: Game mode selection UI is not exposed initially. Backend hardcodes the default mode.

---

## Project Dependency Graph

```
                    ┌─────────────────────────────────────────────────────┐
                    │                   FOUNDATIONAL                       │
                    │                                                     │
                    │   [1. Domain Models]    [2. Map System]             │
                    │          │                    │                      │
                    │          │   [19. Game Mode]  │                      │
                    │          │         │          │                      │
                    │          └────┬────┴──────────┘                      │
                    │               │                                      │
                    │         [3. Hex Utilities]                           │
                    │               │                                      │
                    │      [4. Types & Snapshot]                           │
                    └─────────────────────────────────────────────────────┘
                                        │
                    ┌─────────────────────────────────────────────────────┐
                    │                 ENGINE PHASES                        │
                    │                                                     │
                    │            [5. Order Validation]                     │
                    │                   │                                  │
                    │       ┌───────────┴───────────┐                      │
                    │       │                       │                      │
                    │ [6. Phalanx Detection]  [7. Conflict Detection]      │
                    │       │                       │                      │
                    │       └───────────┬───────────┘                      │
                    │                   │                                  │
                    │            [8. Support]                              │
                    │                   │                                  │
                    │            [9. Strength]                             │
                    │                   │                                  │
                    │           [10. Resolution]                           │
                    │                   │                                  │
                    │       ┌───────────┼───────────┐                      │
                    │       │           │           │                      │
                    │ [11. Movement] [12. Damage] [13. Rotation]           │
                    │       │           │           │                      │
                    │       └───────────┼───────────┘                      │
                    │                   │                                  │
                    │            [14. Energy]                              │
                    └─────────────────────────────────────────────────────┘
                                        │
                    ┌─────────────────────────────────────────────────────┐
                    │                  INTEGRATION                         │
                    │                                                     │
                    │            [15. Pipeline]                            │
                    │                   │                                  │
                    │         [16. Integration Tests]                      │
                    │                   │                                  │
                    │       ┌───────────┴───────────┐                      │
                    │       │                       │                      │
                    │ [17. LiveView Updates]  [18. Game Flow]              │
                    └─────────────────────────────────────────────────────┘
```

---

## Suggested Build Order

| Phase | Projects | Description |
|-------|----------|-------------|
| **Phase A** | 1, 2, 3, 19 | Foundational structs (parallel) |
| **Phase B** | 4, 5 | Types and order validation |
| **Phase C** | 6, 7 | Detection phases (parallel) |
| **Phase D** | 8, 9, 10 | Combat calculation |
| **Phase E** | 11, 12, 13, 14 | State mutation phases (parallel) |
| **Phase F** | 15, 16 | Pipeline and tests |
| **Phase G** | 17, 18 | UI integration |

**Estimated scope**: ~19 projects, ~1425 LOC new code
