# Strength Calculation Formulas: Deep Dive

## Hex Grid Context

Phalanx uses an odd-r, pointy-top hex grid. Each unit has 6 neighbors. For strength calculation, we categorize neighbors relative to facing direction:

| Category | Definition |
|----------|------------|
| **Side allies** | Adjacent allies at 60° or 120° from facing (flanks) |
| **Rear allies** | Adjacent allies at 180° from facing (directly behind) |
| **Front** | 0° from facing (attack direction) |

For a unit facing East (0°):
- Side positions: NE, SE (right flank), NW, SW (left flank)
- Rear position: West
- Front position: East

Maximum possible:
- Side allies: 4 (two on each flank)
- Rear allies: 1 (directly behind)
- Total formation neighbors: 5 (front excluded as that's enemy direction)

---

## Test Formations

All units face the same direction (→ = facing right/East).

```
Formation A: Isolated     Formation B: Side pair    Formation C: Line of 3
    →                         → →                       → → →

Formation D: Column of 2  Formation E: Column of 3  Formation F: 2x2 Block
    →                         →                         → →
    →                         →                         → →
                              →

Formation G: 3x2 Block
    → → →
    → → →
```

---

## Formula Definitions

| # | Formula | Max Strength |
|---|---------|--------------|
| 1 | `1 + sides + rear` | 6 |
| 2 | `1 + min(sides + rear, 4)` | 5 |
| 3 | `1 + min(sides, 2) + min(rear, 2)` | 5 |
| 4 | `1 + sides×0.75 + rear×0.5` | 4 |
| 5 | `1 + tier(sides) + tier(rear)` where tier(0)=0, tier(1-2)=1, tier(3+)=2 | 5 |
| 6 | `1 + (1 if sides>0) + (1 if rear>0)` | 3 |

---

## Formation Analysis

### Formation A: Isolated Unit

```
  →
```

| Position | Sides | Rear | F1 | F2 | F3 | F4 | F5 | F6 |
|----------|-------|------|----|----|----|----|----|----|
| Unit | 0 | 0 | **1** | **1** | **1** | **1.0** | **1** | **1** |

All formulas: Strength = 1. Baseline.

---

### Formation B: Side Pair

```
  → →
```
Hex layout (side-by-side horizontally):

| Position | Sides | Rear | F1 | F2 | F3 | F4 | F5 | F6 |
|----------|-------|------|----|----|----|----|----|----|
| Left unit | 1 | 0 | **2** | **2** | **2** | **1.75** | **2** | **2** |
| Right unit | 1 | 0 | **2** | **2** | **2** | **1.75** | **2** | **2** |

Each unit has 1 side ally. All formulas give strength 2 (except F4: 1.75).

---

### Formation C: Line of 3

```
  → → →
```

| Position | Sides | Rear | F1 | F2 | F3 | F4 | F5 | F6 |
|----------|-------|------|----|----|----|----|----|----|
| Left | 1 | 0 | **2** | **2** | **2** | **1.75** | **2** | **2** |
| Center | 2 | 0 | **3** | **3** | **3** | **2.5** | **2** | **2** |
| Right | 1 | 0 | **2** | **2** | **2** | **1.75** | **2** | **2** |

Center unit gets full side bonus. Note F5 and F6 cap/compress bonuses.

---

### Formation D: Column of 2 (Front/Rear)

```
  →
  →  (behind)
```

| Position | Sides | Rear | F1 | F2 | F3 | F4 | F5 | F6 |
|----------|-------|------|----|----|----|----|----|----|
| Front | 0 | 1 | **2** | **2** | **2** | **1.5** | **2** | **2** |
| Rear | 0 | 0 | **1** | **1** | **1** | **1.0** | **1** | **1** |

Front unit gets rear support. Rear unit gets nothing (no one behind them).

---

### Formation E: Column of 3

```
  →
  →
  →  (rear)
```

| Position | Sides | Rear | F1 | F2 | F3 | F4 | F5 | F6 |
|----------|-------|------|----|----|----|----|----|----|
| Front | 0 | 1 | **2** | **2** | **2** | **1.5** | **2** | **2** |
| Middle | 0 | 1 | **2** | **2** | **2** | **1.5** | **2** | **2** |
| Rear | 0 | 0 | **1** | **1** | **1** | **1.0** | **1** | **1** |

Depth beyond 2 provides no additional benefit (only 1 rear neighbor possible).

---

### Formation F: 2x2 Block

```
  → →
  → →
```

| Position | Sides | Rear | F1 | F2 | F3 | F4 | F5 | F6 |
|----------|-------|------|----|----|----|----|----|----|
| Front-Left | 1 | 1 | **3** | **3** | **3** | **2.25** | **3** | **3** |
| Front-Right | 1 | 1 | **3** | **3** | **3** | **2.25** | **3** | **3** |
| Rear-Left | 1 | 0 | **2** | **2** | **2** | **1.75** | **2** | **2** |
| Rear-Right | 1 | 0 | **2** | **2** | **2** | **1.75** | **2** | **2** |

Front row gets both side + rear bonuses.

---

### Formation G: 3x2 Block

```
  → → →
  → → →
```

| Position | Sides | Rear | F1 | F2 | F3 | F4 | F5 | F6 |
|----------|-------|------|----|----|----|----|----|----|
| Front-Left | 1 | 1 | **3** | **3** | **3** | **2.25** | **3** | **3** |
| Front-Center | 2 | 1 | **4** | **4** | **4** | **3.0** | **3** | **3** |
| Front-Right | 1 | 1 | **3** | **3** | **3** | **2.25** | **3** | **3** |
| Rear-Left | 1 | 0 | **2** | **2** | **2** | **1.75** | **2** | **2** |
| Rear-Center | 2 | 0 | **3** | **3** | **3** | **2.5** | **2** | **2** |
| Rear-Right | 1 | 0 | **2** | **2** | **2** | **1.75** | **2** | **2** |

Front-center achieves maximum practical strength in most formulas.

---

## Strength Summary Table

| Formation | Strongest Unit | F1 | F2 | F3 | F4 | F5 | F6 |
|-----------|----------------|----|----|----|----|----|----|
| A: Isolated | Only unit | 1 | 1 | 1 | 1.0 | 1 | 1 |
| B: Pair | Both | 2 | 2 | 2 | 1.75 | 2 | 2 |
| C: Line-3 | Center | 3 | 3 | 3 | 2.5 | 2 | 2 |
| D: Column-2 | Front | 2 | 2 | 2 | 1.5 | 2 | 2 |
| E: Column-3 | Front/Mid | 2 | 2 | 2 | 1.5 | 2 | 2 |
| F: 2x2 | Front units | 3 | 3 | 3 | 2.25 | 3 | 3 |
| G: 3x2 | Front-Center | 4 | 4 | 4 | 3.0 | 3 | 3 |

---

## Comparative Analysis

### 1. Wide vs Deep Balance

**Question:** Is going wide (more units in line) as valuable as going deep (columns)?

| Comparison | Winner by Formula |
|------------|-------------------|
| Line-3 center (2 sides) vs Column-2 front (1 rear) | F1-F4: Line wins (3 vs 2, or 2.5 vs 1.5). F5-F6: Tie (2 vs 2) |
| Line-3 average vs Column-3 average | Line wins in all formulas |

**Verdict:**
- **F1-F4**: Wide formations strongly preferred. Side allies more valuable.
- **F4**: Deliberately makes rear less valuable (0.5 vs 0.75).
- **F5-F6**: Equal value to having any side support vs any rear support.

**Recommendation:** If you want parity between wide/deep, use F5 or F6. If historical authenticity matters (depth mattered in real phalanxes), increase rear multiplier in F4 or adjust tier thresholds.

---

### 2. Blob Dominance

**Question:** Does massing into a big block always win?

| Formation | Total Strength (F3) | Units | Avg Strength |
|-----------|---------------------|-------|--------------|
| 6 isolated | 6 | 6 | 1.0 |
| 3 pairs | 12 | 6 | 2.0 |
| 2 lines of 3 | 14 | 6 | 2.3 |
| 3x2 block | 18 | 6 | 3.0 |

**Verdict:** Blob dominates in raw strength. The 3x2 block has 3x the total strength of isolated units.

**Mitigation options:**
1. **Mobility penalty**: Blocks move slower or can't change facing easily.
2. **Flanking damage**: Flanking bypasses strength entirely (deals direct health damage).
3. **Command range**: Units far from commander get penalties.
4. **Engagement limit**: Only front units can attack; blob wastes rear units.

---

### 3. Flanking Decisiveness

**Scenario:** Attacker (str 2) hits defender (str 3) on the flank.

**Current mechanics (from MECHANICS.md):**
- Flanking attack: -1 health to defender
- Rear attack: -2 health to defender
- Dislodge if attacker strength > defender strength

**Analysis by formula:**

| Scenario | Attacker | Defender (front hit) | Defender (flank hit) | Delta |
|----------|----------|----------------------|----------------------|-------|
| Pair vs 3x2 center | 2 | 4 (F3) | 4 (F3) | -2 |
| Line-3 edge vs 3x2 edge | 2 | 3 (F3) | 3 (F3) | -1 |

**Problem:** Flanking doesn't reduce defender strength—it just adds damage. A strength-4 center unit is equally hard to dislodge from front or flank.

**Proposed fix:** Strength should only count neighbors in the *attack direction's arc*:
- Attacked from front: full strength (all allies count)
- Attacked from flank: only rear and same-side allies count
- Attacked from rear: minimal strength (only units behind the rear count—usually 0)

**Example with directional strength:**

| Attack Direction | Defender's Countable Allies | Effective Strength (F3) |
|------------------|----------------------------|------------------------|
| Front | 2 sides + 1 rear | 4 |
| Flank (one side) | 1 side + 1 rear | 3 |
| Rear | 0 | 1 |

This makes flanking decisive: strength drops by 25-75% depending on angle.

---

### 4. Formula Recommendation

| Formula | Pros | Cons | Verdict |
|---------|------|------|---------|
| **F1** | Simple, intuitive | Unbounded; blob dominates hard | ❌ Too snowbally |
| **F2** | Capped; simple | Global cap = arbitrary | ⚠️ Viable |
| **F3** | Separate caps make sense | 2+2 split is arbitrary | ✅ Balanced |
| **F4** | Diminishing returns = realistic | Fractional math; harder to grok | ⚠️ Complex |
| **F5** | Tiered = clear breakpoints | Step functions feel gamey | ⚠️ Viable |
| **F6** | Dead simple; max=3 | Too compressed; formations feel same | ❌ Too flat |

**Primary recommendation: F3 (Separate Caps)**

```
Strength = 1 + min(SideAllies, 2) + min(RearAllies, 2)
```

Rationale:
- Max strength 5 prevents runaway blob advantage
- Separate caps reward both width and depth
- Easy to explain: "Each flank and your rear can give you up to +2"
- Mental model: 2 friends on each side, 2 ranks deep = maximum formation

**Secondary recommendation: F5 (Tiered Bonuses) if you want clearer breakpoints**

```
SideBonus = 0/1/2 for 0/1-2/3+ side allies
RearBonus = 0/1/2 for 0/1/2+ rear allies
```

---

## Implementation Notes

### Directional Strength (Recommended Enhancement)

Calculate strength relative to attack direction:

```elixir
def effective_strength(unit, attack_direction) do
  relevant_neighbors = neighbors_in_defense_arc(unit, attack_direction)
  sides = count_side_allies(relevant_neighbors)
  rear = count_rear_allies(relevant_neighbors)
  1 + min(sides, 2) + min(rear, 2)
end
```

Defense arc by attack angle:
| Attack From | Defense Arc (neighbors that count) |
|-------------|-----------------------------------|
| Front (0°) | All 5 formation neighbors |
| Flank (60°) | 3 neighbors (opposite flank + rear) |
| Flank (120°) | 2 neighbors (rear + partial opposite) |
| Rear (180°) | 0-1 neighbors |

### Same Facing Requirement

Per original requirement, allies only count if they share the same facing direction. This prevents ad-hoc blobs from getting full bonuses—units must be deliberately aligned.

```elixir
def allied_neighbors(unit, units) do
  unit
  |> neighbors()
  |> Enum.filter(fn pos ->
    ally = Map.get(units, pos)
    ally && ally.color == unit.color && ally.rotation == unit.rotation
  end)
end
```

---

## Summary

| Metric | F3 (Recommended) | Notes |
|--------|------------------|-------|
| Max strength | 5 | From 2 sides + 2 rear |
| Isolated unit | 1 | Baseline |
| Perfect formation | 5 | 2x2+ block with support |
| Wide vs Deep | Balanced | Both cap at +2 |
| Flanking impact | Decisive (with directional mod) | -1 to -3 strength loss |
| Cognitive load | Low | "2 from sides, 2 from rear" |

**Key design principle:** Strength calculation creates the incentive for historical phalanx tactics (tight formations, depth, protecting flanks). Flanking works not just through bonus damage but through strength reduction—breaking the formation breaks its power.
