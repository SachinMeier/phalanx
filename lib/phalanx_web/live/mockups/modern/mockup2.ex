defmodule PhalanxWeb.Live.Mockups.Modern.Mockup2 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-blue-950 to-slate-900 p-8">
      <div class="max-w-7xl mx-auto">
        <div class="mb-8">
          <.link navigate={~p"/mockups/modern"} class="text-amber-400 hover:text-amber-300 mb-4 inline-block">
            ← Back to Mockups
          </.link>
          <h1 class="text-4xl font-bold text-amber-100 mb-2">Phalanx Formation Display</h1>
          <p class="text-slate-300">Formation bonuses: side cohesion and depth</p>
        </div>

        <div class="space-y-16">
          <div class="bg-slate-800/50 rounded-lg p-8 border border-amber-900/30">
            <h2 class="text-2xl font-bold text-amber-200 mb-4">Line Formation: Side Cohesion</h2>
            <p class="text-slate-300 mb-6">Units with allies on left+right (same facing) gain +2 strength each</p>

            <div class="relative flex items-center justify-center gap-2">
              <.formation_unit name="A" strength={0} position="left" />
              <.formation_bond />
              <.formation_unit name="B" strength={2} position="middle" />
              <.formation_bond />
              <.formation_unit name="C" strength={2} position="middle" />
              <.formation_bond />
              <.formation_unit name="D" strength={2} position="middle" />
              <.formation_bond />
              <.formation_unit name="E" strength={0} position="right" />
            </div>

            <div class="mt-6 p-4 bg-amber-900/20 rounded border border-amber-700/30">
              <p class="text-amber-200 text-sm">
                <span class="font-bold">Formation rule:</span> Units B, C, D have allies on both sides + same facing → +2 strength bonus
              </p>
            </div>
          </div>

          <div class="bg-slate-800/50 rounded-lg p-8 border border-amber-900/30">
            <h2 class="text-2xl font-bold text-amber-200 mb-4">Column Formation: Depth Bonus</h2>
            <p class="text-slate-300 mb-6">Units with allies directly behind them gain +1 strength per supporting rank</p>

            <div class="relative flex flex-col items-center gap-2">
              <.formation_unit name="F" strength={2} position="front" />
              <.depth_bond />
              <.formation_unit name="G" strength={1} position="middle" />
              <.depth_bond />
              <.formation_unit name="H" strength={0} position="rear" />
            </div>

            <div class="mt-6 p-4 bg-amber-900/20 rounded border border-amber-700/30">
              <p class="text-amber-200 text-sm">
                <span class="font-bold">Formation rule:</span> F has 2 behind → +2 strength | G has 1 behind → +1 strength
              </p>
            </div>
          </div>

          <div class="bg-slate-800/50 rounded-lg p-8 border border-amber-900/30">
            <h2 class="text-2xl font-bold text-amber-200 mb-4">Isolated Unit: No Formation Bonus</h2>
            <p class="text-slate-300 mb-6">Without adjacent allies in formation, unit has base strength only</p>

            <div class="flex items-center justify-center">
              <.formation_unit name="Z" strength={0} position="isolated" />
            </div>

            <div class="mt-6 p-4 bg-red-900/20 rounded border border-red-700/30">
              <p class="text-red-200 text-sm">
                <span class="font-bold">Vulnerable:</span> No formation bonuses, exposed to flanking attacks
              </p>
            </div>
          </div>

          <div class="bg-slate-800/50 rounded-lg p-8 border border-amber-900/30">
            <h2 class="text-2xl font-bold text-amber-200 mb-4">Combined Formation: Side + Depth</h2>
            <p class="text-slate-300 mb-6">Units can benefit from both side cohesion and depth simultaneously</p>

            <div class="relative flex flex-col items-center gap-2">
              <div class="flex items-center gap-2">
                <.formation_unit name="I" strength={2} position="front-left" />
                <.formation_bond />
                <.formation_unit name="J" strength={4} position="front-middle" />
                <.formation_bond />
                <.formation_unit name="K" strength={2} position="front-right" />
              </div>
              <div class="flex items-center gap-2">
                <div class="w-16"></div>
                <.depth_bond />
                <div class="w-16"></div>
              </div>
              <div class="flex items-center gap-2">
                <.formation_unit name="L" strength={2} position="rear-left" />
                <.formation_bond />
                <.formation_unit name="M" strength={2} position="rear-middle" />
                <.formation_bond />
                <.formation_unit name="N" strength={2} position="rear-right" />
              </div>
            </div>

            <div class="mt-6 p-4 bg-emerald-900/20 rounded border border-emerald-700/30">
              <p class="text-emerald-200 text-sm">
                <span class="font-bold">Maximum strength:</span> Unit J has side cohesion (+2) and depth (+1) = +3 total bonus
              </p>
            </div>
          </div>
        </div>

        <div class="mt-12 bg-slate-800/30 rounded-lg p-6 border border-slate-700">
          <h3 class="text-xl font-bold text-slate-200 mb-4">Formation Symbols</h3>
          <div class="grid grid-cols-3 gap-6">
            <div>
              <div class="flex items-center gap-2 mb-2">
                <div class="w-12 h-1 bg-amber-400/60 rounded"></div>
                <span class="text-slate-300 text-sm">Side bond</span>
              </div>
              <p class="text-xs text-slate-400">Adjacent units, same facing</p>
            </div>
            <div>
              <div class="flex items-center gap-2 mb-2">
                <div class="w-1 h-12 bg-emerald-400/60 rounded"></div>
                <span class="text-slate-300 text-sm">Depth bond</span>
              </div>
              <p class="text-xs text-slate-400">Units in column, pushing forward</p>
            </div>
            <div>
              <div class="flex items-center gap-2 mb-2">
                <div class="px-2 py-1 bg-amber-500 text-slate-900 rounded text-xs font-bold">+2</div>
                <span class="text-slate-300 text-sm">Strength bonus</span>
              </div>
              <p class="text-xs text-slate-400">Formation advantage in combat</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp formation_unit(assigns) do
    glow = if assigns.position in ["middle", "front-middle"], do: "drop-shadow-[0_0_8px_rgba(251,191,36,0.5)]", else: ""
    assigns = assign(assigns, :glow, glow)

    ~H"""
    <div class="relative flex flex-col items-center">
      <div :if={@strength > 0} class="absolute -top-2 -right-2 z-10 px-2 py-1 bg-amber-500 text-slate-900 rounded text-xs font-bold shadow-lg">
        +<%= @strength %>
      </div>

      <svg viewBox="0 0 100 115.47" width="60" height="69.28" class={@glow}>
        <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#1e3a8a" stroke="#3b82f6" stroke-width="3" />
        <%!-- Chevron health bars --%>
        <polyline points="15,35.21 50,15 85,35.21" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
        <polyline points="25,39.44 50,25 75,39.44" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
        <polyline points="35,43.66 50,35 65,43.66" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
        <%!-- Facing arrow indicator --%>
        <path d="M 50,55 L 50,75 M 42,67 L 50,75 L 58,67" stroke="#fbbf24" stroke-width="3" fill="none" />
        <text x="50" y="95" text-anchor="middle" dominant-baseline="middle" fill="white" font-size="20" font-weight="bold">
          <%= @name %>
        </text>
      </svg>
    </div>
    """
  end

  defp formation_bond(assigns) do
    ~H"""
    <div class="relative w-8 h-1 bg-gradient-to-r from-amber-400/60 via-amber-300/80 to-amber-400/60 rounded shadow-lg">
      <div class="absolute inset-0 bg-amber-400/30 blur-sm"></div>
    </div>
    """
  end

  defp depth_bond(assigns) do
    ~H"""
    <div class="relative h-8 w-1 bg-gradient-to-b from-emerald-400/60 via-emerald-300/80 to-emerald-400/60 rounded shadow-lg">
      <div class="absolute inset-0 bg-emerald-400/30 blur-sm"></div>
    </div>
    """
  end
end
