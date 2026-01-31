# Combat Resolution Edge Cases

Simultaneous-turn hex combat with strength-based resolution. This document explores every edge case with diagrams, rule interpretations, and recommendations.

**Base Rules Reference**:
- Strength = 1 (base) + support bonuses
- Strictly greater strength wins; ties = standoff
- Dislodged = opposing strength > own strength
- Damage: frontal (0 HP - shields block), flank (-1 HP), rear (-2 HP)
- Support nullified if supporter attacked

---

## 1. Mutual Attack Resolution (Symmetric)

**Scenario**: A attacks B, B attacks A, both strength 2.

```
Before:          Orders:           Resolution?
  A → B          A: move to B        ???
  B → A          B: move to A
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **Mutual standoff** | Both hold, no damage | Neither overcomes the other |
| **Mutual bounce** | Both hold, both take -1 HP | Head-on collision penalty |
| **Swap prevented** | Both hold, no damage | Two units cannot swap hexes |
| **Mutual destruction** | Both take full damage, hold | Simultaneous attacks resolve independently |

### Recommended Rule

**Mutual standoff (Diplomacy-style)**. Both units balk, both remain in place, no damage inflicted.

**Rationale**:
- Follows Diplomacy precedent: equal forces = stalemate
- Front-to-front attacks (the only geometry for mutual attack) mean shields block shields
- Swaps are inherently prevented: two units cannot pass through each other
- Simple: "neither overcomes the other, nothing happens"

### Balance Implications

- Head-on charges are ineffective, not risky
- Rewards strength advantage (asymmetric attacks break ties)
- Encourages flanking maneuvers over direct confrontation
- Prevents "mutual destruction" strategies

---

## 2. Asymmetric Mutual Attack

**Scenario**: A (str 3) attacks B, B (str 2) attacks A.

```
Before:          Strengths:
  A ══► B        A: 3 (has support)
  B ══► A        B: 2 (unsupported)
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **Winner takes no damage** | A moves to B's hex, B dislodged, B takes -1 HP | Strength differential means clean victory |
| **Both take damage** | A moves, B dislodged. A takes -1 HP, B takes -1 HP | B's attack still "happened" |
| **Proportional damage** | A takes reduced damage, B takes full | Strength difference reduces damage |
| **Attacker damage only if counterparallel** | Depends on angle | Per MECHANICS.md: non-counterparallel movement = -1 HP |

### Recommended Rule

**Head-on (frontal) attacks cause dislodge but NO damage. Damage only comes from flank/rear attacks.**

```
Case A: Counterparallel (head-on mutual attack)
  A wins (higher strength), moves to B's hex
  A takes 0 HP (B's frontal attack = shields block)
  B dislodged, takes 0 HP (A's frontal attack = shields block), must retreat

Case B: Non-counterparallel (flank/rear attack, not mutual)
  A wins, moves to B's hex
  B dislodged, takes damage based on attack angle:
    - Flank: -1 HP
    - Rear: -2 HP
```

**Rationale**: Shields protect the front. A phalanx can be pushed back frontally but casualties come from exposed flanks/rear.

### Balance Implications

- Head-on attacks are safe but often ineffective (standoffs if equal, only displacement if unequal)
- Flanking supremacy: only way to inflict damage
- Creates tactical depth: "Frontal push to displace, flank to destroy"
- Encourages combined arms: pin frontally, kill from the side

---

## 3. Formation Bonus vs Support Cutting

**Critical distinction**: Phalanx has TWO strength bonuses with different cutting rules.

| Bonus Type | Source | Can Be Cut? |
|------------|--------|-------------|
| **Formation bonus** (side cohesion + depth) | Adjacent allies with same rotation moving same direction | **NO** - intrinsic to formation |
| **Pushing support** (Diplomacy-style) | Ally behind pushing same direction (NOT in group) | **YES** - Diplomacy rules apply |

### Formation Bonus: NEVER Cut

**Scenario**: A and C are in a phalanx (same rotation, adjacent). Both advance against B. D attacks C from the side.

```
Before:                  Orders:
    D                    A: move toward B (attack)
    ↓                    C: move with A (same direction, same rotation)
    C → A → B            D: attack C from flank
                         B: hold
```

**Resolution**:
1. A and C are in a group (same rotation + adjacent + same movement direction)
2. A gets formation bonus from C (+1 side cohesion)
3. D attacks C from flank
4. C may be dislodged and take -1 HP (flank damage)
5. **A's strength is NOT reduced** - formation bonus persists
6. A's attack on B resolves with full strength
7. The phalanx may advance even as C takes damage

**Rationale**: Formation bonus represents the physical structure of overlapping shields and coordinated spears. This doesn't disappear just because one unit is threatened - the line holds together.

### Pushing Support: CAN Be Cut (Diplomacy-Style)

**Scenario**: A attacks B. S (not in formation with A) pushes from behind to support. D attacks S.

```
Before:                  Orders:
    D                    A: attack B
    ↓                    S: move same direction as A (pushing support, NOT in group)
    S → A → B            D: attack S
```

### Support Cutting Rule

Pushing support (from units NOT in the same formation) is voided if the supporter is attacked by any unit **other than**:
1. The unit the supporter is helping to attack
2. The unit the supporter itself is targeting

| S's Role | S is Attacked By | Support Voided? |
|----------|------------------|-----------------|
| S supports A→B (not in group) | D (unrelated) | **YES** |
| S supports A→B (not in group) | B (A's target) | **NO** - B is busy defending |
| S in formation with A | Any unit | **NO** - formation bonus, not support |

### Resolution Example

```
1. Identify formations (groups with same rotation + movement direction)
2. Calculate formation bonuses (side + depth) - NEVER cut
3. Identify pushing support from non-formation units
4. Check if supporters are attacked (cut rule)
5. Calculate final strengths
6. Resolve combat
```

### Balance Implications

- Formations are resilient: attacking one unit doesn't weaken the whole line
- Flanking a formation unit hurts THAT unit but doesn't break the phalanx strength
- Isolated supporters (not in formation) are vulnerable to cutting
- Encourages tight formations over loose support chains
- Encourages combined arms: "pin their supports from the side, then attack"

---

## 4. Chain Dislodge

**Scenario**: A dislodges B. B's only retreat is hex X. C was moving to hex X.

```
Before:          Orders:              Problem:
  A → B → X      A: attack B          B retreats to X
      ↑          B: hold              C moving to X
      C          C: move to X         Collision!
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **B dies (no valid retreat)** | B destroyed, C moves to X | Retreat blocked = death |
| **C's move fails** | B retreats to X, C bounces | Retreating unit has priority |
| **Both bounce** | B dies (no retreat), C fails (hex contested) | Neither gets X |
| **Cascade check** | B retreats to X, C dislodges B from X | Chain resolution |
| **Retreat to different hex** | B must find alternate retreat | Force alternate path |

### Recommended Rule

**Retreating unit has priority over moving unit. C's move fails.**

Resolution order:
1. A dislodges B (attacking from some direction)
2. B must retreat: primary = same direction as A's attack direction
3. If primary retreat hex (X) is valid, B retreats there
4. C's move to X fails (occupied by retreating B)
5. C holds position

**Exception**: If B's primary retreat (X) AND fallback retreat are both blocked, B is destroyed.

### Balance Implications

- Retreat cutting becomes viable tactic
- Surrounding enemies is powerful (forces death instead of retreat)
- Creates "anvil" strategy: attack from one side, block retreat with another

---

## 5. Multiple Attackers on One Defender (Combined Attacks)

**Scenario**: A and B both attack C from different directions.

```
Before:          Strengths:
  A → C ← B      A: 2 (flanking)
                 B: 2 (frontal)
                 C: 1 (defending)
```

### Recommended Rule

**Forces COMBINE (additive) against defender. First unit ordered to move there is the LEAD and moves in upon victory.**

```
Resolution:
1. Combined attacking force: 2 + 2 = 4
2. Defender strength: 1
3. 4 > 1, C is dislodged
4. Damage to C:
   - Dislodge: -1 HP
   - Flank (from A): -1 HP
   - Frontal (from B): 0 HP extra
   - Total: -2 HP
5. **Lead unit determination**: First unit ordered to attack that hex is the LEAD
6. Lead unit moves into the hex; other attackers hold their original positions
```

**Lead unit rule**: The first unit ordered to move to the contested hex (by order submission timestamp or order in the orders list) becomes the "lead attacker." Upon victory, only the lead moves in; other attackers stay in place.

**Why first-ordered?**:
- Simple deterministic rule
- Rewards quick/decisive orders
- No complex strength comparisons for hex occupation

### Edge Cases

| Scenario | Resolution |
|----------|------------|
| Two allies attack same hex, forces combine | Lead (first ordered) moves in, other holds |
| Lead would be blocked from moving in | Second attacker becomes lead, etc. |
| All attackers have equal strength | Still uses order-based lead selection |
| One ally attacks, other supports from behind | Support bonus applies; attacking unit is obviously lead |

### Balance Implications

- Encourages coordinated attacks
- Flanking + frontal = maximum damage and guaranteed victory
- Clear rule for who occupies: first to order
- No wasted movement - non-leads just hold position

---

## 6. Retreat Cascade

**Scenario**: A dislodges B. B retreats into C's hex. What happens to C?

```
Before:          Resolution:
  A → B → C      A dislodges B
                 B retreats toward C
                 C was holding...
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **C dislodged too** | B pushes C back, cascade continues | Retreat has force |
| **Invalid retreat** | B cannot retreat to occupied hex, B dies | Retreat requires empty hex |
| **B dies, C unaffected** | Occupied hex = no retreat | Harsh but simple |
| **Swap if friendly** | B and C trade places if same team | Friendly retreat through lines |
| **Stack temporarily** | Both in hex, must separate next turn | Allows regrouping |

### Recommended Rule

**Retreat requires unoccupied hex. Retreat direction is deterministic.**

Retreat direction algorithm:
1. Primary retreat: hex in same direction as lead attacker's attack
2. Fallback retreat: if primary blocked, use the unit's other backward direction based on its facing
3. If both blocked: unit destroyed

Exceptions:
- Friendly-occupied hex with that unit also retreating in same direction = allowed (cascade retreat)
- Enemy-occupied hex = always invalid

```
Resolution:
1. A dislodges B (A attacked from direction X)
2. B's primary retreat = same direction as X
3. If primary occupied (by C), check B's fallback retreat direction
4. If fallback also blocked, B is destroyed
5. If either retreat hex is valid, B retreats there
```

### Balance Implications

- Surrounding with your own units cuts retreat
- "Backstop" tactic: position friendly unit behind enemy line
- Creates tension: tight formations block own retreats
- Rewards loose formations for retreat flexibility

---

## 7. Surrounded with No Retreat

**Scenario**: Defender completely surrounded. Dislodged but no valid retreat hex.

```
Before:          Attack:
    E E          All surrounding units attack C
  E C E          C has strength 1
    E E          Combined attack: overwhelming
                 All adjacent hexes occupied
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **Instant death** | C destroyed immediately | No retreat = no survival |
| **Extra damage** | C takes additional -2 HP "trapped" penalty | Surrounded bonus |
| **Attack fails** | Can't dislodge if nowhere to go | Must have retreat for dislodge |
| **Defender fights harder** | C gets +2 strength "cornered" bonus | Desperation defense |
| **Surrender** | C captured (removed, special status) | Alternative to death |

### Recommended Rule

**No retreat = destruction. Standard damage applies, then unit removed.**

```
Resolution:
1. Attackers vs C: overwhelming strength
2. C dislodged
3. Damage calculated normally (dislodge + angle bonuses)
4. Retreat check: no valid hex
5. C destroyed (removed from board)
```

No defensive bonus for being surrounded. The penalty is already baked in: you're surrounded.

### Balance Implications

- Encirclement is devastating (as it should be)
- Creates "pocket" tactics: surround and destroy
- Defender incentive: don't get surrounded
- High-health units survive longer even when surrounded

---

## 8. Friendly Fire Scenarios

**Scenario**: A attacks hex containing friendly unit B.

```
Before:          Order:
  A → B          A: move to B's hex
(same team)      Intentional? Misclick?
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **Prevented at validation** | Order rejected, A holds | Can't attack friendlies |
| **Treated as "push"** | B forced to move in A's direction | Friendly shove mechanic |
| **Swap positions** | A and B trade hexes | Reorganization maneuver |
| **Friendly fire allowed** | B takes damage as if enemy | Fog of war / realism |
| **Order converted to support** | A supports B instead of attacking | Intent interpretation |

### Recommended Rule

**Prevent at order validation. Cannot target friendly-occupied hex with attack.**

If unit A is ordered to move to friendly B's hex:
- Order is invalid
- A holds position
- No damage to either unit
- Player receives invalid order feedback

**Exception**: Explicit "swap" order type could be added (costs energy for both).

### Balance Implications

- Simplifies combat resolution (no friendly fire edge cases)
- Prevents griefing in multiplayer
- Tight formations don't risk self-damage
- May want "push" mechanic for repositioning friendlies

---

## 9. Holding Defender vs Moving Attacker

**Scenario**: Defender ordered to hold. Attacker moves in.

```
Before:          Orders:
  A → D          A: move to D's hex (attack)
                 D: hold
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **Defender bonus** | D gets +1 strength for holding | Set defense advantage |
| **No bonus** | Strength comparison as normal | Orders don't affect strength |
| **Energy advantage** | D gains +0 energy (attacked negates hold benefit) | Updated rule: holding only grants +1 E if not attacked |
| **Facing advantage** | D's rotation/facing fully applies | Prepared for attack |
| **First strike** | D attacks A before A arrives | Intercepting charge |

### Recommended Rule

**No strength bonus for holding, and no energy benefit when attacked.**

```
Resolution:
1. A attacks D: compare strengths normally
2. If A wins: D dislodged, D takes damage
3. If tie/D wins: A bounces back, A may take damage
4. D gains +0 energy (was holding but was attacked, negating hold benefit)
```

Defensive advantage comes from:
- Support positioning (phalanx bonus)
- Facing (attacker must approach from valid angle)
- Energy management (defenders must disengage to recover)

### Balance Implications

- Attacking isn't inherently disadvantaged (no static defense bonus)
- Encourages active play over turtling
- Attrition favors defenders (energy gain)
- Position and support matter more than "hold" order

---

## 10. Counter-Attack Timing

**Scenario**: Defender was planning to move elsewhere. Gets attacked before moving.

```
Before:          Orders:
  A → D → X      A: attack D
                 D: move to X (away from A)
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **Simultaneous resolution** | D's move and A's attack resolve together | True simultaneity |
| **Attacker priority** | A's attack hits first, D's move cancelled | Attacker intercepts |
| **Defender escapes** | D moves to X, A moves to D's vacated hex | D's move succeeds |
| **Collision at origin** | D attacked while "leaving", takes damage, move may fail | Caught mid-movement |
| **Depends on direction** | If D moving toward A: mutual attack. If away: escape possible | Directional logic |

### Recommended Rule

**Simultaneous resolution with directional consideration.**

```
Case A: D moving toward A (mutual attack)
  - Both units attack each other
  - Resolve as mutual attack (see Edge Case #1/#2)

Case B: D moving perpendicular/away from A
  - D's move is "intercepted"
  - A attacks D at D's original position
  - If A wins: D dislodged, doesn't complete move
  - If A loses/ties: D completes move, A bounces

Case C: D moving away but A has higher speed (future mechanic?)
  - Could allow pursuit/intercept mechanics
```

Per MECHANICS.md: "Being attacked while moving anything but counterparallel = -1 health"

This suggests moving units take extra damage when attacked from non-opposing angles.

### Balance Implications

- Can't just "run away" from attacks (intercepted)
- Moving toward attacker = mutual combat
- Flanking attacks on moving units are devastating (extra -1 HP)
- Creates depth: "Do I hold to defend, or move and risk flank damage?"

---

## Summary: Recommended Rule Set

| Edge Case | Recommended Resolution |
|-----------|----------------------|
| 1. Symmetric mutual attack | Both balk, no damage (Diplomacy-style standoff) |
| 2. Asymmetric mutual attack | Winner advances; NO damage (frontal = shields block) |
| 3. Formation vs support | Formation bonus: NEVER cut. Pushing support: cut if attacked |
| 4. Chain dislodge | Retreating unit has priority; attacker bounces |
| 5. Multiple attackers | Forces combine (additive); first-ordered unit is lead and moves in |
| 6. Retreat cascade | Same direction as attack; fallback to adjacent backward; death if both blocked |
| 7. Surrounded, no retreat | Destruction after normal damage |
| 8. Friendly fire | Prevented at order validation |
| 9. Holding defender | No strength bonus; no energy gain when attacked |
| 10. Counter-attack timing | Simultaneous; moving away = intercepted with penalty |

---

## Resolution Order Algorithm

For implementation, resolve in this order:

```
1. VALIDATE ORDERS
   - Reject invalid orders (friendly fire, impossible moves)
   - Replace invalid orders with "hold"

2. CALCULATE SUPPORT
   - Identify all support relationships
   - Mark supports as "cut" if supporter is targeted by any attack

3. CALCULATE STRENGTHS
   - Base strength = 1
   - Add valid support bonuses (non-cut)
   - Add phalanx bonuses

4. RESOLVE ATTACKS (by hex)
   For each contested hex:
   a. Sum attacking forces
   b. Compare to defender strength
   c. Determine winner/standoff
   d. Calculate damage (dislodge + angle + movement penalties)
   e. Queue retreats/movements

5. RESOLVE RETREATS
   - Process retreats in order (by distance from attacker?)
   - Validate retreat hexes
   - Destroy units with no valid retreat

6. RESOLVE MOVEMENTS
   - Move victorious attackers to captured hexes
   - Resolve contested hexes (multiple valid attackers)
   - Bounce failed attackers to origin

7. APPLY DAMAGE
   - Reduce health for all affected units
   - Remove destroyed units (health <= 0)

8. APPLY ENERGY
   - Deduct movement costs
   - Add holding bonuses
   - Apply 0-energy health penalty

9. APPLY ROTATIONS
   - Per MECHANICS.md: "rotation is applied after the attack"
```

---

## Open Questions for Design Decision (RESOLVED)

1. **Retreat direction**: **RESOLVED** - Deterministic retreat in the same direction as the attack. If attacked from NE, retreat to NE. If NE blocked, use the unit's adjacent backward direction based on its facing. Multiple attackers do not affect direction (lead attacker determines retreat).
2. **Multiple attackers on same hex**: **RESOLVED** - First-ordered unit is "lead" and moves in upon victory.
3. **Phalanx atomicity vs combat**: If phalanx partially dislodged, whole formation stops?
4. **Support cutting granularity**: Does being attacked by strength-1 cut support?
5. **Damage caps**: Can a unit take more than 3 damage in one turn?
6. **Overkill**: Does excess strength translate to extra damage?
