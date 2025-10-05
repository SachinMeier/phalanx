defmodule Phalanx.Engine do
  @moduledoc """
  This module contains the logic for the engine.
  """

  @callback execute_orders(state :: map(), orders :: map()) :: map()

  def execute_orders(state, orders) do
    engine().execute_orders(state, orders)
  end

  def engine() do
    Application.get_env(:phalanx, :engine)
  end
end
