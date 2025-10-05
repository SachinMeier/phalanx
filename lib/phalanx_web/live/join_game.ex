defmodule PhalanxWeb.Live.JoinGame do
  use PhalanxWeb, :live_view

  @impl true
  def mount(%{"id" => game_id} = _params, session, socket) do
    case Phalanx.Game.find_by_id(game_id) do
      :ok ->
        socket
        |> assign(
          game_id: game_id,
          min_name_length: 1,
          max_name_length: 15
        )
        |> ok()

      _ ->
        socket
        |> put_flash(:error, "Game not found")
        |> redirect(to: ~p"/find")
        |> ok()
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={:public}>
      <div class="min-h-screen bg-gradient-to-br from-blue-900 via-purple-900 to-indigo-900 flex items-center justify-center">
        <div class="text-center space-y-8 p-8 max-w-md w-full">
          <h1 class="text-6xl font-bold text-white mb-4 tracking-wide">
            Join Game
          </h1>

          <.form for={%{}} id="join-game-form" phx-change="validate" phx-submit="join" class="space-y-6">
            <div>
              <.input
                name="player_name"
                type="text"
                value=""
                placeholder="Enter your player name"
                class="w-full px-6 py-4 text-lg rounded-xl border-2 border-blue-400 bg-blue-900/50 text-white placeholder-blue-300 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-blue-400 transition-all duration-200"
              />
            </div>

            <div class="flex justify-center">
              <button
                type="submit"
                class="bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white font-bold py-4 px-8 rounded-xl text-xl shadow-2xl transform hover:scale-105 transition-all duration-200 border-2 border-green-500 hover:border-green-400 w-full"
              >
                Join Game
              </button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("join", %{"player_name" => player_name}, socket) do
    IO.inspect(player_name, label: "player_name")

    socket
    |> redirect(to: ~p"/game/#{socket.assigns.game_id}/join_game?player_name=#{player_name}")
    |> noreply()
  end

  def handle_event("validate", %{"player_name" => player_name}, socket) do
    name_length =
      player_name
      |> String.trim()
      |> String.length()

    valid? =
      name_length >= socket.assigns.min_name_length and
        name_length <= socket.assigns.max_name_length

    socket
    |> assign(valid_player_name: valid?)
    |> noreply()
  end
end
