defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup5 do
  @moduledoc "Retreat & Dislodgement - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="Retreat" />

        <.scroll_panel title="Forced Retreat">
          <p class="text-sm mb-4" style="color: #6b4423;">When outmatched, the loser is pushed back one hex</p>
          <div class="flex justify-center py-4">
            <svg viewBox="0 0 320 100" width="360" height="112">
              <polygon points="50,25 70,37 70,61 50,73 30,61 30,37" fill="#8b0000" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
              <polyline points="42,41 50,33 58,41" stroke="#fff8e7" stroke-width="3" fill="none" />
              <text x="50" y="58" text-anchor="middle" fill="#fff8e7" font-size="14" font-weight="bold">A</text>
              <text x="50" y="90" text-anchor="middle" fill="#22c55e" font-size="11" font-weight="bold">STR 8</text>

              <polygon points="80,40 100,40 100,35 120,50 100,65 100,60 80,60" fill="#ff6600" />

              <g style="opacity: 0.4;">
                <polygon points="140,25 160,37 160,61 140,73 120,61 120,37" fill="#4a1259" stroke="#ff4444" stroke-width="2" stroke-dasharray="6" />
                <text x="140" y="58" text-anchor="middle" fill="#fff8e7" font-size="14" font-weight="bold">B</text>
              </g>

              <polygon points="180,40 200,40 200,35 220,50 200,65 200,60 180,60" fill="#ff4444" />

              <polygon points="250,25 270,37 270,61 250,73 230,61 230,37" fill="#4a1259" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
              <polyline points="266,37 266,61" stroke="#fff8e7" stroke-width="3" fill="none" />
              <text x="250" y="58" text-anchor="middle" fill="#fff8e7" font-size="14" font-weight="bold">B</text>
              <text x="250" y="90" text-anchor="middle" fill="#ff4444" font-size="11" font-weight="bold">STR 5</text>
            </svg>
          </div>
          <p class="text-center text-sm font-semibold" style="color: #aa4444;">B loses — forced to retreat east</p>
        </.scroll_panel>

        <div class="grid grid-cols-2 gap-6 mb-8">
          <.scroll_panel title="Blocked Retreat">
            <p class="text-sm mb-4" style="color: #6b4423;">No escape = extra damage taken</p>
            <div class="flex justify-center py-4">
              <svg viewBox="0 0 180 130" width="200" height="144">
                <polygon points="60,30 80,42 80,66 60,78 40,66 40,42" fill="#4a1259" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
                <text x="60" y="62" text-anchor="middle" fill="#fff8e7" font-size="14" font-weight="bold">C</text>

                <polygon points="95,45 115,45 115,40 130,55 115,70 115,65 95,65" fill="#ff4444" opacity="0.4" />
                <text x="113" y="60" text-anchor="middle" fill="#ff4444" font-size="16" font-weight="bold">×</text>

                <rect x="130" y="50" width="40" height="50" fill="#555" stroke="#333" stroke-width="2" rx="3" />
                <text x="150" y="80" text-anchor="middle" fill="#888" font-size="10">WALL</text>

                <polygon points="60,100" fill="none" />
              </svg>
            </div>
            <div class="p-2 rounded text-center mt-2" style="background: rgba(255, 100, 100, 0.2);">
              <span class="text-sm" style="color: #ff6666;">+1 damage from being trapped</span>
            </div>
          </.scroll_panel>

          <.scroll_panel title="Cascade Retreat">
            <p class="text-sm mb-4" style="color: #6b4423;">Retreat into ally = chain reaction</p>
            <div class="flex justify-center py-4">
              <svg viewBox="0 0 200 80" width="220" height="88">
                <polygon points="40,20 60,32 60,56 40,68 20,56 20,32" fill="#8b0000" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
                <text x="40" y="48" text-anchor="middle" fill="#fff8e7" font-size="14" font-weight="bold">E</text>

                <polygon points="68,30 83,30 83,25 98,40 83,55 83,50 68,50" fill="#ffd700" />

                <polygon points="110,20 130,32 130,56 110,68 90,56 90,32" fill="#4a1259" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
                <text x="110" y="48" text-anchor="middle" fill="#fff8e7" font-size="14" font-weight="bold">F</text>

                <polygon points="138,30 153,30 153,25 168,40 153,55 153,50 138,50" fill="#ffd700" />

                <polygon points="180,20 200,32 200,56 180,68 160,56 160,32" fill="#4a1259" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
                <text x="180" y="48" text-anchor="middle" fill="#fff8e7" font-size="14" font-weight="bold">G</text>
              </svg>
            </div>
            <p class="text-center text-sm" style="color: #ffd700;">F retreats into G → G also retreats</p>
          </.scroll_panel>
        </div>

        <.scroll_panel title="Retreat Priority">
          <div class="grid grid-cols-3 gap-4">
            <div class="p-4 rounded text-center" style="background: rgba(61, 40, 23, 0.3);">
              <div class="text-lg font-bold mb-1" style="color: #e8d4b8;">1st</div>
              <div class="text-sm" style="color: #a08060;">Away from attacker</div>
            </div>
            <div class="p-4 rounded text-center" style="background: rgba(61, 40, 23, 0.3);">
              <div class="text-lg font-bold mb-1" style="color: #e8d4b8;">2nd</div>
              <div class="text-sm" style="color: #a08060;">Toward own lines</div>
            </div>
            <div class="p-4 rounded text-center" style="background: rgba(61, 40, 23, 0.3);">
              <div class="text-lg font-bold mb-1" style="color: #e8d4b8;">3rd</div>
              <div class="text-sm" style="color: #a08060;">Empty hex only</div>
            </div>
          </div>
        </.scroll_panel>
      </div>
    </div>
    """
  end

  defp nav_header(assigns) do
    ~H"""
    <div class="mb-8 flex items-center justify-between">
      <.link navigate={~p"/mockups/siegius"} class="text-amber-600 hover:text-amber-400 text-sm transition-colors">
        ← Back to Mockups
      </.link>
      <h1 class="text-2xl font-bold" style="color: #e8d4b8; font-family: 'Cinzel', serif;">
        {@title}
      </h1>
      <div class="w-24"></div>
    </div>
    """
  end

  defp scroll_panel(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="relative">
        <div class="absolute -top-3 left-8 right-8 h-5 rounded-t-lg" style="background: linear-gradient(90deg, #6b4423, #8b6914, #6b4423);"></div>
        <div class="pt-4 pb-6 px-6 rounded" style="background: linear-gradient(180deg, #e8d4b8 0%, #ddd0ba 100%); border: 2px solid #8b6914;">
          <h2 class="text-lg font-semibold mb-4" style="color: #3d2817; font-family: 'Cinzel', serif; border-bottom: 1px solid #8b6914; padding-bottom: 8px;">
            {@title}
          </h2>
          {render_slot(@inner_block)}
        </div>
        <div class="absolute -bottom-3 left-8 right-8 h-5 rounded-b-lg" style="background: linear-gradient(90deg, #6b4423, #8b6914, #6b4423);"></div>
      </div>
    </div>
    """
  end
end
