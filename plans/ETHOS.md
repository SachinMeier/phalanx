## Ethos

Phalanx is a **MAXIMALLY SIMPLE** war game simulating phalanx-style warfare from antiquity (hoplites, Macedonian pikes, Roman maniples).

### Historical Model

Two armies face one another, each seeking to **flank** the enemy. A phalanx is deadly from the front—the only path to victory is attacking from the side or rear.

### Three Core Dynamics

| Dynamic | Benefit | Historical Basis |
|---------|---------|------------------|
| **Flanking** | Attack side/rear for advantage | Phalanx shields only protect the front |
| **Side cohesion** | Friendly units adjacent + same facing form phalanx | Overlapping shields, coordinated spears |
| **Depth** | Friendly units behind + same facing push forward | Rear ranks add weight to the push |

### Design Constraints

- **Simultaneous resolution**: All orders execute at once (like Diplomacy), not sequentially
- **No hidden information**: Both players see the full board
- **Emergent complexity**: Simple rules create tactical depth through interaction
- **Balance the triangle**: Maneuverability vs side-grouping vs depth—no dominant strategy

### Design Decisions (Resolved)

| Question | Decision | Reference |
|----------|----------|-----------|
| Grouping | Explicit phalanx declaration during battle | `plans/group/spec.md` |
| Win conditions | Elimination first, extensible via game modes | `plans/game-modes/spec.md` |

### Open Questions for Engine Design

- HP/damage vs retreat-when-overpowered (Diplomacy-style)
- Force calculation formula (additive? multiplicative? diminishing returns?)
- How flanking attacks interact with formation bonuses
