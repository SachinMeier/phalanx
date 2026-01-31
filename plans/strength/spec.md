# 2026-01-26: Strength Calculation System

**Author**:
**Approved By**:

---

## 1. What's the problem you're trying to solve?

**Casual**: Units need a way to determine who wins when they collide. A lone unit charging into a tight formation should fail. A flanking attack should succeed. The game needs strength math.

**Key insight**: A phalanx is a **two-dimensional block**. Units gain strength from ALL adjacent allies within the same explicitly declared phalanx—whether beside them (ranks) or behind them (files). The historical phalanx was deep as well as wide; both dimensions matter equally for grouping purposes.

**Formal**:

1. No mechanism exists to compare unit strengths during conflicts
2. Phalanx formation bonuses have no implementation
3. Flanking attacks confer no advantage
4. Conflict resolution treats all collisions as mutual balk—no victor, no dislodgement

**Out of Scope**:

* **Damage calculation**: Health loss is a separate concern; this spec covers strength comparison only
* **Energy system**: Forward/backward movement costs are independent of strength
* **Phalanx atomic movement**: Group dislodgement requires phalanx detection first
* **Win/loss conditions**: Victory logic sits above strength calculation
* **Phalanx declaration**: See `group/spec.md` for phalanx formation mechanics

---

## 2. What's the simplest solution to solve the problem?

The main parts of the solution are:

1. **Strength module**: Pure functions that compute a unit's strength value
2. **Neighbor classification**: Given unit position and rotation, label each adjacent hex as front, flank, or rear
3. **Bonus accumulation**: Count adjacent allies **within the same declared phalanx** to compute additive bonuses
4. **Engine integration**: Replace mutual-balk with strength comparison when units contest a hex

### Design Decisions

#### A. Base Strength

| Option | Value | Pros | Cons |
|--------|-------|------|------|
| **Uniform (recommended)** | 1 | Simpler. All tactical advantage comes from positioning. Easier to balance. | Less unit variety. |
| Variable by unit type | 1-3 | Allows specialist units (heavy infantry = 2, skirmisher = 1). | Adds complexity. Requires unit-type field. Harder to balance. |

**Recommendation**: Uniform base strength of 1. Phalanx is "maximally simple." Tactical depth should emerge from formation, not stat variety.

#### B. Formation Bonus

**Simple rule**: +1 per adjacent ally **in the same declared phalanx**.

**Critical distinction**: Formation bonuses apply ONLY to units that are:
1. Members of an explicitly declared phalanx (see `group/spec.md`)
2. Adjacent to other members of that SAME phalanx

Loose units—even if adjacent to allies with the same facing—receive NO formation bonus. Phalanx membership is explicit, not auto-detected.

**Position classification** (relative to unit's facing):
- **Side positions**: 2 hexes to your left and right (perpendicular to facing)
- **Rear positions**: Hexes behind you (can stack infinitely deep)
- **Front position**: 1 hex directly ahead (facing direction)

```
For unit facing East:

          [FRONT]
          /
         /
   [side]─[UNIT]─[side]
         \
          \
          [REAR]
           [REAR]
            [REAR]
             ...
```

**Side bonus**: Naturally capped at +2 by geometry. You can only have two side-by-side neighbors (one on each flank).

**Depth bonus**: No cap. The deeper the phalanx, the more powerful. However, a deep narrow formation is extremely vulnerable to flanking—this is the natural counterbalance. No artificial cap needed.

| Scenario | Formation Bonus |
|----------|-----------------|
| Isolated unit (no phalanx) | +0 |
| Loose unit adjacent to ally (not in phalanx) | +0 |
| Phalanx member with 1 side ally in same phalanx | +1 |
| Phalanx member with 2 side allies in same phalanx | +2 |
| Phalanx member with 1 rear ally in same phalanx | +1 |
| Phalanx member with 2 side + 1 rear in same phalanx | +3 |
| Phalanx member in middle of 3-deep column | +2 (1 front + 1 rear, but front doesn't count—only side and rear) |

**Strategic tradeoff**: Wide formations (+2 side) are harder to flank but have less pushing power. Deep formations (unlimited rear) have massive pushing power but are vulnerable from the sides. Players must balance width vs depth.

#### C. No Implicit Adjacency Bonus

Units outside a declared phalanx receive **no formation bonus**, regardless of:
- Adjacent allies
- Same facing as neighbors
- Same movement direction

This is intentional. Forming a phalanx is a deliberate tactical commitment (see `group/spec.md`). The bonus rewards coordination and planning, not accidental proximity.

#### D. Bonus Cap

**No artificial cap needed.** The game self-balances:

- **Side bonus**: Geometrically limited to +2 (only 2 side neighbors possible)
- **Depth bonus**: Unlimited, but deep formations are narrow and flankable

A 10-deep column has massive forward pushing power but can be destroyed by a single flanking unit. Players naturally avoid degenerate formations because they lose.

#### E. Phalanx Membership Check

When does an ally count for bonus purposes?

**Simple rule**: Both units must be members of the **same declared phalanx**.

This replaces the previous "same facing AND same movement direction" check. Phalanx membership is:
- Declared explicitly during battle (not auto-detected)
- Stored in game state
- Persistent until broken or disbanded

See `group/spec.md` for phalanx formation requirements (same group, adjacent, same rotation).

#### F. Flanking Effect

**DECISION**: Flanking affects DAMAGE only, not strength. Damage stacks.

| Source | HP Lost |
|--------|---------|
| Dislodge | 1 HP |
| Frontal angle bonus | +0 (shields block) |
| Flank angle bonus | +1 |
| Rear angle bonus | +2 |

**Total on dislodge**: Frontal = 1 HP, Flank = 2 HP, Rear = 3 HP.

Strength calculation is identical regardless of attack direction. The defender keeps all formation bonuses. The incentive to flank is dealing extra damage—frontal dislodge costs only 1 HP while rear dislodge costs 3 HP.

#### G. Support Bonus (Combined Attacks)

**DECISION**: Support bonus exists, separate from formation bonus. Combined attacks on the same hex add strength.

**Definition**: When multiple friendly units attack the same enemy hex, they provide **support** to each other. The lead attacker (first-ordered) gains strength from supporting attackers.

| Bonus Type | Source | Max | Can Be Cut? |
|------------|--------|-----|-------------|
| **Formation** | Adjacent allies in same declared phalanx | No cap (geometry limits side to +2) | **NEVER** |
| **Support** | Friendly units attacking same hex (not in same phalanx) | +2 | **YES** (if supporter is attacked) |

**Key distinction**:
- Formation bonus: From **position** (adjacent phalanx members)
- Support bonus: From **action** (multiple attackers targeting same hex)

**Combined strength formula**:
```
Attacker Strength = Base(1) + Formation + Support(0-2)
Defender Strength = Base(1) + Formation
```

**Support rules**:
1. Multiple attackers targeting the same hex combine their forces
2. Support bonus is +1 per ally attacking the same hex (cap +2)
3. Support is **cut** if the supporter is targeted by an enemy attack
4. Formation bonus is **never** cut (phalanx membership is position-based)
5. A unit can receive BOTH formation bonus AND support bonus

**Example scenarios**:

| Scenario | Strength Calculation |
|----------|---------------------|
| Isolated attacker | 1 (base only) |
| Phalanx member (2 neighbors) attacking | 1 + 2 = 3 (formation only) |
| Two loose units attacking same hex | Lead: 1 + 1 = 2 (support from ally) |
| Phalanx member + loose ally attacking same hex | 1 + 2 + 1 = 4 (formation + support) |

**Support vs Formation summary**:
- Phalanx members get formation bonus from adjacent phalanx allies
- Any attacker gets support bonus from other attackers on same hex
- These bonuses stack but come from different sources

---

## 3. Which key code changes do you need to make?

+++ #### Strength

Strength calculation module. Pure functions, no state.

`lib/phalanx/strength.ex`

```elixir
defmodule Phalanx.Strength do
  @base_strength 1

  @type direction_class :: :front | :flank | :rear
  @type strength_result :: %{
    base: integer(),
    side_bonus: integer(),
    rear_bonus: integer(),
    total: integer()
  }

  @spec calculate(
    position :: tuple(),
    units :: map(),
    phalanxes :: [Phalanx.Phalanx.t()],
    attack_direction :: atom() | nil
  ) :: strength_result()

  @spec classify_direction(unit_rotation :: integer(), neighbor_direction :: atom()) :: direction_class()

  @spec get_neighbors(position :: tuple(), map_dimensions :: tuple()) :: [{atom(), tuple()}]

  @spec count_side_allies(
    position :: tuple(),
    unit :: map(),
    units :: map(),
    phalanx :: Phalanx.Phalanx.t() | nil
  ) :: integer()

  @spec count_rear_allies(
    position :: tuple(),
    unit :: map(),
    units :: map(),
    phalanx :: Phalanx.Phalanx.t() | nil
  ) :: integer()

  @spec in_same_phalanx?(
    position1 :: tuple(),
    position2 :: tuple(),
    phalanxes :: [Phalanx.Phalanx.t()]
  ) :: boolean()
  # Returns true if both positions are members of the same declared phalanx

  @spec get_phalanx_for_position(
    position :: tuple(),
    phalanxes :: [Phalanx.Phalanx.t()]
  ) :: Phalanx.Phalanx.t() | nil
  # Returns the phalanx containing this position, or nil if not in any phalanx
end
```

+++

+++ #### Moves (extension)

Add neighbor enumeration to existing module.

`lib/phalanx/moves.ex`

```elixir
defmodule Phalanx.Moves do
  # Existing functions...

  @spec all_neighbors(map_dimensions :: tuple(), position :: tuple()) :: [{atom(), tuple()}]
  # Returns list of {direction, neighbor_position} for all 6 hex directions
  # Filters out off-map positions
end
```

+++

+++ #### Engine.Diplomacy (modification)

Integrate strength comparison into conflict resolution.

`lib/phalanx/engine/engine_diplomacy.ex`

```elixir
defmodule Phalanx.Engine.Diplomacy do
  # Existing functions...

  @spec resolve_contested_hex(
    state :: map(),
    hex :: tuple(),
    contestants :: [{tuple(), map(), atom()}]  # {from_pos, unit, direction}
  ) :: {:winner, tuple()} | :mutual_balk

  @spec calculate_attack_strength(
    state :: map(),
    attacker_pos :: tuple(),
    target_hex :: tuple(),
    attack_direction :: atom()
  ) :: integer()

  @spec calculate_defense_strength(
    state :: map(),
    defender_pos :: tuple(),
    attack_direction :: atom()
  ) :: integer()
end
```

+++

### Hex Direction Classification

A unit's rotation determines what counts as front, flank, or rear.

For a unit facing 60 (northeast):

```
        NW(2)      NE(1)
           \      /
            \    /         Rotation 60 = facing NE
      W(3) ──[UNIT]── E(0)
            /    \
           /      \
        SW(4)     SE(5)

Front:  NE (direction 1)
Flanks: NW, E, SE, SW (directions 2, 0, 5, 4)
Rear:   W (direction 3)
```

Direction classification formula:

```elixir
def classify_direction(unit_rotation, neighbor_direction) do
  # Convert rotation to front direction index
  front_idx = rotation_to_front_direction_index(unit_rotation)
  neighbor_idx = direction_to_idx(neighbor_direction)

  # Rear is opposite of front (3 steps around hex)
  rear_idx = rem(front_idx + 3, 6)

  cond do
    neighbor_idx == front_idx -> :front
    neighbor_idx == rear_idx -> :rear
    true -> :flank
  end
end

# Rotation to front direction mapping
# 60  -> NE (idx 1)
# 120 -> E  (idx 0)  [rotated 60 clockwise from NE]
# 180 -> SE (idx 5)
# 240 -> SW (idx 4)
# 300 -> W  (idx 3)
# 0   -> NW (idx 2)
```

### Strength Calculation Formula

```
Strength = Base + FormationBonus

Where:
  Base = 1
  FormationBonus = SideAllies + RearAllies (only if unit is in a declared phalanx)
  SideAllies = count of side-adjacent allies in SAME PHALANX (max 2 by geometry)
  RearAllies = count of rear allies in SAME PHALANX (no cap)

CRITICAL: Formation bonuses ONLY apply to units in a declared phalanx.
Loose units (not in any phalanx) always have FormationBonus = 0.
```

**Formation examples**:

```
3-wide phalanx all facing East:

[A][B][C]     Unit B gets (all in same declared phalanx):
                - Side allies: A, C = 2
                - Rear allies: 0
                - Formation bonus: +2
                - Total strength: 3

5-deep phalanx column all facing East:

[A]             Unit C (middle) gets:
[B]             - Side allies: 0
[C]             - Rear allies: D, E = 2
[D]             - Formation bonus: +2
[E]             - Total strength: 3

                But: this column is extremely vulnerable to flanking!

3x3 block phalanx all facing East:

[G][H][I]     Unit E (center of rear rank) gets:
[D][E][F]     - Side allies: D, F = 2
[A][B][C]     - Rear allies: B = 1
                - Formation bonus: +3
                - Total strength: 4

3 loose units (NOT in a phalanx) adjacent and same facing:

[A][B][C]     Unit B gets:
                - NOT in a declared phalanx
                - Formation bonus: +0
                - Total strength: 1
```

**Defender adjustment for flanking**:

```
If attacked from flank:
  Formation bonus excludes the ally on the attacked flank side

If attacked from rear:
  Rear allies don't count toward formation bonus
```

### Example Scenarios

**Scenario 1: Head-on collision**

```
  [A]  vs  [B]

  A attacks east, B attacks west (or holds)

  If both isolated (not in phalanx):
    A strength = 1, B strength = 1  mutual balk

  If A is in phalanx with ally behind:
    A strength = 1 + 1 (rear) = 2
    B strength = 1  A wins, B dislodged
```

**Scenario 2: Flanking attack**

```
       [C]
         |
  [A][B]

  C attacks south into hex occupied by B
  B faces east, C attacks from flank (north)

  If A and B are in same phalanx:
    C strength = 1 (attacker, no allies)
    B strength = 1 base + 1 (A is adjacent in same phalanx)
            - but A is on B's flank, not the attacked side
            = 2 total

    C needs allies to dislodge B.

  If A and B are NOT in a phalanx (just adjacent):
    C strength = 1
    B strength = 1 (no formation bonus for loose units)

    Equal strength  mutual balk (or C wins if has phalanx support)
```

**Scenario 3: Rear attack**

```
  [A][B]

         [C]

  C attacks west into B from B's rear

  If A and B are in same phalanx:
    C strength = 1
    B strength = 1 base + 1 (A adjacent in phalanx) + 0 (rear bonus negated by rear attack) = 2

    Still hard to dislodge, but B loses any rear support bonus.

  If A and B are loose (not in phalanx):
    C strength = 1
    B strength = 1 (no formation bonus)

    Equal strength.
```

---

## 4. What's the PR roadmap?

1. **PR #1: Strength module foundation**
   1. Add `all_neighbors/2` to `Phalanx.Moves`
   2. Create `Phalanx.Strength` with `classify_direction/2`
   3. Implement `get_phalanx_for_position/2` and `in_same_phalanx?/3`
   4. Tests for direction classification across all rotations

2. **PR #2: Bonus calculation**
   1. Implement `count_side_allies/4` (phalanx-aware)
   2. Implement `count_rear_allies/4` (phalanx-aware)
   3. Implement `calculate/4` with phalanx membership check
   4. Tests for bonus counting (phalanx vs loose units)

3. **PR #3: Engine integration**
   1. Modify `detect_conflicts/1` to identify contested hexes
   2. Add `resolve_contested_hex/3` with strength comparison
   3. Replace mutual-balk with winner determination
   4. Integration tests for attack resolution

---

## 5. What are open questions?

1. **Defender reaction**: When a stationary unit is attacked, does it count as "attacking back" for strength purposes, or is defense purely passive?

2. **Multiple attackers**: **RESOLVED** - Yes, friendly attackers combine forces. First-ordered unit is "lead" and moves in; others hold position. Single combat resolution.

3. **Retreat direction**: **RESOLVED** - Retreat in the same direction as the attack (e.g., attacked from NE → retreat NE). If primary retreat hex is blocked, use the unit's adjacent backward direction based on its facing. If both blocked, unit destroyed.

4. **Support chain validation**: If a rear supporter is themselves under attack, does their support still count? (MECHANICS.md suggests no: "support is nulled if the supporting unit is attacked")

5. **Rotation timing interaction**: Attack resolves before rotation. If a unit rotates this turn, which facing determines their strength calculation—pre-rotation or post-rotation?
