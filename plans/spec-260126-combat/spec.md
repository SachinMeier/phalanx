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
* **Phalanx grouping**: Atomic movement and majority-dislodge rules require separate spec
* **Win conditions**: Depends on combat outcomes but is not combat itself
* **Unit types**: All units are identical hoplites for now

## 2. What's the simplest solution to solve the problem?

The main parts of the solution are:

1. **Strength Calculation**: Base strength + support bonus for pushing units
2. **Dislodge Resolution**: Compare strength; strictly greater wins, ties standoff
3. **Damage Application**: Dislodge costs 1 HP; flanking grants attacker bonus strength
4. **Retreat Execution**: Dislodged units retreat or are destroyed

---

### Design Decision 1: Combat Model

**Chosen**: Hybrid (Dislodge + Minimal HP)

Strength comparison determines dislodge (Diplomacy rules). Being dislodged costs 1 HP. Units at 0 HP are destroyed.

| Condition | HP Lost |
|-----------|---------|
| Dislodged | -1 |

Flanking affects strength, not damage. A flanking attacker gets +1 strength (flank) or +2 strength (rear). Defender keeps all bonuses.

**Why**: Creates tactical depth while keeping damage rules minimal. Flanking helps you win the dislodge contest rather than adding damage stacking complexity.

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

**Support**: Any adjacent ally moving same direction adds +1 to your attack, up to +2 max.

- Check all 6 adjacent hexes
- Count allies with same movement direction
- Cap at +2

**Support cutting**: If a supporting unit is attacked, its support is nullified.

**Flanking bonus**: Attacker gains strength based on attack angle relative to defender facing.

| Attack angle | Attacker bonus |
|--------------|----------------|
| Frontal (front 2 edges) | +0 |
| Flank (middle 2 edges) | +1 |
| Rear (back 2 edges) | +2 |

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
6. Apply damage (1 HP to dislodged units)
7. Execute retreats (dislodged units move to valid retreat hex or die)

**Three-way collision**: Highest strength wins. If multiple units share highest strength, all balk.

---

### Design Decision 6: Retreat Rules

**Chosen**: Any adjacent empty hex except:
- The hex the attack came from
- Any hex where a standoff occurred this turn

If multiple valid retreats: random selection. If none valid: unit destroyed.

**Cascade dislodge**: Retreats happen after all movement resolves. Retreating into an empty hex is valid if that hex was empty at end of movement phase.

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

Determines valid retreat hexes and executes retreat.

`lib/phalanx/combat/retreat.ex`

```elixir
defmodule Phalanx.Combat.Retreat do
  @type position :: {integer(), integer()}
  @type retreat_result :: {:ok, position()} | :destroyed

  @spec valid_retreats(
    state :: Phalanx.Game.t(),
    position :: position(),
    attack_from :: position(),
    standoff_hexes :: MapSet.t(position())
  ) :: list(position())

  @spec execute(
    state :: Phalanx.Game.t(),
    dislodged_unit :: position(),
    valid_hexes :: list(position())
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

1. **Retreat order phase**: Should players choose retreat direction, or is random acceptable? Player choice requires async retreat phase.

---

## References

- [Diplomacy Rules - Ultra Board Games](https://www.ultraboardgames.com/diplomacy/game-rules.php)
- [Play Diplomacy Online - Game Rules](https://www.playdiplomacy.com/help.php?sub_page=Game_Rules)
