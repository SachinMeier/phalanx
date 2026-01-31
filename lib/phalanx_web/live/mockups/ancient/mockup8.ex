defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup8 do
  @moduledoc "Ancient theme: Full Battle Scene"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen" style="background: linear-gradient(145deg, #2C2416 0%, #3D3225 50%, #2A2118 100%);">
      <div class="relative z-10 p-8 max-w-7xl mx-auto">
        <%!-- Header --%>
        <div class="mb-8">
          <.link navigate={~p"/mockups/ancient"} class="inline-flex items-center gap-2 text-amber-600 hover:text-amber-400 text-sm mb-6 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Ancient Mockups
          </.link>
          <h1 class="text-4xl font-bold mb-3" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Full Battle Scene
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            The sand table — a mid-game battle with formations clashing
          </p>
        </div>

        <%!-- Main Game Layout --%>
        <div class="grid grid-cols-12 gap-4">
          <%!-- Left Sidebar --%>
          <div class="col-span-2 space-y-4">
            <%!-- Turn Counter --%>
            <div class="rounded-xl p-4 text-center" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 1px solid rgba(206,137,70,0.3);">
              <div class="text-sm mb-1" style="color: #9D8C71;">Turn</div>
              <div class="text-4xl font-bold" style="font-family: 'Cinzel', serif; color: #FACD1E;">VII</div>
            </div>

            <%!-- Compass --%>
            <div class="rounded-xl p-4" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 1px solid rgba(206,137,70,0.3);">
              <div class="text-xs text-center mb-2" style="color: #9D8C71;">Movement</div>
              <div class="grid grid-cols-3 gap-1 text-center text-xs">
                <div class="p-1 rounded" style="background: rgba(206, 137, 70, 0.2); color: #CE8946;">W</div>
                <div class="p-1 rounded" style="background: rgba(206, 137, 70, 0.2); color: #CE8946;">E</div>
                <div></div>
                <div class="p-1 rounded" style="background: rgba(206, 137, 70, 0.2); color: #CE8946;">A</div>
                <div class="p-1 rounded" style="background: rgba(157, 140, 113, 0.2); color: #9D8C71;">•</div>
                <div class="p-1 rounded" style="background: rgba(206, 137, 70, 0.2); color: #CE8946;">F</div>
                <div class="p-1 rounded" style="background: rgba(206, 137, 70, 0.2); color: #CE8946;">S</div>
                <div class="p-1 rounded" style="background: rgba(206, 137, 70, 0.2); color: #CE8946;">D</div>
                <div></div>
              </div>
            </div>

            <%!-- Player Status --%>
            <div class="rounded-xl p-3" style="background: rgba(211, 41, 41, 0.1); border: 1px solid rgba(211, 41, 41, 0.3);">
              <div class="flex items-center gap-2 mb-2">
                <div class="w-6 h-6 rounded-full" style="background: #D32929;"></div>
                <span class="font-semibold text-sm" style="color: #E5DBB7;">Sparta</span>
              </div>
              <div class="text-xs" style="color: #9D8C71;">4 units • 2 in phalanx</div>
            </div>

            <div class="rounded-xl p-3" style="background: rgba(93, 58, 142, 0.1); border: 1px solid rgba(93, 58, 142, 0.3);">
              <div class="flex items-center gap-2 mb-2">
                <div class="w-6 h-6 rounded-full" style="background: #5D3A8E;"></div>
                <span class="font-semibold text-sm" style="color: #E5DBB7;">Persia</span>
              </div>
              <div class="text-xs" style="color: #9D8C71;">5 units • 3 in phalanx</div>
            </div>
          </div>

          <%!-- Battle Grid --%>
          <div class="col-span-8">
            <div class="rounded-xl p-4" style="background: linear-gradient(145deg, #3D3225 0%, #2C2416 100%); border: 2px solid rgba(206,137,70,0.4);">
              <%!-- Greek key border decoration --%>
              <div class="mb-4 h-3 opacity-30" style="background: repeating-linear-gradient(90deg, #CE8946 0px, #CE8946 8px, transparent 8px, transparent 12px, #CE8946 12px, #CE8946 20px, transparent 20px, transparent 24px);"></div>

              <svg viewBox="0 0 700 500" width="100%" height="450" class="mx-auto">
                <%!-- Sand/terrain background --%>
                <rect width="700" height="500" fill="#3D3225"/>

                <%!-- Grid lines (subtle) --%>
                <g stroke="rgba(157, 140, 113, 0.15)" stroke-width="1">
                  <%= for i <- 0..10 do %>
                    <line x1={i * 70} y1="0" x2={i * 70} y2="500" />
                  <% end %>
                  <%= for j <- 0..7 do %>
                    <line x1="0" y1={j * 70} x2="700" y2={j * 70} />
                  <% end %>
                </g>

                <%!-- RED TEAM (Sparta) - Bottom --%>
                <%!-- Phalanx of 2 --%>
                <g transform="translate(180, 350)">
                  <.battle_unit name="Α" color="#D32929" health={3} rotation={0} phalanx={true} />
                </g>
                <g transform="translate(250, 350)">
                  <.battle_unit name="Β" color="#D32929" health={2} rotation={0} phalanx={true} />
                </g>

                <%!-- Bond line between phalanx --%>
                <line x1="230" y1="385" x2="255" y2="385" stroke="#FACD1E" stroke-width="3" stroke-dasharray="4,2"/>

                <%!-- Loose units --%>
                <g transform="translate(400, 380)">
                  <.battle_unit name="Γ" color="#D32929" health={3} rotation={60} />
                </g>
                <g transform="translate(500, 320)">
                  <.battle_unit name="Δ" color="#D32929" health={1} rotation={0} damaged={true} />
                </g>

                <%!-- PURPLE TEAM (Persia) - Top --%>
                <%!-- Phalanx of 3 --%>
                <g transform="translate(200, 120)">
                  <.battle_unit name="Ε" color="#5D3A8E" health={3} rotation={180} phalanx={true} />
                </g>
                <g transform="translate(270, 120)">
                  <.battle_unit name="Ζ" color="#5D3A8E" health={3} rotation={180} phalanx={true} />
                </g>
                <g transform="translate(340, 120)">
                  <.battle_unit name="Η" color="#5D3A8E" health={2} rotation={180} phalanx={true} />
                </g>

                <%!-- Bond lines --%>
                <line x1="250" y1="155" x2="275" y2="155" stroke="#FACD1E" stroke-width="3" stroke-dasharray="4,2"/>
                <line x1="320" y1="155" x2="345" y2="155" stroke="#FACD1E" stroke-width="3" stroke-dasharray="4,2"/>

                <%!-- Loose purple units --%>
                <g transform="translate(450, 180)">
                  <.battle_unit name="Θ" color="#5D3A8E" health={3} rotation={240} />
                </g>
                <g transform="translate(520, 220)">
                  <.battle_unit name="Ι" color="#5D3A8E" health={3} rotation={180} />
                </g>

                <%!-- Combat zone indicator --%>
                <ellipse cx="350" cy="250" rx="120" ry="60" fill="none" stroke="rgba(127, 33, 34, 0.3)" stroke-width="2" stroke-dasharray="8,4"/>
                <text x="350" y="250" text-anchor="middle" fill="rgba(127, 33, 34, 0.5)" font-size="10" font-weight="bold">CONTESTED ZONE</text>

                <%!-- Movement preview arrow (ghost) --%>
                <line x1="230" y1="350" x2="230" y2="300" stroke="#FACD1E" stroke-width="2" stroke-dasharray="6,3" marker-end="url(#previewArrow)"/>
                <defs>
                  <marker id="previewArrow" markerWidth="8" markerHeight="6" refX="7" refY="3" orient="auto">
                    <polygon points="0 0, 8 3, 0 6" fill="#FACD1E"/>
                  </marker>
                </defs>
              </svg>

              <%!-- Greek key border bottom --%>
              <div class="mt-4 h-3 opacity-30" style="background: repeating-linear-gradient(90deg, #CE8946 0px, #CE8946 8px, transparent 8px, transparent 12px, #CE8946 12px, #CE8946 20px, transparent 20px, transparent 24px);"></div>
            </div>
          </div>

          <%!-- Right Sidebar --%>
          <div class="col-span-2 space-y-4">
            <%!-- Selected Unit --%>
            <div class="rounded-xl p-4" style="background: linear-gradient(145deg, rgba(211, 41, 41, 0.1) 0%, rgba(229,219,183,0.04) 100%); border: 2px solid rgba(211, 41, 41, 0.4);">
              <div class="text-xs mb-2" style="color: #9D8C71;">Selected</div>
              <div class="flex items-center gap-3 mb-3">
                <div class="w-12 h-12 rounded-lg flex items-center justify-center font-bold text-white text-xl" style="background: #D32929;">
                  Α
                </div>
                <div>
                  <div class="font-bold" style="color: #E5DBB7;">Unit Alpha</div>
                  <div class="text-xs" style="color: #FACD1E;">In Phalanx</div>
                </div>
              </div>
              <div class="space-y-2 text-xs">
                <div class="flex justify-between">
                  <span style="color: #9D8C71;">Health</span>
                  <div class="flex gap-1">
                    <div class="w-4 h-2 rounded bg-green-500"></div>
                    <div class="w-4 h-2 rounded bg-green-500"></div>
                    <div class="w-4 h-2 rounded bg-green-500"></div>
                  </div>
                </div>
                <div class="flex justify-between">
                  <span style="color: #9D8C71;">Energy</span>
                  <div class="flex gap-1">
                    <div class="w-2 h-2 rounded-full bg-amber-500"></div>
                    <div class="w-2 h-2 rounded-full bg-amber-500"></div>
                    <div class="w-2 h-2 rounded-full bg-stone-700"></div>
                  </div>
                </div>
                <div class="flex justify-between">
                  <span style="color: #9D8C71;">Strength</span>
                  <span style="color: #FACD1E;">3 (1+2)</span>
                </div>
              </div>
            </div>

            <%!-- Pending Orders --%>
            <div class="rounded-xl p-4" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 1px solid rgba(206,137,70,0.3);">
              <div class="text-xs mb-3" style="color: #9D8C71;">Orders (2)</div>
              <div class="space-y-2 text-xs">
                <div class="flex items-center gap-2 p-2 rounded" style="background: rgba(34, 197, 94, 0.1);">
                  <span style="color: #D32929;">Α</span>
                  <span style="color: #9D8C71;">→ NE</span>
                </div>
                <div class="flex items-center gap-2 p-2 rounded" style="background: rgba(34, 197, 94, 0.1);">
                  <span style="color: #D32929;">Β</span>
                  <span style="color: #9D8C71;">→ NE</span>
                </div>
              </div>
            </div>

            <%!-- Submit Button --%>
            <button class="w-full py-3 rounded-xl font-semibold text-sm transition-all hover:brightness-110"
                    style="font-family: 'Cinzel', serif; background: linear-gradient(180deg, #22c55e 0%, #16a34a 100%); color: white; box-shadow: 0 2px 8px rgba(34, 197, 94, 0.3);">
              Submit ⏎
            </button>
          </div>
        </div>

        <%!-- Status Bar --%>
        <div class="mt-4 rounded-xl px-6 py-3 flex items-center justify-between" style="background: linear-gradient(90deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.05) 50%, rgba(206, 137, 70, 0.1) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <div class="flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
            <span class="text-sm" style="color: #22c55e;">Order Phase</span>
          </div>
          <div class="text-sm" style="color: #9D8C71;">
            Thermopylae • 480 BCE
          </div>
          <div class="flex items-center gap-4 text-sm">
            <span style="color: #D32929;">Sparta: 4</span>
            <span style="color: #9D8C71;">vs</span>
            <span style="color: #5D3A8E;">Persia: 5</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp battle_unit(assigns) do
    assigns = assign_new(assigns, :phalanx, fn -> false end)
    assigns = assign_new(assigns, :damaged, fn -> false end)
    assigns = assign_new(assigns, :rotation, fn -> 0 end)

    ~H"""
    <g>
      <%!-- Phalanx glow --%>
      <circle :if={@phalanx} cx="30" cy="35" r="40" fill="none" stroke="#FACD1E" stroke-width="2" opacity="0.3"/>

      <svg viewBox="0 0 100 115.47" width="60" height="69" style={"transform: rotate(#{@rotation}deg); transform-origin: center;"}>
        <polygon
          points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
          fill={@color}
          opacity={if @damaged, do: "0.7", else: "1"}
          style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.4));"
        />
        <%!-- Phalanx ring --%>
        <polygon :if={@phalanx}
          points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
          fill="none"
          stroke="#FACD1E"
          stroke-width="3"
        />
        <%!-- Damaged ring --%>
        <polygon :if={@damaged}
          points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
          fill="none"
          stroke="#7F2122"
          stroke-width="2"
          stroke-dasharray="8,4"
        />
        <%!-- Health chevrons --%>
        <polyline :if={@health > 0} points="15,35.21 50,15 85,35.21" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <polyline :if={@health > 1} points="25,39.44 50,25 75,39.44" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <polyline :if={@health > 2} points="35,43.66 50,35 65,43.66" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <%!-- Name --%>
        <text x="50" y="78" text-anchor="middle" dominant-baseline="middle" fill="#FFF5E6" font-size="22" font-weight="bold" style="font-family: 'Cinzel', serif;" transform={"rotate(#{-@rotation}, 50, 57.735)"}>
          <%= @name %>
        </text>
      </svg>
    </g>
    """
  end
end
