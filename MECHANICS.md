Unit has 3 health + 3 energy

## Strength 

+1 strength per neighbor when moving in a Phalanx formation (group)

+1 strength if unit "behind" is pushing in same direction
	- This support is nulled if the supporting unit is attacked

Unit is disloged if opposing strength > own strength in its attack

Units in a phalanx move atomically.

A phalanx is only dislodged if a majority of its members would be dislodged. 

## Health 

Being dislodged, regardless of direction = -1 health
Being attacked on a flank = -1 health
Being attacked from behind = -2 health

counterparallel means at a 0deg or 60deg angle against one another. 

Being attacked while moving anything but counterparallel = -1 health

These accumulate, so being dislodged by a flanking attack = -2 health

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

