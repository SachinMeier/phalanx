# Multiplayer Synchronization System

Real-time synchronization for two-player simultaneous order submission and resolution.

## Current State Analysis

**Existing infrastructure:**
- GenServer per game (`Phalanx.Game`)
- PubSub broadcasting (`game-state:{id}`)
- Registry-based process lookup
- Player tokens for identity
- Immediate order execution (no turn coordination)

**Gaps:**
- No turn timer or phase management
- Orders execute immediately on Enter press
- No waiting for opponent orders
- No lock/commit mechanism
- Single-player config (`max_players: 1`)

---

## Design Overview

### Turn Phases

```
PLANNING (30s) --> LOCKED --> RESOLUTION --> PLANNING
    |                |            |
    v                v            v
  Orders         Waiting      Animation
  editable       for both     playback
```

| Phase | Duration | Description |
|-------|----------|-------------|
| `planning` | 30s countdown | Both players issue orders |
| `locked` | 0-5s | Waiting for opponent to lock or timeout |
| `resolution` | 2s | Animation of order execution |

---

## 1. Order Collection

### Submission Flow

```
Player presses Enter
      |
      v
Orders sent to GenServer
      |
      v
Mark player as "locked"
      |
      v
Check if both locked
     / \
   No   Yes
   |     |
   v     v
 Wait  Execute
```

### Order Editing

- Orders are freely editable during `planning` phase
- Pressing Enter locks orders (cannot edit after)
- "Unlock" button allows re-editing before timeout (optional)

### Lock Mechanism

**GenServer state additions:**

```elixir
%Phalanx.Game{
  # existing fields...
  phase: :planning | :locked | :resolution,
  turn_deadline: DateTime.t() | nil,
  locked_orders: %{
    player_token => %{position => Order.t()}
  }
}
```

**Lock order message:**

```elixir
def handle_call({:lock_orders, player_token, orders}, _from, state) do
  new_locked = Map.put(state.locked_orders, player_token, orders)
  new_state = %{state | locked_orders: new_locked}

  if all_players_locked?(new_state) do
    execute_turn(new_state)
  else
    broadcast_lock_status(new_state)
    reply(new_state, :ok)
  end
end
```

### Missing Orders

If one player does not submit:
1. Timeout triggers
2. Non-submitting player gets auto-hold for all units
3. Turn executes with available orders

---

## 2. Turn Timer

### Configuration

```elixir
# config/config.exs
config :phalanx, :turn_timer,
  planning_duration: 30_000,    # 30 seconds
  resolution_duration: 2_000,   # 2 seconds
  grace_period: 5_000           # 5 seconds after first lock
```

### Timer Implementation

**Start turn timer:**

```elixir
def start_planning_phase(state) do
  deadline = DateTime.add(DateTime.utc_now(), 30, :second)
  timer_ref = Process.send_after(self(), :planning_timeout, 30_000)

  %{state |
    phase: :planning,
    turn_deadline: deadline,
    timer_ref: timer_ref,
    locked_orders: %{}
  }
  |> broadcast_state()
end
```

**Handle timeout:**

```elixir
def handle_info(:planning_timeout, %{phase: :planning} = state) do
  # Auto-hold for players who didn't lock
  orders = populate_missing_holds(state)
  execute_turn(%{state | locked_orders: orders})
end

def handle_info(:planning_timeout, state) do
  # Already in resolution, ignore
  {:noreply, state}
end
```

### Grace Period

When first player locks:
1. Start 5s grace timer
2. If second player locks within grace: proceed immediately
3. If grace expires: auto-hold for second player

```elixir
def on_first_lock(state) do
  grace_ref = Process.send_after(self(), :grace_timeout, 5_000)
  %{state | grace_timer_ref: grace_ref}
end
```

---

## 3. Resolution Synchronization

### Server-Authoritative Execution

```
Both players locked
        |
        v
Cancel any pending timers
        |
        v
Execute Engine.execute_orders/2
        |
        v
Broadcast {:resolution, pre_state, post_state, orders}
        |
        v
All clients animate simultaneously
        |
        v
After 2s, broadcast {:new_turn, state}
```

### Resolution Message

```elixir
def execute_turn(state) do
  all_orders = merge_locked_orders(state.locked_orders)
  pre_state = state
  post_state = Engine.execute_orders(state, all_orders)

  # Broadcast resolution to all clients
  Phoenix.PubSub.broadcast(
    Phalanx.PubSub,
    state_topic(state.id),
    {:resolution, %{
      turn: state.turn,
      pre_state: pre_state,
      post_state: post_state,
      orders: all_orders
    }}
  )

  # Schedule next planning phase
  Process.send_after(self(), :start_next_turn, @resolution_duration)

  %{state | phase: :resolution}
end
```

### Client Animation Sync

**LiveView handler:**

```elixir
def handle_info({:resolution, resolution_data}, socket) do
  socket
  |> assign(:phase, :resolution)
  |> assign(:resolution_data, resolution_data)
  |> push_event("animate_resolution", resolution_data)
  |> noreply()
end

def handle_info({:new_turn, state}, socket) do
  socket
  |> assign(:state, state)
  |> assign(:phase, :planning)
  |> assign(:orders, %{})
  |> noreply()
end
```

**JavaScript animation:**

```javascript
// assets/js/hooks.js
Hooks.GameBoard = {
  mounted() {
    this.handleEvent("animate_resolution", (data) => {
      this.animateOrders(data.orders, data.pre_state, data.post_state)
    })
  },

  animateOrders(orders, preState, postState) {
    // CSS transitions handle unit movement
    // Duration: 2000ms to match server timing
  }
}
```

### Slow Client Handling

- Animation is fire-and-forget from server perspective
- Server waits fixed 2s regardless of client animation state
- Slow clients may see truncated animations but state will be correct
- No client acknowledgment required

---

## 4. State Authority

### Principles

| Concern | Authority |
|---------|-----------|
| Game state | Server only |
| Order validation | Server only |
| Turn timing | Server only |
| Animation | Client (visual only) |
| Order drafts | Client (until lock) |

### No Client-Side Prediction

- Client shows only confirmed server state
- Order "preview" shows intended destination but not confirmed
- After resolution broadcast, client updates to server state

### State Broadcast

```elixir
def broadcast_state(state) do
  Phoenix.PubSub.broadcast(
    Phalanx.PubSub,
    state_topic(state.id),
    {:state, sanitize_for_broadcast(state)}
  )
  state
end

defp sanitize_for_broadcast(state) do
  # Remove internal fields
  Map.drop(state, [:timer_ref, :grace_timer_ref])
end
```

---

## 5. Disconnect Handling

### Detection

LiveView socket disconnect triggers `terminate/2`:

```elixir
# In LiveView
def terminate(:shutdown, socket) do
  # Clean disconnect (tab closed, navigation)
  handle_player_disconnect(socket)
end

def terminate({:shutdown, :left}, socket) do
  # Player navigated away
  handle_player_disconnect(socket)
end

defp handle_player_disconnect(socket) do
  Game.player_disconnected(socket.assigns.game_id, socket.assigns.player_token)
end
```

### Reconnection Window

```elixir
# In GenServer
def handle_call({:player_disconnected, token}, _from, state) do
  player = find_player(state, token)

  new_state = update_player(state, token, %{
    status: :disconnected,
    disconnect_time: DateTime.utc_now()
  })

  # Start forfeit timer (60 seconds)
  Process.send_after(self(), {:check_forfeit, token}, 60_000)

  broadcast_state(new_state)
  reply(new_state, :ok)
end
```

### Reconnection

```elixir
def handle_call({:rejoin, name, token}, _from, state) do
  case find_player(state, token) do
    nil ->
      reply(state, {:error, :not_found})

    %{status: :disconnected} = player ->
      new_state = update_player(state, token, %{status: :connected})
      broadcast_state(new_state)
      reply(new_state, :ok)

    _player ->
      reply(state, :ok)
  end
end
```

### Forfeit Conditions

| Scenario | Action |
|----------|--------|
| Disconnect 60s+ | Auto-forfeit, opponent wins |
| Disconnect during resolution | Wait for reconnect, extend phase |
| Both disconnect | Pause game, 5min expiry |

```elixir
def handle_info({:check_forfeit, token}, state) do
  case find_player(state, token) do
    %{status: :disconnected, disconnect_time: time} ->
      if DateTime.diff(DateTime.utc_now(), time, :second) >= 60 do
        forfeit_player(state, token)
      else
        {:noreply, state}
      end

    _ ->
      {:noreply, state}
  end
end
```

---

## 6. Spectators

### Join as Spectator

```elixir
def handle_call({:spectate, spectator_id}, _from, state) do
  new_state = add_spectator(state, spectator_id)
  reply(new_state, :ok)
end

defp add_spectator(state, spectator_id) do
  spectators = Map.get(state, :spectators, [])
  %{state | spectators: [spectator_id | spectators]}
end
```

### Spectator View

- Same PubSub topic as players
- Receive all `:state` and `:resolution` broadcasts
- Read-only (cannot submit orders)
- See both teams' units

### LiveView for Spectators

```elixir
def mount(params, session, socket) do
  if socket.assigns.is_spectator do
    # Subscribe but don't register as player
    Phoenix.PubSub.subscribe(Phalanx.PubSub, Game.state_topic(game_id))

    socket
    |> assign(:can_issue_orders, false)
    |> ok()
  else
    # Normal player mount
  end
end
```

### Replay Capability

**Not in MVP scope.** Future implementation would:

1. Store all resolution events per game
2. Allow replay playback from stored events
3. Separate "replay" LiveView component

---

## Implementation Priority

### Phase 1: Core Turn Sync

1. Add phase state to GenServer
2. Implement lock_orders call
3. Add turn timer with timeout
4. Modify broadcast to include phase

### Phase 2: Resolution Animation

1. Split broadcast into pre/post states
2. Add JavaScript animation hook
3. Implement animation timing

### Phase 3: Disconnect Handling

1. Track player connection status
2. Add reconnection logic
3. Implement forfeit timer

### Phase 4: Spectators

1. Add spectator join endpoint
2. Create read-only view mode
3. Spectator count in UI

---

## PubSub Topics

| Topic | Messages | Subscribers |
|-------|----------|-------------|
| `game-state:{id}` | `:state`, `:resolution`, `:new_turn`, `:lock_status` | All players, spectators |
| `game-presence:{id}` | Player connect/disconnect | Admin, debugging |

---

## Message Types

```elixir
# State update (current behavior, extended)
{:state, %Game{}}

# Player locked their orders
{:lock_status, %{
  player: player_token,
  locked: true,
  time_remaining: seconds
}}

# Resolution starting
{:resolution, %{
  turn: integer,
  pre_state: %Game{},
  post_state: %Game{},
  orders: %{position => Order.t()}
}}

# New turn starting
{:new_turn, %{
  turn: integer,
  deadline: DateTime.t(),
  state: %Game{}
}}
```

---

## Timing Sequence Diagram

```
T+0s    Player A          Server          Player B
        |                  |                  |
        |   lock_orders    |                  |
        |----------------->|                  |
        |                  |--grace timer--   |
        |   {:lock_status} |                  |
        |<-----------------|----------------->|
        |                  |                  |
T+3s    |                  |   lock_orders    |
        |                  |<-----------------|
        |                  |--cancel timer--  |
        |                  |                  |
        |   {:resolution}  |   {:resolution}  |
        |<-----------------|----------------->|
        |                  |                  |
        |   [animate]      |   [animate]      |
        |                  |                  |
T+5s    |   {:new_turn}    |   {:new_turn}    |
        |<-----------------|----------------->|
```

---

## GenServer State Shape (Final)

```elixir
%Phalanx.Game{
  # Existing
  id: "ABCD1234",
  status: :waiting | :playing | :finished,
  turn: 0,
  players: [%Player{}],
  units: %{{3, 2} => %{name: "Y", ...}},
  map_dimensions: {10, 10},

  # New: Turn management
  phase: :planning | :locked | :resolution,
  turn_deadline: ~U[2024-01-15 12:30:30Z],
  locked_orders: %{
    "player_token_1" => %{{3, 2} => %Order{}},
    "player_token_2" => %{{3, 7} => %Order{}}
  },

  # New: Spectators
  spectators: ["spectator_id_1", "spectator_id_2"],

  # Internal (not broadcast)
  timer_ref: reference(),
  grace_timer_ref: reference()
}
```

---

## Config Additions

```elixir
# config/config.exs
config :phalanx, :multiplayer,
  max_players: 2,
  planning_duration_ms: 30_000,
  grace_period_ms: 5_000,
  resolution_duration_ms: 2_000,
  disconnect_forfeit_ms: 60_000,
  game_expiry_ms: 300_000  # 5 minutes if all disconnect
```
