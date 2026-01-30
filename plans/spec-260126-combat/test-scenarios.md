# Phalanx Test Scenarios

Comprehensive test scenarios covering movement, formation, and combat edge cases.

**Coordinate System**: Odd-R offset hex grid (pointy-top). Even rows (0, 2, 4...) and odd rows (1, 3, 5...) have different neighbor offsets.

**Notation**:
- `R` = Red unit, `P` = Purple unit
- Arrow direction = unit facing (e.g., `R>` = red facing east)
- `[H]` = holding unit
- `-->` = movement order
- Positions given as (col, row)

---

## Movement Tests

### M1: Head-On Collision (Same Target)

Two units from opposite directions target the same empty hex.

```
Before:                     Orders:
  R>     X     <P           R: move E to (2,1)
(1,1)  (2,1)  (3,1)         P: move W to (2,1)

After (both balk):
  R>     X     <P           Same positions
```

**Setup**:
- R at (1,1), facing 0 (E), color red
- P at (3,1), facing 180 (W), color purple

**Orders**:
- R: move east
- P: move west

**Expected Resolution**:
1. Conflict detected: both target (2,1)
2. Destination conflict - both balk

**Expected End State**:
- R at (1,1)
- P at (3,1)

**What This Tests**: Basic destination conflict detection.

---

### M2: 120-Degree Crossing (Same Target)

Two units approach same hex from 120-degree angle.

```
Before:                     Orders:
        P                   R: move E to (1,2)
       (2,1)                P: move SW to (1,2)
        |
       SW
        v
  R> -- X
(0,2)  (1,2)
```

**Setup**:
- R at (0,2), facing 0 (E), color red
- P at (2,1), facing 240 (SW), color purple

**Orders**:
- R: move east
- P: move southwest

**Expected Resolution**:
1. Conflict detected: both target (1,2)
2. Destination conflict - both balk

**Expected End State**:
- R at (0,2)
- P at (2,1)

**What This Tests**: Conflict detection at non-180-degree angles.

---

### M3: 60-Degree Sliding (No Conflict)

Units move in directions 60 degrees apart to different destinations.

```
Before:                     Orders:
  R> at (1,2)               R: move E to (2,2)
  P^ at (1,1)               P: move NE to (2,0)

After (both move):
  R> at (2,2)
  P^ at (2,0)
```

**Setup**:
- R at (1,2), facing 0 (E), color red
- P at (1,1), facing 60 (NE), color purple

**Orders**:
- R: move east
- P: move northeast

**Expected Resolution**:
1. No conflict - destinations differ
2. Both moves succeed

**Expected End State**:
- R at (2,2)
- P at (2,0)

**What This Tests**: Non-conflicting simultaneous movement.

---

### M4: Position Swap Attempt

Two units attempt to exchange positions.

```
Before:                     Orders:
  R> -- <P                  R: move E to (2,1)
(1,1)  (2,1)                P: move W to (1,1)

After (both balk):
  R> -- <P                  Same positions
```

**Setup**:
- R at (1,1), facing 0 (E), color red
- P at (2,1), facing 180 (W), color purple

**Orders**:
- R: move east
- P: move west

**Expected Resolution**:
1. Swap detected: R->P's position, P->R's position
2. Swap conflict - both balk

**Expected End State**:
- R at (1,1)
- P at (2,1)

**What This Tests**: Position swap prevention (units cannot pass through each other).

---

### M5: Three-Way Destination Conflict

Three units target the same hex from different directions.

```
Before:                     Orders:
        P1                  R: move E to (1,2)
       (2,1)                P1: move SW to (1,2)
        |                   P2: move NW to (1,2)
       SW
        v
  R> -- X
(0,2)  (1,2)
        ^
       NW
        |
        P2
       (2,3)
```

**Setup**:
- R at (0,2), facing 0 (E), color red
- P1 at (2,1), facing 240 (SW), color purple
- P2 at (2,3), facing 120 (NW), color purple

**Orders**:
- R: move east
- P1: move southwest
- P2: move northwest

**Expected Resolution**:
1. Triple conflict at (1,2)
2. All three balk

**Expected End State**:
- R at (0,2)
- P1 at (2,1)
- P2 at (2,3)

**What This Tests**: Multi-unit destination conflict.

---

### M6: Chain Collision Cascade

A chain of units where blocking propagates backward.

```
Before:                     Orders:
R1> R2> R3> [P]             R1: move E
(0,1)(1,1)(2,1)(3,1)        R2: move E
                            R3: move E
                            P: hold

Resolution:
P holds at (3,1) -> R3 blocked (target occupied)
R3 balks -> R2 blocked (target now occupied by R3)
R2 balks -> R1 blocked
All red units balk
```

**Setup**:
- R1 at (0,1), facing 0 (E), color red
- R2 at (1,1), facing 0 (E), color red
- R3 at (2,1), facing 0 (E), color red
- P at (3,1), facing 180 (W), color purple

**Orders**:
- R1, R2, R3: move east
- P: hold

**Expected Resolution**:
1. R3 targets (3,1) where P holds - blocked
2. R3 balks, stays at (2,1)
3. R2 targets (2,1) where R3 now holds - blocked
4. R2 balks, stays at (1,1)
5. R1 targets (1,1) where R2 holds - blocked
6. R1 balks

**Expected End State**: All units remain in original positions.

**What This Tests**: Cascading balk propagation.

---

### M7: Group Atomic Movement (Success)

A phalanx formation moves together.

```
Before:                     Orders:
R1> R2> R3>                 All: move E
(0,1)(1,1)(2,1)

After:
    R1> R2> R3>
   (1,1)(2,1)(3,1)
```

**Setup**:
- R1 at (0,1), facing 0 (E), color red
- R2 at (1,1), facing 0 (E), color red
- R3 at (2,1), facing 0 (E), color red
- All same rotation = group

**Orders**:
- All: move east

**Expected Resolution**:
1. Group detected (same color, same rotation, adjacent)
2. All orders match - group moves together
3. No conflicts - all succeed

**Expected End State**:
- R1 at (1,1)
- R2 at (2,1)
- R3 at (3,1)

**What This Tests**: Group atomic movement with consistent orders.

---

### M8: Group Partial Block (Majority Balk)

A phalanx where one unit is blocked causes entire group to balk.

```
Before:                     Orders:
R1> R2> R3> [P]             R1: move E
(0,1)(1,1)(2,1)(3,1)        R2: move E
                            R3: move E
                            P: hold

After: All red units balk (majority rule triggers)
```

**Setup**:
- R1, R2, R3 form a group (same color, same rotation)
- P at (3,1) blocking

**Orders**:
- R1, R2, R3: move east
- P: hold

**Expected Resolution**:
1. Group detected
2. R3 individually blocked -> would balk
3. Only 1 of 3 blocked; 1/3 < majority (50%)
4. Actually need to re-check: if R3 balks, does that trigger R2 balk? Then 2/3 balk?
5. Cascade: R3 balk -> R2 blocked -> R2 balk -> R1 blocked -> 3/3 balk

**Expected End State**: All remain in place.

**What This Tests**: Group movement with cascade blocking.

---

### M9: Edge of Map Movement

Unit attempts to move off the map boundary.

```
Before:                     Order:
<R                          R: move W (off map)
(0,2)

After:
<R                          R balks (invalid move)
(0,2)
```

**Setup**:
- R at (0,2), facing 180 (W), color red
- Map dimensions: 10x10

**Orders**:
- R: move west

**Expected Resolution**:
1. Move validation fails - destination off map
2. Order converted to hold

**Expected End State**: R at (0,2).

**What This Tests**: Map boundary enforcement.

---

### M10: Invalid Move (Wrong Facing)

Unit attempts move not allowed by current rotation.

```
Before:                     Order:
R>                          R: move NW (not allowed at rotation 0)
(2,2)

Rotation 0 (E) allows: E, SE, W, NW
Actually NW IS allowed. Let me use a different example.

Rotation 0 (E): allowed = E, NE, W, NW (per codebase)
Let me check: SW and SE are blocked when facing E.

Order:
R: move SW (blocked by facing)
```

**Setup**:
- R at (2,2), facing 0 (E), color red

**Orders**:
- R: move southwest (blocked by rotation constraint)

**Expected Resolution**:
1. Move validation fails - direction not allowed for rotation
2. Order converted to hold

**Expected End State**: R at (2,2).

**What This Tests**: Rotation-based movement constraints.

---

### M11: Chase (Vacating Hex)

One unit moves into hex being vacated by another.

```
Before:                     Orders:
R> -- P> -- [empty]         R: move E to (2,1)
(1,1) (2,1) (3,1)           P: move E to (3,1)

After:
    R> -- P>
   (2,1) (3,1)
```

**Setup**:
- R at (1,1), facing 0 (E), color red
- P at (2,1), facing 0 (E), color purple

**Orders**:
- R: move east (to P's current position)
- P: move east (vacating for R)

**Expected Resolution**:
1. P moving to empty (3,1) - succeeds
2. R moving to (2,1) which P vacates - succeeds
3. No conflict (P leaves before R arrives, conceptually)

**Expected End State**:
- R at (2,1)
- P at (3,1)

**What This Tests**: Simultaneous movement where one unit vacates for another.

---

### M12: Three-Way Rotation Swap (Cycle)

Units form a cycle where each targets another's position.

```
Before:                     Orders:
    R1(1,0)                 R1: move SE to (1,1)
      \                     R2: move W to (0,1)
      SE                    R3: move NE to (1,0)
       v
R3(0,1)<-W-R2(1,1)
   \
   NE->R1's position

A->B, B->C, C->A cycle
```

**Setup**:
- R1 at (1,0), facing 300 (SE), color red
- R2 at (1,1), facing 180 (W), color red
- R3 at (0,1), facing 60 (NE), color red

**Orders**:
- R1: move SE to (1,1) - R2's position
- R2: move W to (0,1) - R3's position
- R3: move NE to (1,0) - R1's position

**Expected Resolution**:
1. Cycle detected: R1->R2->R3->R1
2. All units in cycle balk

**Expected End State**: All units remain in original positions.

**What This Tests**: Cycle detection and resolution.

---

## Formation Tests

### F1: Single Isolated Unit (Strength 1)

Unit with no adjacent allies.

```
Before:
    . . .
    . R> .
    . . .
```

**Setup**:
- R at (2,2), facing 0 (E), color red, health 3
- No other units adjacent

**Strength Calculation**:
- Base: 1
- Side cohesion: 0 (no allies in side positions)
- Depth bonus: 0 (no ally behind)
- **Total: 1**

**What This Tests**: Base strength without formation bonuses.

---

### F2: Two Units Side by Side

Two units adjacent in flank position.

```
Before:
    R1>
     |
    R2>
```

**Setup**:
- R1 at (2,1), facing 0 (E), color red
- R2 at (2,2), facing 0 (E), color red
- R2 is at R1's SE (right flank) position

**Strength Calculation for R1**:
- Base: 1
- Side cohesion: +1 (R2 in right flank, same rotation)
- Depth bonus: 0
- **Total: 2**

**Strength Calculation for R2**:
- Base: 1
- Side cohesion: +1 (R1 in left flank, same rotation)
- Depth bonus: 0
- **Total: 2**

**What This Tests**: Side cohesion bonus between two units.

---

### F3: Line of 3 (Center Gets +2)

Three units in a horizontal line.

```
Before:
    R1> R2> R3>
   (1,1)(2,1)(3,1)
```

**Setup**:
- R1 at (1,1), facing 0 (E), color red
- R2 at (2,1), facing 0 (E), color red
- R3 at (3,1), facing 0 (E), color red
- When facing E, E/W are front/rear, NE/NW/SE/SW are flanks

Wait - this is tricky. For facing E (0), neighbors:
- Front: E
- Rear: W
- Left flank: NE, NW
- Right flank: SE, SW

Units at (1,1), (2,1), (3,1) are in a row. Let me check adjacency:
- R1 to R2: R2 is E of R1 = front, not side
- R2 to R3: R3 is E of R2 = front, not side

These don't give side cohesion! They're in front/rear positions.

Let me redo with proper side positioning:

```
Before (units in column, not row):
    R1> (2,0)
    R2> (2,1)
    R3> (2,2)

For odd-R offset, vertical adjacency varies by row parity.
```

This is complex. Let me use a simpler example with clear side positioning:

**Revised Setup** (diagonal line for side cohesion):

```
      R1> at (1,1) [odd row]
       \
       R2> at (1,2) [even row]
        \
        R3> at (1,3) [odd row]
```

Checking: For R2 at (1,2) facing E:
- NE neighbor at even row: (1,1) - that's R1, in left flank
- SE neighbor at even row: (1,3) - that's R3, in right flank

**Strength Calculation for R2**:
- Base: 1
- Side cohesion: +2 (R1 in NE/left flank, R3 in SE/right flank)
- Depth bonus: 0
- **Total: 3**

**What This Tests**: Center unit with flankers on both sides.

---

### F4: Line of 5 (Center Still +2 Max from Sides)

Testing that side cohesion from 4 positions caps properly.

```
Before (5 units forming a staggered line to hit all 4 side positions):
          R1> at NW of R3
    R2> at NE of R3
           |
      R3>  (center)
           |
    R4> at SW of R3
          R5> at SE of R3
```

**Setup**:
- R3 at (2,2) center, facing 0 (E)
- R1 at NW position of R3
- R2 at NE position of R3
- R4 at SW position of R3
- R5 at SE position of R3
- All facing 0 (E)

**Strength Calculation for R3**:
- Base: 1
- Side cohesion: +4 (all 4 side positions filled)
- Depth bonus: 0
- **Total: 5**

**What This Tests**: Maximum side cohesion bonus (+4).

---

### F5: Column of 2 (Rear Support)

Two units in column, one behind the other.

```
Before:
    R1> -- R2>
   (1,2)  (2,2)

R2 is E of R1 (front position for R1)
R1 is W of R2 (rear position for R2)
```

**Setup**:
- R1 at (1,2), facing 0 (E), color red
- R2 at (2,2), facing 0 (E), color red

**Strength Calculation for R2**:
- Base: 1
- Side cohesion: 0 (no allies in side positions)
- Depth bonus: +1 (R1 at rear/W position, same rotation)
- **Total: 2**

**What This Tests**: Depth bonus from single rear ally.

---

### F6: Column of 3 (Max Rear +2)

Three units in column testing depth cap.

```
Before:
    R1> -- R2> -- R3>
   (0,2)  (1,2)  (2,2)
```

**Setup**:
- R1 at (0,2), facing 0 (E)
- R2 at (1,2), facing 0 (E)
- R3 at (2,2), facing 0 (E)

**Strength Calculation for R3** (front unit):
- Base: 1
- Side cohesion: 0
- Depth bonus: Per spec, depth counts only single hex directly behind
- R2 is directly behind R3 (W position) = +1
- R1 is NOT directly behind R3 (two hexes away)
- **Total: 2**

Note: Depth bonus max is +2 from spec, but only 1 hex counts directly. Need to verify interpretation.

**What This Tests**: Depth bonus single-hex rule.

---

### F7: 2x2 Block

Four units in a square formation.

```
Before:
    R1> R2>
    R3> R4>

Positions (assuming proper hex adjacency):
R1 at (1,1), R2 at (2,1)
R3 at (1,2), R4 at (2,2)
```

**Setup**:
- All 4 units facing 0 (E), same color

**Strength Calculation for R1**:
- Base: 1
- Check: R2 is E of R1 (front), R3 is SE of R1 (right flank), R4 is... not adjacent to R1
- Side cohesion: +1 (only R3 in side position)
- Depth: 0
- **Total: 2**

**Strength for center-ish unit would be higher. This formation is compact.**

**What This Tests**: Formation bonus in 2x2 block.

---

### F8: 3x2 Block

Six units in larger block formation.

```
Before (row-staggered hex pattern):
Row 1:   R1> R2> R3>
Row 2:   R4> R5> R6>
```

**Setup**:
- Row 1: R1(1,1), R2(2,1), R3(3,1)
- Row 2: R4(1,2), R5(2,2), R6(3,2)
- All facing 0 (E)

**Strength for R5 (center of row 2)**:
- Check adjacencies at (2,2) even row:
  - E = (3,2) = R6, front position
  - W = (1,2) = R4, rear position
  - NE = (2,1) = R2, left flank
  - SE = (2,3) = empty
- Side cohesion: +1 (R2)
- Depth: +1 (R4)
- **Total: 3**

**What This Tests**: Mixed side and depth bonuses.

---

### F9: L-Shaped Formation

Units in L pattern.

```
Before:
    R1>
     |
    R2> -- R3> -- R4>
```

**Setup**:
- R1 at (2,1), facing 0 (E)
- R2 at (2,2), facing 0 (E) - corner
- R3 at (3,2), facing 0 (E)
- R4 at (4,2), facing 0 (E)

**Strength for R2 (corner)**:
- Base: 1
- R1 at NE (left flank): +1 side
- R3 at E (front): 0
- **Total: 2**

**What This Tests**: Corner unit formation bonus.

---

### F10: Mixed Rotations (No Bonus)

Adjacent units with different facing directions.

```
Before:
    R1> (facing E)
     |
    R2^ (facing NE)
```

**Setup**:
- R1 at (2,1), facing 0 (E)
- R2 at (2,2), facing 60 (NE)
- R2 is in R1's right flank position

**Strength for R1**:
- Base: 1
- R2 is adjacent but rotation differs (0 != 60)
- Side cohesion: 0 (same rotation required)
- **Total: 1**

**What This Tests**: Rotation matching requirement for formation bonus.

---

### F11: Adjacent Different Colors (No Bonus)

Adjacent units of different teams.

```
Before:
    R> (red, facing E)
     |
    P> (purple, facing E)
```

**Setup**:
- R at (2,1), facing 0 (E), color red
- P at (2,2), facing 0 (E), color purple

**Strength for R**:
- Base: 1
- P is adjacent with same rotation but different color
- Side cohesion: 0 (same color required)
- **Total: 1**

**What This Tests**: Color matching requirement for formation bonus.

---

### F12: Surrounded Unit (Maximum +5)

Unit surrounded by 6 same-facing allies.

```
Before:
       R1>   R2>
         \  /
      R3>-R-R4>
         / \
       R5>  R6>

R at center (2,2), 6 allies at all adjacent hexes
```

**Setup**:
- R at (2,2), facing 0 (E)
- All 6 neighbors filled with same color, same rotation allies

**Strength for R**:
- Base: 1
- Side cohesion: +4 (NE, NW, SE, SW all filled)
- Depth bonus: +1 (W filled)
- Note: E is front, doesn't contribute
- **Total: 6**

Actually checking spec: max formation bonus is +5 (4 side + 1 depth). But base is 1, so total = 6.

**What This Tests**: Maximum possible formation bonus.

---

## Combat Tests

### C1: Equal Strength Standoff

Attacker and defender have equal strength - defender holds.

```
Before:                     Orders:
R> -- P>                    R: move E (attack P)
(1,1) (2,1)                 P: hold

Strength: R=1, P=1 (both isolated)
```

**Setup**:
- R at (1,1), facing 0 (E), strength 1
- P at (2,1), facing 0 (E), strength 1

**Orders**:
- R: move east (attacks P)
- P: hold

**Expected Resolution**:
1. Attacker str 1 vs defender str 1
2. Not strictly greater - attacker bounces
3. No damage (tie = standoff)

**Expected End State**:
- R at (1,1)
- P at (2,1)
- No health changes

**What This Tests**: Tie resolution (defender wins ties).

---

### C2: Attacker Wins (Strength 3 vs 2)

Superior attacker dislodges defender.

```
Before:                     Orders:
R1> R2> -- P>               R1, R2: move E (attack P)
(0,1)(1,1)  (2,1)           P: hold

R2 gets +1 support from R1 (pushing same direction)
P has base strength 1
R2: 1 (base) + 1 (support) = 2
Wait, need more strength. Add formation.
```

**Revised Setup**:
- R1 at (0,1), facing 0 (E), color red
- R2 at (1,1), facing 0 (E), color red
- R3 at (1,0), facing 0 (E), color red (in R2's left flank)
- P at (2,1), facing 0 (E), color purple

**Strength Calculation**:
- R2: base 1 + support 1 (R1 pushing) + side 1 (R3) = 3
- P: base 1 = 1

**Orders**:
- R1, R2, R3: move east
- P: hold

**Expected Resolution**:
1. R2 attacks P: 3 vs 1
2. R2 wins, P dislodged
3. P takes -1 HP (dislodge damage), must retreat

**Expected End State**:
- R1 at (1,1)
- R2 at (2,1)
- R3 at (2,0)
- P retreated to valid hex (not (1,1) - attacker origin), HP reduced

**What This Tests**: Successful dislodge with strength advantage.

---

### C3: Flank Attack (+1 Bonus)

Attacker approaches from defender's flank.

```
Before:                     Orders:
      R>                    R: move SW to attack P
     (2,0)                  P: hold
       \
       SW
        v
       P>                   P facing E, attack from NE = left flank
      (2,1)
```

**Setup**:
- R at (2,0), facing 240 (SW), color red
- P at (2,1), facing 0 (E), color purple

Attack direction is SW. From P's perspective (facing E), attack comes from NE direction = left flank.

**Damage Calculation**:
- R attack from P's flank: +1 flanking bonus
- If R strength > P strength: P dislodged (-1 HP) + flank (-1 HP) = -2 HP

**What This Tests**: Flanking damage bonus.

---

### C4: Rear Attack (+2 Bonus)

Attacker approaches from defender's rear.

```
Before:                     Orders:
       P>                   R: move E to attack P
      (2,1)                 P: hold
       ^
       E
       |
      R>                    R at W of P, attacks E (from P's rear)
     (1,1)
```

**Setup**:
- R at (1,1), facing 0 (E), color red
- P at (2,1), facing 0 (E), color purple

Attack direction is E. P faces E, so attack from W = rear.

**Damage Calculation** (if R wins):
- Dislodge: -1 HP
- Rear attack: -2 HP
- **Total: -3 HP**

**What This Tests**: Rear attack damage bonus.

---

### C5: Mutual Attack (Tie - Both Hold)

Two units attack each other with equal strength.

```
Before:                     Orders:
R> <-> <P                   R: move E
(1,1)   (2,1)               P: move W

Both attack each other, both strength 1.
```

**Setup**:
- R at (1,1), facing 0 (E), strength 1
- P at (2,1), facing 180 (W), strength 1

**Orders**:
- R: move east (to 2,1)
- P: move west (to 1,1)

**Expected Resolution**:
1. Swap detected - both balk
2. Alternatively: mutual attack resolution
3. Per combat spec: "Both hold, both take -1 HP" (collision damage)

**Expected End State**:
- R at (1,1), HP -1
- P at (2,1), HP -1

**What This Tests**: Mutual attack/swap resolution with damage.

---

### C6: Mutual Attack (One Wins)

Two units attack each other, one has higher strength.

```
Before:                     Orders:
R1> R2> <-> <P              R1: move E
(0,1)(1,1)  (2,1)           R2: move E (attacks P)
                            P: move W (attacks R2)

R2 has support from R1, strength = 2
P has strength = 1
```

**Setup**:
- R1 at (0,1), facing 0 (E)
- R2 at (1,1), facing 0 (E)
- P at (2,1), facing 180 (W)

**Strength**:
- R2: 1 + 1 (support) = 2
- P: 1

**Expected Resolution**:
1. Mutual attack: compare strengths
2. R2 (2) > P (1)
3. R2 wins, advances to (2,1)
4. P dislodged, takes damage
5. R2 also takes -1 HP (counterparallel attack - P's attack landed before retreat)

**Expected End State**:
- R1 at (1,1)
- R2 at (2,1), HP -1
- P retreated, HP reduced

**What This Tests**: Asymmetric mutual attack resolution.

---

### C7: Three-Way Collision (Highest Wins)

Three units converge on same hex, different strengths.

```
Before:                     Setup:
     P1                     R: strength 3 (with formation)
      \SW                   P1: strength 2
       v                    P2: strength 1
  R>--[X]<--P2
       ^
      target hex
```

**Setup**:
- R at (0,2) with 2 supporting allies, strength 3
- P1 at (2,1), strength 2 (one ally)
- P2 at (2,3), strength 1 (isolated)
- All targeting (1,2)

**Expected Resolution**:
1. Three-way destination conflict at (1,2)
2. Compare strengths: R(3) > P1(2) > P2(1)
3. R wins, gets the hex
4. P1 and P2 balk (no damage - they didn't hold the hex)

**Expected End State**:
- R at (1,2)
- P1 at (2,1)
- P2 at (2,3)

**What This Tests**: Multi-attacker resolution by strength.

---

### C8: Support Cutting

Attack on supporter nullifies their support.

```
Before:                     Orders:
    P1                      R1: attack D
   (2,0)                    R2: support R1's attack
     |                      P1: attack R2 (the supporter)
    atk                     D: hold
     v
R2> -> R1> -> <D
(0,1)  (1,1)  (2,1)
```

**Setup**:
- R1 at (1,1), attacking D at (2,1)
- R2 at (0,1), supporting R1 by pushing same direction
- P1 at (2,0), attacking R2
- D (defender) at (2,1), holding

**Expected Resolution**:
1. P1 targets R2 (supporter)
2. R2's support to R1 is cut (attacked)
3. R1 attacks D without support: strength 1 vs 1
4. Tie - R1 bounces
5. P1 vs R2 resolves separately

**Expected End State**:
- R1 at (1,1) (bounced)
- D at (2,1) (held)
- P1/R2 resolution based on their strengths

**What This Tests**: Support cutting mechanic.

---

### C9: Dislodge with Valid Retreat

Defender dislodged, has open retreat hex.

```
Before:                     Orders:
R> -- P> -- [empty]         R: move E (attack P)
(1,1) (2,1) (3,1)           P: hold

P's retreat options: (3,1) is empty, valid retreat.
```

**Setup**:
- R at (1,1), strength 2 (has support)
- P at (2,1), strength 1

**Expected Resolution**:
1. R attacks P: 2 > 1, P dislodged
2. P takes -1 HP (dislodge)
3. P retreat check: (3,1) empty, valid
4. P retreats to (3,1)

**Expected End State**:
- R at (2,1)
- P at (3,1), HP -1

**What This Tests**: Standard dislodge with retreat.

---

### C10: Dislodge with No Retreat (Death)

Defender dislodged but all retreat hexes blocked.

```
Before:                     Orders:
    P1 P2                   R: move E (attack D)
      \|/                   D: hold
   R>--D--P3                All P units: hold
      /|\
    P4 P5

D completely surrounded by enemies except attack direction.
```

**Setup**:
- R at (0,2), strength 2
- D at (1,2), strength 1
- P1-P5 occupying all other hexes adjacent to D

**Expected Resolution**:
1. R attacks D: 2 > 1, D dislodged
2. D retreat check: all adjacent hexes occupied except (0,2) = attacker origin
3. Cannot retreat to attacker's origin
4. No valid retreat - D destroyed

**Expected End State**:
- R at (1,2)
- D removed from game

**What This Tests**: Death on failed retreat.

---

### C11: Retreat Cascade

Dislodged unit's retreat blocked by another unit that is also being dislodged.

```
Before:                     Orders:
R1> -- P1> -- P2>           R1: move E (attack P1)
(0,1) (1,1)  (2,1)          R2: move NE (attack P2)
        \                   P1, P2: hold
        R2>
       (1,2)

P1 would retreat to (2,1) but P2 is there.
P2 is also being attacked by R2.
```

**Setup**:
- R1 at (0,1), strength 2, attacking P1
- R2 at (1,2), strength 2, attacking P2
- P1 at (1,1), strength 1
- P2 at (2,1), strength 1

**Expected Resolution**:
1. Both attacks succeed (str 2 > str 1)
2. P1 retreat options: (2,1) occupied by P2
3. P2 retreating from (2,1) -> opens hex for P1
4. Order matters: if P2 retreats first, P1 can retreat to (2,1)
5. Per spec: "Retreating unit has priority"

**Expected End State**:
- R1 at (1,1)
- R2 at (2,1) or nearby based on resolution
- P1 retreated (possibly to vacated (2,1))
- P2 retreated

**What This Tests**: Retreat cascade and priority.

---

### C12: Multiple Attackers on One Defender

Two units attack same defender from different directions.

```
Before:                     Orders:
    R1>                     R1: move SW (attack D)
   (2,0)                    R2: move NW (attack D)
      \SW                   D: hold
       v
       D>
      (2,1)
       ^
      NW/
    R2>
   (3,2)
```

**Setup**:
- R1 at (2,0), attacking from D's NE (flank)
- R2 at (3,2), attacking from D's SE (flank)
- D at (2,1), facing E, strength 1

**Strength Calculation**:
- Per spec: "Forces combine against defender"
- Combined attack: R1(1) + R2(1) = 2 vs D(1)

**Expected Resolution**:
1. Combined attacking force: 2 > 1
2. D dislodged
3. Damage: dislodge (-1) + flank from R1 (-1) + flank from R2 (-1) = -3 HP
4. Who gets hex? Highest strength attacker, or if tied, contested

**Expected End State**:
- D retreated or destroyed (based on HP)
- One attacker occupies (2,1) or contested

**What This Tests**: Combined force from multiple attackers.

---

### C13: Defender Retreats into Moving Attacker's Path

Retreating unit has priority over moving unit for destination.

```
Before:                     Orders:
R1> -- D> -- [X]            R1: move E (attack D)
(0,1) (1,1)  (2,1)          R2: move NW to (2,1)
              ^             D: hold
             NW
              |
             R2>
            (3,2)
```

**Setup**:
- R1 at (0,1), strength 2, attacking D
- D at (1,1), strength 1
- R2 at (3,2), moving NW to (2,1)

**Expected Resolution**:
1. R1 attacks D: 2 > 1, D dislodged
2. D must retreat, only option is (2,1)
3. R2 moving to (2,1)
4. Per spec: "Retreating unit has priority"
5. D retreats to (2,1), R2's move fails

**Expected End State**:
- R1 at (1,1)
- D at (2,1)
- R2 at (3,2) (bounced)

**What This Tests**: Retreat priority over movement.

---

### C14: Attack on Moving Unit (Non-Counterparallel Penalty)

Defender was moving perpendicular when attacked.

```
Before:                     Orders:
       R>                   R: move SW (attack P)
      (2,0)                 P: move E (away/perpendicular)
        \SW
         v
        P>--E-->
       (2,1)
```

**Setup**:
- R at (2,0), attacking P via SW
- P at (2,1), facing E, moving E (perpendicular to attack)

**Expected Resolution**:
1. P is moving, not counterparallel to attack
2. Per spec: "attacked while moving non-counterparallel = -1 HP"
3. If R wins: P takes dislodge (-1) + movement penalty (-1) = -2 HP

**Expected End State**:
- P takes extra damage for moving non-counterparallel

**What This Tests**: Movement penalty on attacked unit.

---

### C15: Counterparallel Attack (No Movement Penalty)

Defender moving toward attacker (head-on).

```
Before:                     Orders:
R> -- <P                    R: move E (attack P)
(1,1) (2,1)                 P: move W (toward R)
```

**Setup**:
- R at (1,1), moving E
- P at (2,1), moving W (toward R, counterparallel)

**Expected Resolution**:
1. Mutual attack / swap scenario
2. P moving counterparallel - no extra movement penalty
3. Standard collision damage only

**What This Tests**: Counterparallel exemption from movement penalty.

---

## Integration Tests

### I1: Full Turn Resolution Sequence

Complete turn with multiple simultaneous events.

```
Before:
Red Team:       Purple Team:
R1>(0,1)        P1>(3,1)
R2>(0,2)        P2>(3,2)
R3>(1,2) supporting R2

Orders:
R1: move E
R2: move E (attack P1's eventual position?)
R3: move E (support R2)
P1: move W (attack R1's eventual position)
P2: hold
```

**Expected Resolution Phases**:
1. Snapshot state, detect groups
2. Validate orders
3. Calculate supports (R3 supports R2)
4. Detect conflicts (R1 vs P1 head-on)
5. Calculate strengths
6. Resolve combat
7. Execute movements
8. Apply damage and retreats
9. Apply rotations
10. Update energy

**What This Tests**: Complete resolution order integration.

---

### I2: Group Movement with Combat

Phalanx group attacks enemy.

```
Before:
Red phalanx:    Enemy:
R1> R2> R3>     P>
(0,1)(1,1)(2,1) (3,1)

All reds move E, attacking P.
```

**Expected Resolution**:
1. Group detected (R1, R2, R3 same color/rotation)
2. All move E
3. R3 attacks P: compare strengths
4. If R3 wins with support, P dislodged
5. If P holds, does group majority-balk trigger?

**What This Tests**: Group atomic movement with combat at front.

---

### I3: Energy Depletion Death

Unit at 0 energy takes attrition damage.

```
Before:
R at (2,2), health 1, energy 0
No orders (holds)

Turn End:
Energy check: energy = 0 -> -1 HP
R health: 1 - 1 = 0 -> destroyed
```

**Expected End State**: R removed from game.

**What This Tests**: Zero-energy attrition penalty.

---

### I4: Rotation After Combat

Rotation applies after combat damage.

```
Before:
R at (1,1), facing 0 (E)
P at (2,1), facing 180 (W), attacking R

Orders:
R: rotate clockwise + hold
P: move W (attack R)
```

**Expected Resolution**:
1. Combat resolves using R's PRE-rotation facing (0/E)
2. If R survives, rotation applied: 0 -> 60
3. R ends turn facing 60 (NE)

**What This Tests**: Rotation timing relative to combat.

---

### I5: Formation Bonus During Combat

Verify formation bonuses calculated correctly in combat.

```
Before:
Red formation (all facing E):
    R1>
     |
R2>-R3>-R4>
     |
    R5>

R3 at center, 4 allies in side positions.
P attacking R3.
```

**Expected Strength for R3**:
- Base: 1
- Side cohesion: +4 (R1, R2, R4, R5 in side positions)
- Total: 5

P would need strength > 5 to dislodge R3.

**What This Tests**: Combat resolution with formation bonuses.

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Movement Tests | 12 |
| Formation Tests | 12 |
| Combat Tests | 15 |
| Integration Tests | 5 |
| **Total** | **44** |

---

## Test Implementation Notes

1. **Position Validation**: All scenarios use odd-R offset coordinates. Verify neighbor calculations match codebase `@even_row_moves` and `@odd_row_moves`.

2. **Strength Calculation**: Formation bonuses require:
   - Same color
   - Same rotation
   - Correct neighbor position (side vs front vs rear)

3. **Combat Precedence**:
   - Strictly greater wins (ties favor defender)
   - Support cutting happens before strength calculation
   - Rotation applies after combat

4. **Group Rules**:
   - Groups require 2+ adjacent same-color same-rotation units
   - Majority balk triggers group-wide balk
   - Groups move atomically but don't dislodge atomically

5. **Retreat Rules**:
   - Cannot retreat to attacker's origin hex
   - Cannot retreat to standoff hex
   - Cannot retreat to occupied hex (unless that unit also retreating)
   - No valid retreat = death
