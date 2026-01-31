defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup8 do
  @moduledoc "Full Battle Scene - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-4" style="background: #1e1308;">
      <div class="max-w-6xl mx-auto">
        <.nav_header title="Battle" />

        <div class="grid grid-cols-4 gap-4">
          <div class="col-span-3">
            <div class="rounded p-4" style="background: #2d4a2d; border: 3px solid #1a331a;">
              <div class="text-center mb-4">
                <span class="text-lg font-semibold" style="color: #c9d4b8; font-family: 'Cinzel', serif;">Turn 7 — Combat Phase</span>
              </div>

              <svg viewBox="0 0 500 360" width="100%" height="360">
                <defs>
                  <pattern id="hex-grid" width="44" height="50" patternUnits="userSpaceOnUse">
                    <polygon points="22,2 42,14 42,38 22,50 2,38 2,14" fill="none" stroke="#3d5c3d" stroke-width="1" />
                  </pattern>
                </defs>
                <rect width="500" height="360" fill="url(#hex-grid)" />

                <.battle_unit x={80} y={70} name="A" team="red" health={3} />
                <.battle_unit x={124} y={70} name="B" team="red" health={3} bonded={true} />
                <.battle_unit x={168} y={70} name="C" team="red" health={2} bonded={true} />

                <.battle_unit x={102} y={110} name="D" team="red" health={3} />
                <.battle_unit x={146} y={110} name="E" team="red" health={3} bonded={true} />

                <.battle_unit x={320} y={260} name="V" team="purple" health={3} rotation={180} />
                <.battle_unit x={364} y={260} name="W" team="purple" health={2} rotation={180} bonded={true} />
                <.battle_unit x={408} y={260} name="X" team="purple" health={3} rotation={180} bonded={true} />

                <.battle_unit x={342} y={220} name="Y" team="purple" health={3} rotation={180} />
                <.battle_unit x={386} y={220} name="Z" team="purple" health={1} rotation={180} bonded={true} critical={true} />

                <.battle_unit x={200} y={160} name="F" team="red" health={2} rotation={120} attacking={true} />

                <line x1="218" y1="170" x2="320" y2="220" stroke="#ff6600" stroke-width="3" stroke-dasharray="8,4" />
                <polygon points="320,220 305,212 308,222" fill="#ff6600" />
              </svg>
            </div>
          </div>

          <div class="space-y-4">
            <.info_card title="Turn 7">
              <div class="space-y-2">
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <div class="w-3 h-3 rounded" style="background: #8b0000;"></div>
                    <span style="color: #6b4423;">Red</span>
                  </div>
                  <span class="font-bold" style="color: #3d2817;">6 units</span>
                </div>
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <div class="w-3 h-3 rounded" style="background: #4a1259;"></div>
                    <span style="color: #6b4423;">Purple</span>
                  </div>
                  <span class="font-bold" style="color: #3d2817;">5 units</span>
                </div>
              </div>
            </.info_card>

            <.info_card title="Combat Log">
              <div class="space-y-1 text-sm max-h-28 overflow-y-auto">
                <p style="color: #aa4444;">› F flanks Z</p>
                <p style="color: #6b4423;">› STR 5 vs DEF 2</p>
                <p style="color: #aa4444;">› Z takes 3 damage!</p>
                <p style="color: #8b6914;">› Z is critical</p>
              </div>
            </.info_card>

            <.info_card title="Formations">
              <div class="space-y-2 text-sm">
                <div class="flex items-center justify-between">
                  <span style="color: #6b4423;">Red phalanx</span>
                  <span class="font-bold" style="color: #ffd700;">+4</span>
                </div>
                <div class="flex items-center justify-between">
                  <span style="color: #6b4423;">Purple line</span>
                  <span class="font-bold" style="color: #ffd700;">+3</span>
                </div>
              </div>
            </.info_card>

            <div class="p-3 rounded" style="background: rgba(74, 18, 89, 0.5); border: 1px solid #7a5090;">
              <h3 class="font-semibold mb-1" style="color: #c9a0dc; font-size: 13px;">Objective</h3>
              <p class="text-sm" style="color: #9070a0;">Destroy all enemy units</p>
            </div>
          </div>
        </div>

        <div class="mt-4 p-3 rounded flex items-center justify-between" style="background: linear-gradient(180deg, #e8d4b8 0%, #ddd0ba 100%); border: 2px solid #8b6914;">
          <div class="flex items-center gap-4">
            <span class="font-semibold" style="color: #6b4423;">Phase:</span>
            <div class="flex gap-3 text-sm">
              <span style="color: #aaa;">Orders</span>
              <span style="color: #aaa;">Movement</span>
              <span class="font-bold px-2 py-0.5 rounded" style="background: #ffd700; color: #3d2817;">Combat</span>
              <span style="color: #aaa;">Retreat</span>
              <span style="color: #aaa;">Cleanup</span>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <div class="w-2.5 h-2.5 rounded-full animate-pulse" style="background: #22c55e;"></div>
            <span class="text-sm" style="color: #6b4423;">Resolving...</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp nav_header(assigns) do
    ~H"""
    <div class="mb-4 flex items-center justify-between">
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

  defp info_card(assigns) do
    ~H"""
    <div class="p-3 rounded" style="background: linear-gradient(180deg, #e8d4b8 0%, #ddd0ba 100%); border: 2px solid #8b6914;">
      <h3 class="font-semibold mb-2" style="color: #3d2817; font-family: 'Cinzel', serif; font-size: 13px; border-bottom: 1px solid #8b6914; padding-bottom: 4px;">
        {@title}
      </h3>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp battle_unit(assigns) do
    assigns = assign_new(assigns, :health, fn -> 3 end)
    assigns = assign_new(assigns, :rotation, fn -> 0 end)
    assigns = assign_new(assigns, :bonded, fn -> false end)
    assigns = assign_new(assigns, :attacking, fn -> false end)
    assigns = assign_new(assigns, :critical, fn -> false end)

    team_color = if assigns.team == "red", do: "#8b0000", else: "#4a1259"
    assigns = assign(assigns, :team_color, team_color)

    ~H"""
    <g transform={"translate(#{@x}, #{@y})"}>
      <g transform={"rotate(#{@rotation}, 0, 0)"}>
        <polygon
          points="0,-18 18,-9 18,9 0,18 -18,9 -18,-9"
          fill={@team_color}
          stroke={cond do
            @critical -> "#ff4444"
            @bonded -> "#ffd700"
            true -> "none"
          end}
          stroke-width={if @bonded || @critical, do: "2", else: "0"}
          opacity={if @critical, do: "0.5", else: "1"}
          style="filter: drop-shadow(0 2px 3px rgba(0,0,0,0.4));"
        />

        <polyline :if={@health >= 1 && !@critical} points="-10,-10 0,-15 10,-10" stroke="#fff8e7" stroke-width="2.5" stroke-linecap="round" fill="none" />
        <polyline :if={@health >= 2 && !@critical} points="-7,-7 0,-11 7,-7" stroke="#fff8e7" stroke-width="2.5" stroke-linecap="round" fill="none" />
        <polyline :if={@health >= 3 && !@critical} points="-4,-4 0,-7 4,-4" stroke="#fff8e7" stroke-width="2.5" stroke-linecap="round" fill="none" />
      </g>

      <text x="0" y="5" text-anchor="middle" fill={if @critical, do: "#ff4444", else: "#fff8e7"} font-size="12" font-weight="bold">
        {@name}
      </text>

      <circle :if={@attacking} cx="14" cy="-14" r="5" fill="#ff6600" />

      <g :if={!@critical}>
        <%= for i <- 0..2 do %>
          <rect x={-8 + i * 6} y="12" width="4" height="3" rx="1"
                fill={if i < @health, do: "#22c55e", else: "#333"} />
        <% end %>
      </g>
    </g>
    """
  end
end
