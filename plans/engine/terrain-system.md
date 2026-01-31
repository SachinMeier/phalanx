# 2026-01-27: Terrain System Design

**Author**: Claude
**Status**: Draft

---

> **⚠️ FUTURE WORK - NOT IN CURRENT SCOPE**
>
> This spec describes terrain features for future versions of Phalanx.
> The initial release uses a **flat, uniform hex grid** where all hexes are identical.
> No terrain affects movement, combat, or strategy in v1.
>
> Implement core game mechanics first. Revisit this spec after the base game is complete.

---

## 1. Problem Statement

**Current state**: Flat 10x10 hex grid. All hexes are identical. No terrain affects movement, combat, or strategy.

**Goal (FUTURE)**: Add terrain variety that creates tactical depth without overwhelming the core phalanx mechanics.

**Constraints**:
- Historically, phalanxes required flat ground; rough terrain broke formations
- High ground was tactically important in ancient warfare
- Must integrate cleanly with existing movement, grouping, and combat systems
- Keep v1 minimal; expand later

---

## 2. Terrain Types

### V1: Passable vs Impassable

Start with the simplest distinction.

| Type | Description | Movement | Combat | Formations |
|------|-------------|----------|--------|------------|
| **Clear** | Default hex | Normal | Normal | Normal |
| **Impassable** | Walls, water, cliffs | Cannot enter | Cannot attack through | N/A |

**Impassable rationale**: Creates natural chokepoints and map structure. No complex mechanics.

### V2: Difficult Terrain (Future)

| Type | Movement Cost | Formation Effect | Combat Modifier |
|------|--------------|------------------|-----------------|
| **Rough** | -1 energy extra | Breaks adjacency for phalanx formation | -1 formation bonus while occupying |
| **Marsh** | -1 energy extra | Cannot form phalanx | -1 defense |

**Formation breaking**: Units in rough terrain are not considered adjacent for phalanx formation. A phalanx cannot include units in rough terrain. Existing phalanxes break if a member enters rough terrain.

### V3: Elevation (Future)

| Height | Attack Up | Attack Down | Defense Bonus |
|--------|-----------|-------------|---------------|
| **High ground** | +1 attack when attacking downhill | N/A | +1 defense when attacked from below |
| **Low ground** | N/A | -1 attack when attacking uphill | N/A |

**Height levels**: 0 (normal), 1 (elevated). Binary for simplicity. No multi-level terrain.

---

## 3. Data Representation

### V1: Simple Terrain Map

Add terrain to game state. Separate from units.

```elixir
defmodule Phalanx.Terrain do
  @type terrain_type :: :clear | :impassable

  @type t :: %{
    {integer(), integer()} => terrain_type()
  }

  @spec passable?(terrain :: t(), position :: {integer(), integer()}) :: boolean()
  def passable?(terrain, position) do
    Map.get(terrain, position, :clear) != :impassable
  end
end
```

### Game State Extension

```elixir
defmodule Phalanx.Game do
  @type t :: %__MODULE__{
    id: String.t(),
    status: status(),
    turn: non_neg_integer(),
    players: list(Phalanx.Player.t()),
    units: map(),
    terrain: Phalanx.Terrain.t(),  # NEW
    map_dimensions: {pos_integer(), pos_integer()},
  }
end
```

### V2: Richer Terrain Data

For future terrain types with modifiers:

```elixir
@type terrain_type :: :clear | :impassable | :rough | :marsh | :elevated

@type terrain_hex :: %{
  type: terrain_type(),
  elevation: 0 | 1,  # V3
  modifiers: map()   # V3: custom per-hex effects
}

@type t :: %{
  {integer(), integer()} => terrain_hex()
}
```

---

## 4. Map Configuration

### V1: Hardcoded Maps

Store map definitions in code. Simplest approach.

```elixir
defmodule Phalanx.Maps do
  @spec get_map(name :: atom()) :: %{
    dimensions: {integer(), integer()},
    terrain: Phalanx.Terrain.t(),
    spawn_points: %{red: [position()], purple: [position()]}
  }

  def get_map(:thermopylae) do
    %{
      dimensions: {10, 10},
      terrain: %{
        # Water on left edge
        {0, 0} => :impassable,
        {0, 1} => :impassable,
        {0, 2} => :impassable,
        # ...
        # Cliffs on right edge
        {9, 0} => :impassable,
        {9, 1} => :impassable,
        # Central pass is clear (default)
      },
      spawn_points: %{
        red: [{3, 2}, {4, 2}, {5, 2}, {6, 2}, {7, 2}],
        purple: [{3, 7}, {4, 7}, {5, 7}, {6, 7}, {7, 7}]
      }
    }
  end

  def get_map(:open_field) do
    %{
      dimensions: {10, 10},
      terrain: %{},  # All clear
      spawn_points: %{
        red: [{3, 2}, {4, 2}, {5, 2}, {6, 2}, {7, 2}],
        purple: [{3, 7}, {4, 7}, {5, 7}, {6, 7}, {7, 7}]
      }
    }
  end
end
```

### V2: JSON/External Maps (Future)

Store maps as JSON files for easier editing.

```json
{
  "name": "thermopylae",
  "dimensions": [10, 10],
  "terrain": {
    "0,0": "impassable",
    "0,1": "impassable",
    "9,8": "elevated"
  },
  "spawn_points": {
    "red": [[3, 2], [4, 2]],
    "purple": [[3, 7], [4, 7]]
  }
}
```

Load at startup from JSON file.

### V3: Procedural Generation (Future)

Generate maps with constraints:
- Guarantee path between spawn areas
- Ensure fair symmetry (rotational or mirror)
- Control chokepoint count

---

## 5. Integration Points

### Movement Validation

`Phalanx.Moves.move/4` must check terrain.

```elixir
def move(map_dimensions, terrain, current_position, rotation, abs_direction) do
  new_position = oddr_offset_neighbor(map_dimensions, current_position, rotation, abs_direction)

  cond do
    not direction_allowed?(rotation, abs_direction) ->
      {:error, :invalid_direction}

    not tile_on_map?(map_dimensions, new_position) ->
      {:error, :off_map}

    not Phalanx.Terrain.passable?(terrain, new_position) ->
      {:error, :impassable}

    true ->
      {:ok, new_position}
  end
end
```

**Signature change**: `move/4` becomes `move/5` (add terrain parameter).

### Engine Integration

`Engine.Combat.validate_orders/3` must pass terrain to move validation.

Phase 2 (Order Validation):
```elixir
defp validate_orders(orders, snapshot, map_dimensions, terrain) do
  # Existing validation + terrain check
  Enum.map(orders, fn {position, order} ->
    case validate_single_order(position, order, snapshot, map_dimensions, terrain) do
      :ok -> {position, order}
      :invalid -> {position, Order.null_order(position)}
    end
  end)
  |> Map.new()
end
```

### Conflict Detection

Impassable terrain cannot be a destination. Orders targeting impassable hexes should be rejected in Phase 2, not create conflicts in Phase 4.

### Grouping Detection

V1: No change. Impassable hexes don't affect adjacency.

V2: Units in rough terrain are not adjacent to their neighbors for group detection purposes.

```elixir
def adjacent_for_grouping?(terrain, pos_a, pos_b) do
  hex_adjacent?(pos_a, pos_b) and
    Terrain.allows_formation?(terrain, pos_a) and
    Terrain.allows_formation?(terrain, pos_b)
end
```

### Combat Resolution

V1: No combat modifiers from terrain.

V2: Terrain affects strength calculation:
```elixir
def calculate_defense_strength(state, defender_pos) do
  base = @base_strength
  formation = count_formation_bonus(state, defender_pos)
  terrain = terrain_defense_bonus(state.terrain, defender_pos)

  base + formation + terrain
end
```

---

## 6. Rendering

### Hex Component Update

`PhalanxWeb.Components.Hex.hex_tile/1` must render terrain.

```elixir
defp hex_tile(assigns) do
  terrain_type = Map.get(@terrain, {@x, @y}, :clear)
  terrain_class = terrain_class(terrain_type)

  ~H"""
  <div class={"hex-tile #{terrain_class}"}>
    <%= case Map.get(@units, {@x, @y}) do %>
      <% nil -> %>
        <div class="terrain-marker">
          <%= terrain_marker(terrain_type) %>
        </div>
      <% unit -> %>
        <.unit_svg current_unit={@current_unit} x={@x} y={@y} unit={unit} />
    <% end %>
  </div>
  """
end

defp terrain_class(:clear), do: "bg-black"
defp terrain_class(:impassable), do: "bg-slate-800"
defp terrain_class(:rough), do: "bg-amber-900"
defp terrain_class(:elevated), do: "bg-stone-600"

defp terrain_marker(:impassable), do: "~"  # Water waves or X
defp terrain_marker(:elevated), do: "^"     # Mountain peak
defp terrain_marker(_), do: ""
```

### CSS Updates

Add terrain colors to hex tiles. Use Tailwind classes where possible.

```css
.hex-tile.terrain-water {
  background: linear-gradient(135deg, #1e3a5f, #0f172a);
}

.hex-tile.terrain-cliff {
  background: linear-gradient(to top, #44403c, #78716c);
}

.hex-tile.terrain-elevated {
  background: #57534e;
  box-shadow: inset 0 2px 4px rgba(255,255,255,0.1);
}
```

---

## 7. Design Decisions

### Q1: Line of sight?

**Options**:
| Option | Pros | Cons |
|--------|------|------|
| **No LOS (V1)** | Simpler. Full visibility. | Less tactical depth. |
| LOS blocking | More realistic. Creates ambush opportunities. | Complex to calculate. UI unclear. |

**Decision**: No LOS for V1. Fog of war and LOS are separate features. Terrain visibility can be added later without changing core mechanics.

### Q2: Can units attack across impassable terrain?

**Options**:
| Option | Effect |
|--------|--------|
| **No (V1)** | Impassable completely blocks interaction |
| Yes (ranged only) | Future ranged units could shoot over obstacles |

**Decision**: No for V1. All combat is melee. Impassable hexes fully separate the battlefield.

### Q3: Energy cost for difficult terrain?

**Options**:
| Option | Energy Cost |
|--------|-------------|
| +0 (no extra) | Rough terrain is purely a formation penalty |
| **+1 (double cost, V2)** | Moving into rough terrain costs 2 energy total |
| Blocks movement | Too restrictive |

**Decision**: +1 extra energy for difficult terrain in V2. This creates exhaustion when maneuvering through rough ground, historically accurate.

### Q4: Retreat into impassable terrain?

**Decision**: No. Units cannot retreat into impassable hexes. If no valid retreat exists, unit is destroyed. This makes chokepoints extremely dangerous - defenders can be pinned against walls.

### Q5: Map selection mechanism?

**Options**:
| Option | Complexity |
|--------|------------|
| **Hardcoded default** | Minimal |
| Player selects from list | Moderate |
| Random from pool | Moderate |
| Procedural generation | High |

**Decision**: Hardcoded default for V1 (open field or simple chokepoint). Add map selection UI in V2.

---

## 8. Example Maps

### Open Field (Default)

10x10, all clear. Current behavior. No terrain effects.

```
  0 1 2 3 4 5 6 7 8 9
0 . . . . . . . . . .
1 . . . . . . . . . .
2 . . . R R R R R . .
3 . . . . . . . . . .
4 . . . . . . . . . .
5 . . . . . . . . . .
6 . . . . . . . . . .
7 . . . P P P P P . .
8 . . . . . . . . . .
9 . . . . . . . . . .
```

### Thermopylae (Narrow Pass)

Coastal terrain forces units through central chokepoint.

```
  0 1 2 3 4 5 6 7 8 9
0 ~ ~ ~ . . . . X X X
1 ~ ~ . . . . . . X X
2 ~ . . R R R R R . X
3 ~ . . . . . . . . X
4 ~ ~ . . . . . . X X
5 ~ ~ . . . . . . X X
6 ~ . . . . . . . . X
7 ~ . . P P P P P . X
8 ~ ~ . . . . . . X X
9 ~ ~ ~ . . . . X X X

Legend: ~ = water (impassable), X = cliff (impassable), . = clear
```

### Twin Hills (Elevated Terrain, V3)

Two hills create defensive positions.

```
  0 1 2 3 4 5 6 7 8 9
0 . . . . . . . . . .
1 . . ^ ^ . . ^ ^ . .
2 . . ^ R R R R ^ . .
3 . . . . . . . . . .
4 . . . . . . . . . .
5 . . . . . . . . . .
6 . . . . . . . . . .
7 . . ^ P P P P ^ . .
8 . . ^ ^ . . ^ ^ . .
9 . . . . . . . . . .

Legend: ^ = elevated, . = clear
```

---

## 9. Test Scenarios

### Movement Tests

| ID | Setup | Order | Expected |
|----|-------|-------|----------|
| T-M-01 | Unit at (3,3), impassable at (4,3) | Move E | Order rejected, unit holds |
| T-M-02 | Unit at (3,3), rough at (4,3) | Move E | Move succeeds, -2 energy (V2) |
| T-M-03 | Unit at (3,3), elevated at (4,3) | Move E | Move succeeds (V3: normal cost) |

### Combat Tests (V2+)

| ID | Setup | Action | Expected |
|----|-------|--------|----------|
| T-C-01 | Attacker on high ground, defender on low | Attack downhill | +1 attacker strength |
| T-C-02 | Attacker on low ground, defender on high | Attack uphill | +1 defender strength |
| T-C-03 | Defender in rough terrain | Attacked | -1 formation bonus while in rough |

### Retreat Tests

| ID | Setup | Dislodge Direction | Expected |
|----|-------|-------------------|----------|
| T-R-01 | Unit at (2,1), impassable at (1,1)(3,1)(2,0)(2,2) | Any | Unit destroyed (no retreat) |
| T-R-02 | Unit at (2,1), impassable at (1,1) only | From E | Retreats to (3,1) or (2,0) or (2,2) |

### Group Tests (V2)

| ID | Setup | Expected |
|----|-------|----------|
| T-G-01 | Units at (3,3) and (4,3), rough at (4,3) | Not detected as group |
| T-G-02 | Units at (3,3) and (4,3), elevated at (4,3) | Detected as group (elevation doesn't break) |

---

## 10. Implementation Roadmap

### PR #1: Terrain Data Structures (V1)

1. Create `Phalanx.Terrain` module
   - `terrain_type` type
   - `passable?/2` function
2. Add `terrain` field to `Phalanx.Game` struct
3. Create `Phalanx.Maps` module with `get_map/1`
4. Add `:open_field` and `:thermopylae` map definitions
5. Update `Phalanx.Helpers.default_game/0` to include terrain
6. Tests for passability checks

### PR #2: Movement Integration (V1)

1. Update `Phalanx.Moves.move/4` signature to `move/5` (add terrain)
2. Add impassable check in movement validation
3. Update `Engine.Diplomacy.get_unit_movements/2` to pass terrain
4. Update `Engine.Combat` Phase 2 validation
5. Tests for movement rejection on impassable

### PR #3: Terrain Rendering (V1)

1. Pass terrain to `hex_grid/1` component
2. Add terrain-based background classes
3. Add terrain markers for empty impassable hexes
4. CSS for water/cliff visuals
5. Visual test on Thermopylae map

### PR #4: Map Selection (V2)

1. Add map selection to game creation flow
2. Store selected map name in game state
3. UI: dropdown or button grid for map choice
4. Load terrain from selected map on game start

### PR #5: Difficult Terrain (V2)

1. Add `:rough` and `:marsh` terrain types
2. Implement extra energy cost for difficult terrain
3. Implement formation-breaking for rough terrain
4. Update `Grouping.detect_groups/1` with terrain awareness
5. Tests for group breaking in rough terrain

### PR #6: Elevation (V3)

1. Add `:elevated` terrain type with height field
2. Implement attack/defense modifiers for elevation difference
3. Update `Strength.calculate_attack_strength/4` with elevation
4. Rendering: shadow/highlight for elevated hexes
5. Tests for elevation combat modifiers

---

## 11. Open Questions

1. **Spawning on terrain**: Can units spawn on rough terrain? Elevated terrain?
   - Tentative: Yes. Spawn points are always valid.

2. **Terrain damage**: Should rough terrain damage units over time (attrition)?
   - Tentative: No. Energy cost is sufficient penalty.

3. **Map editor**: Should we build a map editor?
   - Tentative: No for V1. JSON files suffice. Consider for V3.

4. **Symmetry requirement**: Must maps be symmetric for fairness?
   - Tentative: Yes for competitive play. Rotational symmetry (180 degrees) ensures balance.

---

## 12. Historical Considerations

### Phalanx and Terrain

Ancient Greek hoplite warfare favored flat terrain:

- **Rough ground broke formations**: Soldiers couldn't maintain shield-wall on uneven surfaces
- **High ground was decisive**: Charging downhill added momentum; defending uphill was easier
- **Chokepoints were strategic**: Thermopylae, Gates of Fire - narrow passes negated numerical superiority
- **Marshes trapped armies**: Heavy armor made extraction difficult

The terrain system should reward these historical tactics:
- Keeping formation on clear ground gives bonuses
- Rough terrain disrupts coordination (breaks groups)
- High ground provides advantage
- Chokepoints limit maneuver but concentrate force

### Design Principle

**Terrain rewards positioning, not just strength.**

A smaller force in a chokepoint can hold against a larger force on open ground. This creates strategic depth beyond pure strength calculation.
