# Phalanx Game Engine

## Game Concept

Phalanx is a simultaneous-turn tactical strategy game inspired by ancient Greek warfare. Two players command formations of units on a hex grid. The core mechanic: units in tight formation (a "phalanx") gain strength bonuses, but expose flanks to devastating attacks.

## Goal Endstate

A full-fledged web-based strategy game where:
- Two players compete in real-time via browser
- Units maneuver in formations to maximize strength bonuses
- Combat resolves based on facing, formation, and support
- Victory achieved by destroying enemy units or forcing retreat
- Energy management creates push/pull tension (advance costs energy, retreat is free)

## Current State

The foundation is in place:
- Hex grid with movement validation
- Unit selection and order input via keyboard
- GenServer-based game state with PubSub sync
- Diplomacy-style conflict resolution (balking on collision)
- Basic turn execution loop

**Not yet implemented:**
- Combat resolution (strength calculation, damage application)
- Energy system (-1E for forward, 0E for backward, +1E for hold if not attacked)
- Phalanx detection (adjacent units facing same direction)
- Support mechanics (units "behind" add strength)
- Win/loss conditions
- Multi-turn gameplay with proper turn progression

## Engine Architecture

### Execution Flow

```
Orders submitted (all players)
         ↓
┌─────────────────────────────────────┐
│  Phalanx.Engine.execute_orders/2    │
├─────────────────────────────────────┤
│ 1. Populate hold orders for units   │
│    without explicit orders          │
│                                     │
│ 2. Calculate new positions          │
│    (validate per rotation rules)    │
│                                     │
│ 3. Detect conflicts (multiple units │
│    targeting same hex)              │
│                                     │
│ 4. If conflicts: convert to holds,  │
│    recurse (cascading failures)     │
│                                     │
│ 5. If no conflicts: apply state     │
│    (rotations first, then moves)    │
└─────────────────────────────────────┘
         ↓
   New game state
```

### Balking (Conflict Resolution)

When two units try to occupy the same hex, both orders **balk** (convert to hold). This can cascade:

```
Unit A → Hex X ← Unit B   // Both balk
Unit C → where A was      // C's move now fails (A stayed), C balks
```

The engine recursively re-executes until no conflicts remain.

### Movement Validation

Movement is constrained by rotation (facing). A unit can only move in 4 of 6 hex directions based on its current rotation:

| Rotation | Allowed Moves |
|----------|---------------|
| 0° / 180° | E, SE, W, NW |
| 60° / 240° | NE, NW, SE, SW |
| 120° / 300° | NE, E, W, SW |

This creates meaningful facing decisions: you cannot sidestep freely, you must commit to a direction.

### Hex Grid Math

Uses **odd-R offset coordinates**. Even and odd rows have different neighbor calculations:

```elixir
# Even rows (y % 2 == 0)
@even_row_moves [
  {1, 0},   # east
  {0, -1},  # northeast
  {-1, -1}, # northwest
  {-1, 0},  # west
  {-1, 1},  # southwest
  {0, 1}    # southeast
]

# Odd rows (y % 2 == 1)
@odd_row_moves [
  {1, 0},   # east
  {1, -1},  # northeast
  {0, -1},  # northwest
  {-1, 0},  # west
  {0, 1},   # southwest
  {1, 1}    # southeast
]
```

## Combat Rules (To Implement)

From `MECHANICS.md`:

### Strength Calculation

Base strength: 1

Bonuses:
- **+1** per adjacent ally in same phalanx (same facing, touching)
- **+1** if unit directly behind is pushing same direction

A unit is **dislodged** if opposing strength > its strength.

### Phalanx Rule

Units in a phalanx move atomically. A phalanx is only dislodged if a **majority** of its members would be dislodged individually.

### Damage

| Situation | Health Lost |
|-----------|-------------|
| Dislodged (any direction) | -1 |
| Flanked (side attack) | -1 |
| Rear attack | -2 |
| Moving non-counterparallel when attacked | -1 |

These stack. Dislodged + flanked = -2 health.

**Counterparallel** = facing within 60° of opposite direction (head-on collision). Moving counterparallel when attacked avoids the -1 penalty.

### Energy

| Action | Energy Change |
|--------|---------------|
| Move forward | -1 |
| Move backward | 0 |
| Hold position (not attacked) | +1 |
| Hold position (attacked) | 0 |
| At 0 energy | -1 health |

## Key Implementation Files

| File | Contains |
|------|----------|
| `lib/phalanx/engine/engine_diplomacy.ex` | Current engine: conflict detection, balking |
| `lib/phalanx/engine/engine.ex` | Engine behaviour definition |
| `lib/phalanx/moves.ex` | Hex math, rotation constraints |
| `lib/phalanx/order.ex` | Order struct and composition |
| `lib/phalanx/game.ex` | GenServer, state management |
| `lib/phalanx/helpers.ex` | Default units, map setup |

## Extension Points

### Adding Combat

1. After conflict resolution, before applying state:
   - Detect adjacent enemy units
   - Calculate strength (base + formation + support)
   - Determine dislodgement
   - Apply damage based on attack angle

2. Add to `Engine` behaviour:
   ```elixir
   @callback resolve_combat(state, movements) :: {state, casualties}
   ```

### Adding Energy

1. Track energy per unit in state
2. Modify `apply_orders_to_state/2`:
   - Forward move: decrement energy
   - Hold (not attacked): increment energy
   - Hold (attacked): no change
   - Check for 0 energy → apply health penalty

### Adding Phalanx Detection

1. Identify connected groups of same-color units with same rotation
2. For dislodgement: check majority rule
3. For movement: atomic execution (all or none)

## Open Design Questions

From `MECHANICS.md`:

1. **Non-linear support**: When support unit isn't directly behind, how does force apply?
2. **60° attacks**: Should they balk if countered? Creates incentive for gaps in line.
3. **Rotation timing**: Attack resolves before rotation, but rotation applies after. Confirm this is intended.
