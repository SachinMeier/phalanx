# Phalanx Design Decisions Summary

**Date**: 2026-01-26

This document consolidates all explored options and final recommendations for the Phalanx combat and formation system.

---

## 1. Base Strength

**Options considered**:
- Uniform base strength (1 for all units)
- Variable by unit type (1-3 based on unit class)

**Decision**: Uniform base strength of 1

**Rationale**: Maximally simple. All tactical advantage comes from positioning, not stat variety. Easier to balance and teaches players that formation matters more than individual unit power.

---

## 2. Side Cohesion Bonus

**Formula options**:
- +1 per adjacent ally with same facing (uncapped)
- +0.5 per adjacent ally (fractional)
- +1 for first ally only (binary)

**Decision**: +1 per adjacent ally, capped at +2

**Rationale**: Simple counting. Rewards tight formations without becoming dominant. The cap forces tradeoffs between width and depth. Mental model: "Each flank can contribute up to +2."

---

## 3. Depth Bonus

**Formula options**:
- +1 per rear ally (uncapped)
- +2 for first rear ally only (binary)
- +1 first, +0.5 each additional (diminishing returns)

**Decision**: +1 per rear ally, capped at +2

**Rationale**: Symmetric with side bonus. Rewards formations 2-3 ranks deep without infinite stacking. A three-deep column achieves maximum rear bonus.

---

## 4. Bonus Caps

**Cap options**:
- Global cap of +4 total bonus
- Separate caps (+3 side, +2 rear)
- No cap

**Decision**: Separate caps of +2 side and +2 rear (effective max +4)

**Rationale**: Separate caps are intuitive and create meaningful tradeoffs. Wide formations maximize side bonus; deep formations maximize rear bonus. The 2+2 split gives max strength of 5, preventing runaway blob advantage while rewarding tactical positioning.

**Open concern**: Blob formations with max-strength interior units may still dominate. Mitigation relies on flanking mechanics and map design with objectives.

---

## 5. Same Facing Definition

**Options**:
- Exact match (rotation must be identical)
- Within 60 degrees (allows some variance)

**Decision**: Exact match

**Rationale**: A phalanx is soldiers facing precisely the same direction. Misalignment breaks the wall. Binary rule eliminates ambiguity and rewards precise coordination.

---

## 6. Grouping Model

**Options**:
- Implicit (groups computed from adjacency each turn)
- Explicit (players declare groups via orders)
- Hybrid (auto-detect with player override)

**Decision**: Implicit grouping

**Rationale**: Groups emerge from positioning automatically. No new state, no new orders. Adjacent friendly units with identical rotation form a phalanx naturally. Historically accurate (Greeks didn't "declare" formations mid-battle) and zero player burden.

**Future consideration**: If implicit grouping proves too subtle for players to understand, add visual indicators showing detected groups.

---

## 7. Movement Atomicity

**Options**:
- Full atomic (any balk = all balk)
- Independent (each unit moves separately)
- Majority rule (majority balk = all balk)

**Decision**: Majority rule

**Rationale**: Per game design doc: "A phalanx is only dislodged if a majority of its members would be dislodged." If 3 of 5 units would balk, all 5 balk. This prevents accordion effects while allowing some flexibility.

**Implementation note**: Groups detected at turn start, before orders execute. Rotation orders do not affect grouping for the current turn.

---

## 8. Combat Model

**Options**:
- Pure Diplomacy (dislodge only, no HP)
- Pure HP/Damage (attrition only, no dislodge)
- Hybrid (dislodge + angle-based damage, as originally proposed)
- Simplified Hybrid (dislodge = 1 HP loss, no angle damage)

**Decision**: Simplified Hybrid (Diplomacy + Minimal HP)

**Rationale**: Strength comparison determines dislodge. Being dislodged costs 1 HP. Units at 0 HP are destroyed. This creates tactical depth while keeping damage rules minimal. Flanking helps you win the dislodge contest rather than adding damage stacking complexity.

**Rejected alternative**: The original hybrid with angle-based damage (+1 flank, +2 rear) was deemed too complex. Two overlapping damage sources violate the "maximally simple" ethos.

---

## 9. Flanking Mechanics

**Options**:
- Negate defender bonuses only (attacker gains nothing, defender loses directional bonuses)
- Attacker bonus only (+1 flank, +2 rear to attacker strength)
- Damage bonus only (extra HP damage, no strength change)
- Combined (negate + attacker bonus)
- Auto-dislodge (rear attack = automatic win)

**Decision**: Attacker bonus only (+1 flank, +2 rear)

**Rationale**:
1. **Decisive against isolated units**: Lone flanker (strength 2) beats lone defender (strength 1)
2. **Formations still strong**: Single flanker cannot beat 3+ strength formation
3. **Simple rule**: No direction-dependent bonus negation to track
4. **Encourages combined arms**: Frontal pressure + flanking = victory

**Rejected alternative**: "Flanking negates defender bonuses" was deemed too complex (requires tracking attack direction and which allies are on that side) and useless against isolated units (no bonuses to negate).

---

## 10. Retreat Rules

**Options**:
- Any adjacent empty hex
- Any hex except attack origin and standoff hexes
- Player chooses retreat direction
- Random selection from valid hexes

**Decision**: Any adjacent empty hex except attack origin and standoff hexes; random selection if multiple valid options

**Rationale**: Simple rule set. Retreating into the space the attack came from is forbidden. Standoff hexes (where ties occurred this turn) are also forbidden. If no valid retreat exists, unit is destroyed.

**Open concern**: Player choice for retreat direction adds tactical depth but requires async retreat phase. Currently using random selection for simplicity. May revisit if playtesting shows retreat randomness feels unfair.

---

## 11. Collision Geometry

**Options**:
- Destination-only collision (existing Diplomacy behavior)
- Pass-through collision (units crossing paths collide)
- Zone-of-control based collision

**Decision**: Destination-only collision

**Rationale**: Already implemented in Engine.Diplomacy. Simple for players to predict. Units collide if and only if they target the same hex. No new collision types.

**Implementation note**: This means two units swapping positions (A moves to B, B moves to A) do NOT collide, which differs from some wargame systems.

---

## 12. Support Mechanics

**Options**:
- Adjacent allies moving same direction add to attack (+1 per ally, cap +2)
- Rear allies only provide support
- Support cutting (attacked supporters provide no bonus)
- Support chaining (supporters of supporters count)

**Decision**: Adjacent allies moving same direction add +1 to attack (cap +2), with support cutting

**Rationale**: Check all 6 adjacent hexes. Count allies with same movement direction. Cap at +2. If a supporting unit is attacked, its support is nullified. This creates tactical opportunities to break enemy attacks by targeting their support.

**Open concern**: Support chain validation (if a rear supporter is themselves under attack, does their support count?) needs clarification. Current recommendation: attacked supporters provide no support (support is nulled if the supporting unit is attacked).

---

## Summary Table

| Decision | Chosen Option | Max Value |
|----------|---------------|-----------|
| Base strength | Uniform | 1 |
| Side cohesion | +1/ally, capped | +2 |
| Rear depth | +1/ally, capped | +2 |
| Total bonus cap | Separate caps | +4 |
| Same facing | Exact match | - |
| Grouping | Implicit | - |
| Movement | Majority rule | - |
| Combat model | Dislodge + HP | 3 HP |
| Flanking | Attacker bonus | +2 (rear) |
| Retreat | Random valid hex | - |
| Collision | Destination only | - |
| Support | Same direction | +2 |

**Max unit strength**: 1 (base) + 2 (side) + 2 (rear) + 2 (support) = **7** (attacking with full support)

**Max defensive strength**: 1 (base) + 2 (side) + 2 (rear) = **5**

---

## Open Questions for Playtesting

1. **Stalemate frequency**: Will equal forces result in too many standoffs? May need objectives or turn limits.

2. **Snowball dynamics**: First dislodge creates HP advantage that compounds. Consider morale/momentum mechanics if this proves too harsh.

3. **Blob viability**: Max-strength interior units (strength 5) require concentrated assault to crack. Ensure maps have flanking routes.

4. **Retreat randomness**: Random retreat selection may feel arbitrary. Consider player choice if turn structure allows.

5. **Rotation timing**: Attack resolves before rotation. Which facing determines force calculation—pre-rotation or post-rotation? Current assumption: pre-rotation (the facing at turn start).
