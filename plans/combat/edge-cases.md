# Combat & Movement Edge Cases

Movement = combat with opposing strength 0. All hex contests resolved by team strength comparison.

## Core Rules

- Strength = 1 (base) + bonuses
- Strictly greater wins; ties = stalemate (all balk)
- Damage: frontal = 0 HP (shields), flank = -1 HP, rear = -2 HP
- Formation bonus (side/depth): NEVER cut
- Push support (non-formation ally behind): cut if supporter attacked

---

## Movement Cases

| Case | Resolution |
|------|------------|
| `R@(1,1)→E` to empty | Always succeeds |
| `R@(0,1)→E`, `R@(1,0)→SE` both target (1,1) | First-ordered moves, others support |
| `R@(0,1)→E`, `P@(2,1)→W` both target (1,1) | Higher team strength wins; equal = both balk |
| `R@(0,1)→E`, `P@(1,1)→W` (swap attempt) | Impossible. Both balk |
| `R@(0,1)→E` to off-map | Invalid. Balk |

**Cycles**: Any cyclic movement dependency (2-way swap, 3-way rotation) causes all participants to balk, regardless of team composition.

**Same-team chains**: `R(A)→R(B)→R(C)→empty` resolves tail-first: C moves, then B, then A.

**Same-team chain blocked**: `R(A)→R(B)→P(C)` where C holds. B vs C is strength contest. If B loses, B balks, then A balks (can't push friendly B).

---

## Combat Cases

### Mutual Attacks

| Scenario | Resolution |
|----------|------------|
| `R@(0,1)→E` attacks `P@(1,1)`, `P→W` attacks R (equal str) | Both balk, no damage (Diplomacy-style) |
| Same but R has str 3, P has str 2 | R wins, moves to (1,1). P dislodged. Frontal = 0 damage |

Frontal attacks displace but don't damage (shields block shields).

### Multiple Attackers

Combined attack: `R(A)@(0,1)→E` and `R(B)@(1,0)→SE` both attack `P(C)@(1,1)`.

- Forces combine: Red str = A + B
- First-ordered attacker is **lead** (moves in on victory)
- Non-leads hold position
- Damage to defender: dislodge + angle bonuses from each attacker

### Support Cutting

| Supporter Type | Cut if Attacked? |
|----------------|------------------|
| Formation member (same rotation, adjacent, same direction) | NO |
| Push support (behind, not in formation) | YES (unless attacked by the target) |

### Dislodge & Retreat

Retreat direction: same direction as lead attacker's attack.

1. Primary retreat: hex in attack direction
2. Fallback: adjacent backward hex based on facing
3. Both blocked: unit destroyed

Retreating unit has priority over moving units targeting same hex.

### Surrounded / No Retreat

No valid retreat = destruction. No defensive bonus for being surrounded.

### Friendly Fire

Prevented at validation. Cannot target friendly-occupied hex.

### Holding Defender

No strength bonus for holding. No energy gain if attacked. Defense comes from support positioning and facing.

### Attacked While Moving

- Moving toward attacker: mutual combat
- Moving away/perpendicular: intercepted at origin, -1 HP penalty if attacker wins

---

## Resolution Order

```
1. Validate orders (reject friendly fire, off-map)
2. Calculate support (mark cut if supporter attacked)
3. Calculate strengths (base + formation + valid support)
4. Resolve attacks by hex (sum forces, determine winner, calculate damage, queue retreats)
5. Resolve retreats (priority over movers, destroy if blocked)
6. Resolve movements (lead attacker moves in, others hold)
7. Apply damage (remove units at 0 HP)
8. Apply energy (movement costs, hold bonuses negated if attacked)
9. Apply rotations (post-movement)
```

---

## Test Matrix

| ID | Scenario | Expected |
|----|----------|----------|
| 1 | `R→empty` | Moves |
| 2 | `R(A),R(B)→X` same team | First moves, second supports |
| 3 | `R(A)→X←P(B)` equal str | Both balk |
| 4 | `R(A),R(B)→X←P(C)` | Red wins (2v1), A moves |
| 5 | Swap `R↔P` | Both balk |
| 6 | Chain `R(A)→R(B)→R(C)→gap` | All move |
| 7 | Mutual attack equal str | Both balk, 0 damage |
| 8 | Mutual attack R>P | R moves, P dislodged, 0 damage (frontal) |
| 9 | Flank attack | Defender takes -1 HP |
| 10 | Surrounded, dislodged | Destroyed |
| 11 | Friendly fire attempt | Order rejected |

---

## Open Questions

- Phalanx atomicity: if one unit dislodged, does whole formation stop?
- Support cutting granularity: does str-1 attack cut support?
- Damage caps: can a unit take >3 HP in one turn?
- Overkill: does excess strength = extra damage?
