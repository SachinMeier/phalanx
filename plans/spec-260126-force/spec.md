# 2026-01-26: Force Calculation System

**Author**:
**Approved By**:

---

## 1. What's the problem you're trying to solve?

**Casual**: Units need a way to determine who wins when they collide. A lone unit charging into a tight formation should fail. A flanking attack should succeed. The game needs force math.

**Formal**:

1. No mechanism exists to compare unit strengths during conflicts
2. Phalanx formation bonuses (side cohesion, depth) have no implementation
3. Flanking attacks confer no advantage
4. Conflict resolution treats all collisions as mutual balk—no victor, no dislodgement

**Out of Scope**:

* **Damage calculation**: Health loss is a separate concern; this spec covers force comparison only
* **Energy system**: Forward/backward movement costs are independent of force
* **Phalanx atomic movement**: Group dislodgement requires phalanx detection first
* **Win/loss conditions**: Victory logic sits above force calculation

---

## 2. What's the simplest solution to solve the problem?

The main parts of the solution are:

1. **Force module**: Pure functions that compute a unit's force value
2. **Neighbor classification**: Given unit position and rotation, label each adjacent hex as front, flank, or rear
3. **Bonus accumulation**: Count qualifying allies to compute additive bonuses
4. **Engine integration**: Replace mutual-balk with force comparison when units contest a hex

### Design Decisions

#### A. Base Strength

| Option | Value | Pros | Cons |
|--------|-------|------|------|
| **Uniform (recommended)** | 1 | Simpler. All tactical advantage comes from positioning. Easier to balance. | Less unit variety. |
| Variable by unit type | 1-3 | Allows specialist units (heavy infantry = 2, skirmisher = 1). | Adds complexity. Requires unit-type field. Harder to balance. |

**Recommendation**: Uniform base strength of 1. Phalanx is "maximally simple." Tactical depth should emerge from formation, not stat variety.

#### B. Side Cohesion Bonus

"Side cohesion" means adjacent allies facing the same direction form a shield wall.

| Option | Bonus | Pros | Cons |
|--------|-------|------|------|
| **+1 per adjacent ally (recommended)** | +1 | Simple counting. Max theoretical +6 (all neighbors). Rewards tight formations. | Could become dominant if flanking penalty is weak. |
| +0.5 per adjacent ally | +0.5 | Weaker incentive to blob. Leaves room for depth bonus. | Fractional math. Less intuitive. |
| +1 for first ally, +0 thereafter | +1 max | Prevents stacking. | Removes incentive for larger formations. |

**Recommendation**: +1 per adjacent ally (same facing). Simple. Powerful enough to matter. Cap discussion below.

#### C. Depth Bonus (Rear Support)

"Depth" means a unit directly behind, facing the same direction, adds push weight.

| Option | Bonus | Pros | Cons |
|--------|-------|------|------|
| **+1 per rear ally (recommended)** | +1 | Symmetric with side bonus. Rewards lines 2-3 deep. | If uncapped, infinite depth wins. |
| +2 for first rear ally only | +2 | Strong single-push incentive. Prevents infinite stacking. | Binary choice (have support or don't). |
| +1 first, +0.5 each additional | +1, +0.5, +0.5... | Diminishing returns. Realistic. | More complex formula. |

**Recommendation**: +1 per rear ally, capped at +2. Rewards depth without infinite stacking. A three-deep column reaches max rear bonus.

#### D. Bonus Cap

| Option | Cap | Pros | Cons |
|--------|-----|------|------|
| **Global cap of +4 (recommended)** | +4 total bonus | Bounds maximum force at 5. Prevents blob-wins-all. | Requires tracking total. |
| Separate caps (side: +3, rear: +2) | +3 side, +2 rear | Explicit constraints per bonus type. | More rules to remember. |
| No cap | Unlimited | Simplest rule. | Degenerate blob strategy. |

**Recommendation**: Total bonus capped at +4 (force max = 5). Side and rear bonuses compete for the same cap. This forces a tradeoff: wide formation vs deep formation.

#### E. Same Facing Definition

When does an ally count as "same facing"?

| Option | Definition | Pros | Cons |
|--------|------------|------|------|
| **Exact match (recommended)** | Rotation identical (e.g., both 60) | Clear. Binary. No ambiguity. | Units rotated by 60 don't support each other. |
| Within 60 | Rotation differs by at most 60 | More forgiving. Diagonal lines still cohere. | Fuzzier. Harder to reason about. |

**Recommendation**: Exact match. A phalanx is soldiers facing precisely the same direction. Misalignment breaks the wall.

#### F. Flanking Effect on Defender Bonuses

When attacked from the side or rear, does the defender lose formation bonuses?

| Option | Effect | Pros | Cons |
|--------|--------|------|------|
| **Bonuses apply normally** | Defender keeps all bonuses | Simpler. Flanking advantage is attacker's higher force, not defender's lower force. | Flanking feels less devastating. |
| **Flanking negates formation (recommended)** | Defender loses side/rear bonuses from the attacked direction | Historically accurate: shields don't help from behind. Creates strong flanking incentive. | More complex. Must track attack direction. |
| Flanking halves formation | Defender bonuses halved | Middle ground. | Fractional math. |

**Recommendation**: Flanking negates bonuses on the attacked side. If attacked from flank, defender's side-cohesion allies on that flank don't count. If attacked from rear, rear allies don't count. Front allies still count. This creates tactical asymmetry.

---

## 3. Which key code changes do you need to make?

+++ #### Force

Force calculation module. Pure functions, no state.

`lib/phalanx/force.ex`

```elixir
defmodule Phalanx.Force do
  @base_strength 1
  @max_bonus 4

  @type direction_class :: :front | :flank | :rear
  @type force_result :: %{
    base: integer(),
    side_bonus: integer(),
    rear_bonus: integer(),
    total: integer()
  }

  @spec calculate(unit :: map(), position :: tuple(), units :: map(), attack_direction :: atom() | nil) :: force_result()

  @spec classify_direction(unit_rotation :: integer(), neighbor_direction :: atom()) :: direction_class()

  @spec get_neighbors(position :: tuple(), map_dimensions :: tuple()) :: [{atom(), tuple()}]

  @spec count_side_allies(unit :: map(), position :: tuple(), units :: map()) :: integer()

  @spec count_rear_allies(unit :: map(), position :: tuple(), units :: map()) :: integer()

  @spec same_facing?(unit1 :: map(), unit2 :: map()) :: boolean()
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

Integrate force comparison into conflict resolution.

`lib/phalanx/engine/engine_diplomacy.ex`

```elixir
defmodule Phalanx.Engine.Diplomacy do
  # Existing functions...

  @spec resolve_contested_hex(
    state :: map(),
    hex :: tuple(),
    contestants :: [{tuple(), map(), atom()}]  # {from_pos, unit, direction}
  ) :: {:winner, tuple()} | :mutual_balk

  @spec calculate_attack_force(
    state :: map(),
    attacker_pos :: tuple(),
    target_hex :: tuple(),
    attack_direction :: atom()
  ) :: integer()

  @spec calculate_defense_force(
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

### Force Calculation Formula

```
Force = Base + min(SideBonus + RearBonus, MaxBonus)

Where:
  Base = 1
  SideBonus = count of adjacent allies with exact same rotation
  RearBonus = count of rear allies with exact same rotation (max 2 counted)
  MaxBonus = 4
```

**Defender adjustment for flanking**:

```
If attacked from flank:
  SideBonus excludes allies on the attacked flank direction

If attacked from rear:
  RearBonus = 0
```

### Example Scenarios

**Scenario 1: Head-on collision**

```
  [A→]  vs  [←B]

  A attacks east, B attacks west (or holds)

  If both isolated:
    A force = 1, B force = 1 → mutual balk

  If A has ally behind:
    A force = 1 + 1 (rear) = 2
    B force = 1 → A wins, B dislodged
```

**Scenario 2: Flanking attack**

```
       [C→]
         ↓
  [A→][B→]

  C attacks south into hex occupied by B
  B faces east, C attacks from flank (north)

  C force = 1 (attacker, no allies)
  B force = 1 base + 1 (A is adjacent, same facing)
          - but A is on B's flank, not the attacked side
          = 2 total

  C needs allies to dislodge B.
```

**Scenario 3: Rear attack**

```
  [A→][B→]
          ↑
         [C←]

  C attacks west into B from B's rear

  C force = 1
  B force = 1 base + 1 (A adjacent) + 0 (rear bonus negated by rear attack) = 2

  Still hard to dislodge, but B loses any rear support bonus.
```

---

## 4. What's the PR roadmap?

1. **PR #1: Force module foundation**
   1. Add `all_neighbors/2` to `Phalanx.Moves`
   2. Create `Phalanx.Force` with `classify_direction/2`
   3. Implement `same_facing?/2`
   4. Tests for direction classification across all rotations

2. **PR #2: Bonus calculation**
   1. Implement `count_side_allies/3`
   2. Implement `count_rear_allies/3`
   3. Implement `calculate/4` with bonus cap
   4. Tests for bonus counting and cap enforcement

3. **PR #3: Engine integration**
   1. Modify `detect_conflicts/1` to identify contested hexes
   2. Add `resolve_contested_hex/3` with force comparison
   3. Replace mutual-balk with winner determination
   4. Integration tests for attack resolution

---

## 5. What are open questions?

1. **Defender reaction**: When a stationary unit is attacked, does it count as "attacking back" for force purposes, or is defense purely passive?

2. **Multiple attackers**: If two units attack the same hex from different directions, do their forces combine against the defender?

3. **Retreat direction**: When dislodged, which direction does the unit retreat? Opposite of attack? Player choice?

4. **Support chain validation**: If a rear supporter is themselves under attack, does their support still count? (MECHANICS.md suggests no: "support is nulled if the supporting unit is attacked")

5. **Rotation timing interaction**: Attack resolves before rotation. If a unit rotates this turn, which facing determines their force calculation—pre-rotation or post-rotation?
