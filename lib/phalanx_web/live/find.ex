defmodule PhalanxWeb.Live.Find do
  use PhalanxWeb, :live_view

  def mount(_params, session, socket) do
    case PhalanxWeb.GameSession.rejoin_game_from_session(session, socket) do
      {:found, socket} ->
        {:ok, socket}

      {:not_found, socket} ->
        socket
        |> assign(
          valid_game_id: false,
          games: Phalanx.DynamicSupervisor.list_games()
        )
        |> ok()
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-6">
        <.header>
          Find Games
          <:subtitle>
            Join an existing game or create a new one
          </:subtitle>
          <:actions>
            <.button navigate={~p"/new_game"} variant="primary">
              <.icon name="hero-plus" class="size-4" />
              New Game
            </.button>
          </:actions>
        </.header>

        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">
              <.icon name="hero-play" class="size-5" />
              Available Games (<%= length(@games) %>)
            </h2>

            <div :if={@games == []} class="text-center py-8 text-base-content/70">
              <div class="flex flex-col items-center gap-4">
                <div class="text-6xl">🎮</div>
                <div>
                  <h3 class="text-lg font-semibold">No games available</h3>
                  <p>Create the first game to get started!</p>
                </div>
                <.button navigate={~p"/new_game"} variant="primary" class="mt-4">
                  <.icon name="hero-plus" class="size-4" />
                  Create First Game
                </.button>
              </div>
            </div>

            <div :if={@games != []} class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              <%= for game <- @games do %>
                <div class="card bg-base-200 shadow-md hover:shadow-lg transition-shadow">
                  <div class="card-body">
                    <div class="flex items-center justify-between">
                      <h3 class="card-title text-lg">
                        <.icon name="hero-gamepad-20-solid" class="size-5" />
                        Game <%= String.slice(game.id, 0, 8) %>
                      </h3>
                      <div class="badge badge-primary badge-sm">
                        Active
                      </div>
                    </div>

                    <div class="text-sm text-base-content/70 mb-4">
                      <div class="flex items-center gap-2">
                        <.icon name="hero-users" class="size-4" />
                        <span>Players: <%= length(game.players || []) %></span>
                      </div>
                    </div>

                    <div class="card-actions justify-end">
                      <.button navigate={~p"/game/#{game.id}"} class="btn-primary btn-sm">
                        <.icon name="hero-arrow-right" class="size-4" />
                        Join Game
                      </.button>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title">
              <.icon name="hero-information-circle" class="size-5" />
              How to Play
            </h2>
            <div class="prose max-w-none">
              <p>Phalanx is a strategic hex-based game where you command units in tactical combat.</p>
              <ul class="list-disc list-inside space-y-2">
                <li>Use keyboard controls to select and move units</li>
                <li>Plan your moves carefully - strategy is key!</li>
                <li>Join an existing game or create your own</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
