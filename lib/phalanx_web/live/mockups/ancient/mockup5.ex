defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup5 do
  @moduledoc "Ancient theme: Retreat & Dislodgement"
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
            Retreat & Dislodgement
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            When the line breaks — retreat paths, blocked hexes, and destruction
          </p>
        </div>

        <%!-- Retreat Mechanics --%>
        <div class="grid lg:grid-cols-2 gap-8 mb-16">
          <%!-- Basic Retreat --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Successful Retreat
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              Dislodged unit retreats 180° opposite from attack direction.
            </p>

            <div class="flex justify-center mb-4">
              <svg viewBox="0 0 320 200" width="320" height="200">
                <rect width="320" height="200" fill="#3D3225" rx="8"/>

                <%!-- Attacker --%>
                <g transform="translate(40, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#D32929"/>
                  <polyline points="15,35.21 50,15 85,35.21" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                  <polyline points="25,39.44 50,25 75,39.44" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                  <polyline points="35,43.66 50,35 65,43.66" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                  <text x="50" y="78" text-anchor="middle" fill="#FFF5E6" font-size="20" font-weight="bold">Α</text>
                </g>

                <%!-- Attack arrow --%>
                <line x1="145" y1="115" x2="175" y2="115" stroke="#D32929" stroke-width="4" marker-end="url(#attackArrow)"/>
                <defs>
                  <marker id="attackArrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#D32929"/>
                  </marker>
                </defs>

                <%!-- Defender (dislodged position) --%>
                <g transform="translate(130, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#5D3A8E" opacity="0.4"/>
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="none" stroke="#7F2122" stroke-width="2" stroke-dasharray="6,3"/>
                </g>

                <%!-- Retreat arrow --%>
                <line x1="235" y1="115" x2="265" y2="115" stroke="#FACD1E" stroke-width="3" marker-end="url(#retreatArrow)"/>
                <defs>
                  <marker id="retreatArrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#FACD1E"/>
                  </marker>
                </defs>

                <%!-- Retreat destination --%>
                <g transform="translate(220, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#5D3A8E"/>
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="none" stroke="#FACD1E" stroke-width="3"/>
                  <polyline points="15,35.21 50,15 85,35.21" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                  <polyline points="25,39.44 50,25 75,39.44" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                  <text x="50" y="78" text-anchor="middle" fill="#FFF5E6" font-size="20" font-weight="bold">Β</text>
                </g>

                <text x="160" y="190" text-anchor="middle" fill="#FACD1E" font-size="11">Β retreats opposite attack direction</text>
              </svg>
            </div>

            <div class="p-3 rounded" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
              <div class="text-sm" style="color: #9D8C71;">
                Retreat = 180° from attacker's direction. Unit survives but loses position.
              </div>
            </div>
          </div>

          <%!-- Blocked Retreat --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Blocked Retreat
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              If primary retreat is blocked, try fallback direction.
            </p>

            <div class="flex justify-center mb-4">
              <svg viewBox="0 0 320 200" width="320" height="200">
                <rect width="320" height="200" fill="#3D3225" rx="8"/>

                <%!-- Attacker --%>
                <g transform="translate(40, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#D32929"/>
                  <text x="50" y="62" text-anchor="middle" fill="#FFF5E6" font-size="20" font-weight="bold">Α</text>
                </g>

                <%!-- Attack arrow --%>
                <line x1="145" y1="115" x2="175" y2="115" stroke="#D32929" stroke-width="4" marker-end="url(#attackArrow)"/>

                <%!-- Defender --%>
                <g transform="translate(130, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#5D3A8E"/>
                  <text x="50" y="62" text-anchor="middle" fill="#FFF5E6" font-size="20" font-weight="bold">Β</text>
                </g>

                <%!-- Blocked hex (primary retreat) --%>
                <g transform="translate(220, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#7F2122" opacity="0.3"/>
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="none" stroke="#7F2122" stroke-width="2"/>
                  <text x="50" y="55" text-anchor="middle" fill="#7F2122" font-size="12" font-weight="bold">BLOCKED</text>
                  <text x="50" y="70" text-anchor="middle" fill="#7F2122" font-size="24">✕</text>
                </g>

                <%!-- Blocked retreat arrow --%>
                <line x1="235" y1="115" x2="255" y2="115" stroke="#7F2122" stroke-width="3" stroke-dasharray="4,2"/>

                <%!-- Fallback arrow --%>
                <line x1="200" y1="160" x2="220" y2="180" stroke="#22c55e" stroke-width="3" marker-end="url(#fallbackArrow)"/>
                <defs>
                  <marker id="fallbackArrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#22c55e"/>
                  </marker>
                </defs>

                <text x="250" y="185" fill="#22c55e" font-size="10">Fallback</text>
                <text x="160" y="190" text-anchor="middle" fill="#9D8C71" font-size="11">Use unit's other backward direction</text>
              </svg>
            </div>

            <div class="p-3 rounded" style="background: rgba(127, 33, 34, 0.15); border: 1px solid rgba(127, 33, 34, 0.3);">
              <div class="text-sm" style="color: #9D8C71;">
                Primary blocked? Try fallback based on unit's facing direction.
              </div>
            </div>
          </div>

          <%!-- Destruction --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #7F2122;">
              No Retreat = Destruction
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              If both retreat hexes are blocked, the unit is destroyed.
            </p>

            <div class="flex justify-center mb-4">
              <svg viewBox="0 0 320 200" width="320" height="200">
                <rect width="320" height="200" fill="#3D3225" rx="8"/>

                <%!-- Attackers surrounding --%>
                <g transform="translate(40, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#D32929"/>
                  <text x="50" y="62" text-anchor="middle" fill="#FFF5E6" font-size="20" font-weight="bold">Α</text>
                </g>
                <g transform="translate(220, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#D32929"/>
                  <text x="50" y="62" text-anchor="middle" fill="#FFF5E6" font-size="20" font-weight="bold">Γ</text>
                </g>

                <%!-- Defender (being destroyed) --%>
                <g transform="translate(130, 60)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#5D3A8E" opacity="0.3"/>
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="none" stroke="#7F2122" stroke-width="3"/>
                  <%!-- Death X --%>
                  <path d="M 25,35 L 75,80" stroke="#7F2122" stroke-width="5" fill="none" stroke-linecap="round"/>
                  <path d="M 75,35 L 25,80" stroke="#7F2122" stroke-width="5" fill="none" stroke-linecap="round"/>
                  <text x="50" y="100" text-anchor="middle" fill="#7F2122" font-size="12" font-weight="bold">DESTROYED</text>
                </g>

                <%!-- Attack arrows --%>
                <line x1="145" y1="115" x2="165" y2="115" stroke="#D32929" stroke-width="3" marker-end="url(#attackArrow)"/>
                <line x1="235" y1="115" x2="215" y2="115" stroke="#D32929" stroke-width="3" marker-end="url(#attackArrowLeft)"/>
                <defs>
                  <marker id="attackArrowLeft" markerWidth="10" markerHeight="7" refX="1" refY="3.5" orient="auto">
                    <polygon points="10 0, 0 3.5, 10 7" fill="#D32929"/>
                  </marker>
                </defs>

                <text x="160" y="185" text-anchor="middle" fill="#7F2122" font-size="11">Surrounded — no escape possible</text>
              </svg>
            </div>

            <div class="p-3 rounded animate-pulse" style="background: rgba(127, 33, 34, 0.2); border: 1px solid rgba(127, 33, 34, 0.4);">
              <div class="text-sm font-bold text-center" style="color: #7F2122;">
                UNIT ELIMINATED
              </div>
            </div>
          </div>

          <%!-- Standoff Hexes --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Standoff Hexes
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              Cannot retreat into a hex where a tie occurred this turn.
            </p>

            <div class="flex justify-center mb-4">
              <svg viewBox="0 0 320 200" width="320" height="200">
                <rect width="320" height="200" fill="#3D3225" rx="8"/>

                <%!-- Standoff hex indicator --%>
                <g transform="translate(130, 50)">
                  <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="none" stroke="#FACD1E" stroke-width="3" stroke-dasharray="8,4"/>
                  <circle cx="50" cy="57" r="25" fill="none" stroke="#FACD1E" stroke-width="2" opacity="0.5"/>
                  <text x="50" y="50" text-anchor="middle" fill="#FACD1E" font-size="10" font-weight="bold">STANDOFF</text>
                  <text x="50" y="68" text-anchor="middle" fill="#FACD1E" font-size="20">⚔</text>
                </g>

                <%!-- Units that caused standoff --%>
                <g transform="translate(40, 80)">
                  <polygon points="35,0 70,20.21 70,60.62 35,80.83 0,60.62 0,20.21" fill="#D32929" opacity="0.5"/>
                  <text x="35" y="45" text-anchor="middle" fill="#FFF5E6" font-size="14">Α</text>
                </g>
                <g transform="translate(210, 80)">
                  <polygon points="35,0 70,20.21 70,60.62 35,80.83 0,60.62 0,20.21" fill="#5D3A8E" opacity="0.5"/>
                  <text x="35" y="45" text-anchor="middle" fill="#FFF5E6" font-size="14">Β</text>
                </g>

                <text x="160" y="185" text-anchor="middle" fill="#9D8C71" font-size="11">This hex is contested — no retreat allowed here</text>
              </svg>
            </div>

            <div class="p-3 rounded" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
              <div class="text-sm" style="color: #9D8C71;">
                Standoff hexes remain blocked until next turn resolution.
              </div>
            </div>
          </div>
        </div>

        <%!-- Retreat Rules Summary --%>
        <div class="rounded-xl p-6" style="background: linear-gradient(135deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.05) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <h3 class="text-xl font-semibold mb-6" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Retreat Rules
          </h3>

          <div class="grid md:grid-cols-2 gap-6">
            <div class="space-y-3">
              <h4 class="font-semibold" style="color: #FACD1E;">Valid Retreat Hexes</h4>
              <ul class="space-y-2 text-sm" style="color: #9D8C71;">
                <li class="flex items-center gap-2">
                  <span style="color: #22c55e;">✓</span>
                  <span>Empty hexes</span>
                </li>
                <li class="flex items-center gap-2">
                  <span style="color: #22c55e;">✓</span>
                  <span>Within map boundaries</span>
                </li>
              </ul>
            </div>

            <div class="space-y-3">
              <h4 class="font-semibold" style="color: #7F2122;">Invalid Retreat Hexes</h4>
              <ul class="space-y-2 text-sm" style="color: #9D8C71;">
                <li class="flex items-center gap-2">
                  <span style="color: #7F2122;">✕</span>
                  <span>Occupied by any unit</span>
                </li>
                <li class="flex items-center gap-2">
                  <span style="color: #7F2122;">✕</span>
                  <span>Standoff hexes (ties this turn)</span>
                </li>
                <li class="flex items-center gap-2">
                  <span style="color: #7F2122;">✕</span>
                  <span>Off map edge</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
