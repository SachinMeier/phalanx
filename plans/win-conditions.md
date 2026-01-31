# Win Conditions Reference

Reference document describing victory condition types for Phalanx.

**Authoritative implementation spec**: `plans/game-modes/spec.md`

Win conditions are defined as part of game mode configurations. This document serves as background material for the condition types themselves.

---

## Win Condition Types

### 1. Elimination

Destroy all enemy units.

| Pros | Cons |
|------|------|
| Simple, universally understood | Games can drag when outcome is decided |
| No additional state tracking | Snowball: losing side has fewer options |
| Natural conclusion | May discourage tactical retreat |

---

### 2. Objective Control

Hold designated hexes for N consecutive turns, or accumulate control points.

**Variants**:
- **Domination**: Hold 3+ of 5 control points simultaneously
- **Capture**: Hold enemy's home objective for 3 turns
- **King of the Hill**: Single central hex, first to 5 points

| Pros | Cons |
|------|------|
| Creates focal points for combat | Requires map design consideration |
| Rewards positioning over attrition | Additional state: turn counters per hex |
| Comeback mechanics possible | Can feel arbitrary |

---

### 3. Push Victory

Move any unit to enemy's back row (row 0 for red, row 9 for purple on 10x10).

| Pros | Cons |
|------|------|
| Rewards aggression | Can feel sudden/anticlimactic |
| Creates natural front line | May ignore tactical depth |
| Fast resolution | Heavily favors mobile units |

---

### 4. Morale/Rout

Lose 50%+ of starting units, and the army breaks.

| Pros | Cons |
|------|------|
| Faster games | Threshold feels arbitrary |
| Historically plausible | Comebacks harder |
| Avoids grinding last units | "Almost won" frustration |

---

### 5. Turn Limit + Victory Points

Fixed turn count. Most VP wins.

**VP Sources**:
- Unit elimination: 1 VP per unit
- Objective control: 1 VP per turn held
- Territory: 0.5 VP per hex controlled at game end
- Survival bonus: 0.5 VP per surviving unit

| Pros | Cons |
|------|------|
| Guaranteed game length | Complex scoring |
| Multiple paths to victory | Turtling can be optimal |
| Good for competitive play | May need tiebreakers |

---

## Integration with Game Modes

Win conditions are now embedded within game mode definitions. Each mode specifies:

- Which condition type applies
- Condition-specific parameters (thresholds, turn limits, objectives)
- Victory evaluation logic

See `plans/game-modes/spec.md` for the full mode configuration schema.

---

## Current Implementation

**Elimination** is the only implemented win condition.

The backend hardcodes the `:elimination_standard` game mode. No other conditions are implemented or planned for the initial release.

---

## Frontend Strategy

The UI does not expose game mode selection.

- Backend defaults to `:elimination_standard` when creating games
- Mode selection is future work, gated behind multiple condition implementations
- When exposed, mode selection will appear on the game creation screen

---

## Implementation Priority

| Priority | Condition | Status |
|----------|-----------|--------|
| 1 | Elimination | Implemented via game modes |
| 2+ | Objective Control, Rout, Turn Limit, Push Victory | Future work, not currently planned |

Additional conditions require:
- State tracking infrastructure (objectives, scores, turn counters)
- Map editor tooling (objective placement)
- UI for mode-specific information displays

---

## Map Design Guidelines

Map requirements are now part of game mode definitions.

### Grid Size Reference

| Size | Units | Duration | Complexity |
|------|-------|----------|------------|
| 8x8 | 3-4 | 5 min | Low |
| 10x10 | 5-6 | 10 min | Medium |
| 12x12 | 7-8 | 15 min | High |

### Starting Positions

Symmetric across center horizontal axis.

```
Row 0-1: Purple starting zone
Row 2-7: Neutral
Row 8-9: Red starting zone
```

### Objective Placement

- **Center**: Creates clash point (King of the Hill)
- **Flanks**: Spreads combat, rewards maneuvering
- **Home bases**: Creates capture-the-flag dynamic

See game mode definitions for specific map requirements per mode.

---

## Open Questions

1. Draw conditions? (mutual elimination, timeout)
2. Sudden death if turn limit reached with tie?
3. Should objectives be visible from game start or revealed?
