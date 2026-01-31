# GUI Technology Comparison

Which rendering technology for Phalanx's hex-grid tactical gameplay.

## V1 Scope: LiveView + SVG Only

**For v1, we use Phoenix LiveView + HTML/CSS/SVG exclusively.** No external JavaScript rendering libraries.

This means:
- No Pixi.js
- No Phaser
- No Canvas 2D rendering
- No Tauri desktop wrapper
- No Three.js or WebGL

The current stack is sufficient for a turn-based game with ~20 units. JS game libraries are unnecessary complexity for v1.

---

## Current Stack

Phoenix LiveView + HTML/CSS/SVG. Server-rendered, real-time via WebSocket.

## Options Evaluated (For Reference)

| Option | Rendering | State Management | Deployment |
|--------|-----------|------------------|------------|
| **LiveView + SVG** (current) | DOM/SVG | Server (GenServer) | Web |
| **LiveView + Canvas 2D** | Canvas API | Server + client | Web |
| **LiveView + Pixi.js** | WebGL | Server + client | Web |
| **Tauri + Web** | Any web tech | Server + client | Desktop app |

Options excluded: Electron (bloated), Unity/Godot (overkill for 2D hex), native mobile (out of scope), Java applets (deprecated).

---

## Comparison Matrix

| Criterion | LiveView + SVG | LiveView + Canvas | LiveView + Pixi.js | Tauri |
|-----------|----------------|-------------------|--------------------| ------|
| **Simplicity** | ★★★★★ | ★★★☆☆ | ★★★☆☆ | ★★☆☆☆ |
| **Animation** | ★★☆☆☆ | ★★★★☆ | ★★★★★ | ★★★★★ |
| **Performance** | ★★★☆☆ | ★★★★☆ | ★★★★★ | ★★★★★ |
| **Multiplayer fit** | ★★★★★ | ★★★★★ | ★★★★★ | ★★★★☆ |
| **Dev speed** | ★★★★★ | ★★★☆☆ | ★★★☆☆ | ★★☆☆☆ |
| **Learning curve** | None | Medium | Medium | High |

---

## Option 1: LiveView + SVG (Current)

**How it works**: Server renders SVG elements, LiveView diffs and patches DOM.

**Pros**:
- Zero JavaScript for game logic
- Full server authority (anti-cheat by default)
- Existing implementation works
- CSS animations possible (transforms, transitions)
- Accessible (screen readers can parse SVG)

**Cons**:
- DOM manipulation slow for many moving elements
- CSS animations limited (no complex paths)
- Each unit is DOM node (50 units = 50+ SVG elements)
- Rotation/movement jerky without careful CSS

**Best for**: Current scope (10x10 grid, ~20 units). Simple turn-based with minimal animation.

---

## Option 2: LiveView + Canvas 2D

**How it works**: LiveView sends state via hook; JavaScript draws on `<canvas>`.

**Pros**:
- Single canvas element (simpler DOM)
- Smooth animations via requestAnimationFrame
- Full drawing control (paths, gradients, effects)
- LiveView still manages state

**Cons**:
- Must write rendering logic in JavaScript
- Hit detection manual (no DOM events on shapes)
- No CSS styling (all drawing in code)
- Canvas not accessible

**Integration pattern**:
```javascript
// Hook receives state from LiveView
Hooks.GameCanvas = {
  mounted() {
    this.canvas = this.el;
    this.ctx = this.canvas.getContext('2d');
    this.handleEvent("state_update", state => this.render(state));
  },
  render(state) { /* draw hexes, units */ }
}
```

**Best for**: Need animations but want to avoid WebGL complexity.

---

## Option 3: LiveView + Pixi.js

**How it works**: Pixi.js renders to WebGL canvas; LiveView sends state updates.

**Pros**:
- GPU-accelerated 2D (handles 1000s of sprites)
- Built-in sprite batching, texture atlases
- Smooth 60fps animations trivial
- Filters, blend modes, particle effects
- Large game-dev community

**Cons**:
- Another dependency (Pixi.js ~300KB)
- Steeper learning curve than Canvas 2D
- WebGL context management
- Overkill for <50 units

**Integration pattern**:
```javascript
Hooks.GamePixi = {
  mounted() {
    this.app = new PIXI.Application({ view: this.el });
    this.handleEvent("state_update", state => this.updateScene(state));
  }
}
```

**Best for**: Polished animations, combat effects, particle systems, larger battles.

---

## Option 4: Tauri Desktop App

**How it works**: Rust-based wrapper runs web frontend as native app.

**Pros**:
- Native performance, small binary (~10MB vs Electron's 150MB)
- Access to filesystem, system tray
- Offline capable
- Still uses your web stack

**Cons**:
- Build/release pipeline complexity
- Must maintain desktop + web versions
- Rust toolchain required
- WebSocket still needed for multiplayer

**Best for**: If you later want a polished standalone product.

---

## V1 Recommendation

### LiveView + SVG + CSS Transitions

The v1 implementation uses:
- Phoenix LiveView for state management
- SVG elements for unit rendering
- CSS transitions for basic animations
- No external JS libraries

This is sufficient for:
- Core gameplay mechanics
- Multiplayer testing
- Rule iteration
- Basic movement animations

```css
.unit-svg {
  transition: transform 0.3s ease-out;
}
```

LiveView's morphdom will animate position changes if CSS transitions are set.

---

## Future Work (Out of Scope for V1)

The following technologies are documented for future reference but are **not part of v1**:

### Pixi.js (Post-V1)

Consider adding when/if you need:
- 60fps smooth animations
- Combat visual effects (clashes, shields breaking)
- Larger battles (100+ units)
- Particle systems (dust, arrows)

**Migration path (future)**:
1. Add Pixi.js via npm
2. Create `GameCanvas` hook
3. Move rendering to client
4. Keep state management in LiveView/GenServer
5. LiveView pushes state → Pixi renders

### Tauri Desktop App (Post-V1)

Consider if you want a standalone desktop product with:
- Offline play
- System tray presence
- Native performance

### Canvas 2D (Alternative to Pixi.js)

Lighter weight than Pixi.js but requires manual hit detection. Consider only if Pixi.js is too heavy.

---

## Decision Matrix

| Phase | Technology | Why |
|-------|------------|-----|
| **V1** | LiveView + SVG | Ship fast, prove mechanics |
| **V1** | CSS transitions | Basic animations, zero JS |
| Post-V1 | Pixi.js | If animations become critical |
| Post-V1 | Tauri | If desktop app is desired |

---

## Verdict

**V1 uses LiveView + SVG exclusively.** The game is turn-based with simultaneous resolution—60fps rendering is unnecessary. Focus on game design, not rendering tech.

JS libraries like Pixi.js, Phaser, and Canvas APIs are future considerations only. Do not add them to v1.
