defmodule PhalanxWeb.Live.Game do
  use PhalanxWeb, :live_view

  alias Phalanx.Game

  import PhalanxWeb.Components.Hex

  @impl true
  def mount(_params, _session, socket) do
    game_id = socket.assigns.game_id

    IO.inspect("mounting")
    case Game.get_state(game_id) do
      {:ok, game_state} ->
        if connected?(socket) and game_state.status in [:waiting, :playing] do
          Phoenix.PubSub.subscribe(Phalanx.PubSub, Game.state_topic(game_state.id))
        end

        {x, y} = game_state.map_dimensions

        socket
        |> assign(:state, game_state)
        |> assign(:current_unit, nil)
        |> assign(:map_x, x)
        |> assign(:map_y, y)
        # TODO: orders should be in the game state?
        |> assign(:orders, %{})
        |> ok()

      {:error, :not_found} ->
        socket
        |> put_flash(:error, "Game not found")
        |> redirect(to: ~p"/find")
        |> ok()
    end
  end

  @impl true
  def terminate(_reason, socket) do
    Phoenix.PubSub.unsubscribe(Phalanx.PubSub, Game.state_topic(socket.assigns.game_id))
    :ok
  end

  @move_keys move_keys()
  @rotation_keys rotation_keys()
  @unit_keys unit_keys()

  @impl true
  def handle_event("hotkey", %{"key" => key}, socket) do
    case key do
      key when key in @move_keys ->
        handle_move_order(socket, key)

      key when key in @rotation_keys ->
        handle_rotation_order(socket, key)

      key when key in @unit_keys ->
        handle_select_unit(socket, key)

      "Enter" ->
        handle_submit_orders(socket)

      _ ->
        noreply(socket)
    end
  end

  defp handle_move_order(socket, key) do
    abs_direction = key_to_abs_direction(key)
    map_x = socket.assigns.map_x
    map_y = socket.assigns.map_y

    case get_current_unit(socket) do
      {nil, _} ->
        noreply(socket)

      {curr_position, unit} ->
        # TODO: Check validity of this order with Moves.move

        # lookup existing order for this unit
        existing_order = Map.get(socket.assigns.orders, curr_position )
        order = Phalanx.Order.upsert(existing_order, curr_position, abs_direction)

        socket
        |> put_order(order)
        |> noreply()
    end
  end

  defp handle_rotation_order(socket, key) do
    case get_current_unit(socket) do
      {nil, _} ->
        noreply(socket)

      {position, unit} ->
        rotation_order = key_to_rotation_order(key)
        existing_order = Map.get(socket.assigns.orders, position)
        order = Phalanx.Order.upsert(existing_order, position, rotation_order)

        socket
        |> put_order(order)
        |> noreply()
    end
  end

  defp put_order(socket, order) do
    assign(socket, :orders, Map.put(socket.assigns.orders, order.position, order))
  end

  defp handle_select_unit(socket, key) do
    if key == "c" do
      socket
      |> assign(:current_unit, nil)
      |> noreply()
    else
      unit_name = String.upcase(key)
      socket
      |> set_current_unit(unit_name)
      |> noreply()
    end
  end

  defp handle_submit_orders(socket) do
    orders = socket.assigns.orders
    Phalanx.Game.handle_orders(socket.assigns.game_id, orders)

    socket
    |> assign(:orders, %{})
    |> noreply()
  end

  @impl true
  def handle_info({:state, state}, socket) do
    assign(socket, :state, state)
    |> assign(:orders, %{})
    |> noreply()
  end

  defp get_current_unit(socket) do
    {socket.assigns.current_unit, Map.get(socket.assigns.state.units, socket.assigns.current_unit)}
  end

  defp set_current_unit(socket, unit_name) do
    {position, _current_unit} = Enum.find(socket.assigns.state.units, fn {_position, unit} -> unit.name == unit_name end)

    if position == socket.assigns.current_unit do
      assign(socket, :current_unit, nil)
    else
      assign(socket, :current_unit, position)
    end
  end


  @impl true
  def render(assigns) do
    ~H"""
    <div id="game" class="h-screen w-screen" phx-hook="Hotkeys">
      <div class="flex flex-row">
        <!-- Left sidebar content -->
        <.sidebar>
          <div class="w-full text-white text-center py-2">
            Help
          </div>
          <.compass_hex_grid />

          <.controls />

          <.quit_button />
        </.sidebar>
        <%!-- Main Board --%>
        <div id="grid" class="w-full">
          <.hex_grid x_ct={@map_x} y_ct={@map_y} current_unit={@current_unit} units={@state.units}/>
        </div>
        <!-- Right sidebar content -->
        <.sidebar>
          <.orders orders={@orders} state={@state} />
        </.sidebar>
      </div>
    </div>
    """
  end

  slot :inner_block, required: true

  defp sidebar(assigns) do
    ~H"""
    <div class="flex flex-col gap-2 w-1/6 h-screen flex flex-col bg-black">
      <!-- Right sidebar content will go here -->
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp controls(assigns) do
    ~H"""
    <div class="w-full text-white text-center py-2">
      Controls
    </div>

    <div class="flex flex-col">
      <.control_item key="Q" description="counterclockwise" />
      <.control_item key="R" description="clockwise" />
    </div>
    Hit a letter to select that unit, then add a move and/or rotation order.
    """
  end

  defp control_item(assigns) do
    ~H"""
    <div class="w-full text-white text-center py-2">
      <%= @key %>: <%= @description %>
    </div>
    """
  end

  defp quit_button(assigns) do
    ~H"""
    <.link
      href={~p"/clear"}
      class="bg-gradient-to-r mx-auto from-gray-600 to-gray-700 hover:from-gray-700 hover:to-gray-800 text-white font-semibold py-2 px-4 rounded-lg shadow-lg transform hover:scale-105 transition-all duration-200 border border-gray-500 hover:border-gray-400"
    >
      Quit
    </.link>
    """
  end

  attr :orders, :map
  attr :state, :map

  defp orders(assigns) do
    ~H"""
    <div class="w-full text-white text-center py-2">
      Orders
    </div>
    <div class="flex flex-col">
      <%= for {position, order} <- @orders do %>
        <% name = @state.units[order.position].name %>
        <div class={"text-center py-2 #{unit_letter_to_color(name)}"}>
          <%= name %>: <%= Phalanx.Order.to_string(order) %>
        </div>
      <% end %>
    </div>
    """
  end
end
