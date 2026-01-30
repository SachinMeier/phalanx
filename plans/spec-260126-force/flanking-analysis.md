# Flanking Mechanics Analysis

**Date**: 2026-01-26
**Context**: Force Calculation System spec proposes "flanking negates defender bonuses." This analysis evaluates that choice against alternatives.

---

## Current State

From MECHANICS.md:
- Being attacked on a flank: -1 health
- Being attacked from behind: -2 health
- Damage stacks (flanking dislodge = -2 health)

From Force spec (spec-260126-force):
- Base strength: 1
- Side cohesion: +1 per adjacent ally (same facing)
- Rear support: +1 per rear ally (cap +2)
- Total bonus cap: +4 (max force = 5)
- **Flanking negates bonuses on the attacked side**

From Combat spec (spec-260126-combat):
- Dislodge: -1 health
- Flank attack: -1 health (additional)
- Rear attack: -2 health (additional)
- Damage stacks

---

## The Five Options

### Option 1: Flanking Negates Defender Bonuses Only

**Rule**: Attacker from flank/rear causes defender to lose bonuses from that direction. Attacker gains no bonus for flanking.

**Mechanics**:
- Front attack: defender keeps all bonuses
- Flank attack: defender loses side-cohesion from attacked flank
- Rear attack: defender loses rear support bonus

**Isolated defender (force 1)**:
- Front attack (force 1): tie, standoff
- Flank attack (force 1): tie, standoff (no bonuses to negate)
- Rear attack (force 1): tie, standoff

**Effect on isolated units**: None. Flanking meaningless against lone targets.

**Verdict**: Flanking feels pointless against isolated units. Breaks design goal of "decisive."

---

### Option 2: Flanking Grants Attacker Bonus

**Rule**: Attacker gains +1 (flank) or +2 (rear) strength. Defender keeps all bonuses.

**Mechanics**:
- Front attack: attacker force = base + support
- Flank attack: attacker force = base + support + 1
- Rear attack: attacker force = base + support + 2

**Isolated defender (force 1)**:
- Front attack (force 1): tie, standoff
- Flank attack (force 2): attacker wins, defender dislodged
- Rear attack (force 3): attacker wins, defender dislodged

**Defender with 2 side allies (force 3)**:
- Front attack (force 1): defender wins
- Flank attack (force 2): defender wins (3 > 2)
- Rear attack (force 3): tie, standoff

**Effect**: Flanking always matters. Single flanker can dislodge isolated unit. Formation still protects against single flanker.

**Verdict**: Satisfies "decisive against isolated" while preserving formation value. Simple rule.

---

### Option 3: Flanking Deals Bonus Damage Only

**Rule**: Strength comparison unchanged. Flank/rear attacks deal extra damage whether or not they dislodge.

**Mechanics** (from Combat spec, already defined):
- Flank attack: +1 damage
- Rear attack: +2 damage

**Isolated defender (force 1)**:
- Front attack (force 1): tie, no dislodge, no extra damage
- Flank attack (force 1): tie, no dislodge, +1 damage
- Rear attack (force 1): tie, no dislodge, +2 damage

**Effect**: Flanking deals damage but doesn't break formations. Attrition warfare.

**Verdict**: Creates gradual wearing down. Doesn't feel "decisive" for breakthrough. Better as secondary effect alongside dislodge advantage.

---

### Option 4: Combined (Negate + Attacker Bonus)

**Rule**: Flanking negates defender bonuses AND grants attacker bonus.

**Isolated defender (force 1)**:
- Front attack (force 1): tie
- Flank attack (force 2): attacker wins (nothing to negate)
- Rear attack (force 3): attacker wins

**Defender with 2 side allies (force 3)**:
- Front attack (force 1): defender wins (3 > 1)
- Flank attack (force 2): depends on which allies are on attacked side
  - If both allies on attacked side: defender loses both, force = 1. Attacker force = 2. Attacker wins.
  - If one ally on attacked side: defender force = 2. Attacker force = 2. Tie.
  - If no allies on attacked side: defender force = 3. Attacker force = 2. Defender wins.
- Rear attack (force 3): defender loses rear support (if any), gains flank attack bonus. Complex.

**Effect**: Extremely powerful flanking. Single flanker can break formations if they hit the right side.

**Risk**: Flanking becomes dominant strategy. Frontal engagement is suicide. Game devolves into pure flanking attempts.

**Verdict**: Too powerful. Makes formations fragile. Reduces tactical variety.

---

### Option 5: Flanking Ignores Defender (Auto-Dislodge)

**Rule**: Rear attack = automatic dislodge, no strength comparison.

**Effect**: Historical accuracy (phalanx collapses when hit from behind). Extremely harsh.

**Risk**: Single unit behind enemy lines wins the game. No counterplay.

**Verdict**: Too binary. Removes tactical depth from flanking execution.

---

## Scenario Analysis

### Scenario A: 1v1 Isolated

| Attack Type | Option 1 | Option 2 | Option 3 | Option 4 |
|------------|----------|----------|----------|----------|
| Front | Tie | Tie | Tie | Tie |
| Flank | Tie | **Dislodge** | Tie (+1 dmg) | **Dislodge** |
| Rear | Tie | **Dislodge** | Tie (+2 dmg) | **Dislodge** |

**Best**: Option 2 or 4. Flanking should matter against isolated units.

---

### Scenario B: 1 attacker vs defender with 2 side allies (force 3)

**Setup**: Defender has 2 adjacent allies, all facing same direction. No rear support.

| Attack Type | Option 1 | Option 2 | Option 3 | Option 4 |
|------------|----------|----------|----------|----------|
| Front | Def wins | Def wins | Def wins | Def wins |
| Flank (hit 1 ally side) | Force 2 vs 1, Tie | Force 3 vs 2, Def | Tie (+1 dmg) | Force 2 vs 2, Tie |
| Flank (hit 0 ally side) | Force 3 vs 1, Def | Force 3 vs 2, Def | Tie (+1 dmg) | Force 3 vs 2, Def |
| Rear | Force 3 vs 1, Def | Force 3 vs 3, Tie | Tie (+2 dmg) | Force 3 vs 3, Tie |

**Observation**: Single flanker cannot beat 3-strength formation in any option except Option 4 hitting the right side. This is correct behavior.

---

### Scenario C: Coordinated Pincer (2 attackers from opposite flanks)

**Setup**: Defender (force 1-3 depending on allies). Two attackers hit from opposite directions.

**Question**: Do multiple attackers combine strength, or is each resolved separately?

**Resolution options**:

1. **Separate resolution**: Each attack resolved independently against defender's (possibly reduced) force.
   - Attacker A vs Defender, then Attacker B vs Defender
   - If A dislodges, B's attack hits empty hex
   - If A fails, B still attacks

2. **Combined resolution**: Multiple attackers targeting same defender add forces.
   - A force + B force vs Defender force
   - Much more powerful coordinated attacks

**Recommendation**: Separate resolution. Each attacker must independently beat the defender. This:
- Prevents trivial mass-attack wins
- Rewards positioning over numbers
- Creates tactical decision: concentrate force in one direction vs spread attacks

**Pincer with Option 2**:
- Attacker A (force 2 from flank) vs Defender (force 3): Defender wins
- Attacker B (force 2 from opposite flank) vs Defender: Defender wins
- Result: Defender holds against pincer but takes 2 damage (flank attacks)

**Pincer with Option 2 + 1 rear attacker**:
- Attacker A (force 3 from rear) vs Defender (force 3): Tie
- Result: Still need more force or weaker defender

---

### Scenario D: How many flankers to dislodge 5-strength formation?

**Formation**: 1 unit with +4 bonus (2 side allies + 2 rear allies, all same facing)

**Option 2 (attacker bonus only)**:

Each flanker has force 2 (base 1 + flank 1). Resolved separately.
- Force 2 vs Force 5: Defender wins
- Need attacker force > 5

Single attacker cannot reach force 6. Need:
- Rear attack (force 3) + 3 supporting allies moving same direction
- Force = 1 + 2 (rear) + 2 (support cap) = 5. Still ties.

**Cannot dislodge 5-strength formation with single attacker in any scenario.**

This is correct! 5-strength formation should require:
- Multiple coordinated attacks (if combined resolution)
- OR attacking the supporting units first to reduce formation

**Tactic**: Don't attack the formation directly. Attack the flanks of the formation's supporting units. Break the edges, then the center collapses.

---

## Key Questions Answered

### 1. How many flankers needed to dislodge 5-strength formation?

**With separate resolution**: Impossible with pure flanking. Must attack support units first.

**With combined resolution**: 3 flankers (force 6 total) vs force 5 would win.

**Recommendation**: Use separate resolution. Formations should be broken by attacking their edges, not by mass assault on the center.

### 2. Can a single flanker ever beat a formation?

**Option 2**: No. Single flanker (force 2-3) cannot beat formation (force 3+).

**Option 4**: Yes, if hitting the side where all the defender's allies are positioned. Single flanker could beat a 3-strength defender by negating 2 allies and adding 1 bonus (force 2 vs force 1).

**Recommendation**: Single flanker should NOT beat formations. Flanking advantage is for isolated units and edge-of-formation units.

### 3. Is rear attack significantly better than flank?

**Option 2**:
- Flank attack: +1 force, +1 damage
- Rear attack: +2 force, +2 damage

Rear is strictly better: 2x the dislodge advantage, 2x the damage.

**Is this too strong?** No. Getting behind an enemy formation is harder than getting beside it. The reward should match the difficulty.

### 4. How does facing/rotation create tactical depth?

**Rotation determines**:
1. Which hexes are front/flank/rear
2. Which allies count for formation bonuses (same facing required)
3. Which movement directions are available

**Tactical implications**:
- Facing toward enemy = strong attack, vulnerable flanks
- Facing perpendicular = can retreat easily, weak attack
- Rotation costs a turn = committing to a facing is strategic

**Flanking creates value for**:
- Maneuvering around enemy formations
- Holding units in reserve for flank attacks
- Protecting your own flanks with reserves
- Forcing enemy to split attention

---

## Recommendation

### Primary Mechanism: Option 2 (Attacker Bonus)

**Rule**: Flanking grants attacker +1 strength, rear grants +2 strength. Defender keeps all bonuses.

**Why**:
1. **Isolated units vulnerable**: Single flanker beats lone defender
2. **Formations still strong**: Single flanker cannot beat 3+ strength formation
3. **Simple rule**: No direction-dependent bonus negation
4. **Stacks with damage**: Flank = +1 force AND +1 damage. Rear = +2 force AND +2 damage.
5. **Encourages combined arms**: Frontal pressure + flanking = victory

### Secondary Mechanism: Damage (Already Specified)

Keep the existing damage rules from MECHANICS.md:
- Flank attack: +1 damage
- Rear attack: +2 damage
- Stacks with dislodge damage

This creates two flanking benefits:
1. Easier to dislodge (force bonus)
2. More damage dealt (damage bonus)

### Discard Option 1 (Negate Only)

The Force spec currently recommends "flanking negates bonuses." This should be reconsidered because:

1. **Useless against isolated units**: No bonuses to negate
2. **Complex geometry**: Must track which direction attack comes from, which allies are on that side
3. **Unpredictable**: Player must mentally compute which bonuses get negated
4. **Weaker effect**: Negating 1-2 bonuses is less impactful than granting 1-2 attack bonus

### Resolution: Separate (Not Combined)

Multiple attackers on same defender resolve separately. Each must independently beat defender's strength.

**Why**:
- Prevents death-by-numbers
- Rewards flanking position over flanking quantity
- Creates tactical depth in attacking formation edges

---

## Summary Table

| Aspect | Recommendation |
|--------|----------------|
| Flanking mechanism | Attacker bonus (+1 flank, +2 rear) |
| Defender bonuses | Unchanged (keeps all bonuses) |
| Multiple attackers | Separate resolution |
| Damage | Keep existing (+1 flank, +2 rear) |
| Single flanker vs isolated | Dislodges (force 2 vs 1) |
| Single flanker vs formation | Fails (force 2 vs 3+) |
| Break 5-str formation | Attack edges first, then center |

---

## Implementation Note

The Force spec should be updated to replace:

**Current** (Section 2.F):
> Flanking negates bonuses on the attacked side. If attacked from flank, defender's side-cohesion allies on that flank don't count.

**Proposed**:
> Flanking grants attacker +1 strength; rear attack grants +2 strength. Defender retains all formation bonuses regardless of attack direction.

This simplifies implementation (no direction-relative bonus tracking) while achieving the design goal of decisive flanking.
