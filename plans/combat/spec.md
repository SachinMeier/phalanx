# 2026-01-26: Combat Resolution System

**Author**: [leave blank]
**Approved By**: [leave blank]

---

## 1. What's the problem you're trying to solve?

**Casual**: Units can move and rotate, but they pass through each other like ghosts. When two units collide, both balk. No blood. No consequence.

**Formal**:
1. `Engine.Diplomacy` converts all collisions to mutual balk; no dislodgement occurs
2. Unit health (currently 3) is never modified
3. No strength calculation exists (base, formation, support)
4. No damage rules exist (flank, rear, dislodge penalties)

**Out of Scope**:
* **Energy system**: Separate spec
* **Phalanx grouping**: Atomic movement rules covered in group/ spec
* **Win conditions**: Depends on combat outcomes but is not combat itself
* **Unit types**: All units are identical hoplites for now

## 2. What's the simplest solution to solve the problem?

The main parts of the solution are:

1. **Strength Calculation**: Base strength + formation bonus + support bonus
2. **Dislodge Resolution**: Compare strength; strictly greater wins, ties standoff
3. **Damage Application**: Attack angle determines damage (frontal=0, flank=1, rear=2 HP)
4. **Retreat Execution**: Dislodged units retreat or are destroyed

---

### Design Decision 1: Combat Model

**Chosen**: Hybrid (Dislodge + Angle-Based Damage)

Strength comparison determines dislodge (Diplomacy rules). Damage depends on attack angle, not just dislodge. Units at 0 HP are destroyed.

**Damage stacks:** Dislodge costs 1 HP, plus angle-based damage.

| Attack Angle | Angle Damage | Total on Dislodge |
|--------------|--------------|-------------------|
| Frontal (front 2 edges) | 0 (shields block) | 1 HP |
| Flank (middle 2 edges) | +1 | 2 HP |
| Rear (back 2 edges) | +2 | 3 HP |

**Flanking affects DAMAGE only, not strength.** Strength determines who wins. Dislodge costs 1 HP plus angle-based bonus damage.

**Why**: Models historical phalanx warfare - shields protect the front, casualties come from exposed sides/rear. Encourages flanking maneuvers as the path to victory.

---

### Design Decision 2: Collision Geometry

**Chosen**: Destination-only collision (existing Diplomacy behavior)

Units collide if and only if they target the same hex. No new collision types.

**Why**: Already implemented in `Engine.Diplomacy`. Simple for players to predict.

---

### Design Decision 3: Attack Declaration

**Chosen**: Target-based implicit attack

Order specifies direction. If that direction leads to an enemy-occupied hex, it is an attack. If empty, it is a move.

- Current order structure unchanged (position, move_direction, rotation)
- Engine determines attack vs move based on destination contents
- Attack into occupied hex = combat
- Move into empty hex = movement

**Friendly collision**: Pushing support (adds strength to that unit's attack if it is also attacking same direction). Otherwise: standoff.

---

### Design Decision 4: Strength Calculation

**Base strength**: 1 (all units equal)

**Formation bonus** (2D phalanx): A phalanx is explicitly declared during battle. ALL adjacent allies (side positions AND rear positions) within the same declared phalanx provide strength bonuses. Side allies max +2 (geometry). Rear allies have no cap (deep formations are powerful but flankable). See Strength spec for calculation.

**Phalanx declaration**: Phalanxes are player-declared, not auto-detected. Declaration requires:
1. All units in same group (groups are fixed at battle start)
2. All units adjacent (connected)
3. All units same rotation
4. Declaration happens during order phase, before movement resolution

**CRITICAL**: Formation bonuses are NEVER cut. If A and C are in a declared phalanx moving together, and D attacks C, A still gets the formation bonus from C. C may take damage, but A's strength is unchanged.

**Phalanx atomic movement**: All units in a declared phalanx move together or all balk. This is ALL-OR-NOTHING: if ANY member would balk (due to collision, invalid destination, etc.), the ENTIRE phalanx balks. No majority rule.

**Pushing support** (Diplomacy-style): Allies pushing from behind who are NOT in the same formation provide +1 to attack, up to +2 max. This support CAN be cut.

**Combined attacks**: When multiple allies attack the same enemy hex, their forces ADD together. The first unit ordered to attack that hex is the "lead" and moves in upon victory; other attackers hold their original positions.

**Support cutting** (pushing support only): If a pushing supporter (not in same formation) is attacked by any unit **other than**:
1. The unit the supporter is helping to attack, or
2. The unit the supporter itself is targeting

...then the pushing support is voided. Formation bonuses are never affected.

| Bonus Type | Source | Can Be Cut? |
|------------|--------|-------------|
| Formation bonus | Adjacent allies in same declared phalanx | **NEVER** |
| Pushing support | Non-phalanx ally pushing behind | **YES** (Diplomacy rules) |

**Flanking damage**: Dislodge costs 1 HP plus angle-based bonus damage. Flanking does NOT affect strength—only damage.

| Attack angle | Angle Bonus | Total on Dislodge |
|--------------|-------------|-------------------|
| Frontal (front 2 edges) | +0 (shields block) | 1 HP |
| Flank (middle 2 edges) | +1 | 2 HP |
| Rear (back 2 edges) | +2 | 3 HP |

**Key distinction**: Strength determines WHO wins. Dislodge always costs 1 HP; attack angle adds bonus damage.

---

### Design Decision 5: Dislodge Resolution

**Rules** (from Diplomacy):

1. **Ties = standoff**: Equal strength means nobody moves
2. **Strictly greater wins**: Attacker strength > defender strength = dislodge
3. **Mutual attack**: Both units attacking each other = compare strengths, loser retreats
4. **Self-dislodge forbidden**: You cannot dislodge your own units

**Simultaneous Resolution Order**:

1. Calculate all movements (determine each unit's intended destination)
2. Populate holds (units without orders hold position)
3. Identify conflicts (group by destination)
4. Calculate strength (for each conflict, compute attacker and defender strength)
5. Resolve conflicts:
   - If tie: all involved units balk
   - If winner: winner moves, loser is dislodged
6. Apply damage based on attack angle (frontal=0, flank=1, rear=2 HP)
7. Execute retreats (dislodged units move to valid retreat hex or die)

**Three-way collision**: Highest strength wins. If multiple units share highest strength, all balk.

---

### Design Decision 6: Retreat Rules

**Chosen**: Deterministic retreat in the same direction as the attack.

**Retreat direction algorithm**:
1. Identify the **lead attacker** (first-ordered unit attacking this hex)
2. Determine the direction the lead attack came from (e.g., northeast)
3. **Primary retreat**: the hex in the same direction as the attack (e.g., if attacked from NE → retreat NE)
4. **Fallback retreat**: if primary hex is invalid, use one of the defender's two adjacent backward directions based on facing

**Valid retreat hexes** must be:
- Empty (unoccupied)
- Not a standoff hex (where a tie occurred this turn)
- Not off the map

**Fallback direction**: Based on defender's facing. For a unit facing E (rotation 0°), the two adjacent backward hexes are NW and SW. If the primary retreat (same as attack direction) is blocked, try one of these based on facing.

**Multiple attackers**: Retreat direction is determined by the **lead attacker only**. Other attackers do not affect retreat direction.

If primary and fallback retreat hexes are both invalid: unit destroyed.

**Cascade dislodge**: Retreats happen after all movement resolves. Retreating into an empty hex is valid if that hex was empty at end of movement phase.

**Retreat example**:
```
Lead attacker attacks from NE:
  [A]→ attacks [D]
        ↓
       NE (primary retreat - same direction as attack)

If NE blocked, D retreats to adjacent backward hex based on D's facing.
```

**Mutual attack at equal strength**: Neither dislodges. Both hold position. No damage dealt.

---

## 3. Which key code changes do you need to make?

+++ #### Engine.Combat

New engine implementation extending Diplomacy with combat resolution.

`lib/phalanx/engine/engine_combat.ex`

```elixir
defmodule Phalanx.Engine.Combat do
  @behaviour Phalanx.Engine

  @impl Phalanx.Engine
  @spec execute_orders(state :: Phalanx.Game.t(), orders :: map()) :: Phalanx.Game.t()
end
```

+++

+++ #### Combat.Strength

Calculates combat strength from base + support + flanking.

`lib/phalanx/combat/strength.ex`

```elixir
defmodule Phalanx.Combat.Strength do
  @type position :: {integer(), integer()}

  @spec calculate(state :: Phalanx.Game.t(), attacker :: position(), defender :: position(), direction :: atom()) :: integer()

  @spec supporting_allies(state :: Phalanx.Game.t(), position :: position(), direction :: atom()) :: list(position())

  @spec cut_supports(attacks :: list({position(), position()})) :: MapSet.t(position())

  @spec flanking_bonus(defender_rotation :: integer(), attack_from_direction :: atom()) :: integer()
end
```

+++

+++ #### Combat.Retreat

Determines retreat hex and executes retreat. Retreat is deterministic: same direction as attack, fallback to adjacent backward direction.

`lib/phalanx/combat/retreat.ex`

```elixir
defmodule Phalanx.Combat.Retreat do
  @type position :: {integer(), integer()}
  @type retreat_result :: {:ok, position()} | :destroyed

  @spec calculate_retreat_hex(
    state :: Phalanx.Game.t(),
    dislodged_pos :: position(),
    attack_from_direction :: atom(),
    unit_rotation :: integer(),
    standoff_hexes :: MapSet.t(position())
  ) :: {:ok, position()} | :no_valid_retreat
  # Returns primary retreat (same direction as attack) or fallback (adjacent backward direction)
  # Returns :no_valid_retreat if both blocked

  @spec primary_retreat_direction(attack_from_direction :: atom()) :: atom()
  # Returns the same direction (e.g., attack from :northeast -> retreat to :northeast)

  @spec fallback_retreat_direction(unit_rotation :: integer(), primary_direction :: atom()) :: atom()
  # Returns the unit's other backward direction based on its facing

  @spec execute(
    state :: Phalanx.Game.t(),
    dislodged_unit :: position(),
    retreat_hex :: position() | nil
  ) :: {Phalanx.Game.t(), retreat_result()}
end
```

+++

+++ #### Unit

Extract unit struct from inline maps; add damage helpers.

`lib/phalanx/unit.ex`

```elixir
defmodule Phalanx.Unit do
  @type t :: %__MODULE__{
    name: String.t(),
    health: integer(),
    rotation: integer(),
    color: String.t()
  }

  defstruct [:name, :health, :rotation, :color]

  @spec new(name :: String.t(), color :: String.t()) :: t()
  @spec apply_damage(unit :: t(), amount :: integer()) :: t()
  @spec alive?(unit :: t()) :: boolean()
end
```

+++

+++ #### Moves (updated)

Add helpers for angle calculation and direction opposites.

`lib/phalanx/moves.ex`

```elixir
# Add to existing module:

@spec opposite_direction(direction :: atom()) :: atom()

@spec angle_between(dir_a :: atom(), dir_b :: atom()) :: integer()

@spec direction_from_hex(from :: position(), to :: position()) :: atom()
```

+++

## 4. What's the PR roadmap?

1. **PR #1: Unit struct and health tracking**
   1. Extract `Phalanx.Unit` module from inline maps
   2. Add `apply_damage/2` and `alive?/1` functions
   3. Update `Phalanx.Helpers.default_units/0` to use struct
   4. Update `Phalanx.Game` type to use `%Unit{}` in units map

2. **PR #2: Strength calculation**
   1. Implement `Phalanx.Combat.Strength.calculate/4`
   2. Implement `supporting_allies/3` with adjacent-same-direction logic
   3. Implement `cut_supports/1` for attack-based support nullification
   4. Implement `flanking_bonus/2` for angle-based attacker bonus
   5. Add tests for strength scenarios

3. **PR #3: Retreat system**
   1. Implement `Phalanx.Combat.Retreat.valid_retreats/4`
   2. Implement random retreat selection
   3. Add destruction logic when no valid retreat
   4. Add tests for edge cases (map boundary, blocked hexes)

4. **PR #4: Combat engine integration**
   1. Implement `Phalanx.Engine.Combat` module
   2. Resolution order: movements -> conflicts -> strength -> dislodge -> damage -> retreats
   3. Config switch: `:engine, Phalanx.Engine.Combat`
   4. Integration tests for multi-unit combat scenarios

5. **PR #5: UI updates**
   1. Display health on unit SVG
   2. Show damage numbers after resolution
   3. Animate retreat movement
   4. Death animation for destroyed units

## 5. What are open questions?

1. **Retreat order phase**: **RESOLVED** - Deterministic retreat (same direction as attack, fallback to adjacent backward direction). No player choice needed.

---

## References

- [Diplomacy Rules - Ultra Board Games](https://www.ultraboardgames.com/diplomacy/game-rules.php)
- [Play Diplomacy Online - Game Rules](https://www.playdiplomacy.com/help.php?sub_page=Game_Rules)
