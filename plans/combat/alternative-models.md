# Combat Model: Hybrid with Cascading Retreats

## Overview

Phalanx uses a **hybrid model** combining Diplomacy-style dislodge with angle-based HP damage and cascading retreats.

**Core principles:**
- **Dislodge** = positional consequence (you lose ground)
- **Angle damage** = HP consequence (you lose health)
- **Cascade** = chain retreats (purely positional, no HP cost)

---

## Core Rules

### 1. Dislodge

Attacker strength > defender strength → defender retreats.

```
Attacker wins:  Defender dislodged, retreats in same direction as attack
Equal strength: Both balk (no movement)
Attacker loses: Attacker balks
```

### 2. Damage (Angle-Based Only)

HP damage comes from **dislodge + attack angle**. Damage stacks.

| Source | HP Damage |
|--------|-----------|
| Dislodge | 1 |
| Front angle bonus | +0 |
| Flank angle bonus | +1 |
| Rear angle bonus | +2 |

**Total on dislodge**: Frontal = 1 HP, Flank = 2 HP, Rear = 3 HP.

**Damage only applies when dislodged.** Failed attacks deal no damage.

### 3. Cascade

When a dislodged unit retreats into an ally, the ally is also pushed back.

```
Cascade rules:
- Retreat into ally → ally retreats too
- Chain continues until empty hex or edge
- Cascade costs NO HP
- Edge = death
```

### 4. Edge Death

Pushed off map edge = unit dies. This is the primary stake of cascading.

---

## Damage Table

| Attack Angle | Dislodge? | Total HP Damage | Cascade HP |
|--------------|-----------|-----------------|------------|
| Front, win | Yes | 1 (dislodge only) | 0 |
| Front, lose | No | 0 | — |
| Flank, win | Yes | 2 (1 + 1) | 0 |
| Flank, lose | No | 0 | — |
| Rear, win | Yes | 3 (1 + 2) | 0 |
| Rear, lose | No | 0 | — |

**Key insight:** Damage = dislodge (1) + angle bonus. Failed attacks deal no damage. Cascade never costs HP.

---

## Resolution Order

```
1. COLLECT ORDERS
   - Explicit moves/holds from players
   - Implicit holds for units without orders

2. CALCULATE STRENGTHS
   For each unit with enemy in attack direction:
   - Attacker strength = base + phalanx bonus + depth bonus
   - Defender strength = base + phalanx bonus + depth bonus

3. DETERMINE ATTACK ANGLES
   For each attack:
   - Compare attacker position to defender facing
   - Classify: FRONT / FLANK / REAR

4. RESOLVE DISLODGES
   If attacker > defender: defender dislodged
   If attacker == defender: both balk
   If attacker < defender: attacker balks

5. APPLY STACKING DAMAGE
   - Dislodge: 1 HP
   - Front angle bonus: +0 HP
   - Flank angle bonus: +1 HP
   - Rear angle bonus: +2 HP
   (Applied regardless of dislodge result)

6. RESOLVE RETREATS WITH CASCADE
   For each dislodged unit:
   a. Retreat direction = same as attack
   b. Check retreat hex:
      - Empty → move there
      - Ally → ally marked for cascade
      - Enemy → stay in place
      - Edge → DEATH
   c. Process cascade queue (same rules)
   d. Cascade costs NO HP

7. CLEANUP
   - Remove units at 0 HP
```

---

## Example Scenarios

### Frontal assault, attacker wins
```
Attacker str 4 → Defender str 3 (front)
Result: Defender dislodged, retreats. 1 HP damage (dislodge only).
```
Frontal pressure gains ground with minimal damage.

### Flank attack, attacker wins
```
Attacker str 3 → Defender str 2 (flank)
Result: Defender dislodged, 2 HP damage (1 dislodge + 1 flank).
```
Flanking gains ground AND deals extra damage.

### Flank attack, attacker loses
```
Attacker str 2 → Defender str 3 (flank)
Result: No dislodge, no damage. Attacker balks.
```
Failed attacks deal no damage—must win to hurt.

### Cascade (no damage)
```
Attacker → A (dislodged, flank) → B (ally) → C (ally) → [empty]
Result:
- A: -1 HP (flank damage), pushed back
- B: 0 HP, pushed back
- C: 0 HP, pushed back
```
Cascade spreads position loss, not HP loss.

### Cascade into edge
```
Attacker → A (dislodged) → B → [EDGE]
Result:
- A: pushed back to B's position
- B: pushed off edge, DIES
```
Edge death is the cascade stake.

### Retreat blocked by enemy
```
Attacker → A (dislodged) → [Enemy]
Result: A stays in place, no retreat occurs.
```
Attacker won the strength battle but couldn't capitalize.

---

## Design Rationale

### Why separate dislodge from damage?

| Concern | Mechanism |
|---------|-----------|
| Position | Dislodge + cascade |
| Health | Angle damage only |

This creates meaningful choice: frontal assault for territory, flanking for kills.

### Why cascade doesn't cost HP?

- **Comeback potential:** Pushed army can regroup and counter-push
- **One damage source:** Simpler mental model
- **Edge death suffices:** Cascade still has stakes near map edge

### Why chip damage on failed flanks?

Rewards aggressive maneuvering even when you can't win the strength battle. Creates attrition pressure from positioning alone.

---

## Open Questions

### Should failed flanks deal chip damage?

Current: Yes. Flank attack deals 1 HP even without dislodge.

| Option | Pro | Con |
|--------|-----|-----|
| Chip damage | Rewards flanking attempts | "I defended but lost HP" feels unfair |
| No chip damage | Cleaner | Flanking only matters if you win |

**Current decision:** Keep chip damage.

### What if retreat blocked by enemy on all sides?

Options:
1. Stay in place, no extra damage
2. Stay in place, take "trapped" damage
3. Die

**Current decision:** Stay in place, no extra damage.

### Can cascade kill multiple units at edge?

```
Attacker → A → B → C → [EDGE]
```

Options:
1. Only C dies (first to hit edge)
2. All die
3. C dies, cascade stops, B takes C's position

**Current decision:** Only C dies. Cascade stops at death.

---

## Why This Model Works

| Goal | How It Delivers |
|------|-----------------|
| Flanking decisive | Only flanks deal damage |
| Formation matters | Strength bonus + angle protection |
| HP meaningful | Depleted by angle attacks, not attrition |
| Comeback potential | Cascade pushes back without killing |
| Stakes | Edge death, damage accumulates |
| Simple enough | One damage source (angle) |

---

## Alternative Models (Reference)

Short summaries of rejected alternatives.

### Pure Diplomacy (No HP)

**OFF THE TABLE** - HP required for game feel.

- Dislodge on strength > defender
- No damage, no HP
- Retreat or disband

*Why rejected:* Too punishing, low comeback potential.

### Pure HP/Damage

- Adjacent enemies deal damage each turn
- Damage scales with angle
- No forced retreat

*Why rejected:* No positional consequences, games become attrition wars.

### Differential Damage

- Damage = strength difference
- No binary dislodge

*Why rejected:* No movement from combat, games become static.

### Retreat-or-Die

- Dislodge → must retreat to valid hex
- No valid hex = death

*Why rejected:* Too harsh, games decided in first turns.

### Cascade with HP Cost

- Each unit in cascade takes damage

*Why rejected:* Creates second damage source, reduces comeback potential.
