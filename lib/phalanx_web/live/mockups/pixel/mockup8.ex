defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup8 do
  @moduledoc "Full Battle Scene - Pixel Art Style"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      @import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap');
      .pixel-font { font-family: 'Press Start 2P', monospace; }
      .pixel-border { border: 4px solid #5c4033; box-shadow: inset 0 0 0 2px #d4a574, inset 0 0 0 4px #8b6914; }
      .pixel-shadow { box-shadow: 4px 4px 0 #1a0f08; }
      .parchment { background: #e8d4b8; }
    </style>
    <div class="min-h-screen p-4" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-6xl mx-auto">
        <.nav_header title="BATTLE" />

        <div class="grid grid-cols-4 gap-4">
          <div class="col-span-3">
            <div class="pixel-border pixel-shadow p-4" style="background-color: #3d5c3d;">
              <svg viewBox="0 0 500 400" width="100%" height="400" style="image-rendering: pixelated;">
                <defs>
                  <pattern id="grid" width="40" height="46" patternUnits="userSpaceOnUse">
                    <polygon points="20,0 40,12 40,35 20,46 0,35 0,12" fill="none" stroke="#2d4a2d" stroke-width="1" />
                  </pattern>
                </defs>
                <rect width="500" height="400" fill="url(#grid)" />

                <.battle_hex x={100} y={80} name="A" team="red" health={3} rotation={180} />
                <.battle_hex x={140} y={80} name="B" team="red" health={3} rotation={180} bonded={true} />
                <.battle_hex x={180} y={80} name="C" team="red" health={2} rotation={180} bonded={true} />

                <.battle_hex x={120} y={115} name="D" team="red" health={3} rotation={180} />
                <.battle_hex x={160} y={115} name="E" team="red" health={3} rotation={180} bonded={true} />

                <.battle_hex x={320} y={280} name="V" team="purple" health={3} rotation={0} />
                <.battle_hex x={360} y={280} name="W" team="purple" health={2} rotation={0} bonded={true} />
                <.battle_hex x={400} y={280} name="X" team="purple" health={3} rotation={0} bonded={true} />

                <.battle_hex x={340} y={245} name="Y" team="purple" health={3} rotation={0} />
                <.battle_hex x={380} y={245} name="Z" team="purple" health={1} rotation={0} bonded={true} critical={true} />

                <.battle_hex x={200} y={180} name="F" team="red" health={2} rotation={120} attacking={true} />

                <line x1="215" y1="185" x2="305" y2="240" stroke="#ff6600" stroke-width="3" stroke-dasharray="8,4" />

                <text x="250" y="30" text-anchor="middle" fill="#f5f5dc" font-size="12" font-family="'Press Start 2P', monospace">
                  TURN 7 - COMBAT PHASE
                </text>
              </svg>
            </div>
          </div>

          <div class="space-y-4">
            <div class="pixel-border pixel-shadow parchment p-4">
              <h3 class="pixel-font text-stone-800 mb-3" style="font-size: 8px;">TURN 7</h3>
              <div class="flex items-center justify-between mb-2">
                <div class="flex items-center gap-2">
                  <div class="w-4 h-4" style="background-color: #8b0000;"></div>
                  <span class="pixel-font text-stone-700" style="font-size: 7px;">RED</span>
                </div>
                <span class="pixel-font text-stone-800" style="font-size: 8px;">5 UNITS</span>
              </div>
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-2">
                  <div class="w-4 h-4" style="background-color: #4a1259;"></div>
                  <span class="pixel-font text-stone-700" style="font-size: 7px;">PURPLE</span>
                </div>
                <span class="pixel-font text-stone-800" style="font-size: 8px;">5 UNITS</span>
              </div>
            </div>

            <div class="pixel-border pixel-shadow parchment p-4">
              <h3 class="pixel-font text-stone-800 mb-3" style="font-size: 8px;">COMBAT LOG</h3>
              <div class="space-y-2 max-h-32 overflow-y-auto">
                <p class="pixel-font text-red-700" style="font-size: 6px;">> F FLANKS Z</p>
                <p class="pixel-font text-stone-600" style="font-size: 6px;">> STR 5 vs DEF 2</p>
                <p class="pixel-font text-red-700" style="font-size: 6px;">> Z TAKES 3 DMG!</p>
                <p class="pixel-font text-stone-500" style="font-size: 6px;">> Z CRITICAL</p>
              </div>
            </div>

            <div class="pixel-border pixel-shadow parchment p-4">
              <h3 class="pixel-font text-stone-800 mb-3" style="font-size: 8px;">FORMATIONS</h3>
              <div class="space-y-2">
                <div class="flex items-center justify-between">
                  <span class="pixel-font text-stone-600" style="font-size: 6px;">RED PHALANX</span>
                  <span class="pixel-font text-amber-700" style="font-size: 7px;">+4</span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="pixel-font text-stone-600" style="font-size: 6px;">PURPLE LINE</span>
                  <span class="pixel-font text-amber-700" style="font-size: 7px;">+3</span>
                </div>
              </div>
            </div>

            <div class="pixel-border pixel-shadow p-4" style="background-color: #4a1259;">
              <h3 class="pixel-font text-amber-100 mb-2" style="font-size: 8px;">OBJECTIVE</h3>
              <p class="pixel-font text-purple-300" style="font-size: 6px;">DESTROY ALL ENEMY UNITS</p>
            </div>
          </div>
        </div>

        <div class="mt-4 pixel-border pixel-shadow parchment p-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <span class="pixel-font text-stone-700" style="font-size: 8px;">PHASE:</span>
              <div class="flex gap-2">
                <span class="pixel-font text-stone-400" style="font-size: 7px;">ORDER</span>
                <span class="pixel-font text-stone-400" style="font-size: 7px;">MOVE</span>
                <span class="pixel-font text-amber-700" style="font-size: 7px;">[COMBAT]</span>
                <span class="pixel-font text-stone-400" style="font-size: 7px;">RETREAT</span>
                <span class="pixel-font text-stone-400" style="font-size: 7px;">CLEANUP</span>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <div class="w-3 h-3 rounded-full bg-green-500"></div>
              <span class="pixel-font text-stone-600" style="font-size: 7px;">RESOLVING...</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp nav_header(assigns) do
    ~H"""
    <div class="mb-4 flex items-center justify-between">
      <.link navigate={~p"/mockups/pixel"} class="pixel-font text-amber-200 hover:text-amber-100" style="font-size: 8px;">
        &lt; BACK
      </.link>
      <h1 class="pixel-font text-amber-100" style="font-size: 14px; text-shadow: 2px 2px 0 #1a0f08;">
        {@title}
      </h1>
      <div style="width: 60px;"></div>
    </div>
    """
  end

  defp battle_hex(assigns) do
    assigns = assign_new(assigns, :health, fn -> 3 end)
    assigns = assign_new(assigns, :rotation, fn -> 0 end)
    assigns = assign_new(assigns, :bonded, fn -> false end)
    assigns = assign_new(assigns, :attacking, fn -> false end)
    assigns = assign_new(assigns, :critical, fn -> false end)

    team_color = if assigns.team == "red", do: "#8b0000", else: "#4a1259"
    assigns = assign(assigns, :team_color, team_color)

    ~H"""
    <g>
      <polygon
        points={"#{@x},#{@y - 20} #{@x + 20},#{@y - 10} #{@x + 20},#{@y + 10} #{@x},#{@y + 20} #{@x - 20},#{@y + 10} #{@x - 20},#{@y - 10}"}
        fill={@team_color}
        stroke={if @critical, do: "#ff0000", else: (if @bonded, do: "#ffd700", else: "none")}
        stroke-width={if @bonded || @critical, do: "2", else: "0"}
        opacity={if @critical, do: "0.6", else: "1"}
      />

      <line
        x1={@x - 8}
        y1={@y - 12}
        x2={@x}
        y2={@y - 16}
        stroke="#f5f5dc"
        stroke-width="2"
        transform={"rotate(#{@rotation}, #{@x}, #{@y})"}
      />
      <line
        x1={@x + 8}
        y1={@y - 12}
        x2={@x}
        y2={@y - 16}
        stroke="#f5f5dc"
        stroke-width="2"
        transform={"rotate(#{@rotation}, #{@x}, #{@y})"}
      />

      <text x={@x} y={@y + 4} text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">
        {@name}
      </text>

      <%= for i <- 0..2 do %>
        <rect
          x={@x - 9 + i * 7}
          y={@y + 12}
          width="5"
          height="3"
          fill={if i < @health, do: "#228b22", else: "#333"}
        />
      <% end %>

      <circle :if={@attacking} cx={@x + 15} cy={@y - 15} r="5" fill="#ff6600" />
    </g>
    """
  end
end
