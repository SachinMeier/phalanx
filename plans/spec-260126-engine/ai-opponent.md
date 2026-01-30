# AI Opponent System

Single-player AI for Phalanx games.

## Architecture

```
Phalanx.AI.Behaviour           # Callback spec for AI implementations
Phalanx.AI.Scripted            # Tutorial AI
Phalanx.AI.Reactive            # Easy difficulty
Phalanx.AI.Tactical            # Medium difficulty (v2)
Phalanx.AI.Strategic           # Hard difficulty (v2)
```

### Integration Point

```elixir
# In Phalanx.Game GenServer
def handle_call({:handle_orders, orders}, _from, state) do
  ai_orders = AI.generate_orders(state, ai_team_color)
  all_orders = Map.merge(orders, ai_orders)
  new_state = Engine.execute_orders(state, all_orders)
  # ...
end
```

## AI Behaviour

```elixir
defmodule Phalanx.AI.Behaviour do
  @callback generate_orders(state :: Phalanx.Game.t(), color :: String.t()) ::
    %{position => Phalanx.Order.t()}
end
```

## Tier 1: Scripted AI (Tutorial)

Hardcoded responses. Predictable for teaching mechanics.

```elixir
defmodule Phalanx.AI.Scripted do
  @behaviour Phalanx.AI.Behaviour

  @script [
    # Turn 0: All units hold
    %{},
    # Turn 1: Center unit advances
    %{{5, 2} => Order.new({5, 2}, :southeast, nil)},
    # Turn 2: Flanks advance
    %{
      {4, 2} => Order.new({4, 2}, :southeast, nil),
      {6, 2} => Order.new({6, 2}, :southeast, nil)
    }
  ]

  def generate_orders(state, _color) do
    Enum.at(@script, state.turn, %{})
  end
end
```

## Tier 2: Reactive AI (Easy)

Simple heuristics, no multi-turn planning.

### Decision Priority

1. Attack adjacent enemy if facing them
2. Rotate toward nearest enemy if adjacent
3. Move toward nearest enemy
4. Hold

### Implementation

```elixir
defmodule Phalanx.AI.Reactive do
  @behaviour Phalanx.AI.Behaviour

  def generate_orders(state, color) do
    my_units = units_by_color(state.units, color)
    enemy_units = units_by_color(state.units, enemy_color(color))

    my_units
    |> Enum.map(fn {pos, unit} ->
      {pos, decide_order(state, pos, unit, enemy_units)}
    end)
    |> Map.new()
  end

  defp decide_order(state, pos, unit, enemies) do
    cond do
      target = adjacent_enemy_in_front?(pos, unit, enemies) ->
        attack_order(pos, unit, target)

      target = adjacent_enemy?(pos, enemies) ->
        rotate_toward(pos, unit, target)

      target = nearest_enemy(pos, enemies) ->
        move_toward(pos, unit, target, state.map_dimensions)

      true ->
        Order.null_order(pos)
    end
  end
end
```

### Core Utilities

```elixir
defmodule Phalanx.AI.Utils do
  @doc "Hex distance between two positions"
  def hex_distance({x1, y1}, {x2, y2}) do
    # Convert odd-r to cube coordinates, then calculate distance
    {cx1, cy1, cz1} = oddr_to_cube({x1, y1})
    {cx2, cy2, cz2} = oddr_to_cube({x2, y2})
    max(abs(cx1 - cx2), max(abs(cy1 - cy2), abs(cz1 - cz2)))
  end

  @doc "Get all 6 neighbor positions"
  def neighbors(pos, map_dimensions) do
    [:east, :northeast, :northwest, :west, :southwest, :southeast]
    |> Enum.map(&Moves.oddr_offset_neighbor(map_dimensions, pos, 0, &1))
    |> Enum.filter(&Moves.tile_on_map?(map_dimensions, &1))
  end

  @doc "Direction from pos1 to pos2"
  def direction_to(pos1, pos2) do
    # Returns best direction atom (:east, :northeast, etc.)
  end

  @doc "Is position in front arc of unit?"
  def in_front_arc?(unit_pos, unit, target_pos) do
    dir = direction_to(unit_pos, target_pos)
    Moves.direction_allowed?(unit.rotation, dir)
  end
end
```

## Tier 3: Tactical AI (Medium) - v2

Board evaluation + opportunity detection.

### Scoring Function

```elixir
def score_board(state, color) do
  my_units = units_by_color(state.units, color)
  enemy_units = units_by_color(state.units, enemy_color(color))

  formation_score(my_units) +
  flanking_score(my_units, enemy_units) +
  threat_score(my_units, enemy_units) +
  map_control_score(my_units, state.map_dimensions)
end
```

### Scoring Factors

| Factor | Weight | Calculation |
|--------|--------|-------------|
| Formation | +10 | Per adjacent friendly unit (phalanx bonus) |
| Flanking | +15 | Per enemy unit exposing flank to us |
| Threat | -15 | Per own unit with exposed flank |
| Map Control | +5 | Per unit in center 4 hexes |
| Health | +20 | Per health point advantage |

### Order Generation

For each candidate order set:
1. Generate all legal orders for each unit
2. Prune obviously bad moves (moving away from all action)
3. Score resulting board state
4. Select highest-scoring order set

### Pruning Heuristics

- Never move away from enemies unless retreating wounded unit
- Never break formation unless flanking opportunity exists
- Limit search depth: evaluate 2-3 moves per unit max

## Tier 4: Strategic AI (Hard) - v2

Multi-turn lookahead with alpha-beta pruning.

### Minimax with Pruning

```elixir
def best_orders(state, color, depth \\ 2) do
  {_score, orders} = minimax(state, color, depth, -inf, +inf, true)
  orders
end

defp minimax(state, color, 0, _alpha, _beta, _maximizing) do
  {score_board(state, color), nil}
end

defp minimax(state, color, depth, alpha, beta, maximizing) do
  candidate_orders = generate_candidate_orders(state, current_color)
  # ... standard alpha-beta implementation
end
```

### Formation Coordination

```elixir
def coordinated_advance(units, direction) do
  # Generate orders that move all units in formation together
  # Preserves adjacency bonuses
end

def coordinated_rotation(units, rotation) do
  # Rotate entire formation as a unit
end
```

## Game Integration

### Game Struct Addition

```elixir
defstruct [
  # ... existing fields
  :ai_enabled,      # boolean
  :ai_difficulty,   # :scripted | :reactive | :tactical | :strategic
  :ai_color,        # "red" | "purple"
]
```

### Config

```elixir
# config/config.exs
config :phalanx, :ai,
  enabled: true,
  default_difficulty: :reactive,
  thinking_delay_ms: 500  # Simulate "thinking" for UX
```

### New Game Modes

```elixir
def new_game(id, opts \\ []) do
  ai_enabled = Keyword.get(opts, :ai, false)
  ai_difficulty = Keyword.get(opts, :ai_difficulty, :reactive)
  ai_color = Keyword.get(opts, :ai_color, "red")

  %__MODULE__{
    # ... existing fields
    ai_enabled: ai_enabled,
    ai_difficulty: ai_difficulty,
    ai_color: ai_color,
  }
end
```

## V1 Scope

Implement only:
- `Phalanx.AI.Behaviour` callback module
- `Phalanx.AI.Reactive` (easy difficulty)
- `Phalanx.AI.Utils` hex utilities
- Game integration for single-player mode

Defer to v2:
- Tactical AI (board evaluation)
- Strategic AI (minimax)
- Formation coordination
- Difficulty selection UI

## File Structure

```
lib/phalanx/ai/
  behaviour.ex      # Callback spec
  utils.ex          # Hex math, targeting helpers
  reactive.ex       # Easy AI
  scripted.ex       # Tutorial AI (optional v1)
```

## Testing

```elixir
# test/phalanx/ai/reactive_test.exs
describe "generate_orders/2" do
  test "attacks adjacent enemy in front arc" do
    state = game_with_adjacent_enemies()
    orders = Reactive.generate_orders(state, "red")

    assert orders[{3, 2}].move == :southeast
  end

  test "rotates toward adjacent enemy outside front arc" do
    # ...
  end

  test "moves toward distant enemy" do
    # ...
  end

  test "holds when no enemies visible" do
    # ...
  end
end
```

## UX Considerations

- Add 300-500ms delay before AI submits orders (feels more natural)
- Show "AI thinking..." indicator
- Optional: highlight AI units when they're about to move
- Single-player game starts immediately (no waiting for second player)
