defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup2 do
  @moduledoc "Phalanx Formations - Pixel Art Style"
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
    <div class="min-h-screen p-6" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="FORMATIONS" />

        <div class="grid grid-cols-2 gap-6 mb-8">
          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">SIDE COHESION</h2>
            <p class="pixel-font text-stone-600 mb-6" style="font-size: 7px;">UNITS FACING SAME WAY = PHALANX</p>

            <div class="flex justify-center gap-1 mb-4">
              <.pixel_hex name="A" team="red" rotation={0} bonded_right={true} />
              <.pixel_hex name="B" team="red" rotation={0} bonded_left={true} bonded_right={true} />
              <.pixel_hex name="C" team="red" rotation={0} bonded_left={true} />
            </div>

            <div class="flex items-center justify-center gap-2 mt-4">
              <div class="w-4 h-1" style="background-color: #ffd700;"></div>
              <span class="pixel-font text-amber-700" style="font-size: 7px;">SHIELD BOND</span>
            </div>
          </div>

          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">DEPTH BONUS</h2>
            <p class="pixel-font text-stone-600 mb-6" style="font-size: 7px;">UNITS BEHIND ADD PUSH POWER</p>

            <div class="flex flex-col items-center gap-1 mb-4">
              <.pixel_hex name="D" team="purple" rotation={0} depth_front={true} />
              <.pixel_hex name="E" team="purple" rotation={0} depth_behind={true} depth_front={true} />
              <.pixel_hex name="F" team="purple" rotation={0} depth_behind={true} />
            </div>

            <div class="flex items-center justify-center gap-2 mt-4">
              <div class="w-1 h-4" style="background-color: #00ff00;"></div>
              <span class="pixel-font text-green-700" style="font-size: 7px;">DEPTH LINK</span>
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">FULL PHALANX FORMATION</h2>
          <p class="pixel-font text-stone-600 mb-6" style="font-size: 7px;">SIDE COHESION + DEPTH = MAXIMUM STRENGTH</p>

          <div class="flex justify-center">
            <div class="grid gap-1" style="grid-template-columns: repeat(3, 48px);">
              <.pixel_hex name="G" team="red" rotation={0} bonded_right={true} depth_front={true} />
              <.pixel_hex name="H" team="red" rotation={0} bonded_left={true} bonded_right={true} depth_front={true} />
              <.pixel_hex name="I" team="red" rotation={0} bonded_left={true} depth_front={true} />

              <.pixel_hex name="J" team="red" rotation={0} bonded_right={true} depth_behind={true} />
              <.pixel_hex name="K" team="red" rotation={0} bonded_left={true} bonded_right={true} depth_behind={true} />
              <.pixel_hex name="L" team="red" rotation={0} bonded_left={true} depth_behind={true} />
            </div>
          </div>

          <div class="flex items-center justify-center gap-6 mt-6">
            <div class="flex items-center gap-2">
              <div class="w-4 h-4 flex items-center justify-center" style="background-color: #8b0000;">
                <span class="pixel-font text-amber-100" style="font-size: 6px;">6</span>
              </div>
              <span class="pixel-font text-stone-600" style="font-size: 7px;">BASE STR</span>
            </div>
            <div class="pixel-font text-stone-800" style="font-size: 10px;">+</div>
            <div class="flex items-center gap-2">
              <div class="w-4 h-4" style="background-color: #ffd700;"></div>
              <span class="pixel-font text-stone-600" style="font-size: 7px;">+4 SIDE</span>
            </div>
            <div class="pixel-font text-stone-800" style="font-size: 10px;">+</div>
            <div class="flex items-center gap-2">
              <div class="w-4 h-4" style="background-color: #00ff00;"></div>
              <span class="pixel-font text-stone-600" style="font-size: 7px;">+3 DEPTH</span>
            </div>
            <div class="pixel-font text-stone-800" style="font-size: 10px;">=</div>
            <div class="flex items-center gap-2">
              <div class="w-6 h-6 flex items-center justify-center pixel-border" style="background-color: #8b0000;">
                <span class="pixel-font text-amber-100" style="font-size: 8px;">13</span>
              </div>
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">BROKEN FORMATION</h2>
          <p class="pixel-font text-stone-600 mb-6" style="font-size: 7px;">WRONG FACING = NO BONUS</p>

          <div class="flex justify-center gap-4">
            <div class="flex gap-1">
              <.pixel_hex name="M" team="purple" rotation={0} />
              <.pixel_hex name="N" team="purple" rotation={60} />
              <.pixel_hex name="O" team="purple" rotation={0} />
            </div>
          </div>

          <div class="mt-4 text-center">
            <span class="pixel-font text-red-700" style="font-size: 8px;">NO SIDE COHESION - N FACES WRONG WAY</span>
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

  defp pixel_hex(assigns) do
    assigns = assign_new(assigns, :bonded_left, fn -> false end)
    assigns = assign_new(assigns, :bonded_right, fn -> false end)
    assigns = assign_new(assigns, :depth_front, fn -> false end)
    assigns = assign_new(assigns, :depth_behind, fn -> false end)

    team_colors = %{"red" => "#8b0000", "purple" => "#4a1259"}
    assigns = assign(assigns, :color, team_colors[assigns.team])

    ~H"""
    <div class="relative">
      <div :if={@bonded_left} class="absolute left-0 top-1/2 -translate-x-full w-2 h-1" style="background-color: #ffd700;"></div>
      <div :if={@bonded_right} class="absolute right-0 top-1/2 w-2 h-1" style="background-color: #ffd700;"></div>
      <div :if={@depth_front} class="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-full w-1 h-2" style="background-color: #00ff00;"></div>
      <div :if={@depth_behind} class="absolute bottom-0 left-1/2 -translate-x-1/2 w-1 h-2" style="background-color: #00ff00;"></div>

      <svg viewBox="0 0 48 56" width="48" height="56" style="image-rendering: pixelated;">
        <polygon points="24,0 48,14 48,42 24,56 0,42 0,14" fill={@color} />

        <polygon points="24,4 44,16 44,40 24,52 4,40 4,16" fill="none" stroke="#f5f5dc" stroke-width="2"
          transform={"rotate(#{@rotation}, 24, 28)"} />

        <polygon points="24,8 12,14" fill="none" stroke="#f5f5dc" stroke-width="3"
          transform={"rotate(#{@rotation}, 24, 28)"} />
        <polygon points="24,8 36,14" fill="none" stroke="#f5f5dc" stroke-width="3"
          transform={"rotate(#{@rotation}, 24, 28)"} />

        <text x="24" y="38" text-anchor="middle" fill="#f5f5dc" font-size="12" font-weight="bold">
          {@name}
        </text>
      </svg>
    </div>
    """
  end
end
