# [2026-01-31]: Game Mode System

**Author**:
**Approved By**:

---

## 1. What's the problem you're trying to solve?

**Casual**: Players need to start games that end when someone wins. Right now, games have no win condition. We need a system that knows when the game is over and who won.

**Formal**:

1. No win condition checking exists in the engine pipeline
2. No data structure defines what "winning" means for a game
3. Future modes (siege, quick battle) require asymmetric rules the current architecture cannot express
4. Map requirements are implicit in `Helpers.default_game/0`, not configurable per mode

**Out of Scope**:

* **Frontend mode selection UI**: Backend-only in this phase
* **New win condition types**: Only `:elimination` implemented now; `:objective_control`, `:rout`, `:turn_limit` defined but not wired
* **Map system**: Separate spec; this references map requirements but does not implement terrain
* **Unit composition variance**: All modes use homogeneous units for now

---

## 2. What's the simplest solution to solve the problem?

The main parts of the solution are:

1. **GameMode struct**: Defines win conditions, team configuration, map requirements for each mode
2. **Predefined modes catalog**: `:elimination_standard`, `:elimination_quick`, `:siege_basic`
3. **Win condition check phase**: New engine phase after damage that checks for game end
4. **Game struct integration**: Add `game_mode`, `game_mode_state`, `winner` fields

Win conditions live inside mode definitions. Each team can have different win conditions (asymmetric).

---

## 3. Which key code changes do you need to make (files, type/fn/service signatures)?

+++ #### GameMode

Core mode definition. Immutable config per mode.

`lib/phalanx/game_mode.ex`

```elixir
defmodule Phalanx.GameMode do
  @type win_condition_type :: :elimination | :objective_control | :rout | :turn_limit

  @type win_condition_config :: %{
    type: win_condition_type(),
    # For :rout
    threshold: float() | nil,
    # For :turn_limit (team must survive N turns)
    turns_required: pos_integer() | nil,
    # For :objective_control
    objective_positions: [Phalanx.Map.position()] | nil,
    hold_turns: pos_integer() | nil
  }

  @type team_config :: %{
    unit_count: pos_integer(),
    spawn_rows: Range.t()
  }

  @type map_requirements :: %{
    min_width: pos_integer(),
    min_height: pos_integer(),
    max_width: pos_integer() | nil,
    max_height: pos_integer() | nil,
    required_features: [:spawn_points | :objectives]
  }

  @type t :: %__MODULE__{
    id: atom(),
    name: String.t(),
    description: String.t(),
    win_conditions: %{
      team_a: win_condition_config(),
      team_b: win_condition_config()
    },
    team_config: %{
      team_a: team_config(),
      team_b: team_config()
    },
    map_requirements: map_requirements(),
    max_turns: pos_integer() | nil,
    hidden_from_ui: boolean()
  }

  defstruct [
    :id,
    :name,
    :description,
    :win_conditions,
    :team_config,
    :map_requirements,
    :max_turns,
    hidden_from_ui: true
  ]
end
```

+++

+++ #### GameModes

Predefined mode catalog. Pure data, no logic.

`lib/phalanx/game_modes.ex`

```elixir
defmodule Phalanx.GameModes do
  alias Phalanx.GameMode

  @spec get(atom()) :: GameMode.t() | nil
  def get(mode_id)

  @spec default() :: atom()
  def default, do: :elimination_standard

  @spec list_visible() :: [GameMode.t()]
  def list_visible

  @spec list_all() :: [GameMode.t()]
  def list_all
end
```

**Predefined modes:**

```elixir
# :elimination_standard
%GameMode{
  id: :elimination_standard,
  name: "Standard Battle",
  description: "5v5 symmetric elimination",
  win_conditions: %{
    team_a: %{type: :elimination},
    team_b: %{type: :elimination}
  },
  team_config: %{
    team_a: %{unit_count: 5, spawn_rows: 7..8},
    team_b: %{unit_count: 5, spawn_rows: 1..2}
  },
  map_requirements: %{
    min_width: 10,
    min_height: 10,
    max_width: nil,
    max_height: nil,
    required_features: [:spawn_points]
  },
  max_turns: nil,
  hidden_from_ui: false
}

# :elimination_quick
%GameMode{
  id: :elimination_quick,
  name: "Quick Battle",
  description: "3v3 on 8x8 grid",
  win_conditions: %{
    team_a: %{type: :elimination},
    team_b: %{type: :elimination}
  },
  team_config: %{
    team_a: %{unit_count: 3, spawn_rows: 6..7},
    team_b: %{unit_count: 3, spawn_rows: 0..1}
  },
  map_requirements: %{
    min_width: 8,
    min_height: 8,
    max_width: 8,
    max_height: 8,
    required_features: [:spawn_points]
  },
  max_turns: 15,
  hidden_from_ui: true
}

# :siege_basic
%GameMode{
  id: :siege_basic,
  name: "Siege",
  description: "7 attackers vs 4 defenders. Defender survives 12 turns to win.",
  win_conditions: %{
    team_a: %{type: :elimination},  # Attacker: destroy all defenders
    team_b: %{type: :turn_limit, turns_required: 12}  # Defender: survive
  },
  team_config: %{
    team_a: %{unit_count: 7, spawn_rows: 7..9},
    team_b: %{unit_count: 4, spawn_rows: 0..2}
  },
  map_requirements: %{
    min_width: 10,
    min_height: 10,
    max_width: nil,
    max_height: nil,
    required_features: [:spawn_points]
  },
  max_turns: 12,
  hidden_from_ui: true
}
```

+++

+++ #### GameModeState

Runtime state for win condition tracking. Mutable per game.

`lib/phalanx/game_mode_state.ex`

```elixir
defmodule Phalanx.GameModeState do
  @type t :: %__MODULE__{
    starting_unit_counts: %{team_a: non_neg_integer(), team_b: non_neg_integer()},
    objective_control: %{Phalanx.Map.position() => %{
      controller: :team_a | :team_b | nil,
      held_turns: non_neg_integer()
    }} | nil
  }

  defstruct [
    starting_unit_counts: %{team_a: 0, team_b: 0},
    objective_control: nil
  ]

  @spec init(game_mode :: Phalanx.GameMode.t(), units :: map()) :: t()
  def init(game_mode, units)
end
```

+++

+++ #### WinCondition

Win condition checking logic. Stateless evaluation.

`lib/phalanx/engine/phase/win_condition.ex`

```elixir
defmodule Phalanx.Engine.Phase.WinCondition do
  alias Phalanx.{GameMode, GameModeState, Team}

  @type check_result ::
    {:continue, GameModeState.t()} |
    {:winner, Team.id()} |
    {:draw}

  @spec check(
    game_mode :: GameMode.t(),
    game_mode_state :: GameModeState.t(),
    units :: map(),
    turn :: non_neg_integer()
  ) :: check_result()
  def check(game_mode, game_mode_state, units, turn)

  # Per-type checkers (internal)
  @spec check_elimination(units :: map(), team_id :: Team.id()) :: boolean()
  def check_elimination(units, team_id)

  @spec check_turn_limit(turn :: non_neg_integer(), turns_required :: pos_integer()) :: boolean()
  def check_turn_limit(turn, turns_required)

  @spec check_rout(
    units :: map(),
    starting_counts :: map(),
    team_id :: Team.id(),
    threshold :: float()
  ) :: boolean()
  def check_rout(units, starting_counts, team_id, threshold)
end
```

+++

+++ #### Game (updated)

Integration with existing Game struct.

`lib/phalanx/game.ex`

```elixir
defmodule Phalanx.Game do
  @type t :: %__MODULE__{
    # Existing fields
    id: String.t(),
    status: :waiting | :playing | :finished,
    turn: non_neg_integer(),
    players: list(Phalanx.Player.t()),
    units: map(),
    map_dimensions: {pos_integer(), pos_integer()},

    # New fields
    game_mode: atom(),  # References GameModes.get/1
    game_mode_state: Phalanx.GameModeState.t(),
    winner: :team_a | :team_b | :draw | nil
  }

  defstruct [
    :id,
    :status,
    :turn,
    :players,
    :units,
    :map_dimensions,
    game_mode: :elimination_standard,
    game_mode_state: %Phalanx.GameModeState{},
    winner: nil
  ]

  @spec new_game(String.t(), atom()) :: t()
  def new_game(id, game_mode_id \\ :elimination_standard)
end
```

+++

+++ #### Pipeline (updated)

Add win condition check after damage phase.

`lib/phalanx/engine/pipeline.ex`

```elixir
defmodule Phalanx.Engine.Pipeline do
  # After existing phases...

  @impl true
  def execute_orders(game_state, user_orders) do
    # ... existing phases 1-9 ...

    # After Damage phase, before Rotation
    state_after_damage
    |> check_win_condition()
    |> Rotation.apply(orders)
    |> Energy.finalize(orders, results, attacks)
  end

  defp check_win_condition(game_state) do
    mode = GameModes.get(game_state.game_mode)

    case WinCondition.check(
      mode,
      game_state.game_mode_state,
      game_state.units,
      game_state.turn
    ) do
      {:continue, new_mode_state} ->
        %{game_state | game_mode_state: new_mode_state}

      {:winner, team_id} ->
        %{game_state | winner: team_id, status: :finished}

      {:draw} ->
        %{game_state | winner: :draw, status: :finished}
    end
  end
end
```

+++

+++ #### GameQueries (new helpers)

Team membership lookup for win condition checks.

`lib/phalanx/game/queries.ex`

```elixir
defmodule Phalanx.Game.Queries do
  @spec units_for_team(game :: Phalanx.Game.t(), team_id :: :team_a | :team_b) :: map()
  def units_for_team(game, team_id)

  @spec count_units_for_team(game :: Phalanx.Game.t(), team_id :: :team_a | :team_b) :: non_neg_integer()
  def count_units_for_team(game, team_id)

  @spec team_for_color(game :: Phalanx.Game.t(), color :: String.t()) :: :team_a | :team_b | nil
  def team_for_color(game, color)
end
```

+++

---

## 4. What's the PR roadmap?

1. **PR #1: GameMode and GameModes structs**
   1. `Phalanx.GameMode` struct with all types
   2. `Phalanx.GameModes` catalog with three predefined modes
   3. `Phalanx.GameModeState` for runtime tracking
   4. Unit tests for struct construction and mode lookup

2. **PR #2: Game struct integration**
   1. Add `game_mode`, `game_mode_state`, `winner` fields to Game
   2. Update `new_game/1` to accept optional mode parameter
   3. Update `Helpers.default_game/0` to use mode config for unit setup
   4. Initialize `game_mode_state` with starting unit counts

3. **PR #3: Win condition phase**
   1. `Phalanx.Engine.Phase.WinCondition` module
   2. `check_elimination/2` implementation
   3. `check_turn_limit/2` implementation (for siege prep)
   4. Unit tests for each condition type

4. **PR #4: Pipeline integration**
   1. Wire win condition check into engine pipeline
   2. Set `status: :finished` and `winner` when game ends
   3. Broadcast game-over state to clients
   4. Integration test: elimination victory scenario

5. **PR #5: Game.Queries for team unit lookups**
   1. `units_for_team/2`, `count_units_for_team/2`
   2. `team_for_color/2` (bridges current color-based system to team model)
   3. Used by win condition checks internally

---

## 5. What are open questions?

1. **Color-to-team mapping**: Current system uses `color` ("red", "purple"). Mode system uses `:team_a`, `:team_b`. What is the bridging strategy?
   * Proposal: `team_a` = first player's color, `team_b` = second player's color. Add `team_id` to Player struct per architecture doc.

2. **Draw conditions**: What triggers a draw?
   * Mutual elimination (both teams lose last unit same turn)
   * Turn limit reached with no winner (for siege: defender wins, not draw)

3. **Game creation flow**: Who specifies the mode?
   * Phase 1: Hardcode `:elimination_standard` in `new_game/1`
   * Phase 2: Accept mode parameter when creating game (API/LiveView)

4. **Rout threshold**: The `:rout` condition checks if a team lost N% of starting units. Should this end immediately or at turn end?
   * Proposal: Check at end of damage phase, same as elimination.
