defmodule Phalanx.Engine.Diplomacy do
  @behaviour Phalanx.Engine

  alias Phalanx.Moves
  alias Phalanx.Engine.Helpers

  @impl Phalanx.Engine
  def execute_orders(state, orders) do
    orders = Helpers.populate_hold_orders(state, orders)
    # Step 1: Get all unit start and end positions from orders
    unit_movements = get_unit_movements(state, orders)

    # Step 2: Detect conflicts between orders
    conflict_units = detect_conflicts(unit_movements)

    if conflict_units == MapSet.new([]) do
      IO.inspect("No conflicts")
      # Final Step: Apply successful orders to game state
      apply_orders_to_state(state, orders)
    else
      IO.inspect(conflict_units, label: "Conflicts, retrying")
      # Step 3: Convert conflicting orders to hold orders (balking)
      valid_orders = convert_conflicts_to_holds(orders, conflict_units)

      # failed orders due to balks / invalid moves can cause cascading failures,
      # so we need to execute the orders again.
      execute_orders(state, valid_orders)
    end
  end

  # Step 1: Calculate new positions for all units with orders
  defp get_unit_movements(state, orders) do
    Enum.map(orders, fn {position, order} ->
      unit = Map.get(state.units, position)

      if unit && order.move do
        case Moves.move(state.map_dimensions, position, unit.rotation, order.move) do
          {:ok, new_position} -> {position, new_position, unit}
          {:error, _} -> {position, position, unit} # Stay in place if invalid move or only a rotation
        end
      else
        {position, position, unit} # Stay in place if no move order
      end
    end)
  end

  # Step 2: Detect conflicts - units trying to move to same position or occupied positions
  defp detect_conflicts(unit_movements) do
    # Group by destination position. Non-moving units are included here since they are still occupying the position.
    destination_groups =
      unit_movements
      |> Enum.group_by(fn {_start, end_pos, _unit} -> end_pos end)
      |> Enum.filter(fn {_pos, movements} -> length(movements) > 1 end)

    # Find conflicts: multiple units to same position OR moving to occupied position
    destination_groups
    |> Enum.flat_map(fn {_pos, movements} ->
      movements |> Enum.map(fn {start_pos, _end_pos, _unit} -> start_pos end)
    end)
    |> MapSet.new()
  end

  # Step 3: Convert conflicting orders to hold orders (balking)
  defp convert_conflicts_to_holds(orders, conflicts) do
    orders
    |> Enum.map(fn {position, order} ->
      if MapSet.member?(conflicts, position) do
        # Convert to hold order (no move, no rotation - orders are atomic)
        {position, Phalanx.Order.null_order(position)}
      else
        {position, order}
      end
    end)
    |> Map.new()
  end

  # Step 4: Apply successful orders to game state
  defp apply_orders_to_state(state, valid_orders) do
    # Process each valid order
    {new_units, _} =
      Enum.reduce(valid_orders, {state.units, []}, fn {position, order}, {units_acc, processed} ->
        unit = Map.get(units_acc, position)

        if unit do
          # Apply rotation if specified
          updated_unit =
            if order.rotation do
              new_rotation = apply_rotation(unit.rotation, order.rotation)
              Map.put(unit, :rotation, new_rotation)
            else
              unit
            end

          # Apply movement if specified
          if order.move do
            case Moves.move(state.map_dimensions, position, updated_unit.rotation, order.move) do
              {:ok, new_position} ->
                # Remove from old position, add to new position
                new_units =
                  units_acc
                  |> Map.delete(position)
                  |> Map.put(new_position, updated_unit)
                {new_units, [new_position | processed]}

              {:error, _} ->
                # Stay in place if move is invalid
                new_units = Map.put(units_acc, position, updated_unit)
                {new_units, processed}
            end
          else
            # Hold order (no move, no rotation) - stay in same position with no changes
            new_units = Map.put(units_acc, position, updated_unit)
            {new_units, processed}
          end
        else
          {units_acc, processed}
        end
      end)

    # Update the state with new units
    %{state | units: new_units}
  end

  # Helper function to apply rotation
  defp apply_rotation(current_rotation, rotation_order) do
    case rotation_order do
      :clockwise -> rem(current_rotation + 60, 360)
      :counterclockwise ->
        new_rotation = current_rotation - 60
        if new_rotation < 0, do: new_rotation + 360, else: new_rotation
    end
  end
end
