# Overnight Work Summary: UI/UX Design

**Date**: 2026-01-29
**Work Request**: Create UI architecture and technology comparison documentation for Phalanx

---

## Documents Created

| Document | Path | Summary |
|----------|------|---------|
| Technology Comparison | `plans/UI/technology-comparison.md` | Analysis of 4 GUI options with recommendation |
| UI Architecture | `plans/UI/ui-architecture.md` | Design philosophy, components, visual language |

---

## Key Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Rendering tech | LiveView + SVG only for v1 | Working, sufficient for turn-based; no JS libraries needed |
| Color palette | Parchment/bronze/gold antiquity theme | Evokes ancient warfare without fantasy clichés |
| Typography | Cinzel (headers) + Source Sans Pro (body) | Cinzel mimics Roman inscriptions; readable body text |
| Desktop vs web | Web-first | Multiplayer via WebSocket |
| Animation strategy | CSS transitions only for v1 | No external JS libraries in v1 |
| Board orientation | Transform in render (Elixir) | Each player sees self at bottom; flip coords/rotations server-side before render |

### V1 Scope Clarification

**V1 uses no external JavaScript rendering libraries:**
- No Pixi.js
- No Phaser
- No Canvas 2D
- No Tauri
- No WebGL

These are documented for future reference but are explicitly out of scope for v1.

---

## Visual Design Summary

### Colors
- **Background**: Parchment `#FFF5E6`
- **Primary**: Bronze `#CE8946`
- **Accent**: Gold `#FACD1E`
- **Teams**: Red `#D32929`, Purple `#5D3A8E`

### Fonts
- **Cinzel** for headers (Roman inscription style)
- **Source Sans Pro** for body text

### Chrome
- Parchment-textured panels
- Bronze gradient buttons
- Greek key border on battlefield

---

## Open Questions

1. **Order preview arrows**: SVG overlay or separate layer?
2. **Sound design**: Include ambient/combat audio? (Low priority)

## Answered Questions

| Question | Answer |
|----------|--------|
| Mobile support | No. Desktop-only, keyboard-driven. No touch support planned. |
| Board flip for players | Transform in LiveView render. Home player sees canonical; away player sees flipped coords + 180° rotations. No CSS rotate (avoids upside-down text). |

---

## Recommended Next Steps

1. **Read**: `plans/UI/ui-architecture.md` for full design spec
2. **Read**: `plans/UI/technology-comparison.md` for tech rationale
3. **Implement**: Board orientation flip (see "Board Orientation" section in ui-architecture.md)
4. **Implement**: Apply color palette to `assets/css/app.css`
5. **Implement**: Add Cinzel font import
6. **Implement**: Order preview arrows in hex component

---

## Research Summary

### Current Codebase (from exploration)
- LiveView + SVG rendering works
- CSS hex layout using clip-path and shape-outside
- Hotkey hook captures keyboard input
- PubSub broadcasts state to all clients
- DaisyUI provides component primitives

### Technology Options Evaluated (For Future Reference)

**V1 uses LiveView + SVG exclusively.** Other options documented for post-v1 consideration:

- **LiveView + SVG**: ✓ V1 choice. Simple, working, CSS animations sufficient.
- **LiveView + Canvas**: Out of scope. Better animation but manual hit detection.
- **LiveView + Pixi.js**: Out of scope. Best performance but unnecessary for v1.
- **Tauri**: Out of scope. Desktop wrapper for future consideration.

### Visual Design Research
- Antiquity color palettes (terracotta, bronze, parchment)
- Roman-inspired typography (Cinzel font family)
- Game-icons.net for unit/status iconography
- Greek key patterns for decorative borders
