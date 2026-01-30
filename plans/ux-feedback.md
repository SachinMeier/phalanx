# UX Spec: Combat Feedback System

**Purpose**: Define how Phalanx communicates combat resolution to players through visual, temporal, and informational feedback.

---

## Context

- Orders are simultaneous; players submit blindly
- Resolution has 10 phases (see `resolution-order.md`)
- Current UI: static hex grid, right sidebar shows pending orders, no post-resolution feedback
- Tech: Phoenix LiveView, PubSub broadcasts state to all clients

---

## Design Principles

| Principle | Meaning |
|-----------|---------|
| **Clarity over realism** | Players understand what happened, not simulate history |
| **Show causality** | Every outcome traces to visible cause |
| **Progressive disclosure** | Summary first, details on demand |
| **Synchronized experience** | All clients see same animation at same time |

---

## 1. Order Preview (Pre-Submit)

### 1.1 Destination Indicator

Show ghost marker where selected unit will move.

```
Current unit at (3,2), ordered to move NE:
  - Faded hexagon outline at (3,1) or (4,1) depending on row parity
  - Color matches unit team
  - Opacity: 40%
```

**Implementation**: In `hex_grid/1`, render preview hex for each order in `assigns.orders`.

### 1.2 Movement Arrow

Draw arrow from current position to destination.

```
SVG path from unit center to ghost hex center
  - Stroke: team color
  - Opacity: 60%
  - Arrowhead at destination
```

### 1.3 Conflict Warning (Optional)

If destination is enemy-occupied, show crossed swords icon on destination hex.

**Recommendation**: Skip for MVP. Players learn conflict rules through play. Adding warnings adds clutter and removes discovery.

### 1.4 Strength Preview (Optional)

Tooltip showing estimated strength breakdown on hover.

**Recommendation**: Skip for MVP. Too much information reduces tension. Players should commit orders with incomplete information.

---

## 2. Resolution Animation

### 2.1 Animation Phases

Map 10 engine phases to 3 visual phases. Collapse internal logic; players see outcomes.

| Visual Phase | Duration | Engine Phases Collapsed |
|--------------|----------|-------------------------|
| **Movement** | 800ms | 1-7 (snapshot through movement execution) |
| **Combat** | 600ms | 8 (damage & retreat) |
| **Cleanup** | 400ms | 9-10 (rotation, energy) |

Total: 1800ms per turn resolution.

### 2.2 Movement Phase (800ms)

All successful moves animate simultaneously.

```
1. Units that will move: scale down slightly (0.95x) for 100ms
2. Translate to new position over 500ms (ease-out)
3. Scale back to 1x over 200ms
```

**Balked units**: Flash red border (100ms on, 100ms off, repeat once). No position change.

**Implementation**:
- Server broadcasts `{:resolution, %{movements: [...], balks: [...]}}`
- Client uses CSS transitions on unit SVG transform
- `phx-hook="Resolution"` triggers animation sequence

### 2.3 Combat Phase (600ms)

Show damage and retreat.

```
1. Damage numbers float up from damaged unit (200ms fade-in, 400ms float up and fade-out)
2. Dislodged units slide to retreat hex (400ms, starts at 200ms mark)
3. Destroyed units shrink to 0 and fade out (400ms)
```

**Damage number styling**:
```
-1 HP: Red, font-size 18px
-2 HP: Red, font-size 22px, bold
-3 HP: Red, font-size 26px, bold, slight shake
```

### 2.4 Cleanup Phase (400ms)

Show rotation and energy changes.

```
1. Rotating units: animate rotation over 300ms (CSS rotate transition)
2. Energy change: small +1 or -1 floats near unit (matches damage number style, but gray)
3. Zero-energy deaths: same shrink/fade as combat deaths
```

### 2.5 Animation Synchronization

**Problem**: Network latency causes clients to receive state at different times.

**Solution**: Server includes `resolution_timestamp` in broadcast. Client delays animation start until timestamp. All clients see animation at same wall-clock time (within network jitter tolerance).

```elixir
# Server
Phoenix.PubSub.broadcast(Phalanx.PubSub, topic, {:resolution, %{
  movements: movements,
  damage: damage,
  retreats: retreats,
  start_at: System.monotonic_time(:millisecond) + 200  # 200ms future
}})
```

```javascript
// Client hook
const delay = message.start_at - performance.now();
setTimeout(() => playAnimation(message), Math.max(0, delay));
```

---

## 3. Damage Indicators

### 3.1 Health Display on Units

Show health as pips on unit SVG (existing implementation shows 3 lines for health). Keep this.

Add health bar below unit for clearer reading:
```
3 HP: ███ (green)
2 HP: ██░ (yellow)
1 HP: █░░ (red)
0 HP: unit removed
```

**Implementation**: Add `<rect>` elements to `unit_svg/1` component.

### 3.2 Floating Damage Numbers

On damage:
1. Create `<text>` element at unit position
2. Content: `-N` where N is damage amount
3. Animate: translate-y -40px, opacity 1 -> 0, over 600ms
4. Color: red

```elixir
# New component
defp damage_number(assigns) do
  ~H"""
  <text
    class="damage-number animate-float-up"
    x={@x}
    y={@y}
    fill="red"
    font-size="18"
    font-weight="bold"
  >
    -<%= @amount %>
  </text>
  """
end
```

### 3.3 Hit Flash

On receiving damage:
1. Unit fill color flashes white for 100ms
2. Returns to team color

**Implementation**: CSS animation triggered by class toggle.

```css
.unit-hit {
  animation: hit-flash 200ms ease-out;
}

@keyframes hit-flash {
  0%, 100% { filter: brightness(1); }
  50% { filter: brightness(2); }
}
```

---

## 4. Formation Visualization

### 4.1 Phalanx Group Highlight

Show detected phalanx formations with connecting visual.

**Option A: Glow outline** (Recommended)
- Shared glow color around grouped units
- Color: lighter version of team color
- Intensity: brighter with more units

**Option B: Connecting lines**
- SVG lines between adjacent grouped units
- Too cluttered with large formations

**Implementation**: During render, check if unit is in a group. If yes, apply glow class.

```elixir
defp unit_classes(unit, groups) do
  in_group? = Enum.any?(groups, fn g ->
    MapSet.member?(g.positions, unit.position) && MapSet.size(g.positions) > 1
  end)

  if in_group?, do: "unit-in-formation", else: ""
end
```

```css
.unit-in-formation {
  filter: drop-shadow(0 0 4px currentColor);
}
```

### 4.2 Strength Bonus Source

On unit hover, show tooltip with strength breakdown:
```
Base:        1
Formation:  +2 (2 allies)
Support:    +1 (1 pusher)
Total:       4
```

**Implementation**: `phx-mouseenter` pushes event, server returns strength calculation, displayed in overlay.

**Recommendation**: Defer to post-MVP. Information overload during active play.

### 4.3 Facing Visualization

Current: Unit rotation via CSS transform. Clear for most players.

Enhancement: Add small arrow indicator on unit front edge.

```elixir
# In unit_svg, add facing indicator
<path
  d={"M #{@w*0.5},0 L #{@w*0.35},#{@w*0.15} L #{@w*0.65},#{@w*0.15} Z"}
  fill="white"
  opacity="0.6"
/>
```

---

## 5. Combat Log

### 5.1 Turn Summary Panel

Replace right sidebar during resolution phase with turn summary.

```
Turn 5 Summary
--------------
Movements: 3
Balks: 1
Combat:
  Y attacked K (3 vs 2) -> K dislodged
  K retreated to (4,3)
  K took 2 damage (flank + dislodge)
Casualties: 0
```

**Implementation**: Server includes `resolution_log` in broadcast. Displayed in sidebar.

### 5.2 Event Log Format

Each event is a structured entry:

```elixir
@type log_entry ::
  {:move, position, destination} |
  {:balk, position, reason} |
  {:attack, attacker_pos, defender_pos, attacker_str, defender_str, outcome} |
  {:damage, position, amount, reasons} |
  {:retreat, position, destination | :destroyed} |
  {:rotation, position, new_rotation} |
  {:energy_change, position, delta}
```

### 5.3 Expandable Details

Log entries collapse by default. Click to expand details.

**Collapsed**: "Y attacked K -> K dislodged (-2 HP)"
**Expanded**:
```
Y (3,2) attacked K (4,2)
  Attack direction: East
  Y strength: 3 (base 1, formation +2)
  K strength: 2 (base 1, formation +1)
  Outcome: K dislodged
  Damage: 2 (dislodge: 1, flank: 1)
  K retreated to (4,3)
```

### 5.4 History Navigation

Keep last 10 turns of logs. Tabs or dropdown to view past turns.

**Implementation**: Store `resolution_logs` in Game GenServer state.

---

## 6. "Why Did That Happen?" Explanations

### 6.1 Unexpected Outcome Triggers

Auto-display explanation when:
- Player unit balks (intended move failed)
- Player unit takes unexpected damage
- Player attack fails (defender wins)

### 6.2 Explanation Overlay

Triggered by clicking "?" icon on any log entry or unit.

**Balk explanation**:
```
Your unit H balked.

Reason: Destination conflict
  - H tried to move to (3,2)
  - Enemy Y also targeted (3,2)
  - Y strength: 4, H strength: 2
  - Higher strength wins; H holds position
```

**Damage explanation**:
```
Your unit H took 2 damage.

Sources:
  - Dislodged: -1 HP (base dislodge penalty)
  - Flank attack: -1 HP (attacked from side)
```

### 6.3 Strength Breakdown Tooltip

On hover over strength numbers in log or overlay:
```
Strength: 4
  Base:       1
  Side ally:  +1 (unit J adjacent, same facing)
  Side ally:  +1 (unit K adjacent, same facing)
  Rear push:  +1 (unit L pushing, same direction)
  Cap:        4 (max bonus reached)
```

---

## 7. Turn Summary Screen

### 7.1 End-of-Turn Stats

After resolution animation, show summary overlay (dismissable):

```
╔══════════════════════════════════╗
║         TURN 5 COMPLETE          ║
╠══════════════════════════════════╣
║  Red Team         Purple Team    ║
║  ─────────        ───────────    ║
║  Units: 5 (-1)    Units: 4 (-0)  ║
║  Damage dealt: 3  Damage dealt: 1║
║  Hexes gained: 1  Hexes gained: 0║
╠══════════════════════════════════╣
║  [View Details]    [Continue]    ║
╚══════════════════════════════════╝
```

**Implementation**: Rendered as modal component. "Continue" dismisses and enables next turn orders.

### 7.2 Casualty Report

"View Details" expands:
```
Casualties this turn:
  Red K destroyed at (5,3) - no retreat available

Damage taken:
  Red H: 3 -> 1 HP
  Purple Y: 3 -> 2 HP
```

### 7.3 Territory Changes

If territorial control becomes a game element:
```
Territory:
  (3,2) now Red-controlled (was contested)
  (4,3) now contested (was Purple-controlled)
```

**Recommendation**: Defer. Current game has no territory mechanic.

---

## 8. LiveView Implementation Notes

### 8.1 State Shape Addition

```elixir
# In assigns for PhalanxWeb.Live.Game
%{
  # Existing
  state: %Phalanx.Game{},
  current_unit: position | nil,
  orders: %{position => %Order{}},

  # New for combat feedback
  resolution: nil | %{
    phase: :idle | :movement | :combat | :cleanup | :summary,
    movements: [{from, to, unit}],
    balks: [position],
    damage: [{position, amount, reasons}],
    retreats: [{position, destination | :destroyed}],
    rotations: [{position, new_rotation}],
    log: [log_entry]
  },
  turn_history: [%{turn: int, log: [log_entry]}]
}
```

### 8.2 PubSub Message Shape

```elixir
# Server broadcasts after execute_orders
Phoenix.PubSub.broadcast(
  Phalanx.PubSub,
  Game.state_topic(state.id),
  {:resolution, %{
    state: new_state,
    movements: movements,
    balks: balks,
    damage: damage,
    retreats: retreats,
    rotations: rotations,
    log: log,
    start_at: timestamp
  }}
)
```

### 8.3 Client Hooks

```javascript
// assets/js/resolution.js
export const Resolution = {
  mounted() {
    this.handleEvent("resolution_start", ({ start_at, movements, damage, retreats }) => {
      const delay = start_at - performance.now();
      setTimeout(() => {
        this.playMovements(movements);
        setTimeout(() => this.playCombat(damage, retreats), 800);
        setTimeout(() => this.playCleanup(), 1400);
        setTimeout(() => this.showSummary(), 1800);
      }, Math.max(0, delay));
    });
  },

  playMovements(movements) {
    movements.forEach(({ from, to, unit }) => {
      const el = document.querySelector(`[data-unit-pos="${from}"]`);
      if (el) {
        el.classList.add('moving');
        el.style.transform = this.calculateTransform(from, to);
      }
    });
  },
  // ...
};
```

---

## 9. Priority Roadmap

### MVP (PR #1)

1. **Destination ghost hex** - Show where unit will move
2. **Balk flash** - Red border flash on failed move
3. **Damage numbers** - Floating numbers on damage
4. **Health bar** - Visual health indicator

### Phase 2 (PR #2)

5. **Movement animation** - Smooth translation
6. **Combat log sidebar** - Turn event list
7. **Hit flash** - Unit flash on damage

### Phase 3 (PR #3)

8. **Turn summary modal** - End-of-turn stats
9. **Retreat animation** - Dislodge slide
10. **Formation glow** - Phalanx highlight

### Phase 4 (PR #4)

11. **Explanation overlays** - "Why" popups
12. **Strength tooltips** - Breakdown on hover
13. **Animation sync** - Cross-client timing
14. **Turn history** - View past logs

---

## 10. Open Questions

1. **Animation speed preference**: Should players be able to adjust? Checkbox for "instant resolution"?

2. **Mobile touch**: Hover-based tooltips don't work. Tap-and-hold? Dedicated info button?

3. **Colorblind modes**: Red/green damage indicators may be problematic. Use shapes or patterns?

4. **Sound effects**: Scope creep, but audio feedback significantly improves feel. Defer to separate spec?

---

## Appendix: CSS Animation Classes

```css
/* Movement */
.unit-moving {
  transition: transform 500ms ease-out;
}

/* Balk */
.unit-balk {
  animation: balk-flash 200ms ease-out 2;
}
@keyframes balk-flash {
  0%, 100% { box-shadow: none; }
  50% { box-shadow: 0 0 10px 3px red; }
}

/* Damage number */
.damage-number {
  animation: float-up 600ms ease-out forwards;
}
@keyframes float-up {
  0% { opacity: 1; transform: translateY(0); }
  100% { opacity: 0; transform: translateY(-40px); }
}

/* Hit */
.unit-hit {
  animation: hit-flash 200ms ease-out;
}
@keyframes hit-flash {
  0%, 100% { filter: brightness(1); }
  50% { filter: brightness(2); }
}

/* Death */
.unit-dying {
  animation: shrink-fade 400ms ease-out forwards;
}
@keyframes shrink-fade {
  0% { transform: scale(1); opacity: 1; }
  100% { transform: scale(0); opacity: 0; }
}

/* Formation glow */
.unit-in-formation {
  filter: drop-shadow(0 0 4px currentColor);
}
```
