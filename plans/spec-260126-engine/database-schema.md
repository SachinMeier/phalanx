# Database Schema: Optional Persistence for Phalanx

## Overview

Schema for persisting Phalanx games, enabling replay, statistics, async play, and crash recovery.

**Write frequency**: Once per turn (low)
**Read patterns**: Replay (sequential turn fetch), stats (aggregation), leaderboard (sorted)

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Units storage | JSONB in turns | Units change every turn; normalizing gains nothing |
| Orders storage | JSONB in turns | Variable structure, rarely queried individually |
| Map config | JSONB in games | Static per game, flexible for future terrain types |
| State snapshots | `state_after` only | `state_before` = previous turn's `state_after`; eliminates redundancy |

## Schema

### players

```sql
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(32) NOT NULL,
  email VARCHAR(255) UNIQUE,  -- nullable for anonymous play
  rating INTEGER DEFAULT 1200,  -- ELO starting rating
  games_played INTEGER DEFAULT 0,
  games_won INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX players_name_idx ON players(name);
CREATE INDEX players_rating_idx ON players(rating DESC);
```

### games

```sql
CREATE TABLE games (
  id VARCHAR(8) PRIMARY KEY,  -- matches existing 8-char game IDs
  status VARCHAR(16) NOT NULL DEFAULT 'waiting',  -- waiting, playing, finished, abandoned
  player_red_id UUID REFERENCES players(id),
  player_purple_id UUID REFERENCES players(id),
  winner VARCHAR(8),  -- 'red', 'purple', 'draw', or NULL
  map_config JSONB NOT NULL DEFAULT '{"dimensions": [10, 10], "terrain": {}}',
  initial_units JSONB NOT NULL,  -- snapshot of starting positions
  turn_count INTEGER DEFAULT 0,
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX games_status_idx ON games(status);
CREATE INDEX games_player_red_idx ON games(player_red_id);
CREATE INDEX games_player_purple_idx ON games(player_purple_id);
CREATE INDEX games_finished_at_idx ON games(finished_at DESC);
```

### turns

```sql
CREATE TABLE turns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id VARCHAR(8) NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  turn_number INTEGER NOT NULL,
  orders_red JSONB NOT NULL DEFAULT '{}',    -- orders submitted by red
  orders_purple JSONB NOT NULL DEFAULT '{}', -- orders submitted by purple
  state_after JSONB NOT NULL,  -- units map after resolution
  executed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(game_id, turn_number)
);

CREATE INDEX turns_game_id_idx ON turns(game_id);
CREATE INDEX turns_game_turn_idx ON turns(game_id, turn_number);
```

## JSONB Structures

### map_config

```json
{
  "dimensions": [10, 10],
  "terrain": {}
}
```

### initial_units / state_after

```json
{
  "3,2": {"name": "Y", "health": 3, "rotation": 240, "color": "red"},
  "4,2": {"name": "U", "health": 3, "rotation": 240, "color": "red"}
}
```

Key is stringified tuple `"{col},{row}"` for JSON compatibility.

### orders_red / orders_purple

```json
{
  "3,2": {"move": "northeast", "rotation": null},
  "4,2": {"move": null, "rotation": "clockwise"}
}
```

## Ecto Schemas

### Player

```elixir
defmodule Phalanx.Persistence.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "players" do
    field :name, :string
    field :email, :string
    field :rating, :integer, default: 1200
    field :games_played, :integer, default: 0
    field :games_won, :integer, default: 0

    timestamps()
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :email, :rating])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 32)
    |> unique_constraint(:name)
    |> unique_constraint(:email)
  end
end
```

### Game

```elixir
defmodule Phalanx.Persistence.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}

  schema "games" do
    field :status, :string, default: "waiting"
    field :winner, :string
    field :map_config, :map
    field :initial_units, :map
    field :turn_count, :integer, default: 0
    field :started_at, :utc_datetime
    field :finished_at, :utc_datetime

    belongs_to :player_red, Phalanx.Persistence.Player, type: :binary_id
    belongs_to :player_purple, Phalanx.Persistence.Player, type: :binary_id
    has_many :turns, Phalanx.Persistence.Turn

    timestamps(updated_at: false)
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:id, :status, :winner, :map_config, :initial_units,
                    :turn_count, :player_red_id, :player_purple_id,
                    :started_at, :finished_at])
    |> validate_required([:id, :map_config, :initial_units])
    |> validate_inclusion(:status, ~w(waiting playing finished abandoned))
    |> validate_inclusion(:winner, ~w(red purple draw), allow_nil: true)
  end
end
```

### Turn

```elixir
defmodule Phalanx.Persistence.Turn do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "turns" do
    field :turn_number, :integer
    field :orders_red, :map, default: %{}
    field :orders_purple, :map, default: %{}
    field :state_after, :map
    field :executed_at, :utc_datetime

    belongs_to :game, Phalanx.Persistence.Game, type: :string
  end

  def changeset(turn, attrs) do
    turn
    |> cast(attrs, [:game_id, :turn_number, :orders_red, :orders_purple,
                    :state_after, :executed_at])
    |> validate_required([:game_id, :turn_number, :state_after])
    |> unique_constraint([:game_id, :turn_number])
  end
end
```

## Conversion Functions

### GenServer state to DB format

```elixir
defmodule Phalanx.Persistence.Converter do
  @doc "Convert tuple-keyed units map to string-keyed for JSON storage"
  def units_to_json(units) do
    units
    |> Enum.map(fn {{col, row}, unit} ->
      {"#{col},#{row}", unit}
    end)
    |> Map.new()
  end

  @doc "Convert string-keyed JSON back to tuple-keyed units map"
  def json_to_units(json_units) do
    json_units
    |> Enum.map(fn {key, unit} ->
      [col, row] = String.split(key, ",") |> Enum.map(&String.to_integer/1)
      {{col, row}, atomize_unit(unit)}
    end)
    |> Map.new()
  end

  defp atomize_unit(unit) do
    %{
      name: unit["name"],
      health: unit["health"],
      rotation: unit["rotation"],
      color: String.to_atom(unit["color"])
    }
  end

  @doc "Convert orders map for storage"
  def orders_to_json(orders) do
    orders
    |> Enum.map(fn {{col, row}, order} ->
      {"#{col},#{row}", %{
        move: order.move && Atom.to_string(order.move),
        rotation: order.rotation && Atom.to_string(order.rotation)
      }}
    end)
    |> Map.new()
  end
end
```

## Migrations

### 001_create_players

```elixir
defmodule Phalanx.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, size: 32, null: false
      add :email, :string, size: 255
      add :rating, :integer, default: 1200
      add :games_played, :integer, default: 0
      add :games_won, :integer, default: 0

      timestamps()
    end

    create unique_index(:players, [:name])
    create unique_index(:players, [:email])
    create index(:players, [:rating])
  end
end
```

### 002_create_games

```elixir
defmodule Phalanx.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :string, size: 8, primary_key: true
      add :status, :string, size: 16, default: "waiting", null: false
      add :player_red_id, references(:players, type: :binary_id)
      add :player_purple_id, references(:players, type: :binary_id)
      add :winner, :string, size: 8
      add :map_config, :map, null: false
      add :initial_units, :map, null: false
      add :turn_count, :integer, default: 0
      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime

      timestamps(updated_at: false)
    end

    create index(:games, [:status])
    create index(:games, [:player_red_id])
    create index(:games, [:player_purple_id])
    create index(:games, [:finished_at])
  end
end
```

### 003_create_turns

```elixir
defmodule Phalanx.Repo.Migrations.CreateTurns do
  use Ecto.Migration

  def change do
    create table(:turns, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :game_id, references(:games, type: :string, on_delete: :delete_all), null: false
      add :turn_number, :integer, null: false
      add :orders_red, :map, default: %{}, null: false
      add :orders_purple, :map, default: %{}, null: false
      add :state_after, :map, null: false
      add :executed_at, :utc_datetime, null: false
    end

    create index(:turns, [:game_id])
    create unique_index(:turns, [:game_id, :turn_number])
  end
end
```

## Replay System

```elixir
defmodule Phalanx.Persistence.Replay do
  import Ecto.Query
  alias Phalanx.Repo
  alias Phalanx.Persistence.{Game, Turn, Converter}

  @doc "Load complete game for replay"
  def load_game(game_id) do
    game = Repo.get!(Game, game_id) |> Repo.preload(:turns)

    turns =
      game.turns
      |> Enum.sort_by(& &1.turn_number)
      |> Enum.map(fn turn ->
        %{
          turn: turn.turn_number,
          orders_red: turn.orders_red,
          orders_purple: turn.orders_purple,
          state: Converter.json_to_units(turn.state_after)
        }
      end)

    %{
      game: game,
      initial_state: Converter.json_to_units(game.initial_units),
      turns: turns
    }
  end

  @doc "Get state at specific turn"
  def state_at_turn(game_id, turn_number) do
    case turn_number do
      0 ->
        game = Repo.get!(Game, game_id)
        Converter.json_to_units(game.initial_units)

      n ->
        turn =
          from(t in Turn, where: t.game_id == ^game_id and t.turn_number == ^n)
          |> Repo.one!()
        Converter.json_to_units(turn.state_after)
    end
  end

  @doc "Stream turns for large games"
  def stream_turns(game_id) do
    from(t in Turn,
      where: t.game_id == ^game_id,
      order_by: [asc: t.turn_number]
    )
    |> Repo.stream()
  end
end
```

## Statistics Queries

```elixir
defmodule Phalanx.Persistence.Stats do
  import Ecto.Query
  alias Phalanx.Repo
  alias Phalanx.Persistence.{Player, Game}

  @doc "Player win rate"
  def win_rate(player_id) do
    player = Repo.get!(Player, player_id)

    if player.games_played == 0 do
      0.0
    else
      player.games_won / player.games_played * 100
    end
  end

  @doc "Average game length (turns)"
  def avg_game_length do
    from(g in Game,
      where: g.status == "finished",
      select: avg(g.turn_count)
    )
    |> Repo.one()
  end

  @doc "Player's games by outcome"
  def player_games(player_id) do
    from(g in Game,
      where: g.player_red_id == ^player_id or g.player_purple_id == ^player_id,
      where: g.status == "finished",
      order_by: [desc: g.finished_at],
      limit: 20
    )
    |> Repo.all()
  end

  @doc "Most active players"
  def most_active(limit \\ 10) do
    from(p in Player,
      order_by: [desc: p.games_played],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc "Win streak (current)"
  def current_win_streak(player_id) do
    games =
      from(g in Game,
        where: (g.player_red_id == ^player_id or g.player_purple_id == ^player_id),
        where: g.status == "finished",
        order_by: [desc: g.finished_at],
        select: %{
          winner: g.winner,
          was_red: g.player_red_id == ^player_id
        }
      )
      |> Repo.all()

    Enum.reduce_while(games, 0, fn game, streak ->
      won = (game.was_red and game.winner == "red") or
            (not game.was_red and game.winner == "purple")

      if won, do: {:cont, streak + 1}, else: {:halt, streak}
    end)
  end
end
```

## Leaderboard

```elixir
defmodule Phalanx.Persistence.Leaderboard do
  import Ecto.Query
  alias Phalanx.Repo
  alias Phalanx.Persistence.Player

  @doc "Top players by rating"
  def by_rating(limit \\ 50) do
    from(p in Player,
      where: p.games_played >= 5,  -- minimum games for ranking
      order_by: [desc: p.rating],
      limit: ^limit,
      select: %{
        rank: row_number() |> over(order_by: [desc: p.rating]),
        id: p.id,
        name: p.name,
        rating: p.rating,
        games_played: p.games_played,
        win_rate: fragment("ROUND(? * 100.0 / NULLIF(?, 0), 1)", p.games_won, p.games_played)
      }
    )
    |> Repo.all()
  end

  @doc "Top players by wins"
  def by_wins(limit \\ 50) do
    from(p in Player,
      order_by: [desc: p.games_won],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc "Player rank"
  def player_rank(player_id) do
    subquery = from(p in Player,
      where: p.games_played >= 5,
      select: %{
        id: p.id,
        rank: row_number() |> over(order_by: [desc: p.rating])
      }
    )

    from(s in subquery(subquery),
      where: s.id == ^player_id,
      select: s.rank
    )
    |> Repo.one()
  end
end
```

## Integration with GenServer

Minimal changes to existing code. Persistence hooks into existing flow.

### Save turn after execution

```elixir
# In Phalanx.Game, after Engine.execute_orders/2

def handle_call({:handle_orders, orders}, _from, state) do
  new_state = Engine.execute_orders(state, orders)

  # Optional persistence (fire-and-forget)
  if persist_enabled?() do
    Task.start(fn ->
      Phalanx.Persistence.save_turn(state.id, state.turn, orders, new_state)
    end)
  end

  new_state = %{new_state | turn: new_state.turn + 1}
  broadcast_state(new_state)
  reply(new_state, :ok)
end

defp persist_enabled? do
  Application.get_env(:phalanx, :persistence_enabled, false)
end
```

### Resume game from DB

```elixir
defmodule Phalanx.Persistence do
  alias Phalanx.Persistence.{Game, Turn, Converter}
  alias Phalanx.Repo
  import Ecto.Query

  def save_turn(game_id, turn_number, orders, state) do
    {orders_red, orders_purple} = split_orders_by_team(orders, state.units)

    %Turn{}
    |> Turn.changeset(%{
      game_id: game_id,
      turn_number: turn_number,
      orders_red: Converter.orders_to_json(orders_red),
      orders_purple: Converter.orders_to_json(orders_purple),
      state_after: Converter.units_to_json(state.units),
      executed_at: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  def load_game_state(game_id) do
    game = Repo.get(Game, game_id)

    case game do
      nil -> {:error, :not_found}

      %{status: "finished"} -> {:error, :game_finished}

      game ->
        latest_turn =
          from(t in Turn,
            where: t.game_id == ^game_id,
            order_by: [desc: t.turn_number],
            limit: 1
          )
          |> Repo.one()

        units = case latest_turn do
          nil -> Converter.json_to_units(game.initial_units)
          turn -> Converter.json_to_units(turn.state_after)
        end

        turn_number = if latest_turn, do: latest_turn.turn_number + 1, else: 0

        state = %Phalanx.Game{
          id: game.id,
          status: String.to_atom(game.status),
          turn: turn_number,
          players: [],  -- players rejoin
          units: units,
          map_dimensions: parse_dimensions(game.map_config)
        }

        {:ok, state}
    end
  end

  defp split_orders_by_team(orders, units) do
    Enum.reduce(orders, {%{}, %{}}, fn {pos, order}, {red, purple} ->
      case Map.get(units, pos) do
        %{color: "red"} -> {Map.put(red, pos, order), purple}
        %{color: "purple"} -> {red, Map.put(purple, pos, order)}
        _ -> {red, purple}
      end
    end)
  end

  defp parse_dimensions(%{"dimensions" => [w, h]}), do: {w, h}
  defp parse_dimensions(_), do: {10, 10}
end
```

## Configuration

```elixir
# config/config.exs
config :phalanx, :persistence_enabled, false

# config/prod.exs
config :phalanx, :persistence_enabled, true

config :phalanx, Phalanx.Repo,
  database: "phalanx_prod",
  username: "phalanx",
  password: {:system, "DATABASE_PASSWORD"},
  hostname: "localhost",
  pool_size: 10
```

## Future Extensions

| Feature | Schema Change |
|---------|---------------|
| Terrain | Add to `map_config.terrain` JSONB |
| Spectators | Add `game_spectators` join table |
| Chat | Add `game_messages` table |
| Async games | Add `pending_orders` table, deadline fields |
| Tournaments | Add `tournaments`, `tournament_games` tables |
