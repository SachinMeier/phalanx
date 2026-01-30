# Formation Bonus Edge Cases

Analysis of phalanx formation bonuses for hex grid tactical combat.

## System Context

- Hex grid: odd-R offset, pointy-top
- Rotations: 0, 60, 120, 180, 240, 300 degrees
- Six neighbors: E, NE, NW, W, SW, SE
- Current movement: rotation constrains allowed directions (4 of 6 per facing)

## 1. What Counts as "Side"?

### Geometric Analysis

For a pointy-top hex with unit facing direction D:
- **Front**: neighbor in direction D
- **Rear**: neighbor opposite to D (D + 180)
- **Sides**: the 4 remaining neighbors (2 on each flank)

```
         Hex Neighbor Layout (pointy-top)

              NW    NE
                ╲  ╱
             W ──●── E
                ╱  ╲
              SW    SE
```

### Side Neighbors by Rotation

| Facing | Front | Rear | Left Flank | Right Flank |
|--------|-------|------|------------|-------------|
| 0 (E)  | E     | W    | NE, NW     | SE, SW      |
| 60 (NE)| NE    | SW   | NW, W      | E, SE       |
| 120 (NW)| NW   | SE   | W, SW      | NE, E       |
| 180 (W)| W     | E    | SW, SE     | NW, NE      |
| 240 (SW)| SW   | NE   | SE, E      | W, NW       |
| 300 (SE)| SE   | NW   | E, NE      | SW, W       |

### Diagrams by Rotation

```
Facing 0 (East) →

        [L2]  [L1]           NW    NE
           ╲  ╱                ╲  ╱
         W ─[U]→ E          W ─●→ E
           ╱  ╲                ╱  ╲
        [R2]  [R1]           SW    SE

L1 = NE (left flank near)      R1 = SE (right flank near)
L2 = NW (left flank far)       R2 = SW (right flank far)
```

```
Facing 60 (Northeast) ↗

        [L2]   ↗[F]          NW   ↗NE
           ╲  ╱                ╲  ╱
        [L1]─[U]─[R1]        W ─●─ E
           ╱  ╲                ╱  ╲
        [Re]  [R2]           SW    SE

L1 = W, L2 = NW (left flank)
R1 = E, R2 = SE (right flank)
F = NE (front), Re = SW (rear)
```

```
Facing 120 (Northwest) ↖

         ↖[F]  [R2]          ↖NW   NE
           ╲  ╱                ╲  ╱
        [L1]─[U]─[R1]        W ─●─ E
           ╱  ╲                ╱  ╲
        [L2]  [Re]           SW    SE

L1 = W, L2 = SW (left flank)
R1 = NE, R2 = E (right flank)
```

### Recommendation: Side Cohesion

**Rule**: Side cohesion counts neighbors that are perpendicular to facing (4 total, 2 per flank).

**Rationale**: Phalanx formations derive strength from shoulder-to-shoulder contact. The 4 side neighbors represent adjacent soldiers in the line.

---

## 2. What Counts as "Rear"?

### Options

1. **Single rear**: Only the hex directly opposite facing (1 neighbor)
2. **Rear arc**: Include diagonal-rear (3 neighbors: direct + 2 at 120 from facing)

### Geometric Definition

```
Facing 60 (NE) - Rear Analysis

Option A: Single Rear          Option B: Rear Arc (3 hexes)

       NW    NE                      NW    NE
         ╲  ╱                          ╲  ╱
      W ──●→ NE                     W ──●→ NE
         ╱  ╲                          ╱  ╲
     [R] SW   SE                   [R] SW  [r] SE
                                   [r] W

R = primary rear (SW)
r = diagonal-rear (W and SE are NOT rear for 60 facing)

Wait - let me recalculate. For facing 60 (NE):
- Front: NE
- Rear: SW (directly opposite)
- 120 from facing: NW and SE (these are flanks, not rear)
```

Actually, for a 6-hex neighborhood, each unit has exactly:
- 1 front neighbor
- 1 rear neighbor
- 4 side neighbors (2 left, 2 right)

There is no "diagonal-rear" - the neighbors at 120 degrees from facing are the innermost flank hexes.

### Recommendation: Depth Bonus

**Rule**: Depth bonus counts ONLY the single hex directly behind (opposite facing direction).

**Rationale**:
- Historical phalanx depth provided push support from the soldier directly behind
- Multiple rear neighbors would make depth bonus too powerful
- Clean geometric definition: rear = facing + 180

```
Depth Support Diagram (Facing 60)

        [A]           A faces NE
         ╲
     ? ──[U]→         U gets +1 depth if A has same facing
         ╱
        [B]           B at SW position = the rear

U gets depth bonus only from B (SW), not from A (NW) or others.
```

---

## 3. Mixed Rotations in Formation

### Scenario: Adjacent units with different facing

```
Unit A at (2,2) faces 60 (NE)
Unit B at (3,2) faces 120 (NW)  - B is East of A

        [A]→NE    [B]↖NW
        60         120

Question: Does B give A side cohesion?
```

### Analysis

For side cohesion to apply:
- A faces 60 (NE). B is to A's right flank (E direction).
- B faces 120 (NW). A is to B's left flank (W direction).

If same-facing is required: **No bonus** (60 != 120)

If only adjacency required: **+1 each** (they're adjacent)

### Similar Facings

| A Facing | B Facing | Difference | Same? |
|----------|----------|------------|-------|
| 0        | 0        | 0          | Yes   |
| 0        | 60       | 60         | No    |
| 60       | 120      | 60         | No    |
| 0        | 180      | 180        | No (opposite!) |

### Recommendation

**Rule**: Side cohesion requires IDENTICAL rotation. No "close enough" tolerance.

**Rationale**:
- 60 degrees is a significant angle (shields no longer overlap)
- Creates tactical decision: tight formation (same facing) vs flexible positioning
- Simple rule: `rotation_a == rotation_b`

---

## 4. L-Shaped and Corner Formations

### Scenario

```
3 units in L-shape, all facing 0 (East)

        [A]→         Position (1,1)
         │
        [B]→ ─ [C]→  Position (1,2) and (2,2)

All face East (0)
```

### Neighbor Analysis

For odd-R hex grid at row 2 (even):

- **A at (1,1)**: Neighbors include SW=(0,2), SE=(1,2)
- **B at (1,2)**: Neighbors include NE=(1,1), E=(2,2)
- **C at (2,2)**: Neighbors include W=(1,2)

Wait, let me recalculate using the codebase's offset values.

```elixir
# Row 2 is even (rem(2,2) = 0), use @even_row_moves
@even_row_moves [
  {1,0},   # east
  {0,-1},  # northeast
  {-1,-1}, # northwest
  {-1,0},  # west
  {-1,1},  # southwest - TYPO in original, should be SE
  {0,1}    # southeast - TYPO, should be SW
]
```

Using these offsets:

**B at (1,2), facing 0 (E)**:
- E neighbor: (1+1, 2+0) = (2,2) - that's C!
- NE neighbor: (1+0, 2-1) = (1,1) - that's A!

**Side neighbors for B (facing 0)**:
- Left flank: NE, NW
- Right flank: SE, SW

A is at B's NE = left flank (+1 side cohesion)
C is at B's E = front (not side, no cohesion bonus)

**Corner unit B**: Gets +1 from A (side), +0 from C (C is in front direction)

### Corrected Diagram

```
Facing 0 (E) - Side positions are NE, NW, SE, SW

     [A] at NE of B (left flank)
       ╲
    ? ──[B]→→→ [C] at E of B (front direction!)
       ╱
     SW

B gets side cohesion from A (NE = left flank)
B does NOT get side cohesion from C (E = front, not side)
```

### Recommendation

**Rule**: Corner units receive bonus only from neighbors in side positions. Front/rear neighbors don't count for side cohesion (they count for other bonuses).

**Calculated Bonus for B**: +1 (from A on left flank)

---

## 5. Surrounded Unit

### Scenario

```
1 unit surrounded by 6 allies, all facing 0 (East)

        [1]   [2]         NW    NE
          ╲   ╱             ╲   ╱
       [3]──[U]──[4]     W ──●── E
          ╱   ╲             ╱   ╲
        [5]   [6]         SW    SE

All face East (0). U is center unit.
```

### Bonus Calculation

For U facing 0 (E):
- Front: E direction = unit [4] - no side bonus
- Rear: W direction = unit [3] - DEPTH BONUS +1
- Left flank: NE=[2], NW=[1] - SIDE BONUS +2
- Right flank: SE=[6], SW=[5] - SIDE BONUS +2

**Total for U**:
- Side cohesion: +4 (all 4 side neighbors present with same facing)
- Depth bonus: +1 (rear neighbor present with same facing)
- **Total: +5**

### Should There Be a Cap?

| Option | Max Bonus | Rationale |
|--------|-----------|-----------|
| No cap | +5        | Rewards perfect positioning |
| Cap at +3 | +3     | Prevents "super units" |
| Diminishing | +1,+1,+0.5... | Complex but realistic |

### Recommendation

**Rule**: No cap. Maximum possible bonus is +5 (4 sides + 1 depth).

**Rationale**:
- Being surrounded by 6 same-facing allies is rare and requires tactical setup
- Creates high-value targets (kill the formation anchor)
- Simple rule without arbitrary limits

---

## 6. Moving Formation - Pre/Post Move Positions

### Scenario

```
Turn Start:                    Turn End (after moves):

[A]→ [B]→ [C]→                      [A]→ [B]→ [C]→
All face E, all move E              Positions shifted right

A at (1,2), B at (2,2), C at (3,2)  A at (2,2), B at (3,2), C at (4,2)
```

### Question: When is bonus calculated?

**Option A - Pre-move**: Calculate strength using start positions
- A attacks with +1 (B beside, C not adjacent)
- Formation might break during movement

**Option B - Post-move**: Calculate strength using end positions
- If formation stays intact, same bonuses
- But positions aren't known until orders resolve

**Option C - Both**: Attack strength uses pre-move; defense uses post-move

### Formation Breaking Scenario

```
Turn Start:                    Orders:

[A]→ [B]→ [C]→                 A: move E
                               B: move E
                               C: hold (blocked or intentional)

Turn End:
     [C]→ [A]→ [B]→            A is now beside C (different order)
```

### Recommendation

**Rule**: Formation bonuses calculated at CONFLICT RESOLUTION time, using the ENGINE's current position state.

This means:
1. Orders are submitted
2. Engine detects conflicts
3. Balking occurs (conflicting orders become holds)
4. **Formation bonus calculated at this point** (pre-move positions for moving units, accounting for holds)
5. Combat resolves
6. Surviving units move

**Rationale**:
- Matches historical phalanx: you push with current neighbors
- Prevents "phantom formations" (bonus from ghost positions)
- Integrates with existing engine flow (calculate after balk detection)

---

## 7. Rotation Timing

### Scenario

```
Turn Start:                    Order:

     [B]→                      A: rotate clockwise (0 → 60)
      │                        B: hold
[A]→──┘
A faces 0, B at A's NE

Question: Does A get depth/side bonus from B?
```

### Position Analysis

- A at (1,2) faces 0 (E)
- B at (1,1) - that's NE of A

For A facing 0 (E):
- B at NE is A's **left flank** = side cohesion applies

For A facing 60 (NE) after rotation:
- B at NE would be A's **front** = no side cohesion

### When Does Rotation Apply?

Per MECHANICS.md: "The attack hits before the rotation, but the rotation is applied after the attack"

This implies combat uses **pre-rotation** facing.

### Recommendation

**Rule**: Formation bonuses use PRE-ROTATION facing. Rotation applies AFTER combat resolution.

**Phase Order**:
1. Collect orders (moves + rotations)
2. Detect conflicts, apply balks
3. Calculate formation bonuses (using CURRENT facing, before rotation)
4. Resolve combat
5. Apply rotations
6. Apply movement for survivors

**Rationale**:
- Consistent with existing rotation timing rule
- Prevents "defensive rotation" exploits (rotate to face attacker for bonus)
- Formation bonus reflects actual shoulder-to-shoulder alignment at moment of contact

---

## Summary Table

| Edge Case | Recommended Rule |
|-----------|------------------|
| Side definition | 4 neighbors perpendicular to facing (2 per flank) |
| Rear definition | Single hex directly opposite facing |
| Mixed rotations | No bonus - must be IDENTICAL rotation |
| Corner formations | Only side-position neighbors count |
| Surrounded unit | Max +5 (4 side + 1 depth), no cap |
| Move timing | Calculate at conflict resolution (pre-move positions) |
| Rotation timing | Use pre-rotation facing |

## Maximum Bonus Table

| Neighbors Present | Same Facing | Side Bonus | Depth Bonus | Total |
|-------------------|-------------|------------|-------------|-------|
| 1 (side)          | Yes         | +1         | +0          | +1    |
| 1 (rear)          | Yes         | +0         | +1          | +1    |
| 2 (both flanks)   | Yes         | +2         | +0          | +2    |
| 3 (sides + rear)  | Yes         | +2         | +1          | +3    |
| 4 (all sides)     | Yes         | +4         | +0          | +4    |
| 5 (sides + rear)  | Yes         | +4         | +1          | +5    |
| 6 (surrounded)    | Yes         | +4         | +1          | +5    |

Note: Front neighbor provides neither side nor depth bonus.

## Implementation Checklist

- [ ] Define `side_neighbors/1` function: rotation -> list of 4 directions
- [ ] Define `rear_neighbor/1` function: rotation -> single direction
- [ ] Calculate side cohesion: count same-facing allies in side positions
- [ ] Calculate depth bonus: check if rear position has same-facing ally
- [ ] Integrate into engine: call after balk resolution, before combat
- [ ] Unit tests for each rotation value
- [ ] Integration test for surrounded unit
- [ ] Integration test for moving formation
