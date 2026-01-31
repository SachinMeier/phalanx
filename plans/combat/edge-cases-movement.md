# Hex Grid Movement Edge Cases

Movement is a subset of combat. Every hex contest is resolved by strength comparison between teams.

## Core Principle: Movement as Strength Contest

When units target a hex, the system calculates **team strength** for each team involved:
- Empty hex: 0 strength. Any unit moving in wins automatically.
- Held hex: Holder's strength vs attacker(s) strength.
- Multi-unit contest: Sum forces by team. Higher total wins.

**Same-team units never conflict.** If multiple units from the same team target the same hex, the unit whose order was placed first becomes the **leader** (moves in), and subsequent units become **supporters** (add strength but don't move).

---

## Coordinate System Reference

```
Odd-R Offset (Pointy-Top)
Even rows (0, 2, 4...):     Odd rows (1, 3, 5...):

    (0,0) (1,0) (2,0)           (0,1) (1,1) (2,1)
       (0,1) (1,1) (2,1)     (0,2) (1,2) (2,2)
    (0,2) (1,2) (2,2)
```

Six directions: E, NE, NW, W, SW, SE

---

## Category 1: Uncontested Movement

### 1.1 Move to Empty Hex

```
Before:                     After:
    A(Red) ---E--->             [empty] A(Red)

A at (0,1), orders E to (1,1)
Target hex: empty
```

**Strength comparison**: Red 1 vs 0
**Resolution**: Red wins. A moves to (1,1).

### 1.2 Same-Team Units Target Same Empty Hex

```
Before:                     After:
    A(Red) ---E--->             A(Red) at (1,1)
    B(Red) ---NE-->             B(Red) stays at origin
         both target (1,1)

A's order placed first, B's order placed second.
```

**Strength comparison**: Red (A+B support) vs 0
**Resolution**: Red wins. A moves (leader), B supports but stays in place.
**Note**: B's movement is not wasted—B's strength contributes to securing the hex.

### 1.3 Move Off Map

```
[edge]<--W--A(Red)

A at (0,2), orders W.
```

**Resolution**: Invalid move. A balks (map boundary, not strength contest).

---

## Category 2: Head-On Collisions (Opposing Teams)

### 2.1 Direct Head-On: Same Target Hex

```
Before:                     After (assume equal strength):
    A(Red) ---E--->             A(Red)  B(Purple)
         X (empty)
    <---W--- B(Purple)

A at (0,1), B at (2,1)
Both target: (1,1)
```

**Strength comparison**: Red (A) vs Purple (B)
**Resolution**:
- If equal strength: Both balk (stalemate).
- If Red > Purple: A moves in, B balks.
- If Purple > Red: B moves in, A balks.

### 2.2 Position Swap Attempt (Opposing Teams)

```
Before:                     After (assume equal strength):
    A(Red) ---E---> B(Purple)       A(Red)  B(Purple)
           <---W---

A at (0,1), B at (1,1)
A targets (1,1), B targets (0,1)
```

**Analysis**: Two separate contests:
- Hex (1,1): Red (A) vs Purple (B defending or vacating?)
- Hex (0,1): Purple (B) vs Red (A vacating?)

**Resolution**: Swap is impossible. Both units contest each other's hex simultaneously. Both balk (mutual blocking).

### 2.3 Head-On: Gap Between

```
Before:                     After:
    A(Red) ---E--->   <---W--- B(Purple)
           (gap)

A at (0,1), targets (1,1)
B at (3,1), targets (2,1)
```

**Strength comparison**:
- Hex (1,1): Red (A) vs 0 → Red wins
- Hex (2,1): Purple (B) vs 0 → Purple wins

**Resolution**: Both move to their respective empty hexes.

### 2.4 One Stationary, One Moving (Opposing Teams)

```
Before:                     After (assume equal base strength):
    A(Red) ---E---> B(Purple,hold)     A(Red)  B(Purple)

A at (0,1), B at (1,1) holding
```

**Strength comparison**: Red (A attacking) vs Purple (B defending)
**Resolution**: Depends on strength. Defender may get terrain/hold bonus. If stalemate, A balks.

---

## Category 3: Same-Team Coordination

### 3.1 Two Units, One Target (Same Team)

```
Before:                     After:
        B(Red)                  B(Red) stays
        |
       SW
        v
    A(Red)--E-->X           A(Red) at X

A's order placed first. Both target X.
```

**Strength comparison**: Red (A + B support) vs 0
**Resolution**: A moves (leader), B stays but contributes force. The hex is secured with combined strength.

### 3.2 Three Units, One Target (Same Team)

```
        B(Red)
         \
         SW
          v
    A(Red)--E-->X<--NW--C(Red)

A's order first, B second, C third. All target X.
```

**Strength comparison**: Red (A + B + C support) vs 0
**Resolution**: A moves (leader). B and C stay but contribute strength.

### 3.3 Phalanx Slides Together (Same Team)

```
Before:          Order: All E         After:
[A][B][C](Red)   -->-->-->           _[A][B][C](Red)

A at (0,1), B at (1,1), C at (2,1)
All order: E
```

**Analysis**:
- A targets (1,1) where B was
- B targets (2,1) where C was
- C targets (3,1) which is empty

**Resolution**: C moves first (empty hex), B follows (C vacated), A follows (B vacated). Formation shifts intact.

---

## Category 4: Multi-Team Contests

### 4.1 Triple Collision: Two vs One

```
        B(Red)
         \
         SW
          v
    A(Red)--E-->X<--W--C(Purple)

A and B are Red. C is Purple. All target X.
```

**Strength comparison**: Red (A + B) vs Purple (C)
**Resolution**:
- Red has 2 units, Purple has 1.
- Red wins (assuming equal unit strength). A moves to X (first Red order). B supports.
- C balks.

### 4.2 Triple Collision: One vs Two

```
        B(Purple)
         \
         SW
          v
    A(Red)--E-->X<--W--C(Purple)

A is Red. B and C are Purple.
```

**Strength comparison**: Red (A) vs Purple (B + C)
**Resolution**:
- Purple has 2 units, Red has 1.
- Purple wins. Whichever Purple unit ordered first moves to X.
- A balks.

### 4.3 Triple Collision: Three-Way (Three Teams?)

Not applicable—game has two teams only.

### 4.4 Quad Collision: 2v2

```
        B(Red)
        |
       SW
        v
A(Red)--E-->X<--W--C(Purple)
        ^
       NE
        |
        D(Purple)

A, B are Red. C, D are Purple.
```

**Strength comparison**: Red (A + B) vs Purple (C + D)
**Resolution**:
- Equal team strength → stalemate.
- All four units balk.

### 4.5 Quad Collision: 3v1

```
        B(Red)
        |
       SW
        v
A(Red)--E-->X<--W--C(Purple)
        ^
       NE
        |
        D(Red)

A, B, D are Red. C is Purple.
```

**Strength comparison**: Red (A + B + D) vs Purple (C)
**Resolution**:
- Red strength = 3, Purple strength = 1.
- Red wins decisively. Whichever Red unit ordered first moves in.
- C balks.

---

## Category 5: Defender Scenarios

### 5.1 Attacking Held Hex (Opposing Team)

```
A(Red)--E-->[B(Purple,hold)]

A at (0,1), B at (1,1) holding
```

**Strength comparison**: Red (A attacking) vs Purple (B defending)
**Resolution**: Strength determines outcome. May include defender bonuses.

### 5.2 Multiple Attackers vs Holder (Opposing Team)

```
        C(Red)
        |
       SW
        v
A(Red)--E-->[B(Purple,hold)]

A and C are Red, attacking B who is Purple.
```

**Strength comparison**: Red (A + C) vs Purple (B)
**Resolution**: 2v1. Red likely wins. A moves in (if first order), B is pushed/destroyed.

### 5.3 Multiple Attackers vs Holder (Same Team Attacking)

```
        C(Red)
        |
       SW
        v
A(Red)--E-->[B(Red,hold)]

All Red. A and C want B's hex. B is holding.
```

**Resolution**: Same team. No conflict. B holds (stationary orders take precedence over incoming same-team movement). A and C support B's position but don't displace B.

**Note**: Same-team units cannot push each other out of hexes.

### 5.4 Holder with Support vs Attackers

```
        D(Purple)
        |
       SW
        v
A(Red)--E-->[B(Purple,hold)]<--NW--E(Purple)

A is Red attacking. B holds. D and E are Purple moving to support B.
```

**Strength comparison**: Red (A) vs Purple (B + D support + E support)
**Resolution**: Purple has significant strength advantage. A balks.

---

## Category 6: Chain Movement

### 6.1 Same-Team Chain (Follow the Leader)

```
A(Red)--E-->[B(Red)]--E-->[C(Red)]--E-->[gap]

All Red. A pushes into B, B into C, C into gap.
```

**Resolution**: Same team, no conflict. Chain resolves:
- C moves to gap (empty).
- B moves to C's vacated hex.
- A moves to B's vacated hex.

### 6.2 Same-Team Chain Blocked by Enemy

```
A(Red)--E-->[B(Red)]--E-->[C(Purple,hold)]

A, B are Red. C is Purple holding.
```

**Force comparison at C's hex**: Red (B attacking) vs Purple (C holding)
**Resolution**:
- If B cannot overcome C, B balks.
- B balking means A moving into B's hex is now contested: Red (A) vs Red (B, now holding).
- Same team: A can't push B out. A balks too.

### 6.3 Opposing Chain Collision

```
A(Red)--E-->X<--W--B(Purple)--W--[C(Purple)]

A is Red moving E. B is Purple moving W. C is Purple holding (B wants C's hex).
```

**Analysis**:
- B cannot take C's hex (same team, can't push).
- B becomes a "hold" at current position.
- A vs B at X: Red (A) vs Purple (B).

**Resolution**: Strength contest between A and B.

---

## Category 7: Cycle Detection

### 7.1 Two-Unit Swap (Opposing Teams)

```
A(Red) at X, orders to Y
B(Purple) at Y, orders to X
```

**Resolution**: Mutual contest. Both balk (swap impossible regardless of strength).

### 7.2 Two-Unit Swap (Same Team)

```
A(Red) at X, orders to Y
B(Red) at Y, orders to X
```

**Resolution**: Same team cannot swap. First order takes precedence:
- If A ordered first: A moves to Y, B cannot move to X (A vacating doesn't help—they'd pass through).
- Result: A moves, B balks.

Actually, this is a cycle. Same-team cycles resolve by **first order wins**. A moves to Y, B balks (can't enter X while A is still nominally there during resolution).

### 7.3 Three-Way Rotation (Opposing Teams)

```
A(Red) at X, orders to Y
B(Purple) at Y, orders to Z
C(Red) at Z, orders to X
```

**Resolution**: Cyclic dependency. No valid resolution. All balk.

### 7.4 Three-Way Rotation (Same Team)

```
A(Red) at X, orders to Y
B(Red) at Y, orders to Z
C(Red) at Z, orders to X
```

**Resolution**: Same team cycle. First order wins:
- If A first: A moves to Y, pushing B. But B wanted Z, and C wants X.
- Cycle cannot cleanly resolve even within same team.
- All balk.

---

## Category 8: Rotation Interactions

Rotation is post-movement and doesn't affect strength calculations.

### 8.1 Rotate and Move

```
A(Red) at (0,2), rotation 0
Orders: rotate CW + move E
```

**Resolution**: Move validity checked against current rotation. If valid, unit moves then rotates.

### 8.2 Rotation on Balk

```
A(Red)--E(+rotate)-->[B(Purple)]

A balks due to force loss.
```

**Resolution**: Orders are atomic. If move fails, rotation also fails.

---

## Category 9: Edge-of-Map

### 9.1 Move Off Map

```
[edge]<--W--A(Red)
```

**Resolution**: Invalid destination. A balks (not force-related).

### 9.2 Enemy Pushed to Edge

This is combat, not pure movement. See combat edge cases for push mechanics.

---

## Category 10: Odd-R Parity

Different neighbor calculations for even vs odd rows.

### 10.1 Same Direction, Different Parity

```
Even row (y=2):              Odd row (y=1):
A(Red) at (1,2)              B(Red) at (1,1)
A orders: NE → (1,1)         B orders: NE → (2,0)
```

Same direction, different destinations due to row parity.

### 10.2 Cross-Parity Convergence (Same Team)

```
A(Red) at (1,2) [even], orders NE to (1,1)
B(Red) at (2,1) [odd], orders SW to (1,2)

B targets A's origin. A vacates. B enters.
```

**Resolution**: No conflict. Both moves succeed.

---

## Summary: Resolution Rules

| Scenario | Resolution |
|----------|------------|
| Move to empty hex | Always succeeds (force > 0) |
| Same-team same target | First order moves, others support |
| Opposing teams same target | Higher total team force wins |
| Equal force contest | Stalemate, all involved balk |
| Position swap (any teams) | Impossible, both balk |
| Cycle (any configuration) | All in cycle balk |
| Same-team chain | Resolves sequentially, leader to tail |
| Off-map | Invalid move, unit balks |

---

## Force Calculation Notes

For movement contests, base force is unit count. Full force calculation (including formation bonuses, flanking, depth) applies when combat is involved. See `spec.md` for force formulas.

---

## Test Case Matrix

| ID | Scenario | Teams | Expected |
|----|----------|-------|----------|
| 1 | Empty hex | Red A → empty | A moves |
| 2 | Same-team same target | Red A,B → X | First order moves, second supports |
| 3 | Opposing same target (equal) | Red A, Purple B → X | Both balk |
| 4 | Opposing same target (2v1) | Red A,B vs Purple C → X | Red wins, A moves |
| 5 | Opposing same target (1v2) | Red A vs Purple B,C → X | Purple wins |
| 6 | Swap attempt | Red A↔Purple B | Both balk |
| 7 | Same-team swap | Red A↔Red B | First order moves, second balks |
| 8 | Chain (same team) | Red A→B→C→gap | All move |
| 9 | Chain blocked by enemy | Red A→B, Purple C holds | Strength contest at C determines cascade |
| 10 | Phalanx slide | Red A,B,C all E | All move together |
| 11 | Defender with support | Red A attacks Purple B (D,E support) | Purple force advantage, A balks |
| 12 | 2v2 contest | Red A,B vs Purple C,D → X | Equal force, all balk |
| 13 | 3v1 contest | Red A,B,C vs Purple D → X | Red wins decisively |

---

## Open Questions

1. **Defender bonus**: Should holding units get a force multiplier?
2. **Support range**: Can units support a contest without moving toward that hex?
3. **Failed support**: If A moves to X and B's support order fails (B is attacked), does A lose the support force?
4. **Partial cycles**: In A→B→C where C holds, does same-team behave differently than opposing-team?
