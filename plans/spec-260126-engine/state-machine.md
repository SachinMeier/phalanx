# Phalanx Game State Machine

Formal state machine specification for the Phalanx game lifecycle.

---

## ASCII State Diagram

### Top-Level Game States

```
                              ┌─────────────┐
                              │   CREATED   │
                              │  (process   │
                              │   spawned)  │
                              └──────┬──────┘
                                     │ init/1
                                     ▼
                ┌────────────────────────────────────────┐
                │               :waiting                 │
                │   (Waiting for players to join)        │
                │                                        │
                │  Guards:                               │
                │  - players.count < max_players         │
                └───────────────────┬────────────────────┘
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         │                          │                          │
         ▼                          ▼                          ▼
   player_joined              all_players_ready          last_player_quit
   [count < max]              [count == max]             [count == 0]
         │                          │                          │
         │                          │                          ▼
         └──────────────────────────┤              ┌───────────────────┐
                                    │              │    :terminated    │
                                    ▼              │   (game ended)    │
                ┌────────────────────────────────┐ └───────────────────┘
                │           :playing             │
                │     (Main game loop)           │
                │                                │
                │  ┌──────────────────────────┐  │
                │  │    TURN SUB-STATES       │  │
                │  │    (see below)           │  │
                │  └──────────────────────────┘  │
                └───────────────┬────────────────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         │                      │                      │
         ▼                      ▼                      ▼
   win_condition_met      all_players_quit       turn_limit_reached
         │                      │                      │
         │                      │                      │
         └──────────────────────┼──────────────────────┘
                                │
                                ▼
                ┌────────────────────────────────┐
                │           :finished            │
                │      (Game over, results)      │
                └───────────────────┬────────────┘
                                    │
                                    │ cleanup_timeout (1000ms)
                                    ▼
                              ┌───────────┐
                              │ :stopped  │
                              │ (process  │
                              │  exits)   │
                              └───────────┘
```

### Turn Sub-States (within :playing)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          :playing state                                 │
│                                                                         │
│    ┌─────────────────┐                                                  │
│    │ :order_collect  │◄──────────────────────────────────┐              │
│    │                 │                                   │              │
│    │ Each player     │                                   │              │
│    │ builds orders   │                                   │              │
│    │ client-side     │                                   │              │
│    └────────┬────────┘                                   │              │
│             │                                            │              │
│             │ player submits (Enter key)                 │              │
│             ▼                                            │              │
│    ┌─────────────────┐                                   │              │
│    │ :order_pending  │                                   │              │
│    │                 │                                   │              │
│    │ Waiting for     │                                   │              │
│    │ other players   │                                   │              │
│    │ to submit       │                                   │              │
│    └────────┬────────┘                                   │              │
│             │                                            │              │
│             │ all_orders_received OR turn_timeout        │              │
│             ▼                                            │              │
│    ┌─────────────────┐                                   │              │
│    │   :resolving    │                                   │              │
│    │                 │                                   │              │
│    │ Engine.execute_ │                                   │              │
│    │ orders/2 runs   │                                   │              │
│    │                 │                                   │              │
│    │ Steps:          │                                   │              │
│    │ 1. Populate     │                                   │              │
│    │    holds        │                                   │              │
│    │ 2. Get moves    │                                   │              │
│    │ 3. Detect       │                                   │              │
│    │    conflicts    │                                   │              │
│    │ 4. Balk/retry   │                                   │              │
│    │ 5. Apply state  │                                   │              │
│    └────────┬────────┘                                   │              │
│             │                                            │              │
│             │ resolution_complete                        │              │
│             ▼                                            │              │
│    ┌─────────────────┐                                   │              │
│    │ :turn_complete  │                                   │              │
│    │                 │                                   │              │
│    │ Broadcast new   │                                   │              │
│    │ state via       │                                   │              │
│    │ PubSub          │                                   │              │
│    │                 │                                   │              │
│    │ Check win       │───── win_condition_met ─────► :finished          │
│    │ conditions      │                                   │              │
│    └────────┬────────┘                                   │              │
│             │                                            │              │
│             │ no_winner, increment turn                  │              │
│             └────────────────────────────────────────────┘              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Transition Tables

### Game-Level Transitions

| From | Event | Guard | To | Actions |
|------|-------|-------|----|---------|
| (init) | `start_link/2` | - | `:waiting` | Create game struct, register in Registry |
| `:waiting` | `join_game/3` | `count < max_players` AND `name_valid` AND `name_unique` | `:waiting` | Add player, broadcast state |
| `:waiting` | `join_game/3` | `count == max_players - 1` | `:playing` | Add player, broadcast state, start turn |
| `:waiting` | `quit_game/2` | `count > 1` | `:waiting` | Remove player, broadcast state |
| `:waiting` | `quit_game/2` | `count == 1` | `:terminated` | Schedule stop (1000ms) |
| `:playing` | `handle_orders/2` | - | `:playing` | Execute engine, broadcast state, check win |
| `:playing` | `quit_game/2` | `count > 1` | `:playing` | Remove player, broadcast state |
| `:playing` | `quit_game/2` | `count == 1` | `:terminated` | Schedule stop (1000ms) |
| `:playing` | win_condition | `condition_met` | `:finished` | Set winner, broadcast, schedule cleanup |
| `:playing` | `:timeout` | - | `:terminated` | Stop process |
| `:finished` | cleanup_timer | - | `:terminated` | Stop process |
| any | `:stop` | - | `:terminated` | Normal termination |

### Turn-Level Transitions (Future Implementation)

| From | Event | Guard | To | Actions |
|------|-------|-------|----|---------|
| `:order_collect` | `submit_orders/2` | `player_valid` | `:order_pending` | Store orders for player |
| `:order_pending` | `submit_orders/2` | `all_submitted` | `:resolving` | Trigger engine |
| `:order_pending` | `turn_timeout` | - | `:resolving` | Auto-hold for missing, trigger engine |
| `:resolving` | `resolution_complete` | - | `:turn_complete` | Apply state changes |
| `:turn_complete` | `check_win` | `no_winner` | `:order_collect` | Increment turn, broadcast |
| `:turn_complete` | `check_win` | `winner_found` | - | Exit to `:finished` |

### Player-Level Transitions

| From | Event | Guard | To | Actions |
|------|-------|-------|----|---------|
| (none) | `join_game/3` | `game_exists` AND `not_full` | `:active` | Create player, add to game |
| `:active` | `quit_game/2` | - | `:quit` | Remove from game |
| `:active` | `disconnect` | - | `:disconnected` | Mark disconnected, start reconnect timer |
| `:disconnected` | `rejoin_game/3` | `token_matches` | `:active` | Restore session |
| `:disconnected` | `reconnect_timeout` | - | `:quit` | Auto-quit player |

---

## Guard Conditions

### Join Guards

| Guard | Condition | Error Code |
|-------|-----------|------------|
| `game_not_full` | `count_unquit_players(state) < max_players` | `:game_full` |
| `name_length_valid` | `min_len <= String.length(name) <= max_len` | `:player_name_too_short` / `:player_name_too_long` |
| `name_unique` | `player_is_unique?(state, name, token)` | `:duplicate_player` |
| `game_joinable` | `status in [:waiting]` | `:game_already_started` |

### Order Guards

| Guard | Condition | Error Code |
|-------|-----------|------------|
| `unit_exists` | `Map.has_key?(units, position)` | Order ignored |
| `move_valid` | `Moves.move/4` returns `{:ok, _}` | Move becomes hold |
| `player_owns_unit` | `unit.color == player.team` | Order ignored |

### Win Condition Guards (Future)

| Guard | Condition | Result |
|-------|-----------|--------|
| `elimination` | All enemy units destroyed | Winner = surviving team |
| `rout` | Enemy losses > threshold | Winner = team with more remaining |
| `turn_limit` | `turn >= max_turns` | Winner = highest score |
| `forfeit` | Player explicitly forfeits | Winner = opponent |
| `disconnect_timeout` | Player disconnected > timeout | Winner = connected player |

---

## Timeout Handling

### Current Implementation

| Timeout | Duration | Location | Handler | Action |
|---------|----------|----------|---------|--------|
| Idle timeout | GenServer default | `Game.init/1` | `handle_info(:timeout)` | Terminate process |
| Stop delay | 1000ms | `handle_call({:quit, _})` | `handle_info(:stop)` | Normal termination |

### Proposed Timeouts

| Timeout | Duration | Purpose | Handler |
|---------|----------|---------|---------|
| Turn timer | 30-60s configurable | Force order submission | Auto-submit holds for pending |
| Reconnect window | 120s | Allow reconnection | Auto-quit disconnected player |
| Post-game cleanup | 60s | Allow result viewing | Terminate process |
| Order submission | 5s after first submit | Pressure remaining players | Warning broadcast |

---

## Multiplayer Synchronization

### Current Approach

```
Client 1                    Server (GenServer)              Client 2
    │                             │                             │
    │──── hotkey events ─────────►│                             │
    │     (local orders)          │                             │
    │                             │◄──── hotkey events ─────────│
    │                             │      (local orders)         │
    │                             │                             │
    │──── Enter (submit) ────────►│                             │
    │     handle_orders/2         │                             │
    │                             │                             │
    │                      ┌──────┴──────┐                      │
    │                      │   Engine    │                      │
    │                      │  execute    │                      │
    │                      └──────┬──────┘                      │
    │                             │                             │
    │◄──── PubSub broadcast ──────┤────── PubSub broadcast ────►│
    │      {:state, new_state}    │      {:state, new_state}    │
    │                             │                             │
```

### Issue: No Order Aggregation

Currently, each player's `Enter` press immediately executes orders. There is no waiting for both players. This creates race conditions.

### Proposed Synchronization

```
Client 1                    Server (GenServer)              Client 2
    │                             │                             │
    │──── Enter (submit) ────────►│                             │
    │     {submit_orders, orders} │                             │
    │                             │                             │
    │◄──── ack, waiting ──────────│                             │
    │                             │                             │
    │                             │◄──── Enter (submit) ────────│
    │                             │      {submit_orders, orders}│
    │                             │                             │
    │                      ┌──────┴──────┐                      │
    │                      │  Aggregate  │                      │
    │                      │   orders    │                      │
    │                      │             │                      │
    │                      │   Engine    │                      │
    │                      │  execute    │                      │
    │                      └──────┬──────┘                      │
    │                             │                             │
    │◄──── PubSub broadcast ──────┤────── PubSub broadcast ────►│
    │                             │                             │
```

---

## Disconnect/Reconnect Handling

### Current Implementation

```elixir
# GameSession.on_mount/4
# - Checks session for existing game_id, player_token
# - If match: rejoin via Game.rejoin_game/3
# - If mismatch: quit old game, redirect to new
# - If none: redirect to join page
```

### Session-Based Auth Flow

```
Browser                    LiveView                    Game GenServer
    │                          │                              │
    │── mount (with session) ─►│                              │
    │                          │                              │
    │                          │── rejoin_game/3 ────────────►│
    │                          │                              │
    │                          │◄── :ok ──────────────────────│
    │                          │                              │
    │                          │── subscribe to PubSub ──────►│
    │                          │                              │
    │◄── render game ──────────│                              │
    │                          │                              │
```

### Disconnect Recovery States

```
    ┌───────────────────┐
    │  :connected       │
    │  (LiveView up)    │
    └─────────┬─────────┘
              │ LiveView terminate/2
              │ (tab close, network drop)
              ▼
    ┌───────────────────┐
    │  :disconnected    │
    │  (PubSub unsub'd) │
    │                   │
    │  Start reconnect  │
    │  timer (120s)     │
    └─────────┬─────────┘
              │
       ┌──────┴──────┐
       │             │
       ▼             ▼
   reconnect     timeout
   (new mount)   expires
       │             │
       ▼             ▼
    ┌────────┐   ┌────────┐
    │:active │   │ :quit  │
    │(resume)│   │(remove)│
    └────────┘   └────────┘
```

---

## Forfeit/Resign Handling

### Proposed Flow

| Action | Trigger | Server Response | Outcome |
|--------|---------|-----------------|---------|
| Explicit forfeit | "Forfeit" button | Set player status to `:forfeit` | Opponent wins |
| Tab close | Browser event | Disconnect state | Reconnect window starts |
| Reconnect timeout | Timer expires | Auto-forfeit | Opponent wins |
| Idle timeout | No orders for N turns | Warning, then auto-forfeit | Opponent wins |

### Forfeit State Transitions

```
         forfeit_requested
               │
               ▼
    ┌─────────────────────┐
    │  Confirm dialog     │──── cancel ────► (remain in game)
    │  (client-side)      │
    └──────────┬──────────┘
               │ confirm
               ▼
    ┌─────────────────────┐
    │  quit_game/2        │
    │  {forfeit: true}    │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │  Game status:       │
    │  :finished          │
    │  winner: opponent   │
    │  reason: :forfeit   │
    └─────────────────────┘
```

---

## Implementation Notes

### Current Code Locations

| Concept | File | Function |
|---------|------|----------|
| Game state struct | `lib/phalanx/game.ex` | `defstruct` |
| Status type | `lib/phalanx/game.ex:11` | `@type status :: :waiting \| :running \| :finished` |
| Join logic | `lib/phalanx/game.ex:113` | `handle_call({:join, ...})` |
| Quit logic | `lib/phalanx/game.ex:160` | `handle_call({:quit, ...})` |
| Order execution | `lib/phalanx/game.ex:180` | `handle_call({:handle_orders, ...})` |
| Session management | `lib/phalanx_web/game_session.ex` | `on_mount/4` |
| Turn submission | `lib/phalanx_web/live/game.ex:123` | `handle_submit_orders/1` |

### Status Type Mismatch

The type spec defines `:waiting | :running | :finished` but `new_game/1` sets `:playing`. Recommend aligning to:

```elixir
@type status :: :waiting | :playing | :finished
```

### Missing Turn Sub-State

Current implementation has no explicit turn phases. Orders execute immediately on submission. To implement proper turns:

1. Add to Game struct:
```elixir
defstruct [
  # ... existing fields
  turn_phase: :collecting,  # :collecting | :resolving | :complete
  pending_orders: %{},      # player_token => orders map
  turn_deadline: nil,       # DateTime for turn timeout
]
```

2. Modify `handle_orders`:
```elixir
def handle_call({:submit_orders, player_token, orders}, _from, state) do
  new_pending = Map.put(state.pending_orders, player_token, orders)
  new_state = %{state | pending_orders: new_pending}

  if all_players_submitted?(new_state) do
    execute_turn(new_state)
  else
    reply(new_state, {:ok, :waiting_for_others})
  end
end
```

---

## Open Questions

1. **Turn timer**: What happens if one player never submits? Auto-hold after timeout?
2. **Spectator mode**: Can eliminated players watch? Do they count toward "all players"?
3. **Draw conditions**: What if both teams eliminated simultaneously?
4. **Pause**: Should games be pausable for reconnection?
5. **Undo**: Can orders be changed before the turn resolves?
