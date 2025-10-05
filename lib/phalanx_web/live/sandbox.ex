defmodule PhalanxWeb.Live.Sandbox do
  use PhalanxWeb, :live_view

  import PhalanxWeb.Components.Hex


  def mount(_params, _session, socket) do
    units = %{
      {3,3} => %{name: "Y", health: 3, rotation: 240, color: "red"},
      {4,3} => %{name: "U", health: 3, rotation: 240, color: "red"},
      {5,3} => %{name: "I", health: 3, rotation: 240, color: "red"},
      {6,3} => %{name: "O", health: 3, rotation: 240, color: "red"},
      {7,3} => %{name: "P", health: 3, rotation: 240, color: "red"},
      {3,5} => %{name: "H", health: 3, rotation: 60, color: "purple"},
      {4,5} => %{name: "J", health: 3, rotation: 60, color: "purple"},
      {5,5} => %{name: "K", health: 3, rotation: 60, color: "purple"},
      {6,5} => %{name: "L", health: 3, rotation: 60, color: "purple"},
      {7,5} => %{name: "M", health: 3, rotation: 60, color: "purple"},
    }
    socket
    |> assign(:current_unit, nil)
    |> assign(:units, units)
    |> assign(:map_x, 10)
    |> assign(:map_y, 10)
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <%!-- <.unit_svg current_unit={{2,2}} x={1} y={1} unit={%{name: "M", health: 3, rotation: 60, color: "purple"}} /> --%>
    <div id="game" class="h-screen w-screen" phx-hook="Hotkeys">
      <div id="grid" class="w-full mx-auto px-24">
        <.hex_grid x_ct={@map_x} y_ct={@map_y} current_unit={@current_unit} units={@units}/>
      </div>
    </div>
    """
  end

  @move_keys move_keys()
  @rotation_keys rotation_keys()
  @unit_keys unit_keys()

  def handle_event("hotkey", %{"key" => key}, socket) do
    case key do
      # rotation
      key when key in @rotation_keys ->
        case get_current_unit(socket) do
          {nil, _} ->
            noreply(socket)
          {position, unit} ->
            new_rotation = key_to_unit_rotation(unit, key)

            unit = Map.put(unit, :rotation, new_rotation)

            units = Map.put(socket.assigns.units, position, unit)

            socket
            |> assign(:units, units)
            |> noreply()
        end

      # Moves
      key when key in @move_keys ->
        abs_direction = key_to_abs_direction(key)
        map_x = socket.assigns.map_x
        map_y = socket.assigns.map_y


        case get_current_unit(socket) do
          {nil, _} ->
            noreply(socket)

          {old_position, unit} ->
            case Phalanx.Moves.move({map_x, map_y}, old_position, unit.rotation, abs_direction) do
              {:ok, new_position} ->
                # TODO: Check validity & openness of the tile

                units =
                  socket.assigns.units
                  |> Map.delete(old_position)
                  |> Map.put(new_position, unit)

                socket
                |> assign(:units, units)
                |> assign(:current_unit, new_position)
                |> noreply()

              {:error, err} ->
                socket
                |> put_flash(:error, err)
                |> noreply()
            end
        end

      # unit selection
      key when key in @unit_keys ->
        unit_name = String.upcase(key)

        socket
        |> set_current_unit(unit_name)
        |> noreply()

      # health
      key when key in ["-", "="] ->
        case get_current_unit(socket) do
          {nil, _} ->
            noreply(socket)
          {position, unit} ->
            delta =
              case key do
                "-" -> -1
                "=" -> 1
              end
            unit = Map.put(unit, :health, unit.health + delta)

            units = Map.put(socket.assigns.units, position, unit)

            socket
            |> assign(:units, units)
            |> noreply()
        end


      _ ->
        noreply(socket)
    end
  end

  defp get_current_unit(socket) do
    {socket.assigns.current_unit, Map.get(socket.assigns.units, socket.assigns.current_unit)}
  end

  defp set_current_unit(socket, unit_name) do
    {position, _current_unit} = Enum.find(socket.assigns.units, fn {_position, unit} -> unit.name == unit_name end)
    assign(socket, :current_unit, position)
  end




end
