defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup4 do
  @moduledoc "Ancient theme: Movement & Orders"
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
            Movement & Orders
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            Commanding your phalanx — valid moves, order previews, and keyboard controls
          </p>
        </div>

        <%!-- Movement Compass --%>
        <div class="grid lg:grid-cols-2 gap-8 mb-16">
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Movement Compass
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              Six directions on the hex grid. Keyboard layout matches spatial directions.
            </p>

            <div class="flex justify-center">
              <svg viewBox="0 0 300 280" width="300" height="280">
                <rect width="300" height="280" fill="#3D3225" rx="12"/>

                <%!-- Center hex --%>
                <g transform="translate(110, 100)">
                  <polygon points="40,0 80,23.09 80,69.28 40,92.38 0,69.28 0,23.09" fill="#5D3A8E" opacity="0.6"/>
                  <text x="40" y="52" text-anchor="middle" fill="#FFF5E6" font-size="12">UNIT</text>
                </g>

                <%!-- NW direction --%>
                <g transform="translate(60, 35)">
                  <polygon points="35,0 70,20.21 70,60.62 35,80.83 0,60.62 0,20.21" fill="none" stroke="#FACD1E" stroke-width="2" stroke-dasharray="4,2"/>
                  <text x="35" y="45" text-anchor="middle" fill="#FFF5E6" font-size="14" font-weight="bold">W</text>
                  <text x="35" y="62" text-anchor="middle" fill="#9D8C71" font-size="10">NW</text>
                </g>

                <%!-- NE direction --%>
                <g transform="translate(165, 35)">
                  <polygon points="35,0 70,20.21 70,60.62 35,80.83 0,60.62 0,20.21" fill="none" stroke="#FACD1E" stroke-width="2" stroke-dasharray="4,2"/>
                  <text x="35" y="45" text-anchor="middle" fill="#FFF5E6" font-size="14" font-weight="bold">E</text>
                  <text x="35" y="62" text-anchor="middle" fill="#9D8C71" font-size="10">NE</text>
                </g>

                <%!-- W direction --%>
                <g transform="translate(15, 100)">
                  <polygon points="35,0 70,20.21 70,60.62 35,80.83 0,60.62 0,20.21" fill="none" stroke="#FACD1E" stroke-width="2" stroke-dasharray="4,2"/>
                  <text x="35" y="45" text-anchor="middle" fill="#FFF5E6" font-size="14" font-weight="bold">A</text>
                  <text x="35" y="62" text-anchor="middle" fill="#9D8C71" font-size="10">W</text>
                </g>

                <%!-- E direction --%>
                <g transform="translate(210, 100)">
                  <polygon points="35,0 70,20.21 70,60.62 35,80.83 0,60.62 0,20.21" fill="none" stroke="#FACD1E" stroke-width="2" stroke-dasharray="4,2"/>
                  <text x="35" y="45" text-anchor="middle" fill="#FFF5E6" font-size="14" font-weight="bold">F</text>
                  <text x="35" y="62" text-anchor="middle" fill="#9D8C71" font-size="10">E</text>
                </g>

                <%!-- SW direction --%>
                <g transform="translate(60, 165)">
                  <polygon points="35,0 70,20.21 70,60.62 35,80.83 0,60.62 0,20.21" fill="none" stroke="#FACD1E" stroke-width="2" stroke-dasharray="4,2"/>
                  <text x="35" y="45" text-anchor="middle" fill="#FFF5E6" font-size="14" font-weight="bold">S</text>
                  <text x="35" y="62" text-anchor="middle" fill="#9D8C71" font-size="10">SW</text>
                </g>

                <%!-- SE direction --%>
                <g transform="translate(165, 165)">
                  <polygon points="35,0 70,20.21 70,60.62 35,80.83 0,60.62 0,20.21" fill="none" stroke="#FACD1E" stroke-width="2" stroke-dasharray="4,2"/>
                  <text x="35" y="45" text-anchor="middle" fill="#FFF5E6" font-size="14" font-weight="bold">D</text>
                  <text x="35" y="62" text-anchor="middle" fill="#9D8C71" font-size="10">SE</text>
                </g>
              </svg>
            </div>
          </div>

          <%!-- Keyboard Reference --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Keyboard Controls
            </h3>

            <div class="space-y-4">
              <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
                <h4 class="text-sm font-bold mb-3" style="color: #CE8946;">Unit Selection</h4>
                <div class="grid grid-cols-2 gap-2 text-sm">
                  <div class="flex items-center gap-2">
                    <span class="px-2 py-1 rounded font-mono text-xs" style="background: rgba(211, 41, 41, 0.3); color: #FFF5E6;">Y U I O P</span>
                    <span style="color: #D32929;">Red units</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="px-2 py-1 rounded font-mono text-xs" style="background: rgba(93, 58, 142, 0.3); color: #FFF5E6;">H J K L M</span>
                    <span style="color: #5D3A8E;">Purple units</span>
                  </div>
                </div>
              </div>

              <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
                <h4 class="text-sm font-bold mb-3" style="color: #CE8946;">Movement</h4>
                <div class="grid grid-cols-3 gap-2 text-sm">
                  <.key_label key="W" label="NW" />
                  <.key_label key="E" label="NE" />
                  <div></div>
                  <.key_label key="A" label="W" />
                  <div class="text-center" style="color: #9D8C71;">•</div>
                  <.key_label key="F" label="E" />
                  <.key_label key="S" label="SW" />
                  <.key_label key="D" label="SE" />
                  <div></div>
                </div>
              </div>

              <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
                <h4 class="text-sm font-bold mb-3" style="color: #CE8946;">Rotation & Actions</h4>
                <div class="grid grid-cols-2 gap-4 text-sm">
                  <div class="flex items-center gap-2">
                    <span class="px-2 py-1 rounded font-mono" style="background: rgba(206, 137, 70, 0.3); color: #FFF5E6;">Q</span>
                    <span style="color: #9D8C71;">Rotate CCW</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="px-2 py-1 rounded font-mono" style="background: rgba(206, 137, 70, 0.3); color: #FFF5E6;">R</span>
                    <span style="color: #9D8C71;">Rotate CW</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="px-2 py-1 rounded font-mono" style="background: rgba(206, 137, 70, 0.3); color: #FFF5E6;">C</span>
                    <span style="color: #9D8C71;">Deselect</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span class="px-2 py-1 rounded font-mono" style="background: rgba(34, 197, 94, 0.3); color: #22c55e;">Enter</span>
                    <span style="color: #9D8C71;">Submit Orders</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <%!-- Order Preview Example --%>
        <div class="mb-16">
          <div class="flex items-center gap-4 mb-8">
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
            <h2 class="text-2xl font-semibold px-4" style="font-family: 'Cinzel', serif; color: #CE8946;">
              Order Preview
            </h2>
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
          </div>

          <div class="grid md:grid-cols-2 gap-8">
            <%!-- Move Order --%>
            <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
              <h3 class="text-lg font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
                Move Order
              </h3>

              <div class="flex justify-center mb-4">
                <svg viewBox="0 0 280 180" width="280" height="180">
                  <rect width="280" height="180" fill="#3D3225" rx="8"/>

                  <%!-- Current position --%>
                  <g transform="translate(60, 55)">
                    <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#D32929" opacity="0.9"/>
                    <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="none" stroke="#7fff00" stroke-width="3"/>
                    <polyline points="15,35.21 50,15 85,35.21" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                    <polyline points="25,39.44 50,25 75,39.44" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                    <polyline points="35,43.66 50,35 65,43.66" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                    <text x="50" y="78" text-anchor="middle" fill="#FFF5E6" font-size="24" font-weight="bold">Α</text>
                  </g>

                  <%!-- Ghost unit at destination --%>
                  <g transform="translate(145, 55)">
                    <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#D32929" opacity="0.3"/>
                    <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="none" stroke="#FACD1E" stroke-width="2" stroke-dasharray="6,3"/>
                    <text x="50" y="78" text-anchor="middle" fill="#FFF5E6" font-size="24" font-weight="bold" opacity="0.4">Α</text>
                  </g>

                  <%!-- Arrow --%>
                  <line x1="130" y1="110" x2="170" y2="110" stroke="#FACD1E" stroke-width="3" marker-end="url(#moveArrow)"/>
                  <defs>
                    <marker id="moveArrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                      <polygon points="0 0, 10 3.5, 0 7" fill="#FACD1E"/>
                    </marker>
                  </defs>

                  <text x="140" y="170" text-anchor="middle" fill="#FACD1E" font-size="11">Ghost shows destination</text>
                </svg>
              </div>
            </div>

            <%!-- Rotate Order --%>
            <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
              <h3 class="text-lg font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
                Rotate Order
              </h3>

              <div class="flex justify-center mb-4">
                <svg viewBox="0 0 280 180" width="280" height="180">
                  <rect width="280" height="180" fill="#3D3225" rx="8"/>

                  <%!-- Unit with rotation indicator --%>
                  <g transform="translate(90, 30)">
                    <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#5D3A8E"/>
                    <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="none" stroke="#7fff00" stroke-width="3"/>
                    <polyline points="15,35.21 50,15 85,35.21" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                    <polyline points="25,39.44 50,25 75,39.44" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                    <polyline points="35,43.66 50,35 65,43.66" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                    <text x="50" y="78" text-anchor="middle" fill="#FFF5E6" font-size="24" font-weight="bold">Β</text>
                  </g>

                  <%!-- Rotation arc --%>
                  <path d="M 100,100 A 60,60 0 0,1 180,100" fill="none" stroke="#FACD1E" stroke-width="3" stroke-dasharray="6,3"/>
                  <polygon points="180,95 190,100 180,105" fill="#FACD1E"/>

                  <text x="140" y="160" text-anchor="middle" fill="#FACD1E" font-size="11">Curved arrow shows rotation direction</text>
                </svg>
              </div>
            </div>
          </div>
        </div>

        <%!-- Valid Moves Based on Facing --%>
        <div class="rounded-xl p-6" style="background: linear-gradient(135deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.05) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <h3 class="text-xl font-semibold mb-6" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Movement Constraints
          </h3>

          <div class="grid md:grid-cols-2 gap-6">
            <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <h4 class="font-semibold mb-3" style="color: #FACD1E;">Valid Directions</h4>
              <p class="text-sm mb-3" style="color: #9D8C71;">
                Units can only move in certain directions based on their facing. A unit facing NE (60°) can move:
              </p>
              <div class="flex flex-wrap gap-2">
                <span class="px-2 py-1 rounded text-xs" style="background: rgba(34, 197, 94, 0.2); color: #22c55e;">NE</span>
                <span class="px-2 py-1 rounded text-xs" style="background: rgba(34, 197, 94, 0.2); color: #22c55e;">NW</span>
                <span class="px-2 py-1 rounded text-xs" style="background: rgba(34, 197, 94, 0.2); color: #22c55e;">SE</span>
                <span class="px-2 py-1 rounded text-xs" style="background: rgba(34, 197, 94, 0.2); color: #22c55e;">SW</span>
                <span class="px-2 py-1 rounded text-xs" style="background: rgba(127, 33, 34, 0.2); color: #7F2122;">E ✕</span>
                <span class="px-2 py-1 rounded text-xs" style="background: rgba(127, 33, 34, 0.2); color: #7F2122;">W ✕</span>
              </div>
            </div>

            <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <h4 class="font-semibold mb-3" style="color: #FACD1E;">Why Constraints?</h4>
              <p class="text-sm" style="color: #9D8C71;">
                A phalanx cannot sidestep directly—spears and shields get tangled. Moving sideways requires a rotation first. This forces tactical planning and creates meaningful facing decisions.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp key_label(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <span class="w-8 h-8 flex items-center justify-center rounded font-mono font-bold" style="background: rgba(206, 137, 70, 0.3); color: #FFF5E6;">
        <%= @key %>
      </span>
      <span style="color: #9D8C71;"><%= @label %></span>
    </div>
    """
  end
end
