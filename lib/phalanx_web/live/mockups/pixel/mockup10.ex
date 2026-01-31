defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup10 do
  @moduledoc "Game Setup - Pixel Art Style"
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
      .scroll-roll { background: repeating-linear-gradient(180deg, #c4956a 0px, #c4956a 8px, #b4855a 8px, #b4855a 16px); }
    </style>
    <div class="min-h-screen p-6" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-5xl mx-auto">
        <div class="text-center mb-8">
          <div class="pixel-border pixel-shadow inline-block p-6" style="background: linear-gradient(180deg, #d4a574 0%, #c4956a 50%, #b4855a 100%);">
            <h1 class="pixel-font text-stone-900" style="font-size: 18px; text-shadow: 2px 2px 0 #d4a574;">
              PHALANX
            </h1>
            <p class="pixel-font text-stone-700 mt-2" style="font-size: 8px;">PREPARE FOR BATTLE</p>
          </div>
        </div>

        <div class="grid grid-cols-3 gap-6 mb-8">
          <div class="relative">
            <div class="absolute -top-3 left-4 right-4 h-5 scroll-roll rounded-t-lg"></div>
            <div class="pixel-border parchment p-6 pt-8">
              <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">GAME MODE</h2>

              <div class="space-y-3">
                <.mode_option name="ELIMINATION" desc="DESTROY ALL" selected={true} />
                <.mode_option name="SIEGE" desc="HOLD GROUND" />
                <.mode_option name="CAPTURE" desc="TAKE FLAG" />
              </div>
            </div>
            <div class="absolute -bottom-3 left-4 right-4 h-5 scroll-roll rounded-b-lg"></div>
          </div>

          <div class="relative">
            <div class="absolute -top-3 left-4 right-4 h-5 scroll-roll rounded-t-lg"></div>
            <div class="pixel-border parchment p-6 pt-8">
              <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">MAP SIZE</h2>

              <div class="space-y-3">
                <.mode_option name="SMALL" desc="8x8 HEX" />
                <.mode_option name="MEDIUM" desc="10x10 HEX" selected={true} />
                <.mode_option name="LARGE" desc="12x12 HEX" />
              </div>
            </div>
            <div class="absolute -bottom-3 left-4 right-4 h-5 scroll-roll rounded-b-lg"></div>
          </div>

          <div class="relative">
            <div class="absolute -top-3 left-4 right-4 h-5 scroll-roll rounded-t-lg"></div>
            <div class="pixel-border parchment p-6 pt-8">
              <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">ARMY SIZE</h2>

              <div class="space-y-3">
                <.mode_option name="SKIRMISH" desc="3 UNITS" />
                <.mode_option name="BATTLE" desc="5 UNITS" selected={true} />
                <.mode_option name="WAR" desc="8 UNITS" />
              </div>
            </div>
            <div class="absolute -bottom-3 left-4 right-4 h-5 scroll-roll rounded-b-lg"></div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-6" style="font-size: 10px;">CHOOSE YOUR SIDE</h2>

          <div class="grid grid-cols-2 gap-8">
            <div class="p-4 pixel-border cursor-pointer hover:opacity-80" style="background-color: #8b0000;">
              <div class="flex items-center justify-between mb-4">
                <span class="pixel-font text-amber-100" style="font-size: 12px;">RED LEGION</span>
                <div class="w-6 h-6 pixel-border" style="background-color: #ffd700;"></div>
              </div>
              <div class="flex gap-2 mb-4">
                <.mini_unit name="A" />
                <.mini_unit name="B" />
                <.mini_unit name="C" />
                <.mini_unit name="D" />
                <.mini_unit name="E" />
              </div>
              <p class="pixel-font text-red-200" style="font-size: 6px;">DISCIPLINED INFANTRY</p>
              <p class="pixel-font text-red-300 mt-1" style="font-size: 6px;">+1 FORMATION BONUS</p>
            </div>

            <div class="p-4 pixel-border cursor-pointer hover:opacity-80" style="background-color: #4a1259;">
              <div class="flex items-center justify-between mb-4">
                <span class="pixel-font text-amber-100" style="font-size: 12px;">PURPLE HORDE</span>
                <div class="w-6 h-6 pixel-border" style="background-color: transparent; border-color: #888;"></div>
              </div>
              <div class="flex gap-2 mb-4">
                <.mini_unit name="V" />
                <.mini_unit name="W" />
                <.mini_unit name="X" />
                <.mini_unit name="Y" />
                <.mini_unit name="Z" />
              </div>
              <p class="pixel-font text-purple-200" style="font-size: 6px;">FIERCE WARRIORS</p>
              <p class="pixel-font text-purple-300 mt-1" style="font-size: 6px;">+1 ATTACK POWER</p>
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">DEPLOYMENT ZONE</h2>

          <div class="flex justify-center">
            <svg viewBox="0 0 400 200" width="400" height="200" style="image-rendering: pixelated;">
              <rect x="0" y="0" width="400" height="60" fill="#8b0000" opacity="0.3" stroke="#8b0000" stroke-width="2" stroke-dasharray="8" />
              <text x="200" y="35" text-anchor="middle" fill="#8b0000" font-size="10" font-family="'Press Start 2P', monospace">RED DEPLOY</text>

              <rect x="0" y="70" width="400" height="60" fill="#3d5c3d" opacity="0.5" />
              <text x="200" y="105" text-anchor="middle" fill="#2d4a2d" font-size="10" font-family="'Press Start 2P', monospace">BATTLEFIELD</text>

              <rect x="0" y="140" width="400" height="60" fill="#4a1259" opacity="0.3" stroke="#4a1259" stroke-width="2" stroke-dasharray="8" />
              <text x="200" y="175" text-anchor="middle" fill="#4a1259" font-size="10" font-family="'Press Start 2P', monospace">PURPLE DEPLOY</text>

              <.deploy_hex x={80} y={30} name="A" />
              <.deploy_hex x={120} y={30} name="B" />
              <.deploy_hex x={160} y={30} name="C" />
              <.deploy_hex x={200} y={30} name="D" />
              <.deploy_hex x={240} y={30} name="E" />
            </svg>
          </div>

          <div class="mt-4 text-center">
            <span class="pixel-font text-stone-600" style="font-size: 7px;">DRAG UNITS TO POSITION - CLICK TO ROTATE</span>
          </div>
        </div>

        <div class="flex justify-center gap-6">
          <button class="pixel-border pixel-shadow px-8 py-4" style="background-color: #666;">
            <span class="pixel-font text-amber-100" style="font-size: 10px;">BACK</span>
          </button>
          <button class="pixel-border pixel-shadow px-8 py-4" style="background-color: #228b22;">
            <span class="pixel-font text-amber-100" style="font-size: 12px;">START BATTLE</span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp mode_option(assigns) do
    assigns = assign_new(assigns, :selected, fn -> false end)

    ~H"""
    <div class={"p-3 cursor-pointer #{if @selected, do: "border-l-4 border-amber-500"}"} style={"background-color: #{if @selected, do: "#c4956a", else: "#d4c4a8"};"}>
      <div class="flex items-center justify-between">
        <span class="pixel-font text-stone-800" style="font-size: 8px;">{@name}</span>
        <span class="pixel-font text-stone-600" style="font-size: 6px;">{@desc}</span>
      </div>
    </div>
    """
  end

  defp mini_unit(assigns) do
    ~H"""
    <div class="w-8 h-8 flex items-center justify-center pixel-border" style="background-color: rgba(0,0,0,0.3);">
      <span class="pixel-font text-amber-100" style="font-size: 8px;">{@name}</span>
    </div>
    """
  end

  defp deploy_hex(assigns) do
    ~H"""
    <g>
      <polygon
        points={"#{@x},#{@y - 15} #{@x + 15},#{@y - 7} #{@x + 15},#{@y + 7} #{@x},#{@y + 15} #{@x - 15},#{@y + 7} #{@x - 15},#{@y - 7}"}
        fill="#8b0000"
        stroke="#ffd700"
        stroke-width="2"
      />
      <text x={@x} y={@y + 3} text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">
        {@name}
      </text>
    </g>
    """
  end
end
