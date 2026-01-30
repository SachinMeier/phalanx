# Tutorial System Design

## Overview

Teach Phalanx mechanics through progressive scenario-based lessons. Each lesson isolates one concept on a minimal board with scripted success conditions.

## Architecture

### Tutorial Mode

A tutorial is a special game mode with:
- Predefined unit layout (not the default game setup)
- Success/failure conditions checked after each turn
- Contextual hints displayed in the sidebar
- No opponent (or scripted AI opponent in later lessons)

### Data Structure

```elixir
defmodule Phalanx.Tutorial do
  @type t :: %__MODULE__{
    id: atom(),
    name: String.t(),
    objective: String.t(),
    hints: [String.t()],
    initial_units: map(),
    map_dimensions: {pos_integer(), pos_integer()},
    success_condition: (Phalanx.Game.t(), [Phalanx.Order.t()] -> boolean()),
    max_turns: pos_integer() | nil
  }
end
```

### Engine Integration

Tutorial games use the same `Phalanx.Engine.Diplomacy` engine. Success conditions are checked post-execution by a `Phalanx.Tutorial.Evaluator` module.

---

## Lesson Progression

### Lesson 1: Movement

**Objective**: Move unit Y to the target hex.

**Setup**:
- 3x3 board
- One red unit (Y) at {1, 1}, facing east (0 rotation)
- Target marker at {2, 1}

**Teaches**:
- Hex grid navigation
- Hotkey: select unit (Y key)
- Hotkey: move direction (E for east)
- Hotkey: submit orders (Enter)

**Success Condition**:
```elixir
fn state, _orders ->
  Map.has_key?(state.units, {2, 1}) and
    Map.get(state.units, {2, 1}).name == "Y"
end
```

**Hints**:
1. "Press Y to select unit Y"
2. "Press E to move east toward the target"
3. "Press Enter to submit your orders"

---

### Lesson 2: Facing and Rotation

**Objective**: Rotate to face the enemy, then attack.

**Setup**:
- 4x4 board
- Red unit Y at {1, 2}, facing east (0 rotation)
- Purple dummy unit at {1, 1} (directly NW), stationary

**Problem**: Y cannot move NW at 0 rotation. Must rotate first.

**Teaches**:
- Rotation matters for valid moves
- Rotation hotkeys (Q/R)
- Facing constraints (allowed move directions per rotation)

**Success Condition**:
```elixir
# Turn 1: Rotate to 60 (allows NW move)
# Turn 2: Move NW to attack
fn state, _orders ->
  Map.has_key?(state.units, {1, 1}) and
    Map.get(state.units, {1, 1}).color == "red"
end
```

**Hints**:
1. "You cannot move NW while facing east"
2. "Press R to rotate clockwise (face NE)"
3. "Now NW is a valid move direction"

**Visual Aid**: Highlight allowed move directions based on current rotation.

---

### Lesson 3: Simultaneous Orders

**Objective**: Move two units in the same turn.

**Setup**:
- 5x5 board
- Red units Y and U, both needing to reach target hexes

**Teaches**:
- Multiple orders per turn
- All orders execute simultaneously
- Select different units to give each orders

**Success Condition**:
```elixir
fn state, _orders ->
  y_at_target = Map.get(state.units, {3, 2})
  u_at_target = Map.get(state.units, {3, 3})
  y_at_target != nil and u_at_target != nil
end
```

**Hints**:
1. "Select unit Y, give it orders, then select unit U"
2. "All orders execute at the same time when you press Enter"

---

### Lesson 4: Formation (Phalanx)

**Objective**: Form a phalanx and hold position.

**Setup**:
- 6x4 board
- Three red units (Y, U, I) scattered
- Three target hexes in a line, same facing

**Teaches**:
- Adjacency with same facing = phalanx
- Strength bonus (+1 per neighbor in formation)

**Success Condition**:
```elixir
fn state, _orders ->
  # Check three units are adjacent and same rotation
  Phalanx.Formation.is_phalanx?(state, ["Y", "U", "I"])
end
```

**Hints**:
1. "Adjacent units facing the same direction form a phalanx"
2. "Phalanx formation grants +1 strength per neighbor"
3. "Move all three units to the marked hexes, all facing east"

**Visual Aid**: When formation is achieved, display "+2 strength" indicator.

---

### Lesson 5: Combat and Dislodging

**Objective**: Dislodge the enemy unit.

**Setup**:
- 5x5 board
- Red unit Y at {2, 2}
- Purple dummy at {3, 2} (stationary, 1 strength)
- Y has 2 strength (from position/setup)

**Teaches**:
- Dislodge: attacker strength > defender strength
- Movement into occupied hex = attack
- Dislodged units take damage (-1 health)

**Success Condition**:
```elixir
fn state, _orders ->
  # Red unit now occupies the enemy's former position
  Map.get(state.units, {3, 2}).color == "red"
end
```

**Hints**:
1. "Move into an enemy hex to attack"
2. "Your strength (2) > enemy strength (1) = dislodge"
3. "Dislodged units take 1 damage and are pushed back"

---

### Lesson 6: Flanking

**Objective**: Attack the enemy from the flank for bonus damage.

**Setup**:
- 6x6 board
- Purple dummy at center, facing east
- Red unit Y positioned to attack from the side (not front)

**Teaches**:
- Flank attack = attack from 60-120 angle
- Flank attack = -1 additional health to defender
- Rear attack = -2 additional health

**Success Condition**:
```elixir
fn state, orders ->
  # Enemy took 2 damage (dislodge + flank bonus)
  enemy = find_enemy(state)
  enemy.health <= 1
end
```

**Hints**:
1. "The enemy is facing east. Attack from the side."
2. "Flank attacks deal +1 damage"
3. "Rear attacks deal +2 damage"

**Visual Aid**: Highlight enemy's front, flank, and rear arcs.

---

### Lesson 7: Energy Management

**Objective**: Survive 5 turns without running out of energy.

**Setup**:
- Confined board
- Red unit starts with 3 energy
- Must alternate between moving and holding

**Teaches**:
- Moving forward costs 1 energy
- Holding restores 1 energy (only if not attacked)
- 0 energy = -1 health per turn

**Success Condition**:
```elixir
fn state, _orders ->
  state.turn >= 5 and
    Map.get(state.units, find_player_unit(state)).health > 0
end
```

**Hints**:
1. "Moving forward costs 1 energy"
2. "Holding position restores 1 energy (but not if attacked)"
3. "If you run out of energy, you take damage each turn"

---

### Lesson 8: Full Battle (Capstone)

**Objective**: Defeat the AI opponent using all learned mechanics.

**Setup**:
- 8x8 board
- 3 red units vs 3 purple AI units
- AI uses simple scripted behavior

**Teaches**:
- Apply all mechanics together
- Strategic thinking
- Turn planning

**Success Condition**:
```elixir
fn state, _orders ->
  # All enemy units eliminated or unable to act
  Enum.all?(state.units, fn {_pos, unit} -> unit.color == "red" end)
end
```

---

## Implementation Components

### 1. Tutorial Registry

```elixir
defmodule Phalanx.Tutorial.Registry do
  @tutorials %{
    movement: %Tutorial{...},
    rotation: %Tutorial{...},
    simultaneous: %Tutorial{...},
    formation: %Tutorial{...},
    combat: %Tutorial{...},
    flanking: %Tutorial{...},
    energy: %Tutorial{...},
    full_battle: %Tutorial{...}
  }

  def get(id), do: Map.get(@tutorials, id)
  def all, do: @tutorials
  def next(current_id), do: ...
end
```

### 2. Tutorial Game Mode

Extend `Phalanx.Game` to accept a `:tutorial` option:

```elixir
def new_tutorial_game(tutorial_id) do
  tutorial = Tutorial.Registry.get(tutorial_id)
  %__MODULE__{
    id: new_game_id(),
    status: :playing,
    mode: :tutorial,
    tutorial_id: tutorial_id,
    units: tutorial.initial_units,
    map_dimensions: tutorial.map_dimensions,
    turn: 0,
    players: []
  }
end
```

### 3. Success Evaluator

```elixir
defmodule Phalanx.Tutorial.Evaluator do
  def check_success(state, orders, tutorial) do
    tutorial.success_condition.(state, orders)
  end

  def check_failure(state, tutorial) do
    cond do
      tutorial.max_turns && state.turn > tutorial.max_turns -> :timeout
      player_units_eliminated?(state) -> :eliminated
      true -> :continue
    end
  end
end
```

### 4. Hint System

Hints displayed in sidebar, context-sensitive:

```elixir
defmodule Phalanx.Tutorial.Hints do
  def current_hint(state, tutorial) do
    cond do
      state.turn == 0 -> Enum.at(tutorial.hints, 0)
      no_orders_given?(state) -> "Select a unit to give orders"
      true -> Enum.at(tutorial.hints, min(state.turn, length(tutorial.hints) - 1))
    end
  end
end
```

### 5. Simple AI (for Lesson 8)

```elixir
defmodule Phalanx.AI.Scripted do
  @doc "Generate orders for AI units. Simple: hold or attack nearest."
  def generate_orders(state, ai_color) do
    state.units
    |> Enum.filter(fn {_pos, unit} -> unit.color == ai_color end)
    |> Enum.map(&generate_unit_order(state, &1))
    |> Map.new()
  end

  defp generate_unit_order(state, {pos, unit}) do
    enemy = find_nearest_enemy(state, pos, unit.color)
    if adjacent?(pos, enemy.position) do
      {pos, Order.new(pos, direction_to(pos, enemy.position), nil)}
    else
      {pos, Order.null_order(pos)}
    end
  end
end
```

---

## UI Components

### Tutorial LiveView

New LiveView `PhalanxWeb.Live.Tutorial` extending game LiveView:

```elixir
defmodule PhalanxWeb.Live.Tutorial do
  use PhalanxWeb, :live_view

  # Mounts tutorial game instead of regular game
  def mount(%{"id" => tutorial_id}, _session, socket) do
    tutorial = Tutorial.Registry.get(String.to_atom(tutorial_id))
    game = Game.new_tutorial_game(tutorial_id)
    # ... setup assigns
  end

  # After orders, check success/failure
  def handle_info({:state, state}, socket) do
    tutorial = socket.assigns.tutorial
    case Tutorial.Evaluator.check_success(state, socket.assigns.orders, tutorial) do
      true -> show_success_modal(socket)
      false ->
        case Tutorial.Evaluator.check_failure(state, tutorial) do
          :continue -> update_state(socket, state)
          :timeout -> show_failure_modal(socket, "Out of turns!")
          :eliminated -> show_failure_modal(socket, "Your units were eliminated!")
        end
    end
  end
end
```

### Visual Indicators

1. **Target Hexes**: Highlight destination hexes with pulsing border
2. **Allowed Moves**: Show which directions current unit can move (based on rotation)
3. **Formation Indicators**: Glow effect when phalanx formed
4. **Damage Preview**: Show expected damage before confirming attack
5. **Enemy Arcs**: Visualize front/flank/rear zones on enemy units

### Sidebar Components

```heex
<.tutorial_sidebar>
  <.objective text={@tutorial.objective} />
  <.hint text={current_hint(@state, @tutorial)} />
  <.progress current={@state.turn} max={@tutorial.max_turns} />
  <.restart_button />
</.tutorial_sidebar>
```

---

## Progress Tracking

### Session-Based (MVP)

Store completed tutorials in browser session:

```elixir
# In session plug
def set_completed(conn, tutorial_id) do
  completed = get_session(conn, :completed_tutorials) || []
  put_session(conn, :completed_tutorials, [tutorial_id | completed])
end
```

### Database-Backed (Future)

For persistent progress across devices:

```elixir
defmodule Phalanx.TutorialProgress do
  schema "tutorial_progress" do
    belongs_to :player, Phalanx.Player
    field :tutorial_id, :string
    field :completed_at, :utc_datetime
    field :turns_taken, :integer
  end
end
```

---

## Routes

```elixir
# router.ex
scope "/tutorial", PhalanxWeb do
  live "/", Live.TutorialIndex  # List all tutorials
  live "/:id", Live.Tutorial     # Play specific tutorial
end
```

---

## Open Questions

1. **Reset Mid-Lesson**: Allow instant restart or require confirmation?
2. **Skip Ahead**: Can players skip to later lessons?
3. **Par System**: Track "best" completion (fewest turns)?
4. **Replay**: Save/replay successful runs?
5. **Adaptive Hints**: Detect common mistakes and offer targeted help?

---

## Implementation Order

1. `Phalanx.Tutorial` struct and registry
2. Lesson 1 (movement) - minimal viable tutorial
3. `Tutorial.Evaluator` with success checking
4. `PhalanxWeb.Live.Tutorial` LiveView
5. Hint display component
6. Target hex visualization
7. Lessons 2-7
8. Simple AI for Lesson 8
9. Progress tracking
10. Tutorial index page

---

## Summary

| Lesson | Mechanic | Setup | Turns |
|--------|----------|-------|-------|
| 1 | Movement | 1 unit, target hex | 1 |
| 2 | Rotation | 1 unit, blocked path | 2 |
| 3 | Simultaneous | 2 units, 2 targets | 1 |
| 4 | Formation | 3 units, line formation | 2-3 |
| 5 | Combat | 1v1, strength advantage | 1 |
| 6 | Flanking | 1v1, positional advantage | 1-2 |
| 7 | Energy | 1 unit, endurance test | 5 |
| 8 | Full Battle | 3v3, all mechanics | 10+ |

Total: 8 lessons covering all core mechanics progressively.
