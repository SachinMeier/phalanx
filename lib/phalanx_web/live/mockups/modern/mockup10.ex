defmodule PhalanxWeb.Live.Mockups.Modern.Mockup10 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:red_joined, false)
      |> assign(:purple_joined, false)
      |> assign(:selected_team, nil)

    {:ok, socket}
  end

  def handle_event("join_team", %{"team" => team}, socket) do
    case team do
      "red" -> {:noreply, assign(socket, red_joined: true, selected_team: :red)}
      "purple" -> {:noreply, assign(socket, purple_joined: true, selected_team: :purple)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("leave_team", _, socket) do
    socket =
      case socket.assigns.selected_team do
        :red -> assign(socket, red_joined: false, selected_team: nil)
        :purple -> assign(socket, purple_joined: false, selected_team: nil)
        _ -> socket
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-amber-950 via-stone-900 to-red-950 p-8">
      <div class="mb-6">
        <a href={~p"/mockups/modern"} class="text-amber-400 hover:text-amber-300 transition-colors">← Back to Mockups</a>
      </div>

      <div class="text-center mb-12">
        <h1 class="text-6xl font-bold text-amber-100 mb-4 tracking-wider">PREPARE FOR BATTLE</h1>
        <p class="text-xl text-amber-300/80">Choose your legion and march to glory</p>
      </div>

      <div class="grid grid-cols-2 gap-12 max-w-7xl mx-auto mb-8">
        <!-- RED TEAM -->
        <div class="relative">
          <div class="bg-gradient-to-br from-red-950 to-red-900 border-4 border-red-600 rounded-lg shadow-2xl overflow-hidden">
            <div class="bg-red-800/50 border-b-4 border-red-600 p-6 text-center relative">
              <div class="absolute inset-0 bg-gradient-to-r from-red-900/20 via-amber-500/10 to-red-900/20"></div>
              <div class="relative">
                <div class="text-6xl mb-3">🦅</div>
                <h2 class="text-4xl font-bold text-amber-100 mb-2 tracking-wide">LEGIO RUBRA</h2>
                <div class="flex items-center justify-center gap-2">
                  <div class="h-px w-16 bg-amber-500"></div>
                  <p class="text-sm text-amber-400 tracking-[0.3em]">S·P·Q·R</p>
                  <div class="h-px w-16 bg-amber-500"></div>
                </div>
              </div>
            </div>

            <div class="p-8">
              <h3 class="text-xl font-semibold text-amber-200 mb-4 text-center border-b border-red-700/50 pb-2">Your Cohort</h3>
              <div class="space-y-3">
                <%= for {name, label} <- [{"Y", "Prima Cohort"}, {"U", "Secunda Cohort"}, {"I", "Tertia Cohort"}, {"O", "Quarta Cohort"}, {"P", "Quinta Cohort"}] do %>
                  <div class="flex items-center gap-4 bg-red-900/30 border border-red-700/40 rounded p-3 hover:bg-red-900/50 transition-all">
                    <div class="w-12 h-12 bg-red-700 border-2 border-amber-500 rounded flex items-center justify-center">
                      <span class="text-2xl font-bold text-amber-100"><%= name %></span>
                    </div>
                    <div class="flex-1">
                      <div class="font-semibold text-amber-100"><%= label %></div>
                      <div class="text-xs text-red-300">Keyboard: <%= name %></div>
                    </div>
                    <div class="flex gap-1">
                      <%= for _ <- 1..3 do %>
                        <div class="w-2 h-8 bg-amber-500/70 rounded-sm"></div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>

            <div class="p-6 border-t-4 border-red-700 bg-red-950/70">
              <%= if @red_joined do %>
                <div class="space-y-3">
                  <div class="bg-amber-500/20 border-2 border-amber-500 rounded-lg p-4 text-center">
                    <div class="text-2xl mb-2">⚔️</div>
                    <p class="text-amber-100 font-semibold mb-1">You have joined the Red Legion</p>
                    <p class="text-sm text-amber-300"><%= if @purple_joined, do: "Battle begins shortly...", else: "Waiting for opponent..." %></p>
                  </div>
                  <button phx-click="leave_team" class="w-full py-3 bg-red-900/50 border-2 border-red-600 text-red-300 rounded-lg hover:bg-red-900 transition-all font-semibold">Leave Team</button>
                </div>
              <% else %>
                <button phx-click="join_team" phx-value-team="red" class="w-full py-4 bg-gradient-to-br from-red-700 to-red-800 hover:from-red-600 hover:to-red-700 border-2 border-amber-500 text-amber-100 rounded-lg transition-all shadow-lg hover:shadow-xl transform hover:scale-105 font-bold text-xl" disabled={@selected_team == :purple}>
                  <div class="flex items-center justify-center gap-3">
                    <span class="text-2xl">🛡️</span>
                    <span>JOIN RED LEGION</span>
                    <span class="text-2xl">⚔️</span>
                  </div>
                </button>
              <% end %>
            </div>
          </div>

          <div class="absolute -right-6 top-1/2 -translate-y-1/2 z-10">
            <%= if @red_joined do %>
              <div class="w-12 h-12 bg-green-500 border-4 border-green-300 rounded-full flex items-center justify-center shadow-lg"><span class="text-2xl">✓</span></div>
            <% else %>
              <div class="w-12 h-12 bg-stone-700 border-4 border-stone-600 rounded-full flex items-center justify-center shadow-lg animate-pulse"><span class="text-2xl">⏳</span></div>
            <% end %>
          </div>
        </div>

        <!-- PURPLE TEAM -->
        <div class="relative">
          <div class="bg-gradient-to-br from-purple-950 to-purple-900 border-4 border-purple-600 rounded-lg shadow-2xl overflow-hidden">
            <div class="bg-purple-800/50 border-b-4 border-purple-600 p-6 text-center relative">
              <div class="absolute inset-0 bg-gradient-to-r from-purple-900/20 via-indigo-500/10 to-purple-900/20"></div>
              <div class="relative">
                <div class="text-6xl mb-3">👑</div>
                <h2 class="text-4xl font-bold text-indigo-100 mb-2 tracking-wide">LEGIO PURPURA</h2>
                <div class="flex items-center justify-center gap-2">
                  <div class="h-px w-16 bg-indigo-400"></div>
                  <p class="text-sm text-indigo-300 tracking-[0.3em]">IMPERIUM</p>
                  <div class="h-px w-16 bg-indigo-400"></div>
                </div>
              </div>
            </div>

            <div class="p-8">
              <h3 class="text-xl font-semibold text-indigo-200 mb-4 text-center border-b border-purple-700/50 pb-2">Your Cohort</h3>
              <div class="space-y-3">
                <%= for {name, label} <- [{"H", "Prima Cohort"}, {"J", "Secunda Cohort"}, {"K", "Tertia Cohort"}, {"L", "Quarta Cohort"}, {"M", "Quinta Cohort"}] do %>
                  <div class="flex items-center gap-4 bg-purple-900/30 border border-purple-700/40 rounded p-3 hover:bg-purple-900/50 transition-all">
                    <div class="w-12 h-12 bg-purple-700 border-2 border-indigo-400 rounded flex items-center justify-center">
                      <span class="text-2xl font-bold text-indigo-100"><%= name %></span>
                    </div>
                    <div class="flex-1">
                      <div class="font-semibold text-indigo-100"><%= label %></div>
                      <div class="text-xs text-purple-300">Keyboard: <%= name %></div>
                    </div>
                    <div class="flex gap-1">
                      <%= for _ <- 1..3 do %>
                        <div class="w-2 h-8 bg-indigo-400/70 rounded-sm"></div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>

            <div class="p-6 border-t-4 border-purple-700 bg-purple-950/70">
              <%= if @purple_joined do %>
                <div class="space-y-3">
                  <div class="bg-indigo-500/20 border-2 border-indigo-400 rounded-lg p-4 text-center">
                    <div class="text-2xl mb-2">⚔️</div>
                    <p class="text-indigo-100 font-semibold mb-1">You have joined the Purple Legion</p>
                    <p class="text-sm text-indigo-300"><%= if @red_joined, do: "Battle begins shortly...", else: "Waiting for opponent..." %></p>
                  </div>
                  <button phx-click="leave_team" class="w-full py-3 bg-purple-900/50 border-2 border-purple-600 text-purple-300 rounded-lg hover:bg-purple-900 transition-all font-semibold">Leave Team</button>
                </div>
              <% else %>
                <button phx-click="join_team" phx-value-team="purple" class="w-full py-4 bg-gradient-to-br from-purple-700 to-purple-800 hover:from-purple-600 hover:to-purple-700 border-2 border-indigo-400 text-indigo-100 rounded-lg transition-all shadow-lg hover:shadow-xl transform hover:scale-105 font-bold text-xl" disabled={@selected_team == :red}>
                  <div class="flex items-center justify-center gap-3">
                    <span class="text-2xl">⚔️</span>
                    <span>JOIN PURPLE LEGION</span>
                    <span class="text-2xl">🛡️</span>
                  </div>
                </button>
              <% end %>
            </div>
          </div>

          <div class="absolute -left-6 top-1/2 -translate-y-1/2 z-10">
            <%= if @purple_joined do %>
              <div class="w-12 h-12 bg-green-500 border-4 border-green-300 rounded-full flex items-center justify-center shadow-lg"><span class="text-2xl">✓</span></div>
            <% else %>
              <div class="w-12 h-12 bg-stone-700 border-4 border-stone-600 rounded-full flex items-center justify-center shadow-lg animate-pulse"><span class="text-2xl">⏳</span></div>
            <% end %>
          </div>
        </div>
      </div>

      <%= if @red_joined and @purple_joined do %>
        <div class="max-w-3xl mx-auto">
          <div class="bg-gradient-to-r from-amber-900/50 via-green-900/50 to-indigo-900/50 border-4 border-amber-500 rounded-lg p-8 text-center animate-pulse">
            <div class="text-5xl mb-4">⚔️ 🛡️ ⚔️</div>
            <h3 class="text-3xl font-bold text-amber-100 mb-3">BOTH LEGIONS ASSEMBLED</h3>
            <p class="text-xl text-amber-200 mb-4">The battle is about to begin...</p>
            <button class="px-8 py-4 bg-gradient-to-r from-green-600 to-green-700 hover:from-green-500 hover:to-green-600 text-white rounded-lg font-bold text-xl shadow-xl transform hover:scale-105 transition-all">START BATTLE →</button>
          </div>
        </div>
      <% end %>

      <div class="mt-12 text-center text-amber-400/60 text-sm">
        <p>Teams face off on a hex battlefield. Victory through formation, flanking, and tactics.</p>
        <p class="mt-2">Each unit is controlled by keyboard: Red (Y,U,I,O,P) vs Purple (H,J,K,L,M)</p>
      </div>
    </div>
    """
  end
end
