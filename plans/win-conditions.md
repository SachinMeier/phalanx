# Win Conditions and Game Modes

Design document for Phalanx victory mechanics and gameplay variants.

## Win Conditions

### 1. Elimination

**Rule**: Destroy all enemy units.

| Pros | Cons |
|------|------|
| Simple, universally understood | Games can drag when outcome is decided |
| No additional state tracking | Snowball: losing side has fewer options |
| Natural conclusion | May discourage tactical retreat |

**Implementation**: Check `units` map for remaining team colors after each turn.

---

### 2. Objective Control

**Rule**: Hold designated hexes for N consecutive turns OR accumulate control points.

**Variants**:
- **Domination**: Hold 3+ of 5 control points simultaneously
- **Capture**: Hold enemy's home objective for 3 turns
- **King of the Hill**: Single central hex, first to 5 points

| Pros | Cons |
|------|------|
| Creates focal points for combat | Requires map design consideration |
| Rewards positioning over attrition | Additional state: turn counters per hex |
| Comeback mechanics possible | Can feel arbitrary |

**Implementation**:
```elixir
%Game{
  objectives: %{
    {5, 5} => %{controller: :red, held_turns: 2},
    {3, 7} => %{controller: nil, held_turns: 0}
  },
  scores: %{red: 3, purple: 1}
}
```

---

### 3. Push Victory

**Rule**: Move any unit to enemy's back row (row 0 for red, row 9 for purple on 10x10).

| Pros | Cons |
|------|------|
| Rewards aggression | Can feel sudden/anticlimactic |
| Creates natural front line | May ignore tactical depth |
| Fast resolution | Heavily favors mobile units |

**Implementation**: Check unit positions after movement phase. Single unit reaching goal row triggers immediate win.

---

### 4. Morale/Rout

**Rule**: Lose 50%+ of starting units = army breaks. Remaining units flee.

| Pros | Cons |
|------|------|
| Faster games | Threshold feels arbitrary |
| Historically plausible | Comebacks harder |
| Avoids grinding last units | "Almost won" frustration |

**Implementation**:
```elixir
%Game{
  starting_unit_counts: %{red: 5, purple: 5},
  rout_threshold: 0.5
}
```

---

### 5. Turn Limit + Victory Points

**Rule**: Fixed turn count (e.g., 20). Most VP wins.

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

## Recommended Default

**Primary**: Elimination (simple, clear)
**Secondary**: Turn limit with VP (for competitive/timed play)

Start with elimination. Add objective control once terrain/map variety exists.

---

## Game Modes

### 1. Standard (1v1)

- Equal unit count per side
- Symmetric map (or rotationally symmetric)
- Identical unit compositions
- Pure skill test

**Default config**:
- 5 units per side
- 10x10 grid
- Units start on rows 0-1 (purple) and 8-9 (red)

---

### 2. Quick Battle

- 3 units per side
- 8x8 grid
- 10 turn limit
- Simplified VP: kills only

Target duration: 5 minutes.

---

### 3. Skirmish (Asymmetric)

- Attacker gets more units, defender gets position
- Asymmetric win conditions
  - Attacker: eliminate 60% of defenders OR reach objective
  - Defender: survive N turns OR eliminate 40% of attackers

**Example scenario**:
- Attacker: 7 units, starts rows 7-9
- Defender: 4 units, starts rows 0-2, defends hex (5,1)

---

### 4. Siege

- Defender holds fortified position (future: terrain bonuses)
- Attacker must break through
- Defender wins by surviving

---

## Map Design Guidelines

### Grid Size

| Size | Units | Duration | Complexity |
|------|-------|----------|------------|
| 8x8 | 3-4 | 5 min | Low |
| 10x10 | 5-6 | 10 min | Medium |
| 12x12 | 7-8 | 15 min | High |

### Starting Positions

**Symmetric**: Mirror across center horizontal axis.

```
Row 0-1: Purple starting zone
Row 2-7: Neutral
Row 8-9: Red starting zone
```

### Objective Placement

- **Center**: Creates clash point (King of the Hill)
- **Flanks**: Spreads combat, rewards maneuvering
- **Home bases**: Creates capture-the-flag dynamic

---

## Implementation Priority

1. **Elimination** - Already implicit, formalize check
2. **Turn limit** - Add `max_turns` to Game struct
3. **Rout** - Simple percentage check
4. **Objective control** - Requires map/objective system first

---

## Data Structure Changes

```elixir
defmodule Phalanx.Game do
  defstruct [
    # existing fields...

    # Win condition config
    win_condition: :elimination,  # :elimination | :objectives | :rout | :turn_limit
    max_turns: nil,               # for :turn_limit mode
    rout_threshold: 0.5,          # for :rout mode

    # Objective state (when applicable)
    objectives: %{},              # %{position => %{controller: atom, held_turns: int}}
    scores: %{red: 0, purple: 0},

    # Tracking
    starting_unit_counts: %{},    # set at game start
  ]
end
```

---

## Open Questions

1. Should eliminated players spectate or leave?
2. Draw conditions? (mutual elimination, timeout)
3. Sudden death if turn limit reached with tie?
4. Should objectives be visible from game start or revealed?
