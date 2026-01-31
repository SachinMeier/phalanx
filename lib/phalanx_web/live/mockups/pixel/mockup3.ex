defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup3 do
  @moduledoc "Combat Resolution - Pixel Art Style"
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
      @keyframes pixel-flash { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } }
      .combat-flash { animation: pixel-flash 0.5s infinite; }
    </style>
    <div class="min-h-screen p-6" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="COMBAT" />

        <div class="grid grid-cols-2 gap-6 mb-8">
          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">FRONTAL ASSAULT</h2>
            <p class="pixel-font text-stone-600 mb-4" style="font-size: 7px;">SHIELDS DEFLECT - REDUCED DAMAGE</p>

            <div class="flex items-center justify-center gap-8">
              <div class="text-center">
                <.pixel_unit name="A" team="red" attacking={true} />
                <div class="pixel-font text-red-700 mt-2" style="font-size: 8px;">STR: 5</div>
              </div>

              <div class="flex flex-col items-center">
                <svg viewBox="0 0 40 20" width="40" height="20">
                  <polygon points="0,10 15,0 15,7 40,7 40,13 15,13 15,20" fill="#ff6600" />
                </svg>
                <div class="pixel-font text-amber-700 mt-1" style="font-size: 6px;">FRONT</div>
              </div>

              <div class="text-center">
                <.pixel_unit name="X" team="purple" defending={true} />
                <div class="pixel-font text-purple-700 mt-2" style="font-size: 8px;">DEF: 6</div>
              </div>
            </div>

            <div class="mt-4 p-3 text-center" style="background-color: #d4c4a8;">
              <span class="pixel-font text-stone-700" style="font-size: 8px;">RESULT: ATTACKER BOUNCES</span>
            </div>
          </div>

          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">FLANK ATTACK</h2>
            <p class="pixel-font text-stone-600 mb-4" style="font-size: 7px;">EXPOSED SIDE - BONUS DAMAGE</p>

            <div class="flex items-center justify-center gap-4">
              <div class="text-center">
                <.pixel_unit name="B" team="red" attacking={true} />
                <div class="pixel-font text-red-700 mt-2" style="font-size: 8px;">STR: 5</div>
              </div>

              <div class="flex flex-col items-center">
                <svg viewBox="0 0 40 20" width="40" height="20">
                  <polygon points="0,10 15,0 15,7 40,7 40,13 15,13 15,20" fill="#ff0000" />
                </svg>
                <div class="pixel-font text-red-700 mt-1" style="font-size: 6px;">+2 FLANK</div>
              </div>

              <div class="text-center relative">
                <.pixel_unit name="Y" team="purple" rotation={90} hit={true} />
                <div class="pixel-font text-purple-700 mt-2" style="font-size: 8px;">DEF: 3</div>
              </div>
            </div>

            <div class="mt-4 p-3 text-center" style="background-color: #ffcccc;">
              <span class="pixel-font text-red-700" style="font-size: 8px;">RESULT: 4 DAMAGE!</span>
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">REAR ATTACK</h2>
          <p class="pixel-font text-stone-600 mb-4" style="font-size: 7px;">DEVASTATING - MAXIMUM DAMAGE MULTIPLIER</p>

          <div class="flex items-center justify-center gap-8">
            <div class="text-center">
              <.pixel_unit name="C" team="red" attacking={true} />
              <div class="pixel-font text-red-700 mt-2" style="font-size: 8px;">STR: 4</div>
            </div>

            <div class="flex flex-col items-center">
              <svg viewBox="0 0 60 20" width="60" height="20">
                <polygon points="0,10 15,0 15,7 60,7 60,13 15,13 15,20" fill="#ff0000" class="combat-flash" />
              </svg>
              <div class="pixel-font text-red-700 mt-1" style="font-size: 6px;">+4 REAR</div>
            </div>

            <div class="text-center">
              <.pixel_unit name="Z" team="purple" rotation={180} hit={true} critical={true} />
              <div class="pixel-font text-purple-700 mt-2" style="font-size: 8px;">DEF: 1</div>
            </div>
          </div>

          <div class="mt-4 p-3 text-center" style="background-color: #ff6666;">
            <span class="pixel-font text-white" style="font-size: 8px;">CRITICAL HIT! UNIT DESTROYED!</span>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">ATTACK ANGLE REFERENCE</h2>

          <div class="grid grid-cols-3 gap-4 text-center">
            <div class="p-4" style="background-color: #d4c4a8;">
              <div class="pixel-font text-green-700 mb-2" style="font-size: 10px;">FRONT</div>
              <div class="pixel-font text-stone-600" style="font-size: 7px;">x1.0 DMG</div>
              <div class="pixel-font text-stone-500 mt-1" style="font-size: 6px;">SHIELDS UP</div>
            </div>
            <div class="p-4" style="background-color: #ffe4b8;">
              <div class="pixel-font text-amber-700 mb-2" style="font-size: 10px;">FLANK</div>
              <div class="pixel-font text-stone-600" style="font-size: 7px;">x1.5 DMG</div>
              <div class="pixel-font text-stone-500 mt-1" style="font-size: 6px;">EXPOSED</div>
            </div>
            <div class="p-4" style="background-color: #ffcccc;">
              <div class="pixel-font text-red-700 mb-2" style="font-size: 10px;">REAR</div>
              <div class="pixel-font text-stone-600" style="font-size: 7px;">x2.0 DMG</div>
              <div class="pixel-font text-stone-500 mt-1" style="font-size: 6px;">UNDEFENDED</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp nav_header(assigns) do
    ~H"""
    <div class="mb-6 flex items-center justify-between">
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

  defp pixel_unit(assigns) do
    assigns = assign_new(assigns, :rotation, fn -> 0 end)
    assigns = assign_new(assigns, :attacking, fn -> false end)
    assigns = assign_new(assigns, :defending, fn -> false end)
    assigns = assign_new(assigns, :hit, fn -> false end)
    assigns = assign_new(assigns, :critical, fn -> false end)

    team_colors = %{"red" => "#8b0000", "purple" => "#4a1259"}
    assigns = assign(assigns, :color, team_colors[assigns.team])

    ~H"""
    <div class={"relative #{if @critical, do: "combat-flash"}"}>
      <svg viewBox="0 0 48 56" width="48" height="56" style="image-rendering: pixelated;">
        <polygon points="24,0 48,14 48,42 24,56 0,42 0,14" fill={@color} opacity={if @critical, do: "0.5", else: "1"} />

        <polygon points="24,8 12,14" fill="none" stroke="#f5f5dc" stroke-width="3"
          transform={"rotate(#{@rotation}, 24, 28)"} />
        <polygon points="24,8 36,14" fill="none" stroke="#f5f5dc" stroke-width="3"
          transform={"rotate(#{@rotation}, 24, 28)"} />

        <text x="24" y="38" text-anchor="middle" fill="#f5f5dc" font-size="14" font-weight="bold">
          {@name}
        </text>
      </svg>

      <div :if={@attacking} class="absolute -top-2 -right-2 w-4 h-4 flex items-center justify-center" style="background-color: #ff6600;">
        <span class="pixel-font text-white" style="font-size: 8px;">!</span>
      </div>

      <div :if={@hit && !@critical} class="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div class="pixel-font text-red-500" style="font-size: 16px; text-shadow: 1px 1px 0 #000;">-1</div>
      </div>

      <div :if={@critical} class="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div class="pixel-font text-red-500" style="font-size: 12px; text-shadow: 1px 1px 0 #000;">DEAD</div>
      </div>
    </div>
    """
  end
end
