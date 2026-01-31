# Phalanx Combat Engine - Implementation Guide
#
# This guide provides complete, idiomatic Elixir implementations for the
# combat engine system. Modules are organized by dependency order.
#
# Dependencies:
#   Hex -> Unit -> Group -> Strength -> Combat modules -> Engine.Combat

# =============================================================================
# 1. HEX UTILITIES
# =============================================================================

defmodule Phalanx.Hex do
  @moduledoc """
  Hex grid utilities for odd-r offset coordinates.
  Provides neighbor calculation, direction mapping, and angle computation.
  """

  @type position :: {integer(), integer()}
  @type direction :: :east | :northeast | :northwest | :west | :southwest | :southeast

  @directions [:east, :northeast, :northwest, :west, :southwest, :southeast]

  @even_row_offsets %{
    east: {1, 0},
    northeast: {0, -1},
    northwest: {-1, -1},
    west: {-1, 0},
    southwest: {-1, 1},
    southeast: {0, 1}
  }

  @odd_row_offsets %{
    east: {1, 0},
    northeast: {1, -1},
    northwest: {0, -1},
    west: {-1, 0},
    southwest: {0, 1},
    southeast: {1, 1}
  }

  @doc """
  Returns all 6 neighbors of a hex position with their directions.

  ## Example

      iex> Phalanx.Hex.all_neighbors({3, 2})
      [
        {:east, {4, 2}},
        {:northeast, {3, 1}},
        {:northwest, {2, 1}},
        {:west, {2, 2}},
        {:southwest, {2, 3}},
        {:southeast, {3, 3}}
      ]
  """
  @spec all_neighbors(position()) :: [{direction(), position()}]
  def all_neighbors({x, y}) do
    offsets = if rem(y, 2) == 0, do: @even_row_offsets, else: @odd_row_offsets

    Enum.map(@directions, fn dir ->
      {dx, dy} = Map.fetch!(offsets, dir)
      {dir, {x + dx, y + dy}}
    end)
  end

  @doc """
  Returns the neighbor position in a specific direction.
  """
  @spec neighbor(position(), direction()) :: position()
  def neighbor({x, y}, direction) do
    offsets = if rem(y, 2) == 0, do: @even_row_offsets, else: @odd_row_offsets
    {dx, dy} = Map.fetch!(offsets, direction)
    {x + dx, y + dy}
  end

  @doc """
  Determines the direction from one hex to an adjacent hex.
  Returns nil if hexes are not adjacent.

  ## Example

      iex> Phalanx.Hex.direction_between({3, 2}, {4, 2})
      :east
  """
  @spec direction_between(position(), position()) :: direction() | nil
  def direction_between(from, to) do
    all_neighbors(from)
    |> Enum.find_value(fn {dir, pos} -> if pos == to, do: dir end)
  end

  @doc """
  Returns the opposite direction.

  ## Example

      iex> Phalanx.Hex.opposite_direction(:east)
      :west
  """
  @spec opposite_direction(direction()) :: direction()
  def opposite_direction(dir) do
    case dir do
      :east -> :west
      :west -> :east
      :northeast -> :southwest
      :southwest -> :northeast
      :northwest -> :southeast
      :southeast -> :northwest
    end
  end

  @doc """
  Calculates the angle (in degrees) between two directions.
  Returns 0, 60, 120, or 180.

  ## Example

      iex> Phalanx.Hex.angle_between(:east, :west)
      180
  """
  @spec angle_between(direction(), direction()) :: 0 | 60 | 120 | 180
  def angle_between(dir_a, dir_b) do
    idx_a = direction_to_index(dir_a)
    idx_b = direction_to_index(dir_b)
    diff = abs(idx_a - idx_b)
    min(diff, 6 - diff) * 60
  end

  @doc """
  Checks if a position is within map boundaries.
  """
  @spec on_map?(position(), {pos_integer(), pos_integer()}) :: boolean()
  def on_map?({x, y}, {map_x, map_y}) do
    x >= 0 and y >= 0 and x < map_x and y < map_y
  end

  @spec direction_to_index(direction()) :: 0..5
  def direction_to_index(dir) do
    case dir do
      :east -> 0
      :northeast -> 1
      :northwest -> 2
      :west -> 3
      :southwest -> 4
      :southeast -> 5
    end
  end

  @spec index_to_direction(0..5) :: direction()
  def index_to_direction(idx) do
    Enum.at(@directions, idx)
  end

  @doc """
  Returns the front direction for a given unit rotation.
  Rotation 60 faces NE, 120 faces E, etc.
  """
  @spec rotation_to_front_direction(integer()) :: direction()
  def rotation_to_front_direction(rotation) do
    idx = div(rotation, 60)
    # Rotation 60 = NE (idx 1), 120 = E (idx 0), etc.
    front_idx = rem(7 - idx, 6)
    index_to_direction(front_idx)
  end
end

# =============================================================================
# 2. UNIT STRUCT
# =============================================================================

defmodule Phalanx.Unit do
  @moduledoc """
  Unit struct with health, energy, and combat helpers.
  Replaces inline maps in the units registry.
  """

  @type t :: %__MODULE__{
    name: String.t(),
    health: pos_integer(),
    energy: non_neg_integer(),
    rotation: non_neg_integer(),
    color: String.t()
  }

  @default_health 3
  @default_energy 3
  @max_energy 5

  defstruct [:name, :health, :energy, :rotation, :color]

  @doc """
  Creates a new unit with default health and energy.

  ## Example

      iex> Phalanx.Unit.new("Y", "red", 240)
      %Phalanx.Unit{name: "Y", health: 3, energy: 3, rotation: 240, color: "red"}
  """
  @spec new(String.t(), String.t(), non_neg_integer()) :: t()
  def new(name, color, rotation) do
    %__MODULE__{
      name: name,
      health: @default_health,
      energy: @default_energy,
      rotation: rotation,
      color: color
    }
  end

  @doc """
  Applies damage to a unit, reducing health.
  """
  @spec apply_damage(t(), pos_integer()) :: t()
  def apply_damage(%__MODULE__{health: h} = unit, amount) when amount > 0 do
    %{unit | health: max(0, h - amount)}
  end

  @doc """
  Modifies unit energy. Clamps to [0, max_energy].
  """
  @spec apply_energy_delta(t(), integer()) :: t()
  def apply_energy_delta(%__MODULE__{energy: e} = unit, delta) do
    new_energy = e + delta |> max(0) |> min(@max_energy)
    %{unit | energy: new_energy}
  end

  @doc """
  Returns true if unit has health > 0.
  """
  @spec alive?(t()) :: boolean()
  def alive?(%__MODULE__{health: h}), do: h > 0

  @doc """
  Applies rotation order to unit.
  """
  @spec apply_rotation(t(), :clockwise | :counterclockwise | nil) :: t()
  def apply_rotation(unit, nil), do: unit

  def apply_rotation(%__MODULE__{rotation: r} = unit, :clockwise) do
    %{unit | rotation: rem(r + 60, 360)}
  end

  def apply_rotation(%__MODULE__{rotation: r} = unit, :counterclockwise) do
    new_r = r - 60
    %{unit | rotation: if(new_r < 0, do: new_r + 360, else: new_r)}
  end
end

# =============================================================================
# 3. GROUP STRUCT AND DETECTION
# =============================================================================

defmodule Phalanx.Group do
  @moduledoc """
  Represents a phalanx formation: adjacent units with same color and rotation.
  Ephemeral; recomputed each turn.
  """

  alias Phalanx.Hex

  @type position :: {integer(), integer()}

  @type t :: %__MODULE__{
    positions: MapSet.t(position()),
    rotation: non_neg_integer(),
    color: String.t()
  }

  defstruct [:positions, :rotation, :color]

  @doc """
  Returns the number of units in the group.
  """
  @spec size(t()) :: non_neg_integer()
  def size(%__MODULE__{positions: positions}), do: MapSet.size(positions)

  @doc """
  Validates declared phalanxes against current unit positions.
  Phalanxes are explicitly declared by players, not auto-detected.
  Returns only valid phalanxes with 2+ members.

  ## Example

      iex> units = %{
      ...>   {3, 2} => %{rotation: 60, color: "red"},
      ...>   {4, 2} => %{rotation: 60, color: "red"},
      ...>   {5, 2} => %{rotation: 60, color: "red"}
      ...> }
      iex> [group] = Phalanx.Group.detect_groups(units)
      iex> Phalanx.Group.size(group)
      3
  """
  @spec detect_groups(map()) :: [t()]
  def detect_groups(units) when map_size(units) == 0, do: []

  def detect_groups(units) do
    units
    |> Map.keys()
    |> flood_fill_all(units, MapSet.new(), [])
    |> Enum.filter(&(size(&1) >= 2))
  end

  defp flood_fill_all([], _units, _visited, groups), do: groups

  defp flood_fill_all([pos | rest], units, visited, groups) do
    if MapSet.member?(visited, pos) do
      flood_fill_all(rest, units, visited, groups)
    else
      unit = Map.fetch!(units, pos)
      {group_positions, new_visited} = flood_fill(pos, unit, units, visited)

      group = %__MODULE__{
        positions: group_positions,
        rotation: unit.rotation,
        color: unit.color
      }

      flood_fill_all(rest, units, new_visited, [group | groups])
    end
  end

  defp flood_fill(start_pos, reference_unit, units, visited) do
    do_flood_fill([start_pos], reference_unit, units, visited, MapSet.new())
  end

  defp do_flood_fill([], _ref, _units, visited, group) do
    {group, visited}
  end

  defp do_flood_fill([pos | queue], ref, units, visited, group) do
    cond do
      MapSet.member?(visited, pos) ->
        do_flood_fill(queue, ref, units, visited, group)

      not Map.has_key?(units, pos) ->
        do_flood_fill(queue, ref, units, visited, group)

      not same_formation?(Map.get(units, pos), ref) ->
        do_flood_fill(queue, ref, units, MapSet.put(visited, pos), group)

      true ->
        new_visited = MapSet.put(visited, pos)
        new_group = MapSet.put(group, pos)
        neighbors = Hex.all_neighbors(pos) |> Enum.map(&elem(&1, 1))
        new_queue = queue ++ neighbors
        do_flood_fill(new_queue, ref, units, new_visited, new_group)
    end
  end

  defp same_formation?(unit, reference) do
    unit.rotation == reference.rotation and unit.color == reference.color
  end

  @doc """
  Finds the group containing a given position, if any.
  """
  @spec find_group([t()], position()) :: t() | nil
  def find_group(groups, pos) do
    Enum.find(groups, fn group -> MapSet.member?(group.positions, pos) end)
  end
end

# =============================================================================
# 4. STRENGTH CALCULATION
# =============================================================================

defmodule Phalanx.Strength do
  @moduledoc """
  Pure functions for calculating combat strength.
  Strength = Base(1) + Formation(0-4) + Support(0-2) + Flanking(0-2)
  """

  alias Phalanx.Hex

  @type position :: {integer(), integer()}
  @type direction_class :: :front | :flank | :rear

  @base_strength 1
  @max_side_bonus 2
  @max_rear_bonus 2
  @max_total_bonus 4

  @doc """
  Calculates attack strength for a unit attacking a target.

  ## Example

      iex> units = %{{1, 1} => %{rotation: 0, color: "red"}}
      iex> Phalanx.Strength.calculate_attack_strength({1, 1}, {2, 1}, units, [])
      1
  """
  @spec calculate_attack_strength(position(), position(), map(), [position()]) :: pos_integer()
  def calculate_attack_strength(attacker_pos, defender_pos, units, supporters) do
    attacker = Map.fetch!(units, attacker_pos)
    defender = Map.get(units, defender_pos)

    formation_bonus = side_bonus(attacker_pos, attacker, units) +
                      rear_bonus(attacker_pos, attacker, units)

    support_bonus = min(length(supporters), 2)

    flanking = if defender do
      attack_dir = Hex.direction_between(attacker_pos, defender_pos)
      flanking_bonus(attack_dir, defender.rotation)
    else
      0
    end

    @base_strength + min(formation_bonus, @max_total_bonus) + support_bonus + flanking
  end

  @doc """
  Calculates defense strength for a unit being attacked.
  Defender strength = Base + Formation (no support, no flanking).
  """
  @spec calculate_defense_strength(position(), map()) :: pos_integer()
  def calculate_defense_strength(defender_pos, units) do
    defender = Map.fetch!(units, defender_pos)

    formation_bonus = side_bonus(defender_pos, defender, units) +
                      rear_bonus(defender_pos, defender, units)

    @base_strength + min(formation_bonus, @max_total_bonus)
  end

  @doc """
  Counts adjacent allies in the same declared phalanx (side cohesion).
  Only phalanx members count - loose units get no bonus.
  """
  @spec side_bonus(position(), map(), map()) :: non_neg_integer()
  def side_bonus(pos, unit, units) do
    Hex.all_neighbors(pos)
    |> Enum.count(fn {_dir, neighbor_pos} ->
      case Map.get(units, neighbor_pos) do
        nil -> false
        neighbor -> same_facing?(unit, neighbor) and classify_direction(unit.rotation, _dir) == :flank
      end
    end)
    |> min(@max_side_bonus)
  end

  @doc """
  Counts rear allies in the same declared phalanx (depth bonus).
  Only phalanx members count - loose units get no bonus.
  """
  @spec rear_bonus(position(), map(), map()) :: non_neg_integer()
  def rear_bonus(pos, unit, units) do
    Hex.all_neighbors(pos)
    |> Enum.count(fn {dir, neighbor_pos} ->
      case Map.get(units, neighbor_pos) do
        nil -> false
        neighbor -> same_facing?(unit, neighbor) and classify_direction(unit.rotation, dir) == :rear
      end
    end)
    |> min(@max_rear_bonus)
  end

  @doc """
  Returns flanking bonus based on attack direction relative to defender facing.
  Front = 0, Flank = 1, Rear = 2.

  ## Example

      iex> Phalanx.Strength.flanking_bonus(:east, 60)  # Attacking from east, defender faces NE
      1  # Flank attack
  """
  @spec flanking_bonus(Hex.direction() | nil, non_neg_integer()) :: 0 | 1 | 2
  def flanking_bonus(nil, _rotation), do: 0

  def flanking_bonus(attack_from_direction, defender_rotation) do
    case classify_direction(defender_rotation, attack_from_direction) do
      :front -> 0
      :flank -> 1
      :rear -> 2
    end
  end

  @doc """
  Classifies a neighbor direction relative to unit facing.
  Returns :front, :flank, or :rear.
  """
  @spec classify_direction(non_neg_integer(), Hex.direction()) :: direction_class()
  def classify_direction(unit_rotation, neighbor_direction) do
    front_dir = Hex.rotation_to_front_direction(unit_rotation)
    rear_dir = Hex.opposite_direction(front_dir)

    cond do
      neighbor_direction == front_dir -> :front
      neighbor_direction == rear_dir -> :rear
      true -> :flank
    end
  end

  defp same_facing?(unit1, unit2) do
    unit1.rotation == unit2.rotation and unit1.color == unit2.color
  end
end

# =============================================================================
# 5. COMBAT RESOLUTION
# =============================================================================

defmodule Phalanx.Combat do
  @moduledoc """
  Combat resolution: conflict detection, strength comparison, outcome determination.
  """

  alias Phalanx.{Hex, Strength, Group}

  @type position :: {integer(), integer()}
  @type movement :: {position(), position(), map()}
  @type conflict ::
    {:destination, position(), [movement()]}
    | {:attack, position(), position()}
    | {:swap, position(), position()}

  @type result :: :move | :balk | :dislodged | :hold

  @doc """
  Resolves a single conflict between attacker and defender.
  Returns {:attacker_wins, damage} or {:defender_wins, nil}.

  ## Example

      iex> units = %{
      ...>   {1, 1} => %{rotation: 0, color: "red"},
      ...>   {2, 1} => %{rotation: 180, color: "purple"}
      ...> }
      iex> Phalanx.Combat.resolve_conflict({1, 1}, {2, 1}, units, [], [])
      {:tie, nil}
  """
  @spec resolve_conflict(position(), position(), map(), [position()], [Group.t()]) ::
    {:attacker_wins, pos_integer()} | {:defender_wins, nil} | {:tie, nil}
  def resolve_conflict(attacker_pos, defender_pos, units, supporters, _groups) do
    attack_strength = Strength.calculate_attack_strength(attacker_pos, defender_pos, units, supporters)
    defense_strength = Strength.calculate_defense_strength(defender_pos, units)

    cond do
      attack_strength > defense_strength ->
        damage = calculate_damage(attacker_pos, defender_pos, units)
        {:attacker_wins, damage}

      attack_strength < defense_strength ->
        {:defender_wins, nil}

      true ->
        {:tie, nil}
    end
  end

  @doc """
  Calculates damage dealt to a dislodged defender.
  Damage = 1 (dislodge) + angle_bonus.
  """
  @spec calculate_damage(position(), position(), map()) :: pos_integer()
  def calculate_damage(attacker_pos, defender_pos, units) do
    defender = Map.fetch!(units, defender_pos)
    attack_dir = Hex.direction_between(attacker_pos, defender_pos)

    base_damage = 1
    angle_bonus = Strength.flanking_bonus(attack_dir, defender.rotation)

    base_damage + angle_bonus
  end

  @doc """
  Finds all units supporting an attacker.
  A unit supports if: adjacent, same color, moving same direction.
  """
  @spec find_supporters(position(), Hex.direction(), map(), map()) :: [position()]
  def find_supporters(attacker_pos, move_direction, units, orders) do
    attacker = Map.fetch!(units, attacker_pos)

    Hex.all_neighbors(attacker_pos)
    |> Enum.filter(fn {_dir, neighbor_pos} ->
      case {Map.get(units, neighbor_pos), Map.get(orders, neighbor_pos)} do
        {nil, _} -> false
        {_, nil} -> false
        {neighbor, order} ->
          neighbor.color == attacker.color and
          order.move == move_direction and
          not is_being_attacked?(neighbor_pos, orders, units)
      end
    end)
    |> Enum.map(&elem(&1, 1))
  end

  defp is_being_attacked?(pos, orders, units) do
    Enum.any?(orders, fn {from_pos, order} ->
      case {order.move, Map.get(units, from_pos)} do
        {nil, _} -> false
        {_, nil} -> false
        {move_dir, attacker} ->
          target = Hex.neighbor(from_pos, move_dir)
          target == pos and attacker.color != Map.get(units, pos, %{color: nil}).color
      end
    end)
  end

  @doc """
  Detects all conflicts in the current orders.
  Returns list of conflict tuples.
  """
  @spec detect_conflicts(map(), map(), {pos_integer(), pos_integer()}) :: [conflict()]
  def detect_conflicts(orders, units, map_dimensions) do
    movements = calculate_movements(orders, units, map_dimensions)

    destination_conflicts = detect_destination_conflicts(movements)
    attack_conflicts = detect_attack_conflicts(movements, units)
    swap_conflicts = detect_swap_conflicts(movements, units)

    destination_conflicts ++ attack_conflicts ++ swap_conflicts
  end

  defp calculate_movements(orders, units, map_dimensions) do
    Enum.map(orders, fn {pos, order} ->
      unit = Map.get(units, pos)

      destination =
        if unit && order.move do
          target = Hex.neighbor(pos, order.move)
          if Hex.on_map?(target, map_dimensions), do: target, else: pos
        else
          pos
        end

      {pos, destination, unit, order}
    end)
  end

  defp detect_destination_conflicts(movements) do
    movements
    |> Enum.filter(fn {from, to, _, _} -> from != to end)
    |> Enum.group_by(fn {_, to, _, _} -> to end)
    |> Enum.filter(fn {_dest, movers} -> length(movers) > 1 end)
    |> Enum.map(fn {dest, movers} ->
      {:destination, dest, Enum.map(movers, fn {from, _, unit, _} -> {from, dest, unit} end)}
    end)
  end

  defp detect_attack_conflicts(movements, units) do
    movements
    |> Enum.filter(fn {from, to, unit, _} ->
      from != to and unit != nil and
      case Map.get(units, to) do
        nil -> false
        target -> target.color != unit.color
      end
    end)
    |> Enum.map(fn {from, to, _, _} -> {:attack, from, to} end)
  end

  defp detect_swap_conflicts(movements, units) do
    movements
    |> Enum.flat_map(fn {from_a, to_a, unit_a, _} ->
      Enum.filter(movements, fn {from_b, to_b, unit_b, _} ->
        from_a == to_b and to_a == from_b and
        from_a != to_a and
        unit_a != nil and unit_b != nil and
        unit_a.color != unit_b.color
      end)
      |> Enum.map(fn {from_b, _, _, _} ->
        if from_a < from_b, do: {:swap, from_a, from_b}, else: nil
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @doc """
  Applies all-or-nothing atomic movement for declared phalanxes.
  If ANY phalanx member would balk, ALL members balk.
  """
  @spec apply_phalanx_atomic_movement(map(), [Phalanx.t()]) :: map()
  def apply_phalanx_atomic_movement(results, phalanxes) do
    Enum.reduce(phalanxes, results, fn phalanx, acc ->
      phalanx_results = phalanx.positions
        |> MapSet.to_list()
        |> Enum.map(&Map.get(acc, &1, :hold))

      # All-or-nothing: ANY balk = all balk
      any_balk = Enum.any?(phalanx_results, &(&1 == :balk))

      if any_balk do
        # Any balks: convert all moves to balks
        Enum.reduce(phalanx.positions, acc, fn pos, inner_acc ->
          case Map.get(inner_acc, pos) do
            :move -> Map.put(inner_acc, pos, :balk)
            _ -> inner_acc
          end
        end)
      else
        acc
      end
    end)
  end
end

# =============================================================================
# 6. RETREAT LOGIC
# =============================================================================

defmodule Phalanx.Combat.Retreat do
  @moduledoc """
  Retreat hex calculation and execution for dislodged units.
  """

  alias Phalanx.Hex

  @type position :: {integer(), integer()}

  @doc """
  Returns valid retreat hexes for a dislodged unit.
  Valid: empty, on map, not attacker origin, not standoff hex.

  ## Example

      iex> state = %{units: %{{2, 1} => %{}}, map_dimensions: {10, 10}}
      iex> Phalanx.Combat.Retreat.valid_retreats(state, {2, 1}, {1, 1}, MapSet.new())
      # Returns list of valid adjacent empty hexes
  """
  @spec valid_retreats(map(), position(), position(), MapSet.t(position())) :: [position()]
  def valid_retreats(state, defender_pos, attacker_origin, standoff_hexes) do
    Hex.all_neighbors(defender_pos)
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(fn pos ->
      Hex.on_map?(pos, state.map_dimensions) and
      not Map.has_key?(state.units, pos) and
      pos != attacker_origin and
      not MapSet.member?(standoff_hexes, pos)
    end)
  end

  @doc """
  Executes retreat for a dislodged unit.
  Picks random valid hex. Returns updated state and result.

  ## Example

      iex> state = %{units: %{{2, 1} => unit}}
      iex> {new_state, result} = Phalanx.Combat.Retreat.execute_retreat(state, {2, 1}, [{3, 1}])
      iex> result
      {:retreated, {3, 1}}
  """
  @spec execute_retreat(map(), position(), [position()]) :: {map(), {:retreated, position()} | :destroyed}
  def execute_retreat(state, dislodged_pos, []) do
    # No valid retreat: unit destroyed
    new_units = Map.delete(state.units, dislodged_pos)
    {%{state | units: new_units}, :destroyed}
  end

  def execute_retreat(state, dislodged_pos, valid_hexes) do
    retreat_to = Enum.random(valid_hexes)
    unit = Map.fetch!(state.units, dislodged_pos)

    new_units = state.units
      |> Map.delete(dislodged_pos)
      |> Map.put(retreat_to, unit)

    {%{state | units: new_units}, {:retreated, retreat_to}}
  end

  @doc """
  Processes all retreats for dislodged units.
  """
  @spec process_retreats(map(), [{position(), position(), pos_integer()}]) :: map()
  def process_retreats(state, dislodged_units) do
    standoff_hexes = MapSet.new()

    Enum.reduce(dislodged_units, state, fn {defender_pos, attacker_pos, damage}, acc ->
      valid = valid_retreats(acc, defender_pos, attacker_pos, standoff_hexes)
      {new_state, _result} = execute_retreat(acc, defender_pos, valid)

      # Apply damage to retreated unit (or it was destroyed)
      case Map.get(new_state.units, defender_pos) do
        nil -> new_state
        _ -> new_state  # Unit was destroyed, nothing to update
      end
      |> apply_damage_to_dislodged(defender_pos, valid, damage)
    end)
  end

  defp apply_damage_to_dislodged(state, original_pos, valid_hexes, damage) do
    # Find where the unit retreated to
    retreat_pos = case valid_hexes do
      [] -> nil
      _ -> Enum.find(valid_hexes, fn pos -> Map.has_key?(state.units, pos) end)
    end

    case retreat_pos do
      nil -> state
      pos ->
        unit = Map.fetch!(state.units, pos)
        damaged = Phalanx.Unit.apply_damage(unit, damage)
        if Phalanx.Unit.alive?(damaged) do
          %{state | units: Map.put(state.units, pos, damaged)}
        else
          %{state | units: Map.delete(state.units, pos)}
        end
    end
  end
end

# =============================================================================
# 7. ENGINE INTEGRATION
# =============================================================================

defmodule Phalanx.Engine.Combat do
  @moduledoc """
  Combat engine implementing the 13-phase resolution algorithm.
  Orchestrates grouping, strength calculation, and combat resolution.
  """

  @behaviour Phalanx.Engine

  alias Phalanx.{Hex, Unit, Group, Strength, Combat, Order}
  alias Phalanx.Combat.Retreat
  alias Phalanx.Engine.Helpers

  @impl Phalanx.Engine
  @spec execute_orders(Phalanx.Game.t(), map()) :: Phalanx.Game.t()
  def execute_orders(state, orders) do
    # Phase 1: Snapshot
    snapshot = snapshot(state)

    # Phase 2: Order Validation
    validated = validate_orders(orders, snapshot, state.map_dimensions)

    # Phase 3: Support Calculation
    support_data = calculate_supports(validated, snapshot.units)

    # Phase 4: Conflict Detection
    conflicts = Combat.detect_conflicts(validated, snapshot.units, state.map_dimensions)

    # Phase 5: Strength Calculation (done during resolution)
    # Phase 6: Combat Resolution
    results = resolve_all_conflicts(conflicts, snapshot, support_data, validated)

    # Apply all-or-nothing atomic movement for phalanxes
    results = Combat.apply_phalanx_atomic_movement(results, snapshot.phalanxes)

    # Phase 7: Movement Execution
    state = execute_movements(state, results, validated)

    # Phase 8: Damage & Retreat
    state = apply_damage_and_retreats(state, results, validated, snapshot)

    # Phase 9: Rotation Application
    state = apply_rotations(state, validated)

    # Phase 10: Energy & Cleanup
    state = apply_energy_and_cleanup(state, validated, results)

    %{state | turn: state.turn + 1}
  end

  @spec snapshot(Phalanx.Game.t()) :: map()
  defp snapshot(state) do
    groups = Group.detect_groups(state.units)

    %{
      units: deep_copy(state.units),
      groups: groups,
      turn: state.turn
    }
  end

  defp deep_copy(units) do
    Enum.into(units, %{}, fn {pos, unit} -> {pos, Map.from_struct(unit)} end)
  rescue
    # Handle plain maps (not structs)
    _ -> Map.new(units)
  end

  @spec validate_orders(map(), map(), {pos_integer(), pos_integer()}) :: map()
  defp validate_orders(orders, snapshot, map_dimensions) do
    # Populate holds for units without orders
    orders = Helpers.populate_hold_orders(%{units: snapshot.units}, orders)

    # Validate each order
    Enum.reduce(orders, %{}, fn {pos, order}, acc ->
      unit = Map.get(snapshot.units, pos)

      valid_order = cond do
        unit == nil ->
          nil

        order.move == nil ->
          order

        # Check move is valid for rotation
        not move_valid_for_rotation?(unit.rotation, order.move) ->
          Order.null_order(pos)

        # Check destination is on map
        not Hex.on_map?(Hex.neighbor(pos, order.move), map_dimensions) ->
          Order.null_order(pos)

        # Check not moving to ally-occupied hex
        ally_at_destination?(pos, order.move, snapshot.units) ->
          Order.null_order(pos)

        true ->
          order
      end

      if valid_order, do: Map.put(acc, pos, valid_order), else: acc
    end)
    |> enforce_group_movement(snapshot.groups)
  end

  defp move_valid_for_rotation?(rotation, direction) do
    Phalanx.Moves.direction_allowed?(rotation, direction)
  end

  defp ally_at_destination?(pos, direction, units) do
    dest = Hex.neighbor(pos, direction)
    unit = Map.get(units, pos)
    target = Map.get(units, dest)

    unit != nil and target != nil and unit.color == target.color
  end

  defp enforce_group_movement(orders, groups) do
    Enum.reduce(groups, orders, fn group, acc ->
      group_orders = group.positions
        |> MapSet.to_list()
        |> Enum.map(&{&1, Map.get(acc, &1)})
        |> Enum.reject(fn {_, order} -> order == nil end)

      directions = Enum.map(group_orders, fn {_, order} -> order.move end) |> Enum.uniq()

      # If mixed directions (excluding nil for rotation-only), convert all to holds
      move_directions = Enum.reject(directions, &is_nil/1)

      if length(move_directions) > 1 do
        Enum.reduce(group_orders, acc, fn {pos, _}, inner_acc ->
          Map.put(inner_acc, pos, Order.null_order(pos))
        end)
      else
        acc
      end
    end)
  end

  @spec calculate_supports(map(), map()) :: map()
  defp calculate_supports(orders, units) do
    # Build support graph: which units support which
    supports = Enum.reduce(orders, %{}, fn {pos, order}, acc ->
      if order.move do
        supporters = Combat.find_supporters(pos, order.move, units, orders)
        Map.put(acc, pos, supporters)
      else
        Map.put(acc, pos, [])
      end
    end)

    %{supports: supports}
  end

  @spec resolve_all_conflicts([Combat.conflict()], map(), map(), map()) :: map()
  defp resolve_all_conflicts(conflicts, snapshot, support_data, orders) do
    initial_results = Enum.into(orders, %{}, fn {pos, order} ->
      result = if order.move, do: :move, else: :hold
      {pos, result}
    end)

    Enum.reduce(conflicts, initial_results, fn conflict, acc ->
      resolve_single_conflict(conflict, snapshot, support_data, acc)
    end)
  end

  defp resolve_single_conflict({:destination, _dest, contestants}, snapshot, support_data, results) do
    # Multiple units targeting same hex: compare strengths
    strengths = Enum.map(contestants, fn {from, to, _unit} ->
      supporters = Map.get(support_data.supports, from, [])
      strength = Strength.calculate_attack_strength(from, to, snapshot.units, supporters)
      {from, strength}
    end)

    max_strength = strengths |> Enum.map(&elem(&1, 1)) |> Enum.max()
    winners = Enum.filter(strengths, fn {_, s} -> s == max_strength end)

    if length(winners) > 1 do
      # Tie: all balk
      Enum.reduce(contestants, results, fn {from, _, _}, acc ->
        Map.put(acc, from, :balk)
      end)
    else
      # Winner moves, others balk
      [{winner_pos, _}] = winners
      Enum.reduce(contestants, results, fn {from, _, _}, acc ->
        if from == winner_pos do
          acc
        else
          Map.put(acc, from, :balk)
        end
      end)
    end
  end

  defp resolve_single_conflict({:attack, attacker_pos, defender_pos}, snapshot, support_data, results) do
    supporters = Map.get(support_data.supports, attacker_pos, [])

    case Combat.resolve_conflict(attacker_pos, defender_pos, snapshot.units, supporters, snapshot.groups) do
      {:attacker_wins, _damage} ->
        results
        |> Map.put(attacker_pos, :move)
        |> Map.put(defender_pos, :dislodged)

      {:defender_wins, _} ->
        Map.put(results, attacker_pos, :balk)

      {:tie, _} ->
        Map.put(results, attacker_pos, :balk)
    end
  end

  defp resolve_single_conflict({:swap, pos_a, pos_b}, _snapshot, _support_data, results) do
    # Swap conflicts: both balk
    results
    |> Map.put(pos_a, :balk)
    |> Map.put(pos_b, :balk)
  end

  @spec execute_movements(Phalanx.Game.t(), map(), map()) :: Phalanx.Game.t()
  defp execute_movements(state, results, orders) do
    # Collect successful moves
    moves = Enum.filter(results, fn {_pos, result} -> result == :move end)

    Enum.reduce(moves, state, fn {pos, _}, acc ->
      order = Map.get(orders, pos)

      if order && order.move do
        unit = Map.get(acc.units, pos)
        dest = Hex.neighbor(pos, order.move)

        new_units = acc.units
          |> Map.delete(pos)
          |> Map.put(dest, unit)

        %{acc | units: new_units}
      else
        acc
      end
    end)
  end

  @spec apply_damage_and_retreats(Phalanx.Game.t(), map(), map(), map()) :: Phalanx.Game.t()
  defp apply_damage_and_retreats(state, results, orders, snapshot) do
    # Find dislodged units and their attackers
    dislodged = results
      |> Enum.filter(fn {_, result} -> result == :dislodged end)
      |> Enum.map(fn {defender_pos, _} ->
        # Find who attacked this position
        attacker = Enum.find(orders, fn {from, order} ->
          order.move && Hex.neighbor(from, order.move) == defender_pos
        end)

        case attacker do
          {attacker_pos, _order} ->
            damage = Combat.calculate_damage(attacker_pos, defender_pos, snapshot.units)
            {defender_pos, attacker_pos, damage}
          nil ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    Retreat.process_retreats(state, dislodged)
  end

  @spec apply_rotations(Phalanx.Game.t(), map()) :: Phalanx.Game.t()
  defp apply_rotations(state, orders) do
    new_units = Enum.reduce(orders, state.units, fn {pos, order}, acc ->
      case Map.get(acc, pos) do
        nil -> acc
        unit ->
          # Find unit's current position (may have moved)
          # For simplicity, check if unit is still at original pos
          if order.rotation do
            updated = Unit.apply_rotation(unit, order.rotation)
            Map.put(acc, pos, updated)
          else
            acc
          end
      end
    end)

    %{state | units: new_units}
  end

  @spec apply_energy_and_cleanup(Phalanx.Game.t(), map(), map()) :: Phalanx.Game.t()
  defp apply_energy_and_cleanup(state, orders, results) do
    new_units = Enum.reduce(state.units, state.units, fn {pos, unit}, acc ->
      # Determine energy delta based on action
      delta = case {Map.get(orders, pos), Map.get(results, pos)} do
        {nil, false} -> 1  # No order = hold = +1 (if not attacked)
        {nil, true} -> 0   # No order = hold but attacked = 0
        {order, :move} ->
          if forward_move?(order.move, unit.rotation), do: -1, else: 0
        {_, :hold} -> 1
        {_, :balk} -> 0
        {_, :dislodged} -> 0
        _ -> 0
      end

      updated = Unit.apply_energy_delta(unit, delta)

      # Zero energy penalty
      updated = if updated.energy == 0 do
        Unit.apply_damage(updated, 1)
      else
        updated
      end

      if Unit.alive?(updated) do
        Map.put(acc, pos, updated)
      else
        Map.delete(acc, pos)
      end
    end)

    %{state | units: new_units}
  end

  defp forward_move?(direction, rotation) do
    front = Hex.rotation_to_front_direction(rotation)
    direction == front or Hex.angle_between(direction, front) <= 60
  end
end
