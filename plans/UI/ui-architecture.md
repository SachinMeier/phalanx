# UI Architecture: Phalanx

Design philosophy, component structure, and visual language for a hex-grid tactical game themed around ancient phalanx warfare.

---

## Design Philosophy

### Core Principles

| Principle | Meaning |
|-----------|---------|
| **Clarity over decoration** | Information first. Ornament serves function. |
| **Ancient, not fantasy** | Historical weight, not D&D aesthetic. |
| **Simultaneous resolution** | UI must show pending orders, not just current state. |
| **Desktop-first** | Keyboard-driven. Touch/mobile is secondary. |

### Visual Metaphor

The game board is a **commander's sand table**—a tactical planning surface used by ancient generals. Units are markers; the grid is terrain. The UI chrome evokes parchment maps and bronze instruments.

---

## Component Architecture

### Current Structure

```
PhalanxWeb
├── Layouts
│   ├── root.html.heex      # HTML skeleton, theme script
│   └── app/1               # Navbar, flash messages
├── LiveViews
│   ├── Game                # Main battlefield
│   ├── Find                # Game lobby
│   ├── JoinGame            # Player entry
│   └── Sandbox             # Dev testing
├── Components
│   ├── hex.ex              # Hex grid, unit SVG
│   ├── layouts.ex          # Page wrappers
│   └── core_components.ex  # DaisyUI primitives
└── Hooks
    └── Hotkeys             # Keyboard capture
```

### Proposed Component Hierarchy

```
Game LiveView
├── Battlefield
│   ├── HexGrid
│   │   ├── HexTile (terrain + highlight state)
│   │   └── UnitMarker (SVG + health + facing)
│   └── OrderOverlay (pending moves shown as arrows)
├── Sidebar.Left
│   ├── TurnInfo (turn number, phase)
│   ├── Compass (movement reference)
│   └── ControlHelp (keybindings)
├── Sidebar.Right
│   ├── UnitPanel (selected unit details)
│   ├── OrderQueue (pending orders list)
│   └── ActionButtons (submit, clear)
└── StatusBar
    └── GamePhase / Timer / Notifications
```

---

## Visual Language

### Color Palette

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| **Background** | Parchment | `#FFF5E6` | Panels, sidebars |
| **Surface** | Aged paper | `#E5DBB7` | Cards, tooltips |
| **Primary** | Bronze | `#CE8946` | Buttons, borders, highlights |
| **Accent** | Gold | `#FACD1E` | Selection, victory, emphasis |
| **Text** | Dark earth | `#603C18` | Primary text |
| **Text secondary** | Stone | `#9D8C71` | Labels, hints |
| **Danger** | Roman red | `#7F2122` | Errors, flanked status |

### Team Colors

| Team | Primary | Use |
|------|---------|-----|
| **Red** | `#D32929` | Legionary red, warm |
| **Purple** | `#5D3A8E` | Tyrian purple, royal |

### Terrain Colors (Future Work)

> **Note**: Terrain is future work. V1 uses uniform flat grid with single background color.

| Terrain | Hex | Notes |
|---------|-----|-------|
| Dry grass | `#BBB093` | Default (V1 uses this for all hexes) |
| Dust/sand | `#D4BFA7` | Future: open ground variant |
| Stone | `#9D8C71` | Future: rocky/impassable |

### Typography

| Role | Font | Weight |
|------|------|--------|
| **Display** | Cinzel | 700 |
| **Headers** | Cinzel | 400 |
| **Body** | Source Sans Pro | 400 |
| **Stats/mono** | JetBrains Mono | 400 |

Cinzel evokes Roman inscriptions. Use sparingly—headers and unit names only.

```html
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;700&family=Source+Sans+3:wght@400;600&display=swap" rel="stylesheet">
```

---

## Hex Grid Design

### Grid Appearance

- **Lines**: 1px, `rgba(157, 140, 113, 0.3)` (stone at 30%)
- **Fill**: Uniform color (terrain-based fill is future work)
- **Selected hex**: 2px gold (`#FACD1E`) border
- **Movement range**: Dashed bronze border

### Unit Markers

Current: SVG polygon with rotation transform.

Proposed enhancements:
- Health bar along left edge (current)
- Facing indicator: small triangle pointing forward
- Status icon overlay (flanked, phalanx bonus)
- Order preview: ghost arrow showing pending move

```
┌─────────────┐
│  ▲ facing   │
│ ┌───────┐   │
│ │   Y   │   │  ← Unit name (rotated back)
│ │  ███  │   │  ← Health bars
│ └───────┘   │
│    → NE     │  ← Pending order arrow
└─────────────┘
```

---

## UI Chrome

### Panel Style

```css
.panel {
  background: #FFF5E6;
  border: 2px solid #CE8946;
  box-shadow:
    inset 0 0 30px rgba(143, 89, 34, 0.08),
    2px 3px 8px rgba(0, 0, 0, 0.15);
}
```

### Button Style

```css
.btn-bronze {
  background: linear-gradient(180deg, #CE8946 0%, #7F5522 100%);
  border: 2px solid #603C18;
  color: #FFF5E6;
  font-family: 'Cinzel', serif;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
```

### Decorative Elements

| Element | Usage |
|---------|-------|
| Greek key border | Main battlefield frame |
| Laurel wreath | Victory screen, achievements |
| Shield icon | Unit type indicators |

---

## Layout

### Desktop (Primary)

```
┌────────────────────────────────────────────────────┐
│  PHALANX                    Turn 5    [Theme] [?]  │  ← Navbar
├────────┬──────────────────────────────┬────────────┤
│        │                              │            │
│ Turn   │                              │ Selected   │
│ Info   │                              │ Unit       │
│        │                              │            │
│ ────── │        HEX BATTLEFIELD       │ ────────── │
│        │                              │            │
│ Compass│         (10 × 10)            │ Orders     │
│        │                              │ Queue      │
│ ────── │                              │            │
│        │                              │ ────────── │
│ Keys   │                              │ [Submit]   │
│        │                              │ [Clear]    │
├────────┴──────────────────────────────┴────────────┤
│  Phase: Collecting Orders          Red: 5  Prp: 4  │  ← Status
└────────────────────────────────────────────────────┘
```

Ratios: Left sidebar (1/6), Battlefield (4/6), Right sidebar (1/6).

### Platform Support

Desktop only. No mobile or tablet support. The game is keyboard-driven and not designed for touch input.

---

## Board Orientation (Player Perspective)

Each player sees themselves at the bottom of the board, fighting upward—like sitting across a chess board. The server stores one canonical state; one player's view is transformed.

### Design

| Player | Perspective | Board Transform |
|--------|-------------|-----------------|
| **Home** (e.g., Red) | Canonical | None |
| **Away** (e.g., Purple) | Flipped | 180° rotation |

The "home" player sees the board as stored. The "away" player sees coordinates and rotations transformed so their units appear at the bottom.

### What Gets Transformed

| Element | Canonical | Away Player View |
|---------|-----------|------------------|
| **Hex coordinates** | `{col, row}` | `{max_col - col, max_row - row}` |
| **Unit rotation** | `rotation` | `(rotation + 180) mod 360` |
| **Movement directions** | Absolute (NE, E, SE...) | Flipped (SW, W, NW...) |
| **Compass widget** | Shows absolute | Shows player-relative |

### Coordinate Flip (Odd-R Offset Grid)

For a 10×10 grid (indices 0-9):

```
Canonical {3, 2}  →  Away view {6, 7}

Formula:
  flipped_col = (max_col - 1) - col  = 9 - 3 = 6
  flipped_row = (max_row - 1) - row  = 9 - 2 = 7
```

### Rotation Flip

Unit facing rotates 180°:

```
Canonical 0° (pointing right)   →  Away view 180° (pointing left)
Canonical 60° (pointing NE)     →  Away view 240° (pointing SW)
```

### Keybinding Translation (Critical)

The away player's board is upside-down. Their keypresses must be translated to canonical directions.

**Current keybindings** (from `hotkeys.js`):

| Key | Visual Direction | Canonical (Home) |
|-----|------------------|------------------|
| W | Up-left | NW |
| E | Up-right | NE |
| A | Left | W |
| F | Right | E |
| S | Down-left | SW |
| D | Down-right | SE |

**Away player translation:**

When the away player presses a key, they see their units at the bottom. "Up" for them is canonical "down." Every direction flips 180°:

| Key | Away Player Sees | Canonical Direction |
|-----|------------------|---------------------|
| W | Up-left | **SE** (not NW) |
| E | Up-right | **SW** (not NE) |
| A | Left | **E** (not W) |
| F | Right | **W** (not E) |
| S | Down-left | **NE** (not SW) |
| D | Down-right | **NW** (not SE) |

**Rotation keys (Q, R):** No translation needed. Clockwise is clockwise regardless of viewing angle.

**Unit selection keys (Y/U/I/O/P, H/J/K/L/M):** No translation needed. Units are selected by identity (name), not position. Red player always uses Y/U/I/O/P; Purple player always uses H/J/K/L/M.

**Where translation happens:**

In the LiveView hotkey event handler, before storing the order:

```elixir
# In Game LiveView handle_event("hotkey", ...)
def handle_event("hotkey", %{"key" => key}, socket) do
  direction = key_to_direction(key)

  # Translate for away player
  direction = if socket.assigns.player_perspective == :away do
    flip_direction(direction)
  else
    direction
  end

  # Store order with canonical direction
  {:noreply, add_order(socket, direction)}
end
```

### Implementation Approach

**Option A: Transform in Render (Recommended)**

LiveView transforms coordinates when rendering for away player. No JS needed.

```elixir
# In Game LiveView
defp maybe_flip_for_player(state, player) do
  if player.team == :away do
    flip_board(state)
  else
    state
  end
end

defp flip_board(state) do
  {max_x, max_y} = state.map_dimensions

  flipped_units =
    state.units
    |> Enum.map(fn {{x, y}, unit} ->
      {{max_x - 1 - x, max_y - 1 - y},
       %{unit | rotation: rem(unit.rotation + 180, 360)}}
    end)
    |> Map.new()

  %{state | units: flipped_units}
end
```

**Option B: CSS Transform**

Apply `transform: rotate(180deg)` to battlefield container. Simpler but text appears upside-down; requires counter-rotation on labels.

```css
.battlefield--flipped {
  transform: rotate(180deg);
}
.battlefield--flipped .unit-label {
  transform: rotate(180deg); /* counter-rotate text */
}
```

**Recommendation**: Option A (transform in render). Cleaner output, no upside-down text issues, direction labels naturally correct.

### Order Translation

**Two things need translation for away player:**

1. **Direction** — translated at keypress time (see above)
2. **Position** — the unit's position in the order must be canonical

When away player selects a unit, they see it at flipped coordinates. The order must reference canonical position:

```elixir
defp translate_order_for_away(order, map_dimensions) do
  {max_x, max_y} = map_dimensions
  {x, y} = order.position

  %{order |
    position: {max_x - 1 - x, max_y - 1 - y}
    # direction already translated at input time
  }
end
```

**Complete direction flip helper:**

```elixir
defp flip_direction(nil), do: nil
defp flip_direction(:northeast), do: :southwest
defp flip_direction(:east), do: :west
defp flip_direction(:southeast), do: :northwest
defp flip_direction(:southwest), do: :northeast
defp flip_direction(:west), do: :east
defp flip_direction(:northwest), do: :southeast
```

### Compass Widget

The compass shows which key moves which direction. Both players see identical compasses—keys in the same positions, same labels. The translation is invisible to the player.

**Both players see:**
```
     W       E
      NW   NE
   A  W  ·  E  F
      SW   SE
     S       D
```

- Home player presses W → moves NW (canonical NW)
- Away player presses W → moves NW (their visual NW, which is canonical SE)

**The compass never changes.** Labels are player-relative. When the away player presses W, they see their unit move toward the top-left of their screen, which matches the compass. The fact that it's canonical SE is an implementation detail handled by the server.

**No compass rotation needed.** The keybinding translation in `handle_event` makes the compass "just work."

### Edge Cases

| Case | Handling |
|------|----------|
| Spectators | Show canonical (home) view, or let them toggle |
| Replay | Show from winner's perspective, or canonical |
| Asymmetric maps | Flip terrain features along with units |

### Files Affected

| File | Change |
|------|--------|
| `lib/phalanx_web/live/game.ex` | Add `flip_board/1`, apply before render |
| `lib/phalanx_web/components/hex.ex` | No change (receives already-flipped state) |
| `lib/phalanx/order.ex` | Add direction flip helpers |
| `lib/phalanx_web/game_session.ex` | Track which player is "home" vs "away" |

---

## State Visualization

### Order States

| State | Visual Treatment |
|-------|------------------|
| No order | Unit at rest, no overlay |
| Move pending | Ghost arrow from unit to target hex |
| Rotate pending | Curved arrow around unit |
| Move + rotate | Arrow + rotation indicator |

### Combat Indicators

| Status | Visual |
|--------|--------|
| In phalanx | Gold shield icon overlay |
| Flanked | Red broken-shield icon |
| Low health | Health bars turn red |
| Routing | Unit opacity reduced, footprint trail |

---

## Animation Strategy

### V1: CSS Only

```css
.unit-svg {
  transition: transform 0.3s ease-out;
}
```

LiveView morphdom preserves elements; CSS handles transitions. This is sufficient for turn-based gameplay.

**V1 does not use any JavaScript rendering libraries.** No Pixi.js, Phaser, Canvas 2D, or WebGL.

### Future Work (Out of Scope for V1)

If post-v1 development requires advanced animations, consider Pixi.js for:
- Unit slides along movement path
- Combat clash effect at contact point
- Shield-lock animation when phalanxes meet
- Dust particles on movement

See `technology-comparison.md` for evaluation. This is explicitly **not part of v1**.

---

## Accessibility

| Feature | Implementation |
|---------|----------------|
| Keyboard-only | Already supported |
| Screen reader | Add ARIA labels to hexes and units |
| Color blind | Shapes/patterns in addition to team colors |
| High contrast | Respect `prefers-contrast` media query |

---

## Implementation Priorities

### V1 Scope
1. Apply color palette to existing components
2. Add Cinzel font for headers
3. Add Greek key border to battlefield
4. Implement order preview arrows
5. CSS transitions for movement
6. Status icon overlays
7. Panel restyling (parchment texture)

### Out of Scope (Future Work)
The following are explicitly **not part of v1**:
- Pixi.js or other JS rendering libraries
- Canvas 2D rendering
- WebGL effects
- Tauri desktop app
- Sound design

---

## File Changes Required

| File | Changes |
|------|---------|
| `assets/css/app.css` | Add phalanx theme colors, fonts |
| `lib/phalanx_web/components/hex.ex` | Order preview overlay, status icons |
| `lib/phalanx_web/components/layouts.ex` | Navbar restyling |
| `lib/phalanx_web/live/game.ex` | Order preview state |
| `assets/css/hex.css` | Grid line styling, terrain colors |
