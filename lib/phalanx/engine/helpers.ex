defmodule Phalanx.Engine.Helpers do
  @moduledoc """
  Shared helpers for all engine types.
  """

  @doc """
  Populate hold orders for all units that do not have an order.

  Args:
    - state: the current state of the game
    - orders: the orders for the current turn

  Returns:
    - a map of unit positions to orders
  """
  @spec populate_hold_orders(state :: map(), orders :: map()) :: map()
  def populate_hold_orders(state, orders) do
    Enum.map(state.units, fn {position, unit} ->
      case Map.get(orders, position) do
        nil ->
          # hold order
          {position, Phalanx.Order.null_order(position)}
        order ->
          {position, order}
      end
    end)
    |> Map.new()
  end
end
