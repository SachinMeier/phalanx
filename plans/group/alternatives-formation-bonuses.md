# Formation Bonus Alternatives Analysis

**Context**: Phalanx is a simultaneous-turn tactical game simulating ancient Greek warfare. The core question: how should units receive strength bonuses based on their positioning relative to allies?

**Decision**: Explicit phalanx declaration within pre-defined groups. See `group/spec.md` for full specification.

---

## Historical Background

Understanding the real phalanx informs design choices.

### Depth as Strength

Greek phalanxes were typically 8 men deep. The Macedonians used 16. The first 3-5 ranks could project spears forward; rear ranks added "pushing power" (othismos) and replaced fallen soldiers.

Epaminondas at Leuctra (371 BC) massed 50 ranks deep on one wing, demonstrating that depth concentration could break a line. This was revolutionary: depth became a tactical variable, not just a formation constant.

**Design implication**: Depth should matter. A column of 3 units behind each other should fight differently than a line of 3 units abreast.

### Width as Coverage

The phalanx's weakness: flanks. A wider formation covered more ground but thinned the line. Breaking through the center was nearly impossible due to shield overlap and coordinated advance.

**Design implication**: Width provides mutual protection but exposes ends. Formation shape matters.

### The Push (Othismos)

Rear ranks didn't just wait. They pushed forward, adding momentum. If your rear gets attacked, you lose that push.

**Design implication**: Support from behind should be a distinct bonus, and it should be disruptable.

---

## Decision: Explicit Phalanx Declaration Within Groups

### Why This Approach

1. **Historical accuracy**: Forming a phalanx was a deliberate tactical choice, not an emergent property
2. **Costly commitment**: Players must explicitly form up, creating strategic tradeoffs
3. **Clear atomic unit**: Once declared, orders go to the phalanx, not individuals
4. **Breaking formations matters**: Enemies can target a phalanx to break it
5. **Predictability**: Players know exactly what's in a phalanx because they declared it

### Key Rules

| Rule | Description |
|------|-------------|
| Phalanxes require groups | Can only form within a single pre-defined group |
| Explicit declaration | Player issues "Form Phalanx" command |
| Same facing required | All members must share rotation |
| Adjacent positions | Members must be hex neighbors |
| Atomic movement | All members move together or all balk |
| Formation bonus | +1 strength per adjacent phalanx member |

### Deathball Prevention

All phalanx members must share the same rotation. A 7-hex cluster facing east is vulnerable to flanking from north/south. The rotation requirement naturally creates exposed flanks.

---

## Rejected Alternatives

### Option A: Auto-Detected Formations (REJECTED)

**Description**: Engine automatically detects phalanxes from board state (adjacent + same facing + same movement).

**Why rejected**:
- No formation cost (units "accidentally" form phalanxes)
- Ephemeral formations (exist only for one turn)
- Circular logic with atomic movement
- Player unpredictability

### Option B: Stacking (Multiple Units Per Hex) (REJECTED)

**Description**: 2-3 units can occupy the same hex.

**Why rejected**:
- Departure from Diplomacy's 1-unit-per-territory model
- Flanking becomes ambiguous (which hex is "flanked"?)
- Damage distribution complexity
- Visual sparseness (fewer pieces visible)

### Option C: Front/Rear Rank System (REJECTED)

**Description**: Each hex has up to 2 "layers" (Front and Rear).

**Why rejected**:
- Novel position type adds complexity
- Only 2 ranks, not historically deep formations
- Movement awkwardness (what if Rear wants to leave?)

### Option D: Auto-Detected Formation Templates (REJECTED)

**Description**: Engine detects predefined shapes (line of 3, wedge, etc.) and applies bonuses.

**Why rejected**:
- Many templates, complex detection code
- Must match exact shape or no bonus
- Hard to balance different templates
- Players must learn template library

---

## Formation Bonus Calculation

### Chosen Formula

```
Strength = Base + FormationBonus

Where:
  Base = 1
  FormationBonus = count of adjacent allies in same phalanx

  Side allies: max 2 by geometry (1 per side)
  Rear ally: max 1 (directly behind)
  Front ally: does not count (that's the attack direction)

  Maximum bonus: +5 (surrounded by phalanx members)
```

### Why Simple Addition

| Alternative | Reason Rejected |
|-------------|-----------------|
| Diminishing returns | Complex math, harder to predict |
| Separate caps for side/rear | Premature optimization |
| Tiered bonuses | Step functions feel gamey |

Start simple. Playtest. Add differentiation only if needed.

---

## Implementation Summary

### Phalanx Formation

```elixir
def form_phalanx(positions, group, units) do
  with :ok <- validate_same_group(positions, group),
       :ok <- validate_adjacent(positions),
       :ok <- validate_same_rotation(positions, units) do
    {:ok, %Phalanx{positions: MapSet.new(positions), ...}}
  end
end
```

### Formation Bonus

```elixir
def formation_bonus(phalanxes, position, units) do
  case find_phalanx(phalanxes, position) do
    nil -> 0  # Not in a phalanx, no bonus
    phalanx ->
      position
      |> all_hex_neighbors()
      |> Enum.count(&MapSet.member?(phalanx.positions, &1))
  end
end
```

### Atomic Movement

```elixir
def resolve_phalanx_movement(phalanx, order, conflicts) do
  blocked_count = Enum.count(phalanx.positions, &MapSet.member?(conflicts, &1))

  if blocked_count > 0 do
    # All-or-nothing: any block = all balk
    {:balk, phalanx.positions}
  else
    {:move, phalanx.positions}
  end
end
```

---

## Sources

Historical:
- [Phalanx - Britannica](https://www.britannica.com/topic/phalanx-military-formation)
- [The Greek Phalanx - World History Encyclopedia](https://www.worldhistory.org/article/110/the-greek-phalanx/)
- [Battle of Leuctra - History Tools](https://www.historytools.org/stories/the-battle-of-leuctra-a-turning-point-in-ancient-greek-history)
- [Oblique Order - Wikipedia](https://en.wikipedia.org/wiki/Oblique_order)

Game Design:
- [Diplomacy Rules - Support Mechanics](https://en.wikibooks.org/wiki/Diplomacy/Rules)
- [Hex Map - Wikipedia](https://en.wikipedia.org/wiki/Hex_map)
