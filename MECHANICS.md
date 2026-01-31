Unit has 3 health + 3 energy

## Strength 

+1 strength per neighbor when moving in a Phalanx formation (group)

+1 strength if unit "behind" is pushing in same direction
	- This support is nulled if the supporting unit is attacked

Unit is disloged if opposing strength > own strength in its attack

Units in a phalanx move atomically.

A phalanx is only dislodged if a majority of its members would be dislodged. 

## Health

**Damage stacks from two sources:**

| Source | HP Lost |
|--------|---------|
| Dislodged | 1 |
| Flank attack angle | +1 |
| Rear attack angle | +2 |
| Frontal attack angle | +0 (shields block) |

**Total damage on dislodge:**
- Frontal dislodge: 1 HP (dislodge only, shields block angle damage)
- Flank dislodge: 1 + 1 = 2 HP
- Rear dislodge: 1 + 2 = 3 HP

**Key points:**
- Damage only applies to dislodged units
- Dislodge always costs 1 HP regardless of angle
- Flanking adds EXTRA damage on top of dislodge cost
- Flanking affects damage only, NOT strength

Open Questions:

A 60deg attack is balked if countered. This creates a reason to have gaps in your line. Not safe to try adjacent flanking.

How does non-linear support work? Separate attacks? 
- Non-linear support results in Force applied to a tile.

Rotation and Attacks?
- The attack hits before the rotation, but the rotation is applied after the attack

## Energy

Units run out of energy

Moving Forward = -1 E
Moving backward = 0 E

Holding = + 1 E

Having 0 E = -1 Health


### MoveEngine

