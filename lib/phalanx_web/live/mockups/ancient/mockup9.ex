defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup9 do
  @moduledoc "Ancient theme: Strength Calculation"
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
            Strength Calculation
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            The weight of the phalanx — detailed breakdown of combat strength
          </p>
        </div>

        <%!-- Main Calculation Display --%>
        <div class="grid lg:grid-cols-2 gap-8 mb-16">
          <%!-- Attacker Side --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(211, 41, 41, 0.08) 0%, rgba(229,219,183,0.03) 100%); border: 2px solid rgba(211, 41, 41, 0.3);">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-semibold" style="font-family: 'Cinzel', serif; color: #D32929;">
                Attacker
              </h3>
              <div class="text-4xl font-bold" style="font-family: 'Cinzel', serif; color: #D32929;">
                4
              </div>
            </div>

            <%!-- Visual representation --%>
            <div class="flex justify-center mb-6">
              <svg viewBox="0 0 300 180" width="300" height="180">
                <rect width="300" height="180" fill="#3D3225" rx="8"/>

                <%!-- Main attacker --%>
                <g transform="translate(110, 60)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#D32929"/>
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="none" stroke="#FACD1E" stroke-width="3"/>
                  <text x="40" y="52" text-anchor="middle" fill="#FFF5E6" font-size="20" font-weight="bold">Α</text>
                </g>

                <%!-- Support from left --%>
                <g transform="translate(40, 60)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#D32929" opacity="0.6"/>
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="none" stroke="#FACD1E" stroke-width="2"/>
                  <text x="40" y="52" text-anchor="middle" fill="#FFF5E6" font-size="16">Β</text>
                </g>

                <%!-- Support from behind --%>
                <g transform="translate(145, 95)">
                  <polygon points="25,0 50,14.43 50,43.3 25,57.74 0,43.3 0,14.43" fill="#D32929" opacity="0.4"/>
                  <polygon points="25,0 50,14.43 50,43.3 25,57.74 0,43.3 0,14.43" fill="none" stroke="#FACD1E" stroke-width="2"/>
                  <text x="25" y="32" text-anchor="middle" fill="#FFF5E6" font-size="12">Γ</text>
                </g>

                <%!-- Bonus indicators --%>
                <text x="60" y="45" fill="#FACD1E" font-size="10" font-weight="bold">+1</text>
                <text x="170" y="125" fill="#FACD1E" font-size="10" font-weight="bold">+1</text>

                <%!-- Attack direction arrow --%>
                <line x1="200" y1="85" x2="260" y2="85" stroke="#D32929" stroke-width="3" marker-end="url(#attackDir)"/>
                <defs>
                  <marker id="attackDir" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#D32929"/>
                  </marker>
                </defs>
              </svg>
            </div>

            <%!-- Calculation breakdown --%>
            <div class="space-y-3">
              <div class="flex justify-between items-center p-3 rounded-lg" style="background: rgba(0,0,0,0.2);">
                <span style="color: #9D8C71;">Base Strength</span>
                <span class="font-bold" style="color: #E5DBB7;">1</span>
              </div>
              <div class="flex justify-between items-center p-3 rounded-lg" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
                <div>
                  <span style="color: #FACD1E;">Formation Bonus</span>
                  <span class="text-xs ml-2" style="color: #9D8C71;">(side ally Β)</span>
                </div>
                <span class="font-bold" style="color: #FACD1E;">+1</span>
              </div>
              <div class="flex justify-between items-center p-3 rounded-lg" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
                <div>
                  <span style="color: #FACD1E;">Rear Depth</span>
                  <span class="text-xs ml-2" style="color: #9D8C71;">(rear ally Γ)</span>
                </div>
                <span class="font-bold" style="color: #FACD1E;">+1</span>
              </div>
              <div class="flex justify-between items-center p-3 rounded-lg" style="background: rgba(206, 137, 70, 0.15); border: 1px solid rgba(206, 137, 70, 0.4);">
                <div>
                  <span style="color: #CE8946;">Pushing Support</span>
                  <span class="text-xs ml-2" style="color: #9D8C71;">(non-phalanx ally)</span>
                </div>
                <span class="font-bold" style="color: #CE8946;">+1</span>
              </div>
              <div class="border-t pt-3 flex justify-between items-center" style="border-color: rgba(211, 41, 41, 0.3);">
                <span class="font-bold" style="color: #D32929;">Total Strength</span>
                <span class="text-2xl font-bold" style="color: #D32929;">4</span>
              </div>
            </div>
          </div>

          <%!-- Defender Side --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(93, 58, 142, 0.08) 0%, rgba(229,219,183,0.03) 100%); border: 2px solid rgba(93, 58, 142, 0.3);">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-semibold" style="font-family: 'Cinzel', serif; color: #5D3A8E;">
                Defender
              </h3>
              <div class="text-4xl font-bold" style="font-family: 'Cinzel', serif; color: #5D3A8E;">
                2
              </div>
            </div>

            <%!-- Visual representation --%>
            <div class="flex justify-center mb-6">
              <svg viewBox="0 0 300 180" width="300" height="180">
                <rect width="300" height="180" fill="#3D3225" rx="8"/>

                <%!-- Main defender --%>
                <g transform="translate(110, 60)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#5D3A8E"/>
                  <text x="40" y="52" text-anchor="middle" fill="#FFF5E6" font-size="20" font-weight="bold">Δ</text>
                </g>

                <%!-- Side ally --%>
                <g transform="translate(180, 60)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#5D3A8E" opacity="0.6"/>
                  <text x="40" y="52" text-anchor="middle" fill="#FFF5E6" font-size="16">Ε</text>
                </g>

                <%!-- Flanked indicator --%>
                <path d="M 50,85 L 100,85" stroke="#7F2122" stroke-width="3" stroke-dasharray="6,3" marker-end="url(#flankArrow)"/>
                <defs>
                  <marker id="flankArrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                    <polygon points="0 0, 10 3.5, 0 7" fill="#7F2122"/>
                  </marker>
                </defs>
                <text x="40" y="75" fill="#7F2122" font-size="9" font-weight="bold">FLANK</text>

                <%!-- Bonus indicator --%>
                <text x="210" y="50" fill="#FACD1E" font-size="10" font-weight="bold">+1</text>
              </svg>
            </div>

            <%!-- Calculation breakdown --%>
            <div class="space-y-3">
              <div class="flex justify-between items-center p-3 rounded-lg" style="background: rgba(0,0,0,0.2);">
                <span style="color: #9D8C71;">Base Strength</span>
                <span class="font-bold" style="color: #E5DBB7;">1</span>
              </div>
              <div class="flex justify-between items-center p-3 rounded-lg" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
                <div>
                  <span style="color: #FACD1E;">Side Ally</span>
                  <span class="text-xs ml-2" style="color: #9D8C71;">(Ε in same phalanx)</span>
                </div>
                <span class="font-bold" style="color: #FACD1E;">+1</span>
              </div>
              <div class="flex justify-between items-center p-3 rounded-lg" style="background: rgba(127, 33, 34, 0.1); border: 1px solid rgba(127, 33, 34, 0.3);">
                <div>
                  <span style="color: #7F2122;">Flanked Penalty</span>
                  <span class="text-xs ml-2" style="color: #9D8C71;">(attack from side)</span>
                </div>
                <span class="font-bold" style="color: #7F2122;">—</span>
              </div>
              <div class="border-t pt-3 flex justify-between items-center" style="border-color: rgba(93, 58, 142, 0.3);">
                <span class="font-bold" style="color: #5D3A8E;">Total Strength</span>
                <span class="text-2xl font-bold" style="color: #5D3A8E;">2</span>
              </div>
            </div>
          </div>
        </div>

        <%!-- Outcome --%>
        <div class="rounded-xl p-8 text-center mb-16" style="background: linear-gradient(135deg, rgba(211, 41, 41, 0.15) 0%, rgba(206, 137, 70, 0.1) 100%); border: 2px solid rgba(211, 41, 41, 0.4);">
          <div class="text-lg mb-2" style="color: #9D8C71;">Combat Result</div>
          <div class="flex items-center justify-center gap-8 mb-4">
            <div class="text-center">
              <div class="text-5xl font-bold" style="font-family: 'Cinzel', serif; color: #D32929;">4</div>
              <div class="text-sm" style="color: #D32929;">Attacker</div>
            </div>
            <div class="text-3xl" style="color: #9D8C71;">vs</div>
            <div class="text-center">
              <div class="text-5xl font-bold" style="font-family: 'Cinzel', serif; color: #5D3A8E;">2</div>
              <div class="text-sm" style="color: #5D3A8E;">Defender</div>
            </div>
          </div>
          <div class="text-2xl font-bold mb-2" style="font-family: 'Cinzel', serif; color: #D32929;">
            ATTACKER WINS
          </div>
          <div class="text-sm" style="color: #9D8C71;">
            Defender is dislodged. Flank attack: <span style="color: #7F2122;">1 HP damage</span>
          </div>
        </div>

        <%!-- Strength Formula Reference --%>
        <div class="rounded-xl p-6" style="background: linear-gradient(135deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.05) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <h3 class="text-xl font-semibold mb-6" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Strength Formula
          </h3>

          <div class="grid md:grid-cols-2 gap-6">
            <div class="p-4 rounded-lg font-mono text-sm" style="background: rgba(0,0,0,0.3);">
              <div class="mb-2" style="color: #FACD1E;">Strength = Base + Formation</div>
              <div class="space-y-1 text-xs" style="color: #9D8C71;">
                <div>Base = 1 (all units)</div>
                <div>Formation = SideAllies + RearAllies</div>
                <div>SideAllies = max 2 (geometry)</div>
                <div>RearAllies = unlimited</div>
              </div>
            </div>

            <div class="space-y-3">
              <div class="flex items-center gap-3">
                <span class="w-8 h-8 rounded-full flex items-center justify-center" style="background: rgba(250, 205, 30, 0.2);">
                  <span style="color: #FACD1E;">⚔</span>
                </span>
                <div class="text-sm">
                  <span style="color: #E5DBB7;">Formation bonuses</span>
                  <span style="color: #9D8C71;"> — never cut by attacks</span>
                </div>
              </div>
              <div class="flex items-center gap-3">
                <span class="w-8 h-8 rounded-full flex items-center justify-center" style="background: rgba(206, 137, 70, 0.2);">
                  <span style="color: #CE8946;">↗</span>
                </span>
                <div class="text-sm">
                  <span style="color: #E5DBB7;">Pushing support</span>
                  <span style="color: #9D8C71;"> — CAN be cut by attacks</span>
                </div>
              </div>
              <div class="flex items-center gap-3">
                <span class="w-8 h-8 rounded-full flex items-center justify-center" style="background: rgba(127, 33, 34, 0.2);">
                  <span style="color: #7F2122;">⚡</span>
                </span>
                <div class="text-sm">
                  <span style="color: #E5DBB7;">Strictly greater wins</span>
                  <span style="color: #9D8C71;"> — ties = standoff</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
