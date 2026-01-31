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

**Decision**: +1 per adjacent side ally (max +2 by geometry—only 2 side neighbors possible)

**Rationale**: Simple counting. The geometry naturally limits side bonus to +2 (one neighbor on each side). No artificial cap needed.

---

## 3. Depth Bonus

**Formula options**:
- +1 per rear ally (uncapped)
- +2 for first rear ally only (binary)
- +1 first, +0.5 each additional (diminishing returns)

**Decision**: +1 per rear ally (no cap)

**Rationale**: Deep formations are powerful but extremely vulnerable to flanking. A 10-deep column has massive pushing power but can be destroyed by a single flanking attack. The game self-balances without artificial caps.

---

## 4. Bonus Caps

**Cap options**:
- Global cap of +4 total bonus
- Separate caps (+3 side, +2 rear)
- No cap

**Decision**: No artificial cap. Side is limited to +2 by geometry. Rear is unlimited.

**Rationale**: The game self-balances. Deep formations have massive strength but are narrow and easily flanked. Wide formations are harder to flank but have less pushing power. Players naturally avoid degenerate formations because they lose to flanking attacks.

---

## 5. Same Facing AND Same Movement Definition

**Options**:
- Exact rotation match only
- Exact rotation match AND same movement direction (recommended)

**Decision**: Exact rotation match AND same movement direction required

**Rationale**: A phalanx is soldiers facing the same direction AND advancing together. Units with matching rotation but different movements (one advances, one rotates, one holds) are NOT a coordinated formation. This critical rule ensures formation bonuses reward actual tactical coordination, not just proximity.

**Key implications**:
- Formation bonus applies ONLY to units explicitly declared in the same phalanx
- Adjacent units NOT in the same phalanx get NO bonus, regardless of facing
- Movement direction is irrelevant - phalanxes move atomically as one unit

---

## 6. Grouping Model

**Options**:
- Implicit (groups computed from adjacency each turn) - REJECTED
- Explicit (players declare groups via orders) - CHOSEN
- Hybrid (auto-detect with player override) - REJECTED

**Decision**: Explicit phalanx declaration within pre-game groups

**Rationale**:
- **Groups** are organizational units created in pre-game planning stage, fixed for entire battle
- **Phalanxes** are tactical formations explicitly declared during battle via "Form Phalanx" command
- Phalanxes can only form within a single group (cross-group phalanxes not allowed)
- Forming a phalanx is a deliberate tactical commitment, not an emergent property
- Creates strategic depth: players must choose when to form up vs stay flexible

**See**: `group/spec.md` for full specification.

---

## 7. Movement Atomicity

**Options**:
- Full atomic (any balk = all balk) - CHOSEN
- Independent (each unit moves separately)
- Majority rule (majority balk = all balk) - REJECTED

**Decision**: All-or-nothing atomic movement for phalanxes

**Rationale**: If ANY phalanx member would balk, ALL members balk. This is simpler than majority rule and reflects that a phalanx truly moves as one unit. Loose units in a group still move independently (non-atomic).

**Implementation note**: Order precedence is Individual > Phalanx > Group. Phalanxes are stored in game state and persist until disbanded or broken.

---

## 8. Combat Model

**Options**:
- Pure Diplomacy (dislodge only, no HP)
- Pure HP/Damage (attrition only, no dislodge)
- Hybrid (dislodge + angle-based damage, as originally proposed)
- Simplified Hybrid (dislodge = 1 HP loss, no angle damage)

**Decision**: Hybrid (Dislodge + Stacking Damage)

**Rationale**: Strength comparison determines dislodge. Damage stacks: dislodge costs 1 HP plus angle-based bonus damage. Units at 0 HP are destroyed. This creates tactical depth by rewarding flanking maneuvers with extra damage.

**Damage formula**: Dislodge (1 HP) + Angle bonus (Frontal=0, Flank=+1, Rear=+2)
- Frontal dislodge: 1 HP
- Flank dislodge: 2 HP
- Rear dislodge: 3 HP

---

## 9. Flanking Mechanics

**Options**:
- Negate defender bonuses only (attacker gains nothing, defender loses directional bonuses)
- Attacker bonus to strength (+1 flank, +2 rear)
- Damage bonus only (extra HP damage, no strength change)
- Combined (negate + attacker bonus)
- Auto-dislodge (rear attack = automatic win)

**Decision**: Damage bonus only (flanking affects DAMAGE, not strength). Damage stacks.

| Source | HP Lost |
|--------|---------|
| Dislodge | 1 HP |
| Frontal angle bonus | +0 (shields block) |
| Flank angle bonus | +1 |
| Rear angle bonus | +2 |

**Total on dislodge**: Frontal = 1 HP, Flank = 2 HP, Rear = 3 HP.

**Rationale**:
1. **Clean separation**: Strength determines WHO wins, dislodge + angle determines damage
2. **Frontal attacks are safer**: Push enemies back with minimal damage (1 HP)
3. **Flanking is deadly**: Same strength, but flank/rear dislodge deals 2-3 HP
4. **Encourages maneuver**: Frontal pushes create opportunities for flanking damage

**Key insight**: A frontal assault that wins deals NO damage. To hurt the enemy, you must attack from the side or rear.

---

## 10. Retreat Rules

**Options**:
- Any adjacent empty hex
- Any hex except attack origin and standoff hexes
- Player chooses retreat direction
- Random selection from valid hexes
- Deterministic: same direction as attack

**Decision**: Deterministic retreat in the same direction as the attack, with fallback to adjacent backward hex

**Retreat algorithm**:
1. Identify lead attacker (first-ordered unit attacking the hex)
2. Primary retreat: hex in the same direction as the attack (e.g., attacked from NE → retreat NE)
3. Fallback retreat: if primary blocked, use one of the unit's adjacent backward directions based on its facing
4. If both blocked: unit destroyed

**Rationale**: Deterministic rule eliminates randomness complaints. "Retreat in direction of attack" is intuitive (pushed back by the attack). Fallback to adjacent backward direction gives a second chance. Multiple attackers don't complicate the rule—only lead attacker matters for retreat direction.

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

**Decision**: Adjacent allies moving same direction add +1 to attack (cap +2), with Diplomacy-style support cutting

**Support modes**:
- Moving alongside (same direction, adjacent)
- Moving behind (pushing, depth support)
- Attacking same hex (combined attack - forces add)

**Support cutting (Diplomacy-style)**:
Support is voided ONLY if the supporter is attacked by a unit **other than**:
1. The unit being attacked by the supported unit
2. The unit the supporter itself is targeting

This means if B is defending and attacks the supporter, the support is NOT cut (B is busy defending). Only unrelated attackers cut support.

**Rationale**: Following Diplomacy precedent. Creates tactical depth: you can't just attack with the defender to cut support. You need flanking forces to disrupt enemy support lines.

---

## Summary Table

| Decision | Chosen Option | Max Value |
|----------|---------------|-----------|
| Base strength | Uniform | 1 |
| Side cohesion | +1/ally | +2 (geometry) |
| Rear depth | +1/ally | No cap |
| Total bonus cap | None | Self-balancing |
| Phalanx membership | Explicit declaration required | - |
| Groups | Pre-game planning stage | Fixed for battle |
| Movement | All-or-nothing atomic | For phalanxes |
| Combat model | Dislodge + HP | 3 HP |
| Flanking | Damage only (NOT strength) | 2 HP (rear) |
| Retreat | Same direction as attack; fallback to adjacent backward | - |
| Collision | Destination only | - |
| Support | Same direction | +2 |

**Max unit strength**: Unbounded in theory; in practice limited by formation vulnerability. A 10-deep column gives +11 but is destroyed by one flanking unit.

**Typical max strength**: 1 (base) + 2 (side) + 2 (rear) + 2 (support) = **7** (balanced 3-deep formation with support)

---

## Open Questions for Playtesting

1. **Stalemate frequency**: Will equal strengths result in too many standoffs? **DEFERRED** - Turn timer will force rapid decisions. Further investigation left to playtesting.

2. **Snowball dynamics**: First dislodge creates HP advantage that compounds. **DEFERRED** - Energy system should help balance; leave to playtesting.

3. **Blob viability**: Max-strength interior units (strength 5) require concentrated assault to crack. Ensure maps have flanking routes.

4. **Retreat direction**: **RESOLVED** - Deterministic retreat in same direction as attack. Fallback to adjacent backward direction if blocked.

5. **Rotation timing**: **RESOLVED** - Pre-rotation facing used for all calculations.
