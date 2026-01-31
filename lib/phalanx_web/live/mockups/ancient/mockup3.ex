defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup3 do
  @moduledoc "Ancient theme: Combat Resolution"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen" style="background: linear-gradient(145deg, #2C2416 0%, #3D3225 50%, #2A2118 100%);">
      <div class="relative z-10 p-8 max-w-7xl mx-auto">
        <%!-- Header --%>
        <div class="mb-12">
          <.link navigate={~p"/mockups/ancient"} class="inline-flex items-center gap-2 text-amber-600 hover:text-amber-400 text-sm mb-6 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Ancient Mockups
          </.link>
          <h1 class="text-4xl font-bold mb-3" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Combat Resolution
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            The clash of shields — attack angles, strength comparison, and damage
          </p>
        </div>

        <%!-- Attack Angles Section --%>
        <div class="mb-16">
          <div class="flex items-center gap-4 mb-8">
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
            <h2 class="text-2xl font-semibold px-4" style="font-family: 'Cinzel', serif; color: #CE8946;">
              Attack Angles
            </h2>
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
          </div>

          <div class="flex justify-center mb-8">
            <svg viewBox="0 0 500 400" width="500" height="400">
              <%!-- Background --%>
              <rect width="500" height="400" fill="#3D3225" rx="12"/>

              <%!-- Central defender --%>
              <g transform="translate(200, 150)">
                <polygon
                  points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
                  fill="#5D3A8E"
                  style="filter: drop-shadow(0 3px 6px rgba(0,0,0,0.5));"
                />
                <polyline points="15,35.21 50,15 85,35.21" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                <polyline points="25,39.44 50,25 75,39.44" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                <polyline points="35,43.66 50,35 65,43.66" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                <text x="50" y="78" text-anchor="middle" dominant-baseline="middle" fill="#FFF5E6" font-size="24" font-weight="bold">Δ</text>
              </g>

              <%!-- Attack angle zones --%>
              <%!-- Front zone (green/safe) --%>
              <path d="M 250,60 L 320,100 L 320,180 L 250,150 Z" fill="rgba(34, 197, 94, 0.2)" stroke="#22c55e" stroke-width="2" stroke-dasharray="5,3"/>
              <path d="M 250,60 L 180,100 L 180,180 L 250,150 Z" fill="rgba(34, 197, 94, 0.2)" stroke="#22c55e" stroke-width="2" stroke-dasharray="5,3"/>
              <text x="250" y="45" text-anchor="middle" fill="#22c55e" font-size="14" font-weight="bold">FRONTAL</text>
              <text x="250" y="85" text-anchor="middle" fill="#22c55e" font-size="11">0 damage</text>

              <%!-- Flank zones (yellow/warning) --%>
              <path d="M 320,100 L 380,140 L 380,220 L 320,180 Z" fill="rgba(250, 205, 30, 0.2)" stroke="#FACD1E" stroke-width="2" stroke-dasharray="5,3"/>
              <text x="360" y="145" text-anchor="middle" fill="#FACD1E" font-size="12" font-weight="bold" transform="rotate(30, 360, 145)">FLANK</text>
              <text x="360" y="165" text-anchor="middle" fill="#FACD1E" font-size="10" transform="rotate(30, 360, 165)">1 HP</text>

              <path d="M 180,100 L 120,140 L 120,220 L 180,180 Z" fill="rgba(250, 205, 30, 0.2)" stroke="#FACD1E" stroke-width="2" stroke-dasharray="5,3"/>
              <text x="140" y="145" text-anchor="middle" fill="#FACD1E" font-size="12" font-weight="bold" transform="rotate(-30, 140, 145)">FLANK</text>
              <text x="140" y="165" text-anchor="middle" fill="#FACD1E" font-size="10" transform="rotate(-30, 140, 165)">1 HP</text>

              <%!-- Rear zone (red/danger) --%>
              <path d="M 180,260 L 250,300 L 320,260 L 320,180 L 250,220 L 180,180 Z" fill="rgba(127, 33, 34, 0.25)" stroke="#7F2122" stroke-width="2" stroke-dasharray="5,3"/>
              <text x="250" y="285" text-anchor="middle" fill="#7F2122" font-size="14" font-weight="bold">REAR</text>
              <text x="250" y="305" text-anchor="middle" fill="#7F2122" font-size="11">2 HP damage</text>

              <%!-- Direction arrow showing unit facing --%>
              <line x1="250" y1="130" x2="250" y2="50" stroke="#FFF5E6" stroke-width="3" marker-end="url(#arrowhead)"/>
              <defs>
                <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                  <polygon points="0 0, 10 3.5, 0 7" fill="#FFF5E6"/>
                </marker>
              </defs>
              <text x="265" y="95" fill="#FFF5E6" font-size="10">FACING</text>

              <%!-- Legend --%>
              <g transform="translate(380, 280)">
                <rect width="110" height="100" fill="rgba(0,0,0,0.3)" rx="6"/>
                <text x="55" y="20" text-anchor="middle" fill="#E5DBB7" font-size="11" font-weight="bold">DAMAGE</text>
                <circle cx="15" cy="40" r="6" fill="#22c55e"/>
                <text x="28" y="44" fill="#9D8C71" font-size="10">Frontal: 0 HP</text>
                <circle cx="15" cy="60" r="6" fill="#FACD1E"/>
                <text x="28" y="64" fill="#9D8C71" font-size="10">Flank: 1 HP</text>
                <circle cx="15" cy="80" r="6" fill="#7F2122"/>
                <text x="28" y="84" fill="#9D8C71" font-size="10">Rear: 2 HP</text>
              </g>
            </svg>
          </div>
        </div>

        <%!-- Combat Examples --%>
        <div class="grid md:grid-cols-2 gap-8 mb-16">
          <%!-- Frontal Attack --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Frontal Attack
            </h3>

            <div class="flex justify-center mb-4">
              <svg viewBox="0 0 280 160" width="280" height="160">
                <rect width="280" height="160" fill="#3D3225" rx="8"/>

                <%!-- Attacker --%>
                <g transform="translate(50, 50)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#D32929"/>
                  <polyline points="12,28.17 40,12 68,28.17" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="20,31.55 40,20 60,31.55" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="28,34.93 40,28 52,34.93" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <text x="40" y="62" text-anchor="middle" fill="#FFF5E6" font-size="18" font-weight="bold">Α</text>
                </g>

                <%!-- Arrow --%>
                <line x1="135" y1="95" x2="175" y2="95" stroke="#FACD1E" stroke-width="3" marker-end="url(#arrow2)"/>
                <defs>
                  <marker id="arrow2" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#FACD1E"/>
                  </marker>
                </defs>

                <%!-- Defender --%>
                <g transform="translate(180, 50)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#5D3A8E"/>
                  <polyline points="12,28.17 40,12 68,28.17" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="20,31.55 40,20 60,31.55" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="28,34.93 40,28 52,34.93" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <text x="40" y="62" text-anchor="middle" fill="#FFF5E6" font-size="18" font-weight="bold">Β</text>
                </g>

                <text x="140" y="155" text-anchor="middle" fill="#22c55e" font-size="12">Shields absorb impact — 0 damage</text>
              </svg>
            </div>

            <div class="p-3 rounded" style="background: rgba(34, 197, 94, 0.1); border: 1px solid rgba(34, 197, 94, 0.3);">
              <div class="flex justify-between text-sm">
                <span style="color: #9D8C71;">If dislodged:</span>
                <span class="font-bold" style="color: #22c55e;">0 HP lost</span>
              </div>
            </div>
          </div>

          <%!-- Flank Attack --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Flank Attack
            </h3>

            <div class="flex justify-center mb-4">
              <svg viewBox="0 0 280 180" width="280" height="180">
                <rect width="280" height="180" fill="#3D3225" rx="8"/>

                <%!-- Defender (facing up) --%>
                <g transform="translate(100, 70)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#5D3A8E"/>
                  <polyline points="12,28.17 40,12 68,28.17" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="20,31.55 40,20 60,31.55" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="28,34.93 40,28 52,34.93" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <text x="40" y="62" text-anchor="middle" fill="#FFF5E6" font-size="18" font-weight="bold">Β</text>
                </g>

                <%!-- Attacker coming from side --%>
                <g transform="translate(200, 45) rotate(90, 40, 46)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#D32929"/>
                  <polyline points="12,28.17 40,12 68,28.17" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="20,31.55 40,20 60,31.55" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="28,34.93 40,28 52,34.93" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <text x="40" y="62" text-anchor="middle" fill="#FFF5E6" font-size="18" font-weight="bold" transform="rotate(-90, 40, 62)">Α</text>
                </g>

                <%!-- Attack arrow --%>
                <line x1="220" y1="115" x2="185" y2="115" stroke="#FACD1E" stroke-width="3" marker-end="url(#arrow2)"/>

                <text x="140" y="175" text-anchor="middle" fill="#FACD1E" font-size="12">Unshielded side exposed — 1 damage</text>
              </svg>
            </div>

            <div class="p-3 rounded" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
              <div class="flex justify-between text-sm">
                <span style="color: #9D8C71;">If dislodged:</span>
                <span class="font-bold" style="color: #FACD1E;">1 HP lost</span>
              </div>
            </div>
          </div>

          <%!-- Rear Attack --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Rear Attack
            </h3>

            <div class="flex justify-center mb-4">
              <svg viewBox="0 0 280 180" width="280" height="180">
                <rect width="280" height="180" fill="#3D3225" rx="8"/>

                <%!-- Defender (facing up) --%>
                <g transform="translate(100, 20)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#5D3A8E"/>
                  <polyline points="12,28.17 40,12 68,28.17" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="20,31.55 40,20 60,31.55" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="28,34.93 40,28 52,34.93" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <text x="40" y="62" text-anchor="middle" fill="#FFF5E6" font-size="18" font-weight="bold">Β</text>
                </g>

                <%!-- Attacker from behind --%>
                <g transform="translate(100, 100) rotate(180, 40, 46)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#D32929"/>
                  <polyline points="12,28.17 40,12 68,28.17" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="20,31.55 40,20 60,31.55" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <polyline points="28,34.93 40,28 52,34.93" stroke="#FFF5E6" stroke-width="3" stroke-linecap="round" fill="none"/>
                  <text x="40" y="62" text-anchor="middle" fill="#FFF5E6" font-size="18" font-weight="bold" transform="rotate(180, 40, 62)">Α</text>
                </g>

                <%!-- Attack arrow --%>
                <line x1="140" y1="140" x2="140" y2="120" stroke="#7F2122" stroke-width="3" marker-end="url(#arrow3)"/>
                <defs>
                  <marker id="arrow3" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#7F2122"/>
                  </marker>
                </defs>

                <text x="140" y="175" text-anchor="middle" fill="#7F2122" font-size="12">Struck from behind — devastating</text>
              </svg>
            </div>

            <div class="p-3 rounded" style="background: rgba(127, 33, 34, 0.15); border: 1px solid rgba(127, 33, 34, 0.3);">
              <div class="flex justify-between text-sm">
                <span style="color: #9D8C71;">If dislodged:</span>
                <span class="font-bold" style="color: #7F2122;">2 HP lost</span>
              </div>
            </div>
          </div>

          <%!-- Strength Comparison --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Strength Comparison
            </h3>

            <div class="space-y-4 mb-4">
              <div class="flex items-center justify-between p-3 rounded" style="background: rgba(0,0,0,0.2);">
                <span style="color: #D32929;">Attacker: 3</span>
                <span style="color: #9D8C71;">vs</span>
                <span style="color: #5D3A8E;">Defender: 2</span>
                <span class="font-bold px-2 py-1 rounded text-sm" style="background: rgba(211, 41, 41, 0.2); color: #D32929;">DISLODGE</span>
              </div>

              <div class="flex items-center justify-between p-3 rounded" style="background: rgba(0,0,0,0.2);">
                <span style="color: #D32929;">Attacker: 2</span>
                <span style="color: #9D8C71;">vs</span>
                <span style="color: #5D3A8E;">Defender: 2</span>
                <span class="font-bold px-2 py-1 rounded text-sm" style="background: rgba(250, 205, 30, 0.2); color: #FACD1E;">STANDOFF</span>
              </div>

              <div class="flex items-center justify-between p-3 rounded" style="background: rgba(0,0,0,0.2);">
                <span style="color: #D32929;">Attacker: 1</span>
                <span style="color: #9D8C71;">vs</span>
                <span style="color: #5D3A8E;">Defender: 3</span>
                <span class="font-bold px-2 py-1 rounded text-sm" style="background: rgba(93, 58, 142, 0.2); color: #5D3A8E;">REPELLED</span>
              </div>
            </div>

            <p class="text-sm text-center" style="color: #9D8C71;">
              Strictly greater wins. Ties = nobody moves.
            </p>
          </div>
        </div>

        <%!-- Combat Resolution Steps --%>
        <div class="rounded-xl p-6" style="background: linear-gradient(135deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.05) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <h3 class="text-xl font-semibold mb-6" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Resolution Order
          </h3>

          <div class="flex flex-wrap gap-4 justify-center">
            <.step_badge number={1} label="Calculate Movements" />
            <.step_arrow />
            <.step_badge number={2} label="Identify Conflicts" />
            <.step_arrow />
            <.step_badge number={3} label="Compare Strength" />
            <.step_arrow />
            <.step_badge number={4} label="Resolve Dislodge" />
            <.step_arrow />
            <.step_badge number={5} label="Apply Damage" />
            <.step_arrow />
            <.step_badge number={6} label="Execute Retreats" />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp step_badge(assigns) do
    ~H"""
    <div class="flex items-center gap-2 px-4 py-2 rounded-lg" style="background: rgba(206, 137, 70, 0.2); border: 1px solid rgba(206, 137, 70, 0.4);">
      <span class="w-6 h-6 rounded-full flex items-center justify-center text-sm font-bold" style="background: #CE8946; color: #2C2416;">
        <%= @number %>
      </span>
      <span class="text-sm" style="color: #E5DBB7;"><%= @label %></span>
    </div>
    """
  end

  defp step_arrow(assigns) do
    ~H"""
    <span style="color: #CE8946;" class="hidden md:inline">→</span>
    """
  end
end
