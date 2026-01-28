# Alternative Combat Models Comparison

## Current System Baseline

Phalanx currently uses a **hybrid Diplomacy + HP** model:
- Diplomacy-style balking on movement conflicts
- Dislodge based on strength comparison (opponent > self)
- HP damage from: dislodge (-1), flank (-1), rear (-2), non-counterparallel movement when attacked (-1)
- Stacking damage (dislodged + flanked = -2)

---

## Model 1: Pure Diplomacy (No HP)

Units have strength only. Dislodge on strictly greater strength. No damage accumulation.

### Mechanics
- Base strength 1, +1 per phalanx neighbor, +1 per supporting unit behind
- Attacker > Defender: dislodge
- Equal strength: both balk
- Dislodged unit must retreat to valid hex or disband

### Flanking Feel
**Decisive but binary.** Flanking breaks formation bonuses, reducing defender strength. A successful flank = immediate displacement. No gradual wear-down. Either you dislodge or you don't.

### Formation Interaction
Critical. Phalanx bonuses determine everything. Maintaining formation = surviving. Single isolated units are trivially dislodged.

### Game Length
**Short.** Once one side achieves positional advantage, cascading dislodges accelerate. No HP buffer to absorb bad positioning.

### Comeback Potential
**Low.** Positional disadvantage compounds rapidly. No way to "trade HP for time."

### Complexity
**2/5.** Simple: compare numbers, higher wins.

### Best For
Chess-like positioning games. Every move matters. Rewards strategic planning over tactical slugfests.

---

## Model 2: Pure HP/Damage

Units have hit points (e.g., 3 HP). Attacks deal damage. No forced retreat.

### Mechanics
- Adjacent enemies deal damage each turn
- Damage scales with attack angle (front: 1, flank: 2, rear: 3)
- Death at 0 HP
- No movement restriction from combat

### Flanking Feel
**Incremental.** Flanking = better damage rate. But enemy survives multiple turns unless surrounded. Decisive flank still takes 2+ turns to kill.

### Formation Interaction
Weak. Formation reduces incoming damage but doesn't prevent it. Phalanx becomes "damage reduction" rather than "impenetrable wall."

### Game Length
**Long.** At 3 HP per unit with 1-3 damage per attack, units survive multiple exchanges. Games become attrition wars.

### Comeback Potential
**Medium-High.** Damaged units still fight at full effectiveness. Can trade positioning for time. Late-game rallies possible.

### Complexity
**2/5.** Track HP per unit. Simple damage calculation.

### Best For
RPG-style tactical games where unit investment matters. Players attached to individual units.

---

## Model 3: Hybrid Dislodge + Damage

Diplomacy-style dislodge PLUS angle-based damage. This is essentially the **current Phalanx design**.

### Mechanics
- Dislodge on strength > defender
- Damage applied based on attack angle regardless of dislodge result
- Retreat AND take damage (compounding penalty)

### Flanking Feel
**Decisive AND punishing.** Successful flank: enemy retreats AND loses HP. Even failed flank attempts deal chip damage if you're attacking from angle.

### Formation Interaction
Very strong. Formation both prevents dislodge AND reduces incoming damage angle. Breaking formation = double penalty.

### Game Length
**Medium.** Dislodge accelerates positioning collapse, but HP buffer prevents instant annihilation.

### Comeback Potential
**Medium.** HP creates buffer, but dislodge cascades still devastating.

### Complexity
**4/5.** Must track: HP, strength calculation, dislodge resolution, damage calculation, angle determination.

### Best For
Games wanting tactical depth with meaningful flanking. Rewards both positioning AND attrition play.

### Issues for Phalanx
- Two overlapping damage sources (dislodge vs angle) add complexity
- "Maximally simple" ethos violated
- Harder to teach new players

---

## Model 4: Differential Damage

Winner deals damage equal to strength difference. No binary dislodge.

### Mechanics
- Compare strength: winner deals (own strength - enemy strength) damage
- E.g., str 3 vs str 2 = 1 damage to loser
- Equal strength = no damage to either
- Flanking reduces defender strength (same as other models)

### Flanking Feel
**Incremental but scalable.** Small flank advantage = small damage. Overwhelming flank = massive damage. Linear relationship between advantage and outcome.

### Formation Interaction
Moderate. Formation increases strength, reducing incoming differential. But no "wall" effect - even strong formations take some damage from stronger attackers.

### Game Length
**Medium-Long.** Without dislodge, units hold position until killed. But differential can spike with overwhelming advantage.

### Comeback Potential
**High.** Equal-strength combat is stalemate. Defenders can hold indefinitely if evenly matched. Rewards concentration of force.

### Complexity
**2/5.** Simple subtraction.

### Best For
Games emphasizing force concentration. Rewards massing units rather than spreading thin.

### Issues for Phalanx
- No positional movement from combat (units never forced to retreat)
- Games become static without retreat mechanic
- Might need separate "push" mechanic

---

## Model 5: Zone of Control

Units project threat to adjacent hexes. Moving through ZoC triggers attack of opportunity.

### Mechanics
- Each unit threatens 3-4 adjacent hexes (based on facing)
- Moving INTO threatened hex = take damage
- Moving OUT of threatened hex = take damage (attack of opportunity)
- Holding in ZoC = no damage

### Flanking Feel
**Positional pressure.** Flanking creates escape routes or blocks them. Moving through flanked positions is deadly. But static units unaffected.

### Formation Interaction
Complex. Overlapping ZoC creates kill zones. Gaps in formation = safe passages for enemy.

### Game Length
**Variable.** Highly dependent on whether players engage or maneuver around ZoC.

### Comeback Potential
**Medium.** Positioning matters more than unit count. Small force with good positioning can hold.

### Complexity
**4/5.** Must track: which hexes are threatened, by whom, movement paths through ZoC.

### Best For
Games about controlling space rather than destroying units. Siege-like scenarios.

### Issues for Phalanx
- **Conflicts with simultaneous resolution.** ZoC assumes sequential movement.
- Phalanx's simultaneous turn structure makes "attack of opportunity" timing ambiguous
- Would require fundamental architecture change

---

## Model 6: Retreat-or-Die (Harsh)

Dislodged units MUST retreat to valid hex. No valid hex = instant death.

### Mechanics
- Dislodge on strength > defender (like Diplomacy)
- Dislodged unit must retreat to unoccupied hex not threatened by enemy
- No valid retreat hex = unit destroyed
- Retreat direction: opposite of attack direction

### Flanking Feel
**Extremely decisive.** Successful flank often = instant kill if retreat blocked. Corner traps lethal.

### Formation Interaction
Critical for survival. Formation provides strength AND retreat paths. Isolated units trivially killed.

### Game Length
**Very short.** Once encirclement begins, units die rapidly. Snowball effect extreme.

### Comeback Potential
**Very low.** First blood often decides game. Losing one unit creates gap, gap enables encirclement, encirclement = death spiral.

### Complexity
**3/5.** Must calculate: strength, valid retreat hexes, blocked paths.

### Best For
High-stakes tactical puzzles. Every unit precious. Positioning is everything.

### Issues for Phalanx
- May be too punishing for casual play
- Games could be decided in first 2-3 turns
- Discourages aggression (defender advantage too strong)

---

## Model 7: Retreat Cascade

Retreating can push other units. Chain reaction retreats possible.

### Mechanics
- Dislodge forces retreat
- If retreat hex occupied by ally, that ally also retreats (cascade)
- Cascade continues until: empty hex found OR edge reached (death)
- Retreating through enemy = damage

### Flanking Feel
**Chaotic but forgiving.** Successful flank pushes whole line back rather than killing. Creates space rather than casualties.

### Formation Interaction
Interesting dynamics. Tight formation = cascade risk (one push affects all). Loose formation = less cascade but weaker defense.

### Game Length
**Medium.** Cascades create dramatic swings but rarely kill immediately. Territory changes hands.

### Comeback Potential
**High.** Being pushed back isn't death. Can rally and counter-push.

### Complexity
**3/5.** Must calculate: cascade paths, blocking terrain, eventual landing positions.

### Best For
Games about territorial control rather than unit destruction. Push-of-war feel.

### Issues for Phalanx
- Reduces stakes of combat (retreat isn't punishing enough?)
- May create perpetual stalemates (push, counter-push, repeat)
- Cascade calculation complex in UI

---

## Comparison Matrix

| Model | Flanking Decisiveness | Game Length | Comeback Potential | Complexity | Fits "Simple" Ethos? |
|-------|----------------------|-------------|-------------------|------------|---------------------|
| 1. Pure Diplomacy | High (binary) | Short | Low | 2/5 | Yes |
| 2. Pure HP | Low (incremental) | Long | High | 2/5 | Yes |
| 3. Hybrid (current) | High + punishing | Medium | Medium | 4/5 | No |
| 4. Differential | Medium (linear) | Medium-Long | High | 2/5 | Yes |
| 5. ZoC | Variable | Variable | Medium | 4/5 | No (conflicts w/ simultaneous) |
| 6. Retreat-or-Die | Extreme | Very Short | Very Low | 3/5 | Borderline |
| 7. Cascade | Low (displacement) | Medium | High | 3/5 | Borderline |

---

## Recommendation

### Primary: Model 1 (Pure Diplomacy) + Minimal HP

**Why:**
1. **Maximum simplicity.** One strength comparison decides outcome. No stacking damage sources.
2. **Flanking is decisive.** Break formation = lose strength = get dislodged. Binary and clear.
3. **Formation matters maximally.** Phalanx bonus isn't damage reduction - it's survival.
4. **Fast games.** Positioning mistakes punished immediately.

**Modification for Phalanx:**
- Keep 3 HP as "lives" rather than gradual health
- Dislodge = -1 HP (but NOT angle-based damage)
- 0 HP = death
- HP creates buffer against single mistake but doesn't create attrition wars

**This gives:**
- Simple: One comparison (strength > strength)
- Decisive flanking: Flank breaks formation, dislodge follows
- Some forgiveness: 3 HP means 3 dislodges before death
- Fast games: Positional advantage accelerates, but HP prevents turn-1 elimination

### Secondary: Model 4 (Differential Damage) + Forced Retreat

If pure Diplomacy feels too binary, differential provides middle ground:
- Strength difference = damage dealt
- Add: losing differential by 2+ = forced retreat
- Flanking reduces defender strength, increasing differential, increasing damage AND triggering retreat

This preserves:
- Simple calculation (subtraction)
- Decisive flanking (big differential = big damage + retreat)
- Gradual wear-down option (small advantages accumulate)

### Avoid

- **Model 3 (current hybrid):** Too complex. Two damage sources, stacking rules, angle calculations.
- **Model 5 (ZoC):** Incompatible with simultaneous resolution.
- **Model 7 (Cascade):** Reduces flanking stakes, creates stalemates.

---

## Implementation Path for Recommended Model

### Pure Diplomacy + HP Lives

```
Combat Resolution:
1. For each unit with enemy in attack direction:
   - Calculate attacker strength (base + phalanx + support)
   - Calculate defender strength (base + phalanx + support)

2. If attacker > defender:
   - Defender marked for dislodge
   - Defender HP -= 1

3. If attacker == defender:
   - Both balk (no movement, no damage)

4. Dislodged units:
   - Must retreat to valid hex (away from attacker)
   - No valid hex = another -1 HP

5. HP == 0:
   - Unit removed
```

**Complexity: 2/5**
- One comparison
- One damage source
- Clear retreat rules

This delivers decisive flanking within the "maximally simple" constraint.
