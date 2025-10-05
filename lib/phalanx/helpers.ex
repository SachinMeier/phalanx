defmodule Phalanx.Helpers do
  def default_game() do
    %{
      units: default_units(),
      map_dimensions: default_map_dimensions(),
    }
  end

  def default_units() do
    %{
      {3,2} => %{name: "Y", health: 3, rotation: 240, color: "red"},
      {4,2} => %{name: "U", health: 3, rotation: 240, color: "red"},
      {5,2} => %{name: "I", health: 3, rotation: 240, color: "red"},
      {6,2} => %{name: "O", health: 3, rotation: 240, color: "red"},
      {7,2} => %{name: "P", health: 3, rotation: 240, color: "red"},
      {3,7} => %{name: "H", health: 3, rotation: 60, color: "purple"},
      {4,7} => %{name: "J", health: 3, rotation: 60, color: "purple"},
      {5,7} => %{name: "K", health: 3, rotation: 60, color: "purple"},
      {6,7} => %{name: "L", health: 3, rotation: 60, color: "purple"},
      {7,7} => %{name: "M", health: 3, rotation: 60, color: "purple"},
    }
  end

  def default_map_dimensions() do
    {10, 10}
  end

  def ok(), do: :ok
  def ok(value), do: {:ok, value}

  def noreply(socket), do: {:noreply, socket}

  def reply(socket, value), do: {:reply, value, socket}
end
