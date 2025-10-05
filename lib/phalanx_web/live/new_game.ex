defmodule PhalanxWeb.Live.NewGame do
  use PhalanxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={:public}>
      <div class="min-h-screen bg-gradient-to-br from-blue-900 via-purple-900 to-indigo-900 flex items-center justify-center">
        <div class="text-center space-y-8 p-8">
          <h1 class="text-6xl font-bold text-white mb-4 tracking-wide">
            Phalanx
          </h1>

          <div class="flex justify-center">
            <.link
              href={~p"/game/new"}
              method="POST"
              class="bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white font-bold py-6 px-12 rounded-xl text-2xl shadow-2xl transform hover:scale-105 transition-all duration-200 border-2 border-red-500 hover:border-red-400"
            >
              Start Game
            </.link>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
