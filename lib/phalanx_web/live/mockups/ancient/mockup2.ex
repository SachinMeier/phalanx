defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup2 do
  @moduledoc "Ancient theme: Phalanx Formations"
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
            Phalanx Formations
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            The strength of many, the will of one — formation bonds and cohesion
          </p>
        </div>

        <%!-- Formation Types --%>
        <div class="grid lg:grid-cols-2 gap-8 mb-16">
          <%!-- Loose Units (No Formation) --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-2" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Loose Units
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              Adjacent but not in a declared phalanx. No formation bonus.
            </p>

            <div class="flex justify-center mb-6">
              <svg viewBox="0 0 320 180" width="320" height="180">
                <%!-- Background sand texture --%>
                <rect width="320" height="180" fill="#3D3225" rx="8"/>

                <%!-- Three loose units, same facing but no formation --%>
                <g transform="translate(60, 50)">
                  <.hex_unit x={0} y={0} name="Α" color="#D32929" />
                </g>
                <g transform="translate(130, 50)">
                  <.hex_unit x={0} y={0} name="Β" color="#D32929" />
                </g>
                <g transform="translate(200, 50)">
                  <.hex_unit x={0} y={0} name="Γ" color="#D32929" />
                </g>

                <%!-- Labels --%>
                <text x="160" y="160" text-anchor="middle" fill="#9D8C71" font-size="12">No bonds — each fights alone</text>
              </svg>
            </div>

            <div class="flex items-center justify-between p-3 rounded" style="background: rgba(127, 33, 34, 0.15); border: 1px solid rgba(127, 33, 34, 0.3);">
              <span style="color: #9D8C71;">Formation Bonus</span>
              <span class="font-bold" style="color: #7F2122;">+0</span>
            </div>
          </div>

          <%!-- Line Formation --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-2" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Line Formation
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              Shields locked in a row. Side cohesion at maximum.
            </p>

            <div class="flex justify-center mb-6">
              <svg viewBox="0 0 320 180" width="320" height="180">
                <rect width="320" height="180" fill="#3D3225" rx="8"/>

                <%!-- Three units in phalanx with bond lines --%>
                <g transform="translate(60, 50)">
                  <.hex_unit x={0} y={0} name="Α" color="#D32929" phalanx={true} />
                </g>
                <g transform="translate(130, 50)">
                  <.hex_unit x={0} y={0} name="Β" color="#D32929" phalanx={true} />
                </g>
                <g transform="translate(200, 50)">
                  <.hex_unit x={0} y={0} name="Γ" color="#D32929" phalanx={true} />
                </g>

                <%!-- Bond lines (golden) --%>
                <line x1="95" y1="70" x2="130" y2="70" stroke="#FACD1E" stroke-width="3" stroke-dasharray="4,2"/>
                <line x1="165" y1="70" x2="200" y2="70" stroke="#FACD1E" stroke-width="3" stroke-dasharray="4,2"/>

                <text x="160" y="160" text-anchor="middle" fill="#FACD1E" font-size="12">Golden bonds — locked shields</text>
              </svg>
            </div>

            <div class="flex items-center justify-between p-3 rounded" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
              <span style="color: #9D8C71;">Formation Bonus (center unit)</span>
              <span class="font-bold" style="color: #FACD1E;">+2</span>
            </div>
          </div>

          <%!-- Column Formation --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-2" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Column Formation
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              Depth over width. Unstoppable push, vulnerable flanks.
            </p>

            <div class="flex justify-center mb-6">
              <svg viewBox="0 0 320 200" width="320" height="200">
                <rect width="320" height="200" fill="#3D3225" rx="8"/>

                <%!-- Column of 4 units --%>
                <g transform="translate(130, 15)">
                  <.hex_unit x={0} y={0} name="Α" color="#5D3A8E" phalanx={true} />
                </g>
                <g transform="translate(130, 55)">
                  <.hex_unit x={0} y={0} name="Β" color="#5D3A8E" phalanx={true} />
                </g>
                <g transform="translate(130, 95)">
                  <.hex_unit x={0} y={0} name="Γ" color="#5D3A8E" phalanx={true} />
                </g>
                <g transform="translate(130, 135)">
                  <.hex_unit x={0} y={0} name="Δ" color="#5D3A8E" phalanx={true} />
                </g>

                <%!-- Bond lines --%>
                <line x1="160" y1="50" x2="160" y2="55" stroke="#FACD1E" stroke-width="3" stroke-dasharray="4,2"/>
                <line x1="160" y1="90" x2="160" y2="95" stroke="#FACD1E" stroke-width="3" stroke-dasharray="4,2"/>
                <line x1="160" y1="130" x2="160" y2="135" stroke="#FACD1E" stroke-width="3" stroke-dasharray="4,2"/>

                <%!-- Danger zones --%>
                <text x="80" y="100" text-anchor="middle" fill="#7F2122" font-size="10" transform="rotate(-90, 80, 100)">⚠ EXPOSED</text>
                <text x="240" y="100" text-anchor="middle" fill="#7F2122" font-size="10" transform="rotate(90, 240, 100)">EXPOSED ⚠</text>

                <text x="160" y="190" text-anchor="middle" fill="#FACD1E" font-size="12">Massive depth — flanks exposed</text>
              </svg>
            </div>

            <div class="flex items-center justify-between p-3 rounded" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
              <span style="color: #9D8C71;">Formation Bonus (front unit)</span>
              <span class="font-bold" style="color: #FACD1E;">+3</span>
            </div>
          </div>

          <%!-- Block Formation --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <h3 class="text-xl font-semibold mb-2" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
              Block Formation
            </h3>
            <p class="text-sm mb-6" style="color: #9D8C71;">
              Width and depth combined. The ideal phalanx.
            </p>

            <div class="flex justify-center mb-6">
              <svg viewBox="0 0 320 200" width="320" height="200">
                <rect width="320" height="200" fill="#3D3225" rx="8"/>

                <%!-- 3x3 block --%>
                <%!-- Row 1 --%>
                <g transform="translate(90, 30)">
                  <.hex_unit x={0} y={0} name="Α" color="#D32929" phalanx={true} size={55} />
                </g>
                <g transform="translate(150, 30)">
                  <.hex_unit x={0} y={0} name="Β" color="#D32929" phalanx={true} size={55} />
                </g>
                <g transform="translate(210, 30)">
                  <.hex_unit x={0} y={0} name="Γ" color="#D32929" phalanx={true} size={55} />
                </g>
                <%!-- Row 2 --%>
                <g transform="translate(90, 75)">
                  <.hex_unit x={0} y={0} name="Δ" color="#D32929" phalanx={true} size={55} />
                </g>
                <g transform="translate(150, 75)">
                  <.hex_unit x={0} y={0} name="Ε" color="#D32929" phalanx={true} size={55} />
                </g>
                <g transform="translate(210, 75)">
                  <.hex_unit x={0} y={0} name="Ζ" color="#D32929" phalanx={true} size={55} />
                </g>
                <%!-- Row 3 --%>
                <g transform="translate(90, 120)">
                  <.hex_unit x={0} y={0} name="Η" color="#D32929" phalanx={true} size={55} />
                </g>
                <g transform="translate(150, 120)">
                  <.hex_unit x={0} y={0} name="Θ" color="#D32929" phalanx={true} size={55} />
                </g>
                <g transform="translate(210, 120)">
                  <.hex_unit x={0} y={0} name="Ι" color="#D32929" phalanx={true} size={55} />
                </g>

                <%!-- Center highlight --%>
                <circle cx="175" cy="100" r="35" fill="none" stroke="#FACD1E" stroke-width="2" stroke-dasharray="6,3" opacity="0.5"/>

                <text x="160" y="185" text-anchor="middle" fill="#FACD1E" font-size="12">Center unit: +3 (2 side + 1 rear)</text>
              </svg>
            </div>

            <div class="flex items-center justify-between p-3 rounded" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
              <span style="color: #9D8C71;">Formation Bonus (center unit)</span>
              <span class="font-bold" style="color: #FACD1E;">+3</span>
            </div>
          </div>
        </div>

        <%!-- Formation Rules --%>
        <div class="rounded-xl p-6" style="background: linear-gradient(135deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.05) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <h3 class="text-xl font-semibold mb-6" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Formation Rules
          </h3>

          <div class="grid md:grid-cols-3 gap-6">
            <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <div class="text-2xl mb-2" style="color: #FACD1E;">⚔</div>
              <h4 class="font-semibold mb-2" style="color: #E5DBB7;">Phalanx Requirements</h4>
              <ul class="text-sm space-y-1" style="color: #9D8C71;">
                <li>• Same group membership</li>
                <li>• All units adjacent</li>
                <li>• Same rotation (facing)</li>
                <li>• Minimum 2 units</li>
              </ul>
            </div>

            <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <div class="text-2xl mb-2" style="color: #FACD1E;">🛡</div>
              <h4 class="font-semibold mb-2" style="color: #E5DBB7;">Bonus Calculation</h4>
              <ul class="text-sm space-y-1" style="color: #9D8C71;">
                <li>• +1 per adjacent phalanx ally</li>
                <li>• Side allies: max +2</li>
                <li>• Rear allies: unlimited</li>
                <li>• Bonuses NEVER cut</li>
              </ul>
            </div>

            <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <div class="text-2xl mb-2" style="color: #FACD1E;">⚡</div>
              <h4 class="font-semibold mb-2" style="color: #E5DBB7;">Atomic Movement</h4>
              <ul class="text-sm space-y-1" style="color: #9D8C71;">
                <li>• All move together</li>
                <li>• All balk together</li>
                <li>• One blocked = all stop</li>
                <li>• Total commitment</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp hex_unit(assigns) do
    assigns = assign_new(assigns, :phalanx, fn -> false end)
    assigns = assign_new(assigns, :size, fn -> 60 end)

    ~H"""
    <g>
      <%!-- Phalanx glow --%>
      <circle :if={@phalanx} cx={@size/2} cy={@size * 0.577} r={@size * 0.6} fill="none" stroke="#FACD1E" stroke-width="2" opacity="0.3"/>

      <svg viewBox="0 0 100 115.47" width={@size} height={@size * 1.1547}>
        <polygon
          points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
          fill={@color}
          style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.4));"
        />
        <%!-- Phalanx indicator ring --%>
        <polygon :if={@phalanx}
          points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
          fill="none"
          stroke="#FACD1E"
          stroke-width="3"
        />
        <%!-- Chevrons --%>
        <polyline points="15,35.21 50,15 85,35.21" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <polyline points="25,39.44 50,25 75,39.44" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <polyline points="35,43.66 50,35 65,43.66" stroke="#FFF5E6" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
        <%!-- Name --%>
        <text x="50" y="78" text-anchor="middle" dominant-baseline="middle" fill="#FFF5E6" font-size="22" font-weight="bold" style="font-family: 'Cinzel', serif;">
          <%= @name %>
        </text>
      </svg>
    </g>
    """
  end
end
