defmodule PhalanxWeb.Live.Mockups.Mockup8 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-stone-950 via-neutral-900 to-stone-950 p-4">
      <div class="max-w-7xl mx-auto space-y-4">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-amber-50">Full Battle Scene</h1>
            <p class="text-sm text-stone-400">Mockup 8: Mid-game combat with formations</p>
          </div>
          <.link navigate={~p"/mockups"} class="btn btn-sm btn-ghost text-stone-300 hover:text-amber-50">← Back to Mockups</.link>
        </div>

        <!-- Game Status Panel -->
        <div class="bg-stone-900/50 border border-stone-700 rounded-lg p-4">
          <div class="grid grid-cols-4 gap-4">
            <div>
              <div class="text-xs text-stone-500 uppercase">Turn</div>
              <div class="text-2xl font-bold text-amber-400">12</div>
            </div>
            <div>
              <div class="text-xs text-stone-500 uppercase">Phase</div>
              <div class="text-lg font-semibold text-emerald-400">Combat Resolution</div>
            </div>
            <div>
              <div class="text-xs text-stone-500 uppercase">Red Army</div>
              <div class="flex items-center gap-2">
                <div class="w-3 h-3 bg-red-500 rounded-full"></div>
                <span class="text-lg font-semibold text-stone-200">5 Units</span>
              </div>
            </div>
            <div>
              <div class="text-xs text-stone-500 uppercase">Purple Army</div>
              <div class="flex items-center gap-2">
                <div class="w-3 h-3 bg-purple-500 rounded-full"></div>
                <span class="text-lg font-semibold text-stone-200">5 Units</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Battle Grid -->
        <div class="bg-stone-900/30 border border-stone-800 rounded-lg p-6">
          <svg viewBox="0 0 700 500" class="w-full max-w-4xl mx-auto">
            <!-- Grid background -->
            <defs>
              <pattern id="hex-pattern" patternUnits="userSpaceOnUse" width="69.28" height="80">
                <polygon points="34.64,0 69.28,20 69.28,60 34.64,80 0,60 0,20" fill="none" stroke="#374151" stroke-width="0.5" />
              </pattern>
            </defs>
            <rect width="700" height="500" fill="url(#hex-pattern)" opacity="0.3" />

            <!-- Purple Army (top) -->
            <g transform="translate(200, 50)">
              <.battle_unit name="H" color="purple" health={3} />
            </g>
            <g transform="translate(270, 50)">
              <.battle_unit name="J" color="purple" health={3} />
            </g>
            <g transform="translate(340, 50)">
              <.battle_unit name="K" color="purple" health={2} />
            </g>

            <!-- Purple second rank -->
            <g transform="translate(235, 120)">
              <.battle_unit name="L" color="purple" health={3} />
            </g>
            <g transform="translate(305, 120)">
              <.battle_unit name="M" color="purple" health={3} />
            </g>

            <!-- Formation outline for purple -->
            <path d="M 190,40 L 410,40 L 410,180 L 190,180 Z" stroke="#9333ea" stroke-width="2" fill="none" stroke-dasharray="5,5" opacity="0.5" />

            <!-- Red Army (bottom) -->
            <g transform="translate(150, 300)">
              <.battle_unit name="Y" color="red" health={2} />
            </g>
            <g transform="translate(220, 300)">
              <.battle_unit name="U" color="red" health={3} />
            </g>

            <g transform="translate(185, 370)">
              <.battle_unit name="I" color="red" health={3} />
            </g>
            <g transform="translate(255, 370)">
              <.battle_unit name="O" color="red" health={2} />
            </g>
            <g transform="translate(325, 370)">
              <.battle_unit name="P" color="red" health={1} />
            </g>

            <!-- Attack arrows -->
            <defs>
              <marker id="battle-arrow" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                <polygon points="0 0, 10 3, 0 6" fill="#fbbf24" />
              </marker>
            </defs>

            <!-- Attack: I toward K -->
            <line x1="215" y1="370" x2="350" y2="110" stroke="#fbbf24" stroke-width="2" marker-end="url(#battle-arrow)" stroke-dasharray="6,3" opacity="0.7" />

            <!-- Clash indicator -->
            <g transform="translate(280, 220)">
              <circle r="20" fill="#fbbf24" opacity="0.3" />
              <text x="0" y="5" text-anchor="middle" fill="#fbbf24" font-size="16" font-weight="bold">⚔</text>
            </g>

            <!-- Turn indicator -->
            <g transform="translate(550, 50)">
              <rect width="120" height="60" rx="8" fill="#1f2937" stroke="#4b5563" stroke-width="2" />
              <text x="60" y="25" text-anchor="middle" fill="#9ca3af" font-size="12">TURN</text>
              <text x="60" y="50" text-anchor="middle" fill="#fbbf24" font-size="24" font-weight="bold">12</text>
            </g>
          </svg>

          <!-- Formation Indicators -->
          <div class="mt-6 grid grid-cols-2 gap-4">
            <div class="bg-purple-950/30 border border-purple-700/50 rounded-lg p-4">
              <div class="text-sm font-semibold text-purple-300 mb-2">Purple Phalanx</div>
              <div class="space-y-1 text-xs text-purple-200">
                <div>Front Line: H, J, K (3 wide)</div>
                <div>Second Rank: L, M (depth +2)</div>
                <div>Formation Strength: +5</div>
              </div>
            </div>
            <div class="bg-red-950/30 border border-red-700/50 rounded-lg p-4">
              <div class="text-sm font-semibold text-red-300 mb-2">Red Formation</div>
              <div class="space-y-1 text-xs text-red-200">
                <div>Front: Y, U (2 wide)</div>
                <div>Main: I, O, P (scattered)</div>
                <div>Formation Strength: +2</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Combat Status -->
        <div class="bg-amber-950/20 border border-amber-700/50 rounded-lg p-4">
          <div class="text-sm font-semibold text-amber-300 mb-3">Active Combat</div>
          <div class="space-y-2 text-sm text-stone-300">
            <div class="flex items-center gap-3">
              <span class="font-mono text-purple-400">H→U</span>
              <span class="text-xs text-stone-500">Front Attack</span>
              <span class="badge badge-sm bg-purple-900/50">Str: 8</span>
              <span class="text-stone-500">vs</span>
              <span class="badge badge-sm bg-red-900/50">Str: 6</span>
            </div>
            <div class="flex items-center gap-3">
              <span class="font-mono text-red-400">I→K</span>
              <span class="text-xs text-stone-500">Flank Attempt</span>
              <span class="badge badge-sm bg-red-900/50">Str: 5</span>
              <span class="text-stone-500">vs</span>
              <span class="badge badge-sm bg-purple-900/50">Str: 7</span>
            </div>
            <div class="flex items-center gap-3">
              <span class="font-mono text-red-400">P→M</span>
              <span class="text-xs text-stone-500">Weak Attack</span>
              <span class="badge badge-sm bg-red-900/50">Str: 3</span>
              <span class="text-stone-500">vs</span>
              <span class="badge badge-sm bg-purple-900/50">Str: 9</span>
            </div>
          </div>
        </div>

        <!-- Legend -->
        <div class="bg-stone-900/30 border border-stone-800 rounded-lg p-4">
          <div class="text-sm font-semibold text-stone-300 mb-3">Tactical Situation</div>
          <div class="grid grid-cols-2 gap-4 text-xs text-stone-400">
            <div>
              <div class="font-semibold text-purple-300 mb-1">Purple Advantage</div>
              <ul class="list-disc list-inside space-y-1">
                <li>Superior formation cohesion</li>
                <li>3-wide front line</li>
                <li>Depth bonus from second rank</li>
              </ul>
            </div>
            <div>
              <div class="font-semibold text-red-300 mb-1">Red Disadvantage</div>
              <ul class="list-disc list-inside space-y-1">
                <li>Scattered formation</li>
                <li>Unit P critically wounded</li>
                <li>No effective flanking position</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp battle_unit(assigns) do
    fill = if assigns.color == "red", do: "#dc2626", else: "#9333ea"
    stroke = if assigns.color == "red", do: "#fca5a5", else: "#c4b5fd"

    health_color =
      case assigns.health do
        3 -> "#22c55e"
        2 -> "#eab308"
        1 -> "#ef4444"
        _ -> "#6b7280"
      end

    assigns = assign(assigns, fill: fill, stroke: stroke, health_color: health_color)

    ~H"""
    <g>
      <%!-- Regular hexagon scaled to 50x57.7 --%>
      <polygon points="25,0 50,14.43 50,43.3 25,57.74 0,43.3 0,14.43" fill={@fill} stroke={@stroke} stroke-width="1.5" />
      <%!-- Chevron health bars (scaled from 100x115.47 viewBox) --%>
      <polyline :if={@health >= 1} points="7.5,17.6 25,7.5 42.5,17.6" stroke={@health_color} stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none" />
      <polyline :if={@health >= 2} points="12.5,19.7 25,12.5 37.5,19.7" stroke={@health_color} stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none" />
      <polyline :if={@health >= 3} points="17.5,21.8 25,17.5 32.5,21.8" stroke={@health_color} stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none" />
      <%!-- Name --%>
      <text x="25" y="42" text-anchor="middle" fill="white" font-size="14" font-weight="bold" font-family="monospace"><%= @name %></text>
    </g>
    """
  end
end
