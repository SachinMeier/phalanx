# Combat Resolution Edge Cases

Simultaneous-turn hex combat with strength-based resolution. This document explores every edge case with diagrams, rule interpretations, and recommendations.

**Base Rules Reference**:
- Strength = 1 (base) + support bonuses
- Strictly greater strength wins; ties = standoff
- Dislodged = opposing strength > own strength
- Damage: dislodge (-1 HP), flank (-1 HP), rear (-2 HP), non-counterparallel move (-1 HP)
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

**Mutual bounce with damage**. Both units hold position, both take -1 HP (collision damage).

**Rationale**:
- Creates risk in head-on attacks
- Rewards flanking over direct confrontation
- Simple to explain: "head-on collision hurts both"

### Balance Implications

- Discourages mutual charge tactics
- Favors defensive positioning
- Makes strength advantage more valuable (asymmetric attacks break ties)

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

**Loser takes dislodge damage; winner takes damage only if attack was counterparallel (0° or 60°)**.

```
Case A: Counterparallel (head-on or 60°)
  A wins, moves to B's hex
  A takes -1 HP (counterparallel hit)
  B dislodged, takes -1 HP, must retreat

Case B: Non-counterparallel (flank/rear)
  A wins, moves to B's hex
  A takes 0 HP (B's attack never lands - wrong facing)
  B dislodged, takes -1 HP + angle bonus
```

### Balance Implications

- Head-on attacks are costly even when winning
- Flanking supremacy: attack without retaliation
- Creates tactical depth: "Do I want a costly frontal victory or wait for flank?"

---

## 3. Support Cutting

**Scenario**: A attacks B. C supports A's attack. D attacks C (the supporter).

```
Before:                  Orders:
    D                    A: attack B
    ↓                    C: support A's attack
    C → A → B            D: attack C
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **Support cut unconditionally** | A loses C's support regardless of D's success | Being attacked = distracted |
| **Support cut only if D succeeds** | Support remains if D's attack fails | Failed attacks don't disrupt |
| **Support cut if D matches strength** | Support cut on tie or loss | Engaged units can't support |
| **Support never cut mid-resolution** | All supports calculated before attacks resolve | Simultaneity means no interruption |

### Recommended Rule

**Support cut unconditionally if supporter is targeted by any attack**.

Per MECHANICS.md: "support is nulled if the supporting unit is attacked."

No success requirement. The act of being attacked breaks concentration.

```
Resolution:
1. D attacks C → C's support to A is nullified
2. A attacks B with strength 1 (lost C's +1)
3. If B has strength >= 1, standoff
4. D vs C resolves separately
```

### Balance Implications

- Weak units can neutralize support by threatening supporters
- Creates "support cutting" as a tactical role
- Defenders must protect their support lines
- Encourages combined arms: "pin their supports, then attack"

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
1. A dislodges B
2. B must retreat; X is only valid hex
3. B retreats to X
4. C's move to X fails (occupied by retreating B)
5. C holds position

**Exception**: If B has no valid retreat (all hexes blocked), B is destroyed.

### Balance Implications

- Retreat cutting becomes viable tactic
- Surrounding enemies is powerful (forces death instead of retreat)
- Creates "anvil" strategy: attack from one side, block retreat with another

---

## 5. Multiple Attackers on One Defender

**Scenario**: A and B both attack C from different directions.

```
Before:          Strengths:
  A → C ← B      A: 2 (flanking)
                 B: 2 (frontal)
                 C: 1 (defending)
```

### Rule Interpretations

| Interpretation | Outcome | Rationale |
|----------------|---------|-----------|
| **Strengths combine** | A+B = 4 vs C's 1, C destroyed | Coordinated attack |
| **Separate attacks** | Each attack resolves independently | No coordination bonus |
| **Highest wins, others support** | Strongest attacker gets the hex, others wasted | Competition for spoils |
| **Force applied to tile** | Per MECHANICS.md: "Non-linear support results in Force" | Combined pressure |

### Recommended Rule

**Forces combine against defender. Each attacker contributes damage separately.**

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
5. Who gets the hex? Highest strength attacker, or...
```

**Hex occupation tiebreaker**: If multiple attackers have equal strength, the hex is contested (neither occupies). Both attackers hold original positions.

### Balance Implications

- Encourages coordinated attacks
- Flanking + frontal = maximum damage
- Creates decision: "Do we split attacks or concentrate?"
- Risk of wasted movement if ally takes the hex

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

**Retreat requires unoccupied hex. Retreating into occupied hex = death.**

Exceptions:
- Friendly-occupied hex with that unit also retreating in same direction = allowed (cascade retreat)
- Enemy-occupied hex = always invalid

```
Resolution:
1. A dislodges B
2. B's retreat options checked
3. C's hex is occupied → invalid retreat
4. If no other retreat hex exists, B is destroyed
5. If alternate retreat exists, B must use it
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
| 1. Symmetric mutual attack | Both hold, both take -1 HP |
| 2. Asymmetric mutual attack | Winner advances; both take damage only if counterparallel |
| 3. Support cutting | Cut unconditionally if supporter targeted |
| 4. Chain dislodge | Retreating unit has priority; attacker bounces |
| 5. Multiple attackers | Forces combine; highest strength occupies hex |
| 6. Retreat cascade | Cannot retreat to occupied hex; death if blocked |
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

## Open Questions for Design Decision

1. **Retreat direction**: Must retreat directly away from attacker? Any non-blocked hex?
2. **Multiple attackers on same hex**: Who gets the hex if both win?
3. **Phalanx atomicity vs combat**: If phalanx partially dislodged, whole formation stops?
4. **Support cutting granularity**: Does being attacked by strength-1 cut support?
5. **Damage caps**: Can a unit take more than 3 damage in one turn?
6. **Overkill**: Does excess strength translate to extra damage?
