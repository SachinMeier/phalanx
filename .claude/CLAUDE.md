# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
mix setup                  # Install deps, build assets
iex -S mix phx.server      # Start dev server at localhost:4000
mix precommit              # Compile (warnings=errors) + format + test
mix test                   # Run all tests
mix test path/to/test.exs  # Run single test file
mix test --failed          # Re-run failed tests
```

## Personal Preferences

- **Elixir**: Use idiomatic patterns. Prefer pattern matching, pipelines, small functions.
- **TypeScript**: Explain non-obvious TS patterns when used.
- **MAXIMIZE SIMPLICITY**. Many small functions over long complex ones.
- **MAXIMIZE BREVITY** in prose and comments.
- **Tailwind over CSS**. Never write raw CSS.

### Testing Philosophy
Ask: "Does this test actual logic or just test construction/mocks?"
- Write tests that catch real bugs
- No tests that only verify mocks return configured values
- No tests that only verify data flows through unchanged

## Project Overview

**Phalanx** is a real-time tactical strategy game built with:
- Elixir 1.15+ / Phoenix 1.8 / LiveView 1.1
- Tailwind CSS + DaisyUI
- GenServer-based game state management

Two teams (Red vs Purple) maneuver units on a hex grid. Units have health, energy, and rotation. Movement is constrained by facing direction. Combat resolves through strength calculations based on formation (phalanx) bonuses.

## Ethos

Phalanx is a **MAXIMALLY SIMPLE** war game simulating phalanx-style warfare from antiquity (hoplites, Macedonian pikes, Roman maniples).

### Historical Model

Two armies face one another, each seeking to **flank** the enemy. A phalanx is deadly from the front—the only path to victory is attacking from the side or rear.

### Three Core Dynamics

| Dynamic | Benefit | Historical Basis |
|---------|---------|------------------|
| **Flanking** | Attack side/rear for advantage | Phalanx shields only protect the front |
| **Side cohesion** | Friendly units adjacent + same facing form phalanx | Overlapping shields, coordinated spears |
| **Depth** | Friendly units behind + same facing push forward | Rear ranks add weight to the push |

### Design Constraints

- **Simultaneous resolution**: All orders execute at once (like Diplomacy), not sequentially
- **No hidden information**: Both players see the full board
- **Emergent complexity**: Simple rules create tactical depth through interaction
- **Balance the triangle**: Maneuverability vs side-grouping vs depth—no dominant strategy

### Open Questions for Engine Design

- Implicit vs explicit grouping (auto-detect phalanx or player-declared?)
- HP/damage vs retreat-when-overpowered (Diplomacy-style)
- Force calculation formula (additive? multiplicative? diminishing returns?)
- How flanking attacks interact with formation bonuses

## Architecture

### OTP Structure

```
Phalanx.Application
├── Phalanx.PubSub          # Phoenix PubSub for real-time broadcasts
├── Phalanx.Game.Registry   # Registry for game process lookup
├── Phalanx.DynamicSupervisor  # Spawns game GenServers
└── PhalanxWeb.Endpoint
```

### Key Modules

| Module | Purpose |
|--------|---------|
| `Phalanx.Game` | GenServer per game. Holds state, handles join/quit/orders |
| `Phalanx.Engine.Diplomacy` | Executes orders: conflict detection, balking, state application |
| `Phalanx.Moves` | Hex grid math. Validates moves per rotation/facing |
| `Phalanx.Order` | Order struct: position + move + rotation |
| `PhalanxWeb.Live.Game` | Main game LiveView. Keyboard input, order collection, rendering |
| `PhalanxWeb.Components.Hex` | Hex grid rendering, SVG units |

### Engine Strategy Pattern

Engine implementation is config-driven:
```elixir
# config/dev.exs
config :phalanx, :engine, Phalanx.Engine.Diplomacy
```

Behaviour defined in `Phalanx.Engine` with `execute_orders/2` callback.

### Game State Flow

```
User hotkey → LiveView event handler → collect order in assigns
  ↓
User presses Enter → Game.handle_orders/2
  ↓
GenServer calls Engine.execute_orders/2
  ↓
Engine: populate holds → detect conflicts → balk if needed → apply state
  ↓
PubSub broadcasts → all LiveViews update
```

### Hex Grid Coordinate System

**Odd-R offset** (row-based). Even/odd rows have different neighbor offsets.

Movement constrained by rotation (facing direction):
- `0°`: E, SE, W, NW allowed
- `60°`: NE, NW, SE, SW allowed
- `120°`: NE, E, W, SW allowed
- (Pattern repeats at 180° intervals)

## Data Structures

```elixir
# Game state
%Phalanx.Game{
  id: "ABCD1234",
  status: :playing,
  turn: 0,
  players: [%Player{name: "...", token: "..."}],
  units: %{{3, 2} => %{name: "Y", health: 3, rotation: 240, color: "red"}},
  map_dimensions: {10, 10}
}

# Order
%Phalanx.Order{
  position: {3, 2},
  move: :northeast,        # or nil
  rotation: :clockwise     # or :counterclockwise or nil
}
```

## Keyboard Controls

| Keys | Action |
|------|--------|
| Y, U, I, O, P | Select red units |
| H, J, K, L, M | Select purple units |
| C | Deselect |
| W, E, A, S, D, F | Move (NW, NE, W, SW, SE, E) |
| Q, R | Rotate (counter/clockwise) |
| Enter | Submit all orders |

## Phoenix Patterns Used

- **GenServer per game** with Registry-based via-tuple naming
- **PubSub** for multi-client sync (topic: `"game-state:{id}"`)
- **LiveView on_mount hook** (`GameSession`) for session/token management
- **Session-based auth** (no database, token stored in session)
- **DynamicSupervisor** for game process lifecycle

## File Locations

| Purpose | Path |
|---------|------|
| Game logic | `lib/phalanx/` |
| Engine impls | `lib/phalanx/engine/` |
| LiveViews | `lib/phalanx_web/live/` |
| Components | `lib/phalanx_web/components/` |
| Hex CSS | `assets/css/hex.css` |
| Keyboard handler | `assets/js/hotkeys.js` |
| Game mechanics doc | `MECHANICS.md` |
