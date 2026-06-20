# UI Specification: Phalanx

Hex-grid tactical game with ancient phalanx warfare theme. LiveView + SVG rendering.

---

## Design Philosophy

| Principle | Meaning |
|-----------|---------|
| **Clarity over decoration** | Information first. Ornament serves function. |
| **Ancient, not fantasy** | Historical weight, not D&D aesthetic. |
| **Simultaneous resolution** | UI shows pending orders, not just current state. |
| **Desktop-first** | Keyboard-driven. No mobile/touch support. |

**Visual Metaphor**: Commander's sand table—a tactical planning surface. Units are markers; the grid is terrain. Chrome evokes parchment maps and bronze instruments.

---

## Visual Language

### Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| **Background** | `#FFF5E6` | Parchment panels, sidebars |
| **Surface** | `#E5DBB7` | Cards, tooltips |
| **Primary** | `#CE8946` | Bronze buttons, borders, highlights |
| **Accent** | `#FACD1E` | Gold selection, victory, emphasis |
| **Text** | `#603C18` | Dark earth, primary text |
| **Text secondary** | `#9D8C71` | Stone, labels, hints |
| **Danger** | `#7F2122` | Roman red, errors, flanked status |

### Team Colors

| Team | Hex | Notes |
|------|-----|-------|
| **Red** | `#D32929` | Legionary red, warm |
| **Purple** | `#5D3A8E` | Tyrian purple, royal |

### Typography

| Role | Font | Weight |
|------|------|--------|
| **Display/Headers** | Cinzel | 400/700 |
| **Body** | Source Sans Pro | 400 |
| **Stats/mono** | JetBrains Mono | 400 |

Cinzel evokes Roman inscriptions. Use sparingly—headers and unit names only.

```html
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;700&family=Source+Sans+3:wght@400;600&display=swap" rel="stylesheet">
```

---

## Component Architecture

```
Game LiveView
├── Battlefield
│   ├── HexGrid
│   │   ├── HexTile (terrain + highlight state)
│   │   └── UnitMarker (SVG + health + facing)
│   └── OrderOverlay (pending moves as arrows)
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

## Layout

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

---

## Hex Grid Design

### Grid Appearance

- **Lines**: 1px, `rgba(157, 140, 113, 0.3)` (stone at 30%)
- **Fill**: Uniform color (terrain-based fill is future work)
- **Selected hex**: 2px gold (`#FACD1E`) border
- **Movement range**: Dashed bronze border

### Unit Markers

SVG polygon with rotation transform. Elements:
- Health bar along left edge
- Facing indicator: small triangle pointing forward
- Status icon overlay (flanked, phalanx bonus)
- Order preview: ghost arrow showing pending move

```
┌─────────────┐
│  ▲ facing   │
│ ┌───────┐   │
│ │   Y   │   │  ← Unit name
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
| Laurel wreath | Victory screen |
| Shield icon | Unit type indicators |

---

## Board Orientation (Player Perspective)

Each player sees themselves at the bottom of the board. Server stores canonical state; away player's view is transformed.

| Player | Board Transform |
|--------|-----------------|
| **Home** (Red) | None (canonical view) |
| **Away** (Purple) | 180° rotation |

### What Gets Transformed

| Element | Away Player Transform |
|---------|----------------------|
| Hex coordinates | `{max_col - col, max_row - row}` |
| Unit rotation | `(rotation + 180) mod 360` |
| Movement directions | Flipped 180° |

### Coordinate Flip (10×10 Grid)

```
Canonical {3, 2}  →  Away view {6, 7}
```

### Keybinding Translation

Away player's keypresses must translate to canonical directions:

| Key | Away Player Sees | Canonical Direction |
|-----|------------------|---------------------|
| W | Up-left | **SE** (not NW) |
| E | Up-right | **SW** (not NE) |
| A | Left | **E** (not W) |
| F | Right | **W** (not E) |
| S | Down-left | **NE** (not SW) |
| D | Down-right | **NW** (not SE) |

**Rotation keys (Q, R)**: No translation needed.
**Unit selection keys**: No translation—units selected by identity.

### Implementation

Transform in LiveView render (Option A). No CSS transform (avoids upside-down text).

```elixir
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

defp flip_direction(nil), do: nil
defp flip_direction(:northeast), do: :southwest
defp flip_direction(:east), do: :west
defp flip_direction(:southeast), do: :northwest
defp flip_direction(:southwest), do: :northeast
defp flip_direction(:west), do: :east
defp flip_direction(:northwest), do: :southeast
```

### Order Translation

Away player's order position must be flipped to canonical:

```elixir
defp translate_order_for_away(order, {max_x, max_y}) do
  {x, y} = order.position
  %{order | position: {max_x - 1 - x, max_y - 1 - y}}
end
```

### Compass Widget

Both players see identical compass—keys in same positions. Translation is invisible.

```
     W       E
      NW   NE
   A  W  ·  E  F
      SW   SE
     S       D
```

---

## State Visualization

### Order States

| State | Visual |
|-------|--------|
| No order | Unit at rest |
| Move pending | Ghost arrow to target hex |
| Rotate pending | Curved arrow around unit |
| Move + rotate | Arrow + rotation indicator |

### Combat Indicators

| Status | Visual |
|--------|--------|
| In phalanx | Gold shield icon overlay |
| Flanked | Red broken-shield icon |
| Low health | Health bars turn red |
| Routing | Reduced opacity, footprint trail |

---

## Animation Strategy (V1)

CSS transitions only. No JavaScript rendering libraries.

```css
.unit-svg {
  transition: transform 0.3s ease-out;
}
```

LiveView morphdom preserves elements; CSS handles transitions.

---

## Accessibility

| Feature | Implementation |
|---------|----------------|
| Keyboard-only | Already supported |
| Screen reader | ARIA labels on hexes and units |
| Color blind | Shapes/patterns + team colors |
| High contrast | `prefers-contrast` media query |

---

## V1 Implementation Priorities

1. Apply color palette to existing components
2. Add Cinzel font for headers
3. Add Greek key border to battlefield
4. Implement order preview arrows
5. CSS transitions for movement
6. Status icon overlays
7. Panel restyling (parchment texture)
8. Board orientation flip

### Files to Modify

| File | Changes |
|------|---------|
| `assets/css/app.css` | Theme colors, fonts |
| `lib/phalanx_web/components/hex.ex` | Order preview, status icons |
| `lib/phalanx_web/components/layouts.ex` | Navbar restyling |
| `lib/phalanx_web/live/game.ex` | Order preview state, board flip |
| `assets/css/hex.css` | Grid line styling |

---

## Future Work

Post-v1 considerations (no implementation details):
- Pixi.js or Canvas 2D for advanced animations (combat effects, particles)
- Tauri for desktop app
- Sound design
- Terrain variety (visual differentiation)
