# Phalanx: Rules of Play

## 1. Overview

**Phalanx** is a simultaneous-turn tactical strategy game for two players. Command a formation of ancient soldiers on a hex grid. Coordinate your units, maintain formation, and outmaneuver your opponent.

**Objective**: Destroy all enemy units.

**Players**: 2 (Red vs Purple)

---

## 2. Setup

### The Board

A 10x10 hexagonal grid. Hexes are arranged in offset rows (odd-r layout).

```
    0   1   2   3   4   5   6   7   8   9
  +---+---+---+---+---+---+---+---+---+---+
0 |   |   |   |   |   |   |   |   |   |   |  <- Purple's back row
  +---+---+---+---+---+---+---+---+---+---+
1   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+
2 |   |   |   | P | P | P | P | P |   |   |  <- Purple starting line
  ...
7 |   |   |   | R | R | R | R | R |   |   |  <- Red starting line
  ...
9 |   |   |   |   |   |   |   |   |   |   |  <- Red's back row
```

### Starting Units

Each team begins with **5 units** arranged in a horizontal line:

| Team | Units | Starting Row | Facing |
|------|-------|--------------|--------|
| Red | Y, U, I, O, P | Row 2 | Southwest (toward Purple) |
| Purple | H, J, K, L, M | Row 7 | Northeast (toward Red) |

### Unit Stats

Each unit starts with:
- **Health**: 3
- **Energy**: 3

---

## 3. Turn Structure

Phalanx uses **simultaneous turns**. Both players issue orders secretly, then all orders resolve at once.

### Phase 1: Order Phase

Both players issue orders to their units at the same time. Each unit may receive **one order** (or none).

Orders are:
- **Move**: Move one hex in an allowed direction
- **Rotate**: Turn 60 degrees clockwise or counterclockwise
- **Move + Rotate**: Both in one turn
- **Hold**: No order (unit stays in place)

### Phase 2: Resolution Phase

All orders execute simultaneously:

1. **Conflict Detection**: If two units would occupy the same hex, both orders **balk** (cancel)
2. **Movement**: Valid moves execute
3. **Rotation**: Rotations apply
4. **Combat**: Adjacent enemy units fight
5. **Energy**: Update energy based on actions
6. **Cleanup**: Remove dead units, advance turn counter

### Phase 3: Turn End

Check for victory. If no winner, begin next turn.

---

## 4. Orders

### Move Orders

Move one hex in any of **6 directions**:

```
        NW    NE
          \  /
     W ----+---- E
          /  \
        SW    SE
```

**Restriction**: Based on your unit's facing, only **4 of 6 directions** are allowed (see Movement section).

### Rotation Orders

- **Clockwise**: Turn right 60 degrees
- **Counterclockwise**: Turn left 60 degrees

Rotation can be combined with movement in a single turn.

### Hold

A unit without orders **holds position**. Holding recovers energy (+1), unless the unit is attacked (then no energy change).

### One Order Per Unit

Each unit may receive at most one order per turn. A unit can:
- Move only
- Rotate only
- Move and rotate
- Hold (no order)

---

## 5. Movement

### Facing and Allowed Directions

Units have a **facing direction** (indicated by rotation). A unit can only move in 4 of the 6 hex directions based on its current facing.

| Facing | Allowed Moves |
|--------|---------------|
| E (0 degrees) | E, SE, W, NW |
| SE (60 degrees) | NE, NW, SE, SW |
| SW (120 degrees) | NE, E, W, SW |
| W (180 degrees) | E, SE, W, NW |
| NW (240 degrees) | NE, NW, SE, SW |
| NE (300 degrees) | NE, E, W, SW |

You cannot move directly to your sides. Commit to your facing.

### Movement Diagram

A unit facing NE (rotation 60 degrees) can move to these hexes:

```
        NW    NE     <- Can move here
          \  /
     W ----X---- E
          /  \
        SW    SE     <- Can move here

    X = Unit position
```

The unit **cannot** move E or W (perpendicular to facing).

### Conflicts (Balking)

If two units try to occupy the same hex, **both orders balk**. Neither unit moves.

```
Unit A -> [Hex X] <- Unit B
         CONFLICT!

Result: Both A and B stay in their original positions.
```

### Cascading Conflicts

Balking can cascade. If Unit A balks, a unit trying to move into A's original position also balks.

```
Unit C -> [A's position] -> [Hex X] <- Unit B
                   ^
                   A tried to move here but balked

Result: A balks, then C balks because A didn't move.
```

---

## 6. Combat

### When Combat Occurs

Combat occurs when units attempt to move into each other or when adjacent at turn end. A unit **attacks** in the direction it moves.

### Strength Calculation

Base strength: **1**

**Formation Bonus** (Phalanx):
- +1 per adjacent allied unit facing the same direction AND moving the same direction this turn
- Maximum: +2
- **IMPORTANT**: Both rotation AND movement must match. Units moving different directions get NO formation bonus from each other.

**Support Bonus**:
- +1 per allied unit directly behind, pushing in the same direction
- Maximum: +2

**Combined Attack**:
When multiple allies attack the same enemy hex, their forces ADD together. The first unit ordered to attack that hex is the "lead" - upon victory, only the lead moves in; other attackers hold position.

**Total maximum strength**: 1 (base) + 2 (formation) + 2 (support) = **5** (single unit), or higher with combined attacks

### Flanking Bonus (Attacker)

When attacking from an angle:
- **Flank** (60-120 degrees from front): +1 to attacker
- **Rear** (behind the defender): +2 to attacker

### Dislodge Resolution

A unit is **dislodged** if:
- Enemy strength > Unit strength

Dislodged units are pushed back and take damage.

### Phalanx Rule

Units in a **phalanx** (adjacent, same facing, **same movement direction**) move and fight as one. A phalanx is only dislodged if a **majority** of its members would be dislodged individually.

**Critical**: Formation bonuses only apply when units share both facing AND movement. A unit rotating while its neighbor advances breaks the formation bond for that turn.

---

## 7. Damage

### Health

Units start with **3 health**. At 0 health, the unit dies.

### Damage Sources

| Event | Damage |
|-------|--------|
| Dislodged (any direction) | -1 HP |
| Attacked on flank | -1 HP |
| Attacked from rear | -2 HP |
| Moving non-counterparallel when attacked | -1 HP |
| Zero energy at turn end | -1 HP |

**Counterparallel**: Facing within 60 degrees of opposite direction (head-on). If attacked head-on, no extra damage for moving.

### Stacking Damage

Damage stacks. Being dislodged by a flanking attack = -1 (dislodge) + -1 (flank) = **-2 HP**.

---

## 8. Retreat

### Forced Retreat

A dislodged unit must retreat to an adjacent hex:
- **Must be AWAY from the attacker** (opposite direction from where the attack came)
- Cannot retreat into occupied hexes
- Cannot retreat off the map
- Cannot retreat into standoff hexes (where ties occurred)

If attacked by multiple units, retreat must be away from ALL attackers.

**Retreat selection**: If multiple valid retreat hexes exist, one is chosen randomly.

### No Retreat = Death

If a dislodged unit has no valid retreat hex, it **dies**.

---

## 9. Energy

### Energy Pool

Each unit has **3 energy** (maximum 3, minimum 0).

### Energy Costs

| Action | Energy Change |
|--------|---------------|
| Move forward | -1 |
| Move backward | 0 |
| Hold (not attacked) | +1 |
| Hold (attacked) | 0 |
| Rotate only (not attacked) | +1 (counts as hold) |
| Rotate only (attacked) | 0 |
| Balk (blocked move) | 0 |

### Forward vs Backward

**Forward**: The 2 allowed directions closest to your facing.
**Backward**: The 2 allowed directions closest to your rear.

| Facing | Forward Moves (-1) | Backward Moves (0) |
|--------|-------------------|-------------------|
| E | E, SE | W, NW |
| SE | SE, NE | NW, SW |
| SW | SW, W | NE, E |
| W | W, NW | E, SE |
| NW | NW, NE | SE, SW |
| NE | NE, E | SW, W |

### Exhaustion

**Zero-energy penalty is TBD.** Options under consideration:
- -1 HP at turn end (exhaustion damage)
- Unit can't receive orders until energy recovers
- Reduced combat strength

### Energy Strategy

- 3 consecutive forward moves = 0 energy
- Aggressive pursuit exhausts units
- Defensive holding recovers energy (only if not attacked)
- Alternate advance and rest for sustained offense

---

## 10. Victory

### Elimination

**Win by destroying all enemy units.**

The game ends immediately when one team has no units remaining.

### Draw

If both teams lose their last units simultaneously, the game is a draw.

---

## 11. Diagrams

### Hex Directions

```
          N
          |
    NW ---+--- NE
         / \
        /   \
   W --+     +-- E
        \   /
         \ /
    SW ---+--- SE
          |
          S
```

Note: In Phalanx, the six directions are NE, E, SE, SW, W, NW. There is no pure N or S.

### Facing / Rotation

Units face one of 6 directions. Rotation is measured in degrees:

```
  0 deg = E (East)
 60 deg = SE (Southeast)
120 deg = SW (Southwest)
180 deg = W (West)
240 deg = NW (Northwest)
300 deg = NE (Northeast)
```

A unit's icon points in its facing direction.

### Formation Example (Phalanx)

Three units in phalanx formation, all facing NE:

```
    [A]--[B]--[C]
      \    \    \
       NE   NE   NE   <- All facing NE

Each unit gets +2 formation bonus (2 adjacent allies).
Total strength when attacking together: 3 each.
```

### Flanking Example

Attacker X hits Defender D from the side:

```
        [X]
          \
           v
    [D] -> NE    (D is facing NE)

X attacks from NW (flank position).
X gets +1 flanking bonus.
D takes -1 HP flank damage if hit.
```

### Rear Attack Example

Attacker X hits Defender D from behind:

```
    [D] -> NE    (D is facing NE)
           ^
          /
        [X]

X attacks from SW (rear position).
X gets +2 rear attack bonus.
D takes -2 HP rear damage if hit.
```

### Support Example

Unit B supports Unit A's attack:

```
    [B] -> NE    (B is behind A, pushing same direction)
      |
    [A] -> NE    (A is attacking NE)

A gets +1 support bonus from B.
If B is attacked, the support is nullified.
```

---

## 12. Quick Reference

### Turn Sequence
1. Both players issue orders (secret)
2. Resolve conflicts (balking)
3. Execute moves
4. Apply rotations
5. Resolve combat
6. Update energy
7. Remove dead units
8. Check victory

### Strength Bonuses
| Source | Bonus | Max |
|--------|-------|-----|
| Base | 1 | - |
| Adjacent ally (phalanx) | +1 each | +2 |
| Supporting unit behind | +1 each | +2 |
| Flank attack | +1 | +1 |
| Rear attack | +2 | +2 |

### Damage Table
| Cause | HP Lost |
|-------|---------|
| Dislodged | -1 |
| Flanked | -1 |
| Rear attack | -2 |
| Non-counterparallel attack | -1 |
| Exhaustion (0 energy) | TBD |

### Energy Costs
| Action | Energy |
|--------|--------|
| Forward move | -1 |
| Backward move | 0 |
| Hold/Rotate only (not attacked) | +1 |
| Hold/Rotate only (attacked) | 0 |
| Balk | 0 |

---

## Controls

| Keys | Action |
|------|--------|
| Y, U, I, O, P | Select red units |
| H, J, K, L, M | Select purple units |
| C | Deselect |
| W | Move NW |
| E | Move NE |
| D | Move E |
| F | Move SE |
| S | Move SW |
| A | Move W |
| Q | Rotate counterclockwise |
| R | Rotate clockwise |
| Enter | Submit all orders |
