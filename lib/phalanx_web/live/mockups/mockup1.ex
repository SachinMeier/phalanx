defmodule PhalanxWeb.Live.Mockups.Mockup1 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-stone-900 via-amber-950 to-stone-900 p-8">
      <div class="max-w-7xl mx-auto">
        <div class="mb-8">
          <.link navigate={~p"/mockups"} class="text-amber-400 hover:text-amber-300 text-sm mb-4 inline-block">
            ← Back to Mockups
          </.link>
          <h1 class="text-4xl font-bold text-amber-100 mb-2">Unit Health & Energy States</h1>
          <p class="text-amber-300/80 text-lg">Visual progression of unit degradation in combat</p>
        </div>

        <div class="mb-16">
          <h2 class="text-2xl font-bold text-amber-200 mb-6 border-b border-amber-800 pb-2">Health States</h2>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
            <.unit_display name="A" color="#dc2626" health={3} energy={3} label="Healthy (3 HP)" description="Full strength, all spears ready" />
            <.unit_display name="B" color="#dc2626" health={2} energy={3} label="Damaged (2 HP)" description="One rank fallen" />
            <.unit_display name="C" color="#dc2626" health={1} energy={3} label="Critical (1 HP)" description="Last stand, one spear left" />
            <.unit_display name="D" color="#4a4a4a" health={0} energy={0} label="Destroyed (0 HP)" description="Unit eliminated" dead={true} />
          </div>
        </div>

        <div class="mb-16">
          <h2 class="text-2xl font-bold text-amber-200 mb-6 border-b border-amber-800 pb-2">Energy States</h2>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
            <.unit_display name="E" color="#9333ea" health={3} energy={3} label="Full Energy (3 E)" description="Can move + rotate freely" />
            <.unit_display name="F" color="#9333ea" health={3} energy={2} label="Medium Energy (2 E)" description="Limited movement" />
            <.unit_display name="G" color="#9333ea" health={3} energy={1} label="Low Energy (1 E)" description="Nearly exhausted" />
            <.unit_display name="H" color="#9333ea" health={3} energy={0} label="Exhausted (0 E)" description="Takes damage next turn!" exhausted={true} />
          </div>
        </div>

        <div class="mb-16">
          <h2 class="text-2xl font-bold text-amber-200 mb-6 border-b border-amber-800 pb-2">Combined Degradation</h2>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
            <.unit_display name="I" color="#dc2626" health={3} energy={1} label="Healthy but Tired" description="3 HP, 1 E" />
            <.unit_display name="J" color="#9333ea" health={2} energy={2} label="Wounded & Winded" description="2 HP, 2 E" />
            <.unit_display name="K" color="#dc2626" health={1} energy={1} label="Near Death" description="1 HP, 1 E - desperate" />
            <.unit_display name="L" color="#9333ea" health={1} energy={0} label="Critical & Exhausted" description="1 HP, 0 E - doomed" exhausted={true} />
          </div>
        </div>

        <div class="bg-stone-800/50 border border-amber-800/30 rounded-lg p-6">
          <h3 class="text-xl font-bold text-amber-200 mb-3">Design Notes</h3>
          <ul class="space-y-2 text-amber-300/80">
            <li class="flex items-start"><span class="text-amber-500 mr-2">•</span><span><strong class="text-amber-200">Health (spears):</strong> Visual count of remaining combat strength</span></li>
            <li class="flex items-start"><span class="text-amber-500 mr-2">•</span><span><strong class="text-amber-200">Energy (pips):</strong> Small dots below unit showing movement capacity</span></li>
            <li class="flex items-start"><span class="text-amber-500 mr-2">•</span><span><strong class="text-amber-200">Exhaustion warning:</strong> Red pulsing glow when energy = 0</span></li>
            <li class="flex items-start"><span class="text-amber-500 mr-2">•</span><span><strong class="text-amber-200">Death state:</strong> Grayed out, crossed spears</span></li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  defp unit_display(assigns) do
    assigns = assign_new(assigns, :dead, fn -> false end)
    assigns = assign_new(assigns, :exhausted, fn -> false end)

    ~H"""
    <div class="flex flex-col items-center">
      <div class={"relative #{if @exhausted, do: "animate-pulse"}"}>
        <div :if={@exhausted && !@dead} class="absolute inset-0 flex items-center justify-center">
          <div class="absolute w-20 h-20 bg-red-500/30 rounded-full blur-xl animate-pulse"></div>
        </div>

        <svg viewBox="0 0 100 115.47" width="70" height="81" class="relative z-10">
          <%!-- Regular hexagon --%>
          <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill={@color} opacity={if @dead, do: "0.3", else: "1"} />

          <%!-- Chevron health bars - arrow formation indicating facing --%>
          <polyline :if={@health > 0} points="15,35.21 50,15 85,35.21" stroke={if @dead, do: "#666", else: "white"} stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
          <polyline :if={@health > 1} points="25,39.44 50,25 75,39.44" stroke={if @dead, do: "#666", else: "white"} stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
          <polyline :if={@health > 2} points="35,43.66 50,35 65,43.66" stroke={if @dead, do: "#666", else: "white"} stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />

          <%!-- Death X --%>
          <path :if={@dead} d="M 20,30 L 80,85" stroke="#ff0000" stroke-width="4" fill="none" />
          <path :if={@dead} d="M 80,30 L 20,85" stroke="#ff0000" stroke-width="4" fill="none" />

          <text x="50" y="78" text-anchor="middle" dominant-baseline="middle" fill={if @dead, do: "#666", else: "white"} font-size="24" font-weight="bold">
            <%= @name %>
          </text>
        </svg>

        <div class="flex justify-center gap-1 mt-2">
          <%= for i <- 1..3 do %>
            <div class={"w-2 h-2 rounded-full #{if i <= @energy, do: (if @exhausted, do: "bg-red-500", else: "bg-amber-400"), else: "bg-stone-700"}"}></div>
          <% end %>
        </div>

        <div :if={@exhausted && !@dead} class="text-red-400 text-xs font-bold mt-1 text-center animate-pulse">
          EXHAUSTED
        </div>
      </div>
      <div class="mt-4 text-center">
        <div class="text-amber-100 font-bold mb-1"><%= @label %></div>
        <div class="text-amber-400/70 text-sm"><%= @description %></div>
      </div>
    </div>
    """
  end
end
