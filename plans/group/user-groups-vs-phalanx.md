# Groups vs Phalanx Formations

**Purpose**: Clarify the distinction between groups (organizational, pre-battle) and phalanxes (tactical, during battle).

---

## Two Separate Concepts

| Concept | When Created | Persistence | Scope | Order Behavior |
|---------|--------------|-------------|-------|----------------|
| **Group** | Pre-game planning stage | Fixed for entire battle | Organizational | Non-atomic (each unit independent) |
| **Phalanx** | During battle | Until broken/disbanded | Within single group only | Atomic (all-or-nothing) |

---

## Groups

An organizational structure created before battle. The player assigns units to divisions (left flank, center, reserves, etc.) during the planning stage.

**Created**: Planning stage only. Once battle begins, groups are locked.

**Purpose**: Command convenience. Order a group → all members receive the order.

**No adjacency required.** A group can contain scattered units across the map.

**No mechanical effect.** Groups do not confer bonuses. They're purely organizational.

**Non-atomic execution.** When a group receives an order, each unit executes independently. If one unit balks, others still move.

---

## Phalanxes

A tactical formation declared during battle. Units lock shields and fight as one.

**Created**: During battle via explicit "Form Phalanx" command.

**Scope**: Can only form within a single group. Cross-group phalanxes are not allowed.

**Requirements**:
- Units must be in the same group
- Units must be adjacent (hex neighbors)
- Units must share the same rotation (facing)

**Mechanical effects**:
- **Formation bonus**: +1 strength per adjacent phalanx member
- **Atomic movement**: All members move together or all balk

**Persistence**: Remains until voluntarily disbanded or broken (member death, forced separation, individual order).

---

## The Layered Structure

```
Game State
├── Group: "Left Flank"
│   ├── Unit A (loose)
│   ├── Unit B (loose)
│   └── Phalanx α
│       ├── Unit C
│       └── Unit D
├── Group: "Center"
│   ├── Phalanx β
│   │   ├── Unit E
│   │   ├── Unit F
│   │   └── Unit G
│   └── Unit H (loose)
└── Ungrouped
    └── Unit I (independent, cannot form phalanx)
```

---

## Order Precedence

**Individual > Phalanx > Group**

| Order Target | Effect |
|--------------|--------|
| Group | All members receive order. Loose units execute independently; phalanx subgroups execute atomically. |
| Phalanx | Phalanx members follow this order, ignoring any group order. |
| Individual unit (loose) | Unit follows this order, ignoring any group order. |
| Individual unit (in phalanx) | Unit **leaves the phalanx** and follows this order. |

---

## Example

```
Board state (planning complete, battle started):

Group "Left Flank": [A, B, C, D]
  - A and B are loose
  - C and D formed Phalanx α

Orders submitted:
  - Group "Left Flank": move east
  - Phalanx α: move west
  - Unit B: rotate clockwise
```

**Resolution**:
1. Unit A: moves east (group order, no override)
2. Unit B: rotates clockwise (individual order overrides group)
3. Units C, D: move west atomically (phalanx order overrides group)

---

## Why This Design?

**Historical accuracy**: Generals organized armies into divisions before battle. Mid-battle reorganization was rare and costly. Phalanx formation was a deliberate tactical choice, not an emergent property.

**Strategic depth**:
- Group assignment in planning phase constrains phalanx options
- Players must think ahead about which units might need to form up
- Cross-group phalanxes not allowed = seams between divisions are vulnerable

**Clear mental model**:
- Group = "units I command together" (organizational)
- Phalanx = "units fighting as one" (tactical reality)

---

## Summary

- **Groups** = pre-battle organization, fixed for battle, non-atomic
- **Phalanxes** = during-battle formation, within one group, atomic
- Ungrouped units cannot form phalanxes
- Order precedence: Individual > Phalanx > Group
