# Phalanx Balance Analysis

## Mechanics Summary

| Mechanic | Value |
|----------|-------|
| Base strength | 1 |
| Side ally bonus | +1 per ally, max +2 |
| Rear ally bonus | +1 per ally, max +2 |
| **Max formation strength** | **5** |
| Flank attack bonus | +1 |
| Rear attack bonus | +2 |
| Damage on dislodge | 1 HP |
| Starting HP | 3 |
| Combat resolution | Strictly greater wins; ties = standoff |

---

## 1. Formation vs Maneuver Tradeoff

### Formation Incentive
A unit in full formation (2 side + 2 rear allies) has strength 5. An isolated unit has strength 1.

**Strength differential**: 5:1 ratio. This is a massive incentive to stay grouped.

### Maneuver Incentive
Flanking grants +1 (attacker strength becomes base + formation + 1).
Rear attack grants +2.

**Key insight**: A lone flanker (strength 1 + 1 = 2) cannot dislodge even a minimally supported defender (strength 1 + 1 = 2). Ties are standoffs.

### Balance Assessment

| Attacker | Defender | Result |
|----------|----------|--------|
| Lone flanker (2) | Lone defender (1) | Attacker wins |
| Lone flanker (2) | 1-ally defender (2) | Standoff |
| 2-unit flank (2+1=3) | 2-ally defender (3) | Standoff |
| Rear attacker (3) | Lone defender (1) | Attacker wins |
| Rear attacker (3) | 2-ally defender (3) | Standoff |

**Conclusion**: Formation and maneuver are reasonably balanced. Flanking alone rarely breaks formations. You need **numerical advantage at the point of attack** or **combined arms** (multiple attackers from different angles).

**Interesting tension**: To achieve decisive flanks, you must commit multiple units, which weakens your own formation elsewhere.

---

## 2. Blob Strategy Viability

### Maximum Blob Efficiency

In a tight hexagonal blob, center units have 6 neighbors. With caps of +2 side and +2 rear, interior units achieve strength 5.

**Blob strengths**:
- All interior units at max strength (5)
- Edge units still get partial bonuses (2-4)
- Compact shape = short communication lines

**Blob weaknesses**:
- Limited mobility (can only move as fast as slowest unit)
- Cannot project force in multiple directions simultaneously
- Vulnerable to being surrounded and attacked from multiple angles simultaneously

### Counters to Blob

1. **Encirclement**: Force the blob to defend 360 degrees. Edge units get attacked while interior units cannot contribute.

2. **Attrition at edges**: Even if edge attacks result in standoffs, they pin the blob. The blob cannot advance without exposing flanks.

3. **Retreat denial**: If surrounded, dislodged units have nowhere to retreat (except attack origin, which is forbidden). This could mean destruction or capture.

4. **Concentration of force**: Attack one edge with overwhelming local superiority. Even max-strength defenders (5) lose to coordinated multi-unit assault.

### Assessment

The +4 cap is **sufficient** to prevent blob dominance. A blob of 7 units (hexagonal formation) has:
- 1 center unit at strength 5
- 6 edge units at strength 3-4

Against a mobile force of 7 units that concentrates 4 against 2 edge units, the mobile force achieves local superiority.

**Blob is viable but not dominant**. It trades mobility for resilience.

---

## 3. Comeback Potential

### Scenario: 2 units vs 5 units

**Raw strength comparison**:
- 2 adjacent allies: each has strength 2
- 5 in formation: 2-3 units at strength 4-5

**Can position save you?**

| Strategy | Viability |
|----------|-----------|
| Hold terrain chokepoint | Possible. If 5 must attack through narrow passage, they cannot bring full force to bear. |
| Hit-and-run flanking | Unlikely. 2 units cannot flank without exposing themselves. |
| Bait and punish | Possible. Draw 1-2 enemies out of formation, concentrate on isolated unit. |
| Stall for... nothing | No reinforcement mechanic exists. Time does not help. |

**Assessment**: Comeback is **difficult but possible** through:
1. Exploiting terrain chokepoints (map-dependent)
2. Punishing enemy mistakes (overextension)
3. Accepting trades that favor the underdog (2-for-1 exchanges)

The mechanics do not provide inherent comeback mechanisms. The losing side must outplay through superior tactics.

**Risk**: This may lead to "snowball" dynamics where early advantage compounds. First blood matters.

---

## 4. Stalemate Risk

### Equal Formation Standoff

Two 5-unit lines facing each other head-on:
- All attackers at strength 3 (1 base + 2 side allies)
- All defenders at strength 3 (1 base + 2 side allies)
- Result: All attacks are standoffs

**This is a stable equilibrium**. Neither side can break through without taking losses.

### Stalemate Breakers

| Mechanism | How It Works |
|-----------|--------------|
| Flanking attempt | One player sacrifices line integrity to attempt flank. High risk. |
| Rotation to create angle | Rotate units to attack at 60-degree angle. Requires coordination. |
| Feint and exploit | Move as if flanking, bait response, exploit gap. Mind games. |
| Accept attrition | Push forward, accept dislodges, hope to outlast. Favors larger force. |

**Assessment**: Stalemates are **likely between equal forces**. This may be intended (historical phalanx warfare was often about waiting for the enemy to make a mistake).

**Concern**: If both players are risk-averse, games may become slow. Consider adding:
- Objectives (capture points)
- Turn limits with tiebreakers
- Fatigue/morale mechanics

---

## 5. Map Edge Effects

### Edge Disadvantages

1. **Reduced ally potential**: Edge/corner units have fewer adjacencies. Max strength of 3-4 instead of 5.

2. **Retreat restriction**: If attacked toward edge, fewer retreat hexes available. Against edge = no retreat = destruction?

3. **Flanking vulnerability**: Easier to achieve rear position against edge-pinned units.

### Edge Advantages

1. **Refused flank**: Cannot be outflanked on one side. Anchor formation to edge.

2. **Predictable threat axis**: Only need to defend 180 degrees instead of 360.

3. **Corridor control**: In narrow maps, edge-hugging formations control chokepoints.

### Assessment

Edge is **situationally useful** rather than purely bad.

| Situation | Edge Value |
|-----------|------------|
| Open field battle | Negative (reduces options) |
| Defensive holding action | Positive (anchors flank) |
| Controlling narrow passage | Positive (force concentration) |

**Design note**: Map design heavily influences edge value. Ensure maps have both open areas and corridors.

---

## 6. First-Mover Advantage

### Simultaneous Turns

Simultaneous resolution should eliminate classical first-mover advantage. Both players commit orders without seeing opponent's choices.

### Hidden First-Mover Effects

| Effect | Analysis |
|--------|----------|
| Setup asymmetry | If one team sets up closer to objectives or better terrain, that is positional advantage, not first-mover. |
| Initiative on ties | Ties result in standoff. No hidden advantage. |
| Information asymmetry | Both players see full board. No hidden information advantage. |
| Momentum effects | Dislodging enemy grants initiative only if you can exploit the gap before they recover. Simultaneous turns limit this. |

**Assessment**: No significant first-mover advantage detected in the mechanics. Any perceived advantage is positional or skill-based.

---

## 7. Theoretical Simulations

### Simulation 1: 5v5 Line vs Line (Head-On)

```
Turn 0:
Red:  A B C D E  (facing south, strength 3 each)
      -----------
Purple: 1 2 3 4 5  (facing north, strength 3 each)

Turn 1: Both advance
- All collisions are 3v3 = standoffs
- No unit dislodged

Turn 2+: Stalemate until one side attempts maneuver
```

**Result**: Stalemate. Confirms Section 4 analysis.

### Simulation 2: 5v5 Flank Attempt

```
Turn 0:
Red:  A B C D E  (line formation)
Purple: 1 2 3 4 5  (line formation)

Red strategy: A and B swing wide to flank Purple's 4-5

Turn 1:
- C D E hold/advance to pin 1 2 3
- A B move to flank position

Turn 2:
- If successful, A B attack 5's flank
- A (strength 1+1 flank = 2) vs 5 (strength 2-3 depending on 4's position)
- B supports A from side

Analysis:
- Flank requires 2+ turns to execute
- Purple can respond: rotate 4-5 to face flank, or counter-flank C D E
- High risk, moderate reward
```

**Result**: Flanking is possible but telegraphed. Defender has time to respond. Success requires predicting/outmaneuvering opponent.

### Simulation 3: 3v5 Positional Defense

```
Setup: Red has 3 units in narrow passage (2 hexes wide)
Purple has 5 units approaching

Analysis:
- Red can only be attacked by 2 Purple units at a time
- Red front 2 units each have strength 2 (1 side ally each)
- Purple front 2 units each have strength 2-3
- Back 3 Purple units cannot contribute to attack

Result:
- If Red holds the chokepoint, Purple's numerical advantage is negated
- Purple must either:
  a) Accept attrition (trade 1-for-1 in the chokepoint)
  b) Find alternate route (map-dependent)
  c) Wait Red out (no mechanic forces Red to leave)
```

**Result**: Position can equalize numerical disadvantage. Terrain matters.

### Simulation 4: 2v2 Endgame

```
Setup: 2 Red vs 2 Purple, open field

Configurations:
- Both pairs adjacent: 2v2 strength matchup
- One pair splits: Lone units (strength 1) vs pair (strength 2)

Key insight: Staying together is dominant. First pair to break loses.

Endgame dynamics:
- Standoffs likely if both pairs stay together
- Victory requires forcing enemy to split (dislodging one unit)
- HP attrition may decide: whichever pair has more HP can push
```

**Result**: Endgame rewards cohesion. Damaged units (lower HP) become liabilities as they can be dislodged and eliminated faster.

---

## 8. Identified Issues

### Dominant Strategies

| Strategy | Why Dominant | Counter-Play Available? |
|----------|--------------|------------------------|
| Stay grouped | +4 bonus is massive vs isolation | Yes, but requires coordination |
| Never split unless forced | Lone units die | Somewhat, terrain-dependent |
| Concentrate at attack point | Local superiority wins | Requires prediction/reaction |

**Concern**: "Stay together and push" may be too universally correct. Consider mechanics that reward dispersion (e.g., zone control, objective capture).

### Weak Strategies

| Strategy | Why Weak |
|----------|----------|
| Lone wolf flanking | Strength 2 vs formation strength 3+ = standoff or loss |
| Aggressive overextension | Exposed flanks without compensating gain |
| Static defense without objective | No win condition; eventually outmaneuvered |

### Interesting Decision Points

1. **When to commit the flank**: Risk breaking formation for uncertain gain
2. **How to respond to enemy flank**: Counter-rotate or counter-flank?
3. **HP resource management**: Push damaged units to front (sacrifice) or protect them?
4. **Retreat direction choice**: Which adjacent hex to retreat to affects next turn's positioning

### Potential Exploits

1. **Retreat direction gaming**: If retreat is "any adjacent empty hex except attack origin," attacker can position to force unfavorable retreat direction.

2. **Formation lock**: A defensive blob can be nearly impossible to crack without overwhelming force. If map has no objectives, this leads to stalemate.

3. **HP advantage snowball**: The team that lands first dislodge has HP advantage. This compounds over time. No comeback mechanic.

---

## 9. Recommendations

### Confirmed Balanced

- Strength formula with +4 cap
- Flanking/rear bonuses
- Strictly-greater-wins combat resolution
- Dislodge = 1 HP damage

### Consider Adjustments

| Issue | Potential Fix |
|-------|---------------|
| Stalemate risk | Add objectives or turn limits |
| Snowball dynamics | Add morale or momentum mechanics |
| Blob dominance in late game | Add fatigue for stationary units |
| Weak lone flanker | Increase flank bonus to +2 (rear +3)? Risky, may over-incentivize flanking |

### Final Assessment

The proposed mechanics create a **fundamentally sound tactical game** that rewards:
- Formation discipline
- Coordinated maneuver
- Positional awareness
- Reading opponent intentions

**Primary concern**: Risk of stalemates and snowball victories. Mitigation requires meta-level design (objectives, asymmetric maps, scenario rules) rather than mechanical changes.

The core combat math is balanced. Formation strength (+4 max) appropriately exceeds flanking bonus (+2 max), creating the intended dynamic where breaking formations requires commitment and risk.
