# Hex Grid Movement Intersection Edge Cases

Exhaustive documentation of simultaneous movement scenarios on an odd-R offset hex grid.

## Coordinate System Reference

```
Odd-R Offset (Pointy-Top)
Even rows (0, 2, 4...):     Odd rows (1, 3, 5...):

    (0,0) (1,0) (2,0)           (0,1) (1,1) (2,1)
       (0,1) (1,1) (2,1)     (0,2) (1,2) (2,2)
    (0,2) (1,2) (2,2)
```

Six directions: E (east), NE (northeast), NW (northwest), W (west), SW (southwest), SE (southeast)

---

## Category 1: Head-On Collisions (180 degrees)

Units moving toward each other along the same axis.

### 1.1 Direct Head-On: Same Target Hex

```
Before:                     After (both balk):
    A ----E---->               A
         X                     X
    <----W---- B               B

A at (0,1), B at (2,1)
A orders: E, B orders: W
Both target: (1,1)
```

**Collision**: YES
**Resolution**: Both units balk. Neither moves.
**Rationale**: Destination conflict - two units cannot occupy same hex.

### 1.2 Direct Head-On: Position Swap Attempt

```
Before:                     After (both balk):
    A ----E----> B             A    B
    <----W----

A at (0,1), B at (1,1)
A orders: E (to 1,1), B orders: W (to 0,1)
```

**Collision**: YES
**Resolution**: Both units balk.
**Rationale**: Diplomacy rule - units cannot swap positions. They would "pass through" each other, which is physically impossible. Implementation: detect when A's destination = B's origin AND B's destination = A's origin.

### 1.3 Head-On: Gap Between (Miss)

```
Before:                     After (both move):
    A ----E---->   <----W---- B        A'        B'
       (gap)                        (1,1)     (2,1)

A at (0,1), B at (3,1)
A orders: E (to 1,1), B orders: W (to 2,1)
```

**Collision**: NO
**Resolution**: Both moves succeed.
**Rationale**: Destinations are distinct; no physical intersection.

### 1.4 Head-On: One Stationary (Blocking)

```
Before:                     After (A balks):
    A ----E----> B(hold)       A    B

A at (0,1), B at (1,1)
A orders: E (to 1,1), B orders: hold
```

**Collision**: YES
**Resolution**: A balks. B holds.
**Rationale**: Moving into occupied hex is blocked.

---

## Category 2: 120-Degree Crossings

Paths form a 120-degree angle. These can produce path intersections.

### 2.1 Crossing Paths: Same Target

```
Before:                     After (both balk):
        B                           B
        |                           |
       NW                          NW
        v                           v
    A --E--> X                  A   X

A at (0,2), B at (2,1) [odd row]
A orders: E (to 1,2), B orders: SW (to 1,2)
Both target: (1,2)
```

**Collision**: YES
**Resolution**: Both balk.
**Rationale**: Destination conflict.

### 2.2 Crossing Paths: Adjacent Destinations

```
Before:                     After (both move):
        B                           B'(1,1)
        |
       SW
        \
    A ---E---> A'               A'(1,2)

A at (0,2), B at (2,0) [even row]
A orders: E (to 1,2), B orders: SW (to 1,1)
```

**Collision**: NO
**Resolution**: Both moves succeed.
**Rationale**: Distinct destinations; paths cross conceptually but not physically in discrete movement.

### 2.3 Crossing: B's Destination is A's Origin (Chase)

```
Before:                     After:
    A ---E--->                  A'(1,2)
    ^
    |                          B'(0,2)
   SW
    |
    B

A at (0,2), B at (1,1) [odd row]
A orders: E (to 1,2), B orders: SW (to 0,2)
```

**Collision**: NO
**Resolution**: Both moves succeed.
**Rationale**: A vacates (0,2) simultaneously as B arrives. No occupation conflict.

### 2.4 Crossing: Triple Collision

```
Before:                     After (all balk):
        B                           B
         \
         SW
          v
    A--E-->X<--NW--C            A   X   C

A at (0,2), B at (2,1), C at (2,3)
All target: (1,2)
```

**Collision**: YES
**Resolution**: All three balk.
**Rationale**: Multi-unit destination conflict.

---

## Category 3: 60-Degree Sliding

Units moving in directions 60 degrees apart. Generally divergent.

### 3.1 Diverging Slide

```
Before:                     After (both move):
    A ---E---> A'                   A'(1,2)
     \                             /
      NE                         B'(1,1)
       \
        B

A at (0,2), B at (0,2)... wait, same hex?
```

CORRECTION - 60-degree from different starting positions:

```
Before:                     After (both move):
    A ---E---> A'                   A'(2,2)
    B
    |                             B'(1,1)
   NE
    v

A at (1,2), B at (0,2) [even row]
A orders: E (to 2,2), B orders: NE (to 0,1)
```

**Collision**: NO
**Resolution**: Both succeed.
**Rationale**: Diverging paths, distinct destinations.

### 3.2 Converging Slide: Same Destination

```
Before:                     After (both balk):
    B                               B
     \
     SE
      v
    A--E-->X                    A   X

A at (0,2), B at (0,1) [odd row]
A orders: E (to 1,2), B orders: SE (to 1,2)
Both target: (1,2)
```

**Collision**: YES
**Resolution**: Both balk.
**Rationale**: Destination conflict.

### 3.3 Near-Miss Slide

```
Before:                     After (both move):
    A ---E--->                      A'(2,2)
         B                         B'(2,1)
         |
        NE
         v

A at (1,2), B at (1,1) [odd row]
A orders: E (to 2,2), B orders: NE (to 2,1)
```

**Collision**: NO
**Resolution**: Both succeed.
**Rationale**: Adjacent destinations, no conflict.

---

## Category 4: Position Swap Variants

Attempting to exchange positions.

### 4.1 Direct Swap (Already covered in 1.2)

```
A <---> B    (A at X, B at Y; A->Y, B->X)
```

**Collision**: YES
**Resolution**: Both balk.

### 4.2 Diagonal Swap (60-degree)

```
Before:                     Analysis:
    A                           A targets (1,1)
     \                          B targets (0,2)
     SE
      \
       B
      /
    NW
    /

A at (0,2), B at (1,1) [odd row]
A orders: SE (to 1,3), B orders: NW (to 0,2)
```

Wait - need correct neighbor calculation:
- A at (0,2) [even row], SE goes to... checking even_row_moves: SE is index 5 = (0,1). So A->SE = (0,3).
- B at (1,1) [odd row], NW goes to... checking odd_row_moves: NW is index 2 = (0,-1). So B->NW = (1,0).

These don't swap. Let me find an actual diagonal swap:

```
A at (1,2) [even row], B at (0,1) [odd row]
A orders: NW (to 0,1)
B orders: SE (to 1,2)
```

**Collision**: YES - this is a position swap
**Resolution**: Both balk.
**Rationale**: A->B's position, B->A's position = swap = forbidden.

### 4.3 Three-Way Rotation Swap

```
Before:                     Analysis:
      A                         A at (1,0), targets (1,1)
       \                        B at (1,1), targets (0,1)
       SE                       C at (0,1), targets (1,0)
        v
    C<--W--B                    Circular dependency!

A orders: SE (to 1,1)
B orders: W (to 0,1)
C orders: NE (to 1,0)
```

**Collision**: YES
**Resolution**: All three balk.
**Rationale**: Forms a cycle. A needs B's spot, B needs C's spot, C needs A's spot. No valid resolution order.

**Detection algorithm**: Build directed graph of position->destination. Any cycle = conflict.

---

## Category 5: Multi-Unit Convergence

Three or more units targeting the same hex.

### 5.1 Three-Way: All Moving

```
        B
        |
       SW
        v
A--E-->[ ]<--W--C
        ^
       NE
        |
        D

A, B, C, D all target center hex.
```

**Collision**: YES
**Resolution**: All four balk.
**Rationale**: Cannot resolve which unit "wins" the hex. Fair resolution = all fail.

### 5.2 Three-Way: One Holding

```
        B
        |
       SW
        v
A--E-->[H]<--W--C

H is holding at target hex.
```

**Collision**: YES
**Resolution**: A, B, C balk. H remains.
**Rationale**: H occupies destination; attackers cannot displace via movement alone (would require combat).

### 5.3 Two Attack, One Flees

```
Before:                     Analysis:
A--E-->[B]--E-->C               A targets B's position (1,1)
                                B targets C's position (2,1)
                                C holds at (2,1)

A at (0,1), B at (1,1), C at (2,1)
```

**Collision**:
- A targets (1,1)
- B moving away from (1,1) to (2,1)
- C holding at (2,1)

B and C both want (2,1) -> conflict -> both balk.
But wait, B balks means B stays at (1,1).
A was moving to (1,1) where B now stays -> conflict.

**Resolution**: First pass: B,C conflict -> both balk. Second pass: A targets (1,1) where B is holding -> A balks.
**Implementation**: Iterative conflict detection (current codebase does this via recursion in `execute_orders/2`).

---

## Category 6: Chain Collisions

Sequential dependencies where one balk causes another.

### 6.1 Simple Chain

```
Before:                     Resolution:
A--E-->[B]--E-->[C]--E-->[D(hold)]

D holds -> C balks (targeting D's hex)
C balks -> B balks (targeting C's hex)
B balks -> A balks (targeting B's hex)
```

**Collision**: YES (cascading)
**Resolution**: All balk.
**Rationale**: Each unit targets the current position of the next, but no one can move.

### 6.2 Chain with Gap

```
Before:                     Resolution:
A--E-->[B]--E-->[gap]--[C(hold)]

B moves E (to gap) - succeeds
A moves E (to B's vacated hex) - succeeds
```

**Collision**: NO
**Resolution**: Both A and B move.
**Rationale**: B's destination is empty, A's destination is vacated.

### 6.3 Branching Chain

```
        B
        |
       SE
        v
A--E-->[X]<--W--C
        |
       (D below targeting X)

Plus D at south, moving N to X.
```

All four target X. All four balk.

### 6.4 Chain with Swap Attempt

```
A--E-->[B]--W-->A

A targets B's hex, B targets A's hex.
```

**Collision**: YES - swap
**Resolution**: Both balk.

### 6.5 Long Chain Partial Resolution

```
A--E-->B--E-->C--E-->D--E-->[gap]

D can move (gap is empty)
C can move (D vacates)
B can move (C vacates)
A can move (B vacates)
```

**Collision**: NO
**Resolution**: All four move, each shifting one hex east.
**Implementation Note**: Must process in correct order or use fixpoint iteration.

---

## Category 7: Edge-of-Map Scenarios

### 7.1 Move Off Map

```
[edge]<--W--A

A at (0,2), orders W.
```

**Collision**: NO (different error type)
**Resolution**: A balks (invalid move, not conflict).
**Implementation**: `Moves.move/4` returns `{:error, "tile not on map"}`.

### 7.2 Pushed to Edge

```
A--E-->[B]--E-->[edge]

B cannot move (would go off map).
A targets B's hex where B is stuck.
```

**Collision**: YES
**Resolution**: B balks (invalid destination), A balks (occupied).

---

## Category 8: Rotation Interactions

Rotation happens but doesn't affect collision (rotation is post-move).

### 8.1 Rotate and Move

```
A at (0,2), rotation 0 (facing E)
A orders: rotate CW + move E

Rotation: 0 -> 60
Move validity checked against OLD rotation (0).
E is allowed at rotation 0. Move succeeds.
After move, unit is at new position with rotation 60.
```

**Collision**: None (single unit).
**Resolution**: Order succeeds.

### 8.2 Rotation Doesn't Change Collision

```
A--E(+rotate)-->[B(+rotate)]

A moves E and rotates.
B holds and rotates.
```

**Collision**: YES (A moving to occupied hex)
**Resolution**: A balks (including rotation - orders are atomic). B rotates (hold succeeds).

---

## Category 9: Phalanx (Group) Movement

Units moving as a formation.

### 9.1 Phalanx Slides Together

```
Before:          Order: All E         After:
[A][B][C]        -->-->-->           _[A][B][C]

A at (0,1), B at (1,1), C at (2,1)
All order: E
```

**Collision**: Potential - each targets adjacent unit's destination.

Analysis:
- A targets (1,1) - B's current position
- B targets (2,1) - C's current position
- C targets (3,1) - empty (assuming map extends)

Using current implementation: No destination conflict because B vacates for A, C vacates for B.

**Collision**: NO
**Resolution**: All move together.
**Note**: Order-independent because destinations form a consistent shift pattern.

### 9.2 Phalanx Blocked

```
[A][B][C]-->[D(hold)]

A, B, C all order E. D holds.
```

D blocks C. C balks. C blocking B. B balks. B blocking A. A balks.

**Collision**: YES (chain)
**Resolution**: All of A, B, C balk.

### 9.3 Phalanx Collision

```
[A][B][C]--E-->
<--W--[D][E][F]

Both formations moving toward each other.
```

All target occupied/contested hexes. All balk.

**Collision**: YES
**Resolution**: All six balk.

---

## Category 10: Odd-R Parity Edge Cases

Different neighbor calculations for even vs odd rows.

### 10.1 Same Direction, Different Row Parity

```
Even row (y=2):              Odd row (y=1):
A at (1,2)                   B at (1,1)
A orders: NE                 B orders: NE
A's NE = (1,1)               B's NE = (2,0)
```

**Note**: Same direction produces different offsets based on row parity.

### 10.2 Convergence from Different Parities

```
A at (1,2) [even], B at (2,1) [odd]
A orders: NE (to 1,1)
B orders: NW (to 1,0)

Different destinations - no conflict.

But:
A at (1,2) [even], B at (2,1) [odd]
A orders: NE (to 1,1)
B orders: SW (to 1,2)
B now targets A's origin - A vacates, B enters. OK.
```

---

## Summary: Conflict Types

| Type | Detection | Resolution |
|------|-----------|------------|
| Destination Conflict | Two+ units target same hex | All targeting units balk |
| Position Swap | A->B and B->A | Both balk |
| Cycle | A->B->C->A (any length) | All in cycle balk |
| Blocked by Holder | Moving to held hex | Mover balks |
| Chain Cascade | A->B where B balks | A balks (iterative) |
| Off-Map | Destination outside grid | Invalid move, unit balks |

---

## Implementation Checklist

1. **Destination grouping**: Group all movements by destination. Any group with 2+ entries = conflict.

2. **Swap detection**: For each pair (A->X, B->Y), check if X=B.origin AND Y=A.origin.

3. **Cycle detection**: Build graph of origin->destination edges. Find strongly connected components or simple cycle detection.

4. **Iterative resolution**: Current implementation recurses until no conflicts. This handles cascading balks.

5. **Hold population**: Units without orders get hold orders (already implemented in `populate_hold_orders/2`).

6. **Atomic orders**: If move fails, rotation also fails (currently implemented).

---

## Test Case Matrix

| ID | Scenario | A.pos | A.order | B.pos | B.order | C.pos | C.order | Expected |
|----|----------|-------|---------|-------|---------|-------|---------|----------|
| 1 | Head-on same target | (0,1) | E | (2,1) | W | - | - | Both balk |
| 2 | Position swap | (0,1) | E | (1,1) | W | - | - | Both balk |
| 3 | Gap miss | (0,1) | E | (3,1) | W | - | - | Both move |
| 4 | Blocked by holder | (0,1) | E | (1,1) | hold | - | - | A balks |
| 5 | 120-deg same target | (0,2) | E | (2,1) | SW | - | - | Both balk |
| 6 | Chase (B to A's origin) | (0,2) | E | (1,1) | SW | - | - | Both move |
| 7 | Three-way target | (0,2) | E | (2,1) | SW | (2,3) | NW | All balk |
| 8 | Diagonal swap | (1,2) | NW | (0,1) | SE | - | - | Both balk |
| 9 | Three-way rotation | (1,0) | SE | (1,1) | W | (0,1) | NE | All balk |
| 10 | Chain block | (0,1) | E | (1,1) | E | (2,1) | hold | A,B balk |
| 11 | Chain gap | (0,1) | E | (1,1) | E | (3,1) | hold | A,B move |
| 12 | Phalanx slide | (0,1) | E | (1,1) | E | (2,1) | E | All move |
| 13 | Off-map | (0,1) | W | - | - | - | - | A balks |

---

## Open Questions for Game Design

1. **Should strength affect collision resolution?** Currently all conflicts result in balks. Alternative: stronger unit wins contested hex.

2. **Should momentum matter?** Unit moving into conflict vs unit holding at conflict.

3. **Retreat behavior?** When combat causes displacement, does the displaced unit get a free move or balk?

4. **Phalanx atomicity?** MECHANICS.md says "phalanx moves atomically" - does this mean if ANY unit in phalanx balks, ALL balk?

5. **Support nullification?** MECHANICS.md mentions support is nulled if supporting unit is attacked. How does this interact with simultaneous movement?
