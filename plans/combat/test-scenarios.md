# Phalanx Test Scenarios

Odd-R offset hex grid. `R` = red, `P` = purple. Positions as `(col, row)`.

---

## Movement Tests (M1-M12)

### M1: Head-On Collision
`R@(1,1)→E` and `P@(3,1)→W` both target `(2,1)`. **Both balk.**

### M2: 120° Crossing
`R@(0,2)→E` and `P@(2,1)→SW` both target `(1,2)`. **Both balk.**

### M3: 60° Sliding (No Conflict)
`R@(1,2)→E` to `(2,2)` and `P@(1,1)→NE` to `(2,0)`. Different destinations. **Both succeed.**

### M4: Position Swap Attempt
`R@(1,1)→E` and `P@(2,1)→W`. Each targets other's position. **Swap blocked, both balk.**

### M5: Three-Way Destination Conflict
`R@(0,2)→E`, `P1@(2,1)→SW`, `P2@(2,3)→NW` all target `(1,2)`. **All three balk.**

### M6: Chain Collision Cascade
`R1@(0,1)`, `R2@(1,1)`, `R3@(2,1)` all `→E`. `P@(3,1)` holds.
P blocks R3 → R3 blocks R2 → R2 blocks R1. **All balk.**

### M7: Group Atomic Movement
`R1@(0,1)`, `R2@(1,1)`, `R3@(2,1)` same rotation, all `→E`, path clear.
**All succeed:** R1→(1,1), R2→(2,1), R3→(3,1).

### M8: Phalanx Partial Block
Phalanx `{R1,R2,R3}` all `→E`, but `P@(3,1)` blocks R3.
**All-or-nothing:** entire phalanx balks.

### M9: Edge of Map
`R@(0,2)` facing W, orders `→W` (off map). **Invalid → converted to hold.**

### M10: Invalid Move (Wrong Facing)
`R@(2,2)` facing E (0°), orders `→SW` (blocked by rotation constraint). **Converted to hold.**

### M11: Chase (Vacating Hex)
`R@(1,1)→E` to `(2,1)`, `P@(2,1)→E` to `(3,1)`.
P vacates as R arrives. **Both succeed.**

### M12: Three-Way Rotation Swap (Cycle)
`R1@(1,0)→SE` to (1,1), `R2@(1,1)→W` to (0,1), `R3@(0,1)→NE` to (1,0).
Cycle: A→B→C→A. **All balk.**

---

## Formation Tests (F1-F12)

### F1: Single Isolated Unit
`R@(2,2)` no adjacent allies. **Strength: 1** (base only).

### F2: Two Units Side by Side
`R1@(2,1)` and `R2@(2,2)` both facing E. R2 is R1's SE (right flank).
**Each gets +1 side cohesion = strength 2.**

### F3: Line of 3 (Center Gets +2)
`R1@(1,1)`, `R2@(1,2)`, `R3@(1,3)` all facing E.
R2 has R1 at NE (left flank) and R3 at SE (right flank).
**R2 strength: 1 + 2 = 3.**

### F4: Maximum Side Cohesion
R at center with allies at all 4 flank positions (NE, NW, SE, SW).
**Side bonus capped at +2** (geometry: only 2 actual side hexes per facing).

### F5: Column of 2 (Rear Support)
`R1@(1,2)` and `R2@(2,2)` both facing E. R1 is W (rear) of R2.
**R2 strength: 1 + 1(depth) = 2.**

### F6: Column of 3 (Depth Rule)
`R1@(0,2)`, `R2@(1,2)`, `R3@(2,2)` all facing E.
R3 front: R2 directly behind = +1. R1 is two hexes away (no bonus).
**R3 strength: 1 + 1 = 2.** (Depth counts only immediate rear hex.)

### F7: 2×2 Block
4 units in square: `{(1,1),(2,1),(1,2),(2,2)}` all facing E.
Corner units get partial bonuses. **Formation bonus varies by position.**

### F8: 3×2 Block
6 units in 3×2 grid. Center unit (R5) has allies at NE and W.
**R5 strength: 1 + 1(side) + 1(depth) = 3.**

### F9: L-Shaped Formation
Corner unit has ally in one flank position + ally in front.
**Corner strength: 1 + 1(side) = 2.** (Front doesn't add bonus.)

### F10: Mixed Rotations (No Bonus)
`R1@(2,1)` facing E, `R2@(2,2)` facing NE. Adjacent but different rotations.
**No side cohesion: same rotation required.**

### F11: Adjacent Different Colors
`R@(2,1)` facing E, `P@(2,2)` facing E. Adjacent, same rotation, different teams.
**No bonus: same color required.**

### F12: Surrounded Unit (Maximum)
Unit at center with 6 allies at all adjacent hexes, all same rotation.
**Max strength: 1 + 2(sides) + 1(rear) = 4.** (Front hex doesn't contribute.)

---

## Combat Tests (C1-C15)

### C1: Equal Strength Standoff
`R(str=1)@(1,1)→E` attacks `P(str=1)@(2,1)` holding.
Tie: **attacker bounces, no damage.**

### C2: Attacker Wins (Dislodge)
`R1@(0,1)`, `R2@(1,1)` with R3 flanking. `R2(str=3)→E` attacks `P(str=1)@(2,1)`.
**P dislodged. Frontal attack = 0 damage.** P must retreat.

### C3: Flank Attack (+1 Bonus)
`R@(2,0)→SW` attacks `P@(2,1)` facing E. Attack from P's NE = flank.
**If R wins: P takes -1 HP (flank damage).**

### C4: Rear Attack (+2 Bonus)
`R@(1,1)→E` attacks `P@(2,1)` facing E. Attack from P's W = rear.
**If R wins: P takes -2 HP (rear damage).**

### C5: Mutual Attack (Equal Strength)
`R@(1,1)→E` and `P@(2,1)→W`. Both str=1.
**Standoff: both balk, no damage (front-to-front).**

### C6: Mutual Attack (Unequal)
`R1@(0,1)→E`, `R2@(1,1)→E` attacks `P@(2,1)→W`. R2 has support, str=2 vs P str=1.
**R2 wins, advances. P dislodged, retreats. No HP damage (frontal).**

### C7: Three-Way Collision (Highest Wins)
`R(str=3)`, `P1(str=2)`, `P2(str=1)` all target `(1,2)`.
**R wins, gets hex. P1 and P2 balk (no damage—they weren't holding).**

### C8a: Pushing Support Cutting
`R1→E` attacks D, `R2` supports R1 (different rotation = not in formation), `P1` attacks R2.
**P1's attack cuts R2's pushing support. R1 loses bonus, tie, bounces.**

### C8b: Formation Bonus NOT Cut
Same setup but R1 and R2 have same rotation (in formation).
**R1's formation bonus persists even when R2 is attacked.** Phalanx cohesion.

### C9: Dislodge with Valid Retreat
`R(str=2)@(1,1)→E` attacks `P(str=1)@(2,1)`. Empty `(3,1)` available.
**P dislodged, retreats to (3,1), takes damage per attack angle.**

### C10: Dislodge with No Retreat (Death)
P surrounded by enemies except attack direction. R dislodges P.
**No valid retreat hex → P destroyed.**

### C11: Retreat Cascade
R1 dislodges P1 (wants to retreat to P2's hex). R2 simultaneously dislodges P2.
**P2 retreats first (opens hex), P1 retreats to vacated hex.** Retreating unit priority.

### C12: Multiple Attackers on One Defender
`R1@(2,0)→SW` and `R2@(3,2)→NW` both attack `D@(2,1)`.
**Forces combine: 1+1=2 vs 1. D dislodged. Damage = worst angle (flank = -1 HP, not stacking).**

### C13: Retreat Priority Over Movement
R1 dislodges D. D's only retreat is (2,1). R2 is moving to (2,1).
**D gets (2,1) (retreat priority). R2 bounces.**

### C14: Attack on Moving Unit
`R@(2,0)→SW` attacks `P@(2,1)→E`. Attack from P's flank.
**P's move cancelled. If R wins: P dislodged, -1 HP (flank).**

### C15: Counterparallel Attack (Frontal)
`R@(1,1)→E` and `P@(2,1)→W`. Head-on.
**Equal: standoff, no damage. Unequal: winner advances, loser retreats, NO damage (shields).**

---

## Integration Tests (I1-I5)

### I1: Full Turn Resolution Sequence
Multiple units with moves, attacks, supports. Verifies 10-phase resolution order:
1. Snapshot state, detect groups
2. Validate orders
3. Calculate supports
4. Detect conflicts
5. Calculate strengths
6. Resolve combat
7. Execute movements
8. Apply damage/retreats
9. Apply rotations
10. Update energy

### I2: Group Movement with Combat
Phalanx `{R1,R2,R3}` all `→E` attacks `P@(3,1)`.
**Tests:** group atomic movement + combat at front + balk propagation.

### I3: Energy Depletion Death
`R@(2,2)` health=1, energy=0, no orders.
**Turn end: energy=0 → -1 HP → health=0 → destroyed.**

### I4: Rotation After Combat
`R@(1,1)` orders rotate clockwise. `P@(2,1)→W` attacks R.
**Combat uses R's PRE-rotation facing. Rotation applied after combat resolves.**

### I5: Formation Bonus During Combat
R3 at center with 4 allies in side positions, all facing E.
`R3 strength: 1 + 2(sides) + 1(depth) = 4.` Enemy needs >4 to dislodge.

---

## Summary

| Category | Count |
|----------|-------|
| Movement | 12 |
| Formation | 12 |
| Combat | 15 |
| Integration | 5 |
| **Total** | **44** |

## Implementation Notes

- **Strength requires:** same color + same rotation + correct neighbor position
- **Combat:** strictly-greater wins (ties = defender)
- **Group:** 2+ adjacent same-color same-rotation; any member blocked = all balk
- **Retreat:** not to attacker origin, not to occupied hex (unless vacating), no retreat = death
