defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup9 do
  @moduledoc "Strength Calculation - Pixel Art Style"
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
        <.nav_header title="STRENGTH" />

        <div class="grid grid-cols-2 gap-6 mb-8">
          <div class="pixel-border pixel-shadow parchment p-6">
            <div class="flex items-center gap-3 mb-4">
              <div class="w-10 h-10 flex items-center justify-center pixel-border" style="background-color: #8b0000;">
                <span class="pixel-font text-amber-100" style="font-size: 12px;">A</span>
              </div>
              <div>
                <h2 class="pixel-font text-stone-800" style="font-size: 10px;">ATTACKER</h2>
                <span class="pixel-font text-red-700" style="font-size: 8px;">RED UNIT A</span>
              </div>
            </div>

            <div class="space-y-3">
              <.calc_row label="BASE STRENGTH" value="3" />
              <.calc_row label="HEALTH BONUS" value="+2" note="(3 HP)" />
              <.calc_row label="SIDE COHESION" value="+2" note="(2 ALLIES)" />
              <.calc_row label="DEPTH PUSH" value="+1" note="(1 BEHIND)" />
              <.calc_row label="FLANK BONUS" value="+2" note="(SIDE ATK)" highlight={true} />
              <div class="h-1 my-2" style="background-color: #5c4033;"></div>
              <.calc_row label="TOTAL STRENGTH" value="10" total={true} />
            </div>
          </div>

          <div class="pixel-border pixel-shadow parchment p-6">
            <div class="flex items-center gap-3 mb-4">
              <div class="w-10 h-10 flex items-center justify-center pixel-border" style="background-color: #4a1259;">
                <span class="pixel-font text-amber-100" style="font-size: 12px;">X</span>
              </div>
              <div>
                <h2 class="pixel-font text-stone-800" style="font-size: 10px;">DEFENDER</h2>
                <span class="pixel-font text-purple-700" style="font-size: 8px;">PURPLE UNIT X</span>
              </div>
            </div>

            <div class="space-y-3">
              <.calc_row label="BASE DEFENSE" value="3" />
              <.calc_row label="HEALTH BONUS" value="+1" note="(2 HP)" />
              <.calc_row label="SHIELD WALL" value="+0" note="(FLANKED)" />
              <.calc_row label="DEPTH BRACE" value="+1" note="(1 BEHIND)" />
              <.calc_row label="TERRAIN" value="+0" note="(OPEN)" />
              <div class="h-1 my-2" style="background-color: #5c4033;"></div>
              <.calc_row label="TOTAL DEFENSE" value="5" total={true} />
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-6" style="font-size: 12px;">COMBAT RESOLUTION</h2>

          <div class="flex items-center justify-center gap-8">
            <div class="text-center">
              <div class="pixel-font text-red-700 mb-2" style="font-size: 10px;">ATTACKER</div>
              <div class="w-16 h-16 flex items-center justify-center pixel-border" style="background-color: #8b0000;">
                <span class="pixel-font text-amber-100" style="font-size: 20px;">10</span>
              </div>
            </div>

            <div class="flex flex-col items-center">
              <span class="pixel-font text-stone-700" style="font-size: 14px;">VS</span>
              <svg viewBox="0 0 60 20" width="60" height="20" class="mt-2">
                <polygon points="0,10 20,0 20,7 40,7 40,0 60,10 40,20 40,13 20,13 20,20" fill="#ffd700" />
              </svg>
            </div>

            <div class="text-center">
              <div class="pixel-font text-purple-700 mb-2" style="font-size: 10px;">DEFENDER</div>
              <div class="w-16 h-16 flex items-center justify-center pixel-border" style="background-color: #4a1259;">
                <span class="pixel-font text-amber-100" style="font-size: 20px;">5</span>
              </div>
            </div>

            <div class="text-center">
              <div class="pixel-font text-stone-700 mb-2" style="font-size: 10px;">RESULT</div>
              <div class="w-16 h-16 flex items-center justify-center pixel-border" style="background-color: #228b22;">
                <span class="pixel-font text-amber-100" style="font-size: 14px;">+5</span>
              </div>
            </div>
          </div>

          <div class="mt-6 p-4 text-center" style="background-color: #ffcccc;">
            <span class="pixel-font text-red-800" style="font-size: 10px;">ATTACKER WINS BY 5</span>
            <p class="pixel-font text-red-700 mt-2" style="font-size: 8px;">DEFENDER TAKES 2 DAMAGE + RETREATS</p>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">DAMAGE TABLE</h2>

          <div class="grid grid-cols-4 gap-3">
            <.damage_cell diff="0-2" damage="0" result="TIE" />
            <.damage_cell diff="3-4" damage="1" result="PUSH" />
            <.damage_cell diff="5-7" damage="2" result="WOUND" />
            <.damage_cell diff="8+" damage="3" result="ROUT" />
          </div>

          <div class="mt-4 p-3 text-center" style="background-color: #d4c4a8;">
            <span class="pixel-font text-stone-600" style="font-size: 7px;">CURRENT: DIFF 5 = 2 DAMAGE + RETREAT</span>
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

  defp calc_row(assigns) do
    assigns = assign_new(assigns, :note, fn -> nil end)
    assigns = assign_new(assigns, :highlight, fn -> false end)
    assigns = assign_new(assigns, :total, fn -> false end)

    ~H"""
    <div class={"flex items-center justify-between p-2 #{if @highlight, do: "border-l-4 border-amber-500"}"} style={"background-color: #{if @total, do: "#c4956a", else: "#d4c4a8"};"}>
      <div class="flex items-center gap-2">
        <span class={"pixel-font #{if @total, do: "text-stone-900", else: "text-stone-700"}"} style={"font-size: #{if @total, do: "9px", else: "7px"};"}>{@label}</span>
        <span :if={@note} class="pixel-font text-stone-500" style="font-size: 6px;">{@note}</span>
      </div>
      <span class={"pixel-font #{if @total, do: "text-amber-800", else: "text-stone-800"}"} style={"font-size: #{if @total, do: "12px", else: "9px"};"}>{@value}</span>
    </div>
    """
  end

  defp damage_cell(assigns) do
    bg_color = case assigns.damage do
      "0" -> "#d4c4a8"
      "1" -> "#ffe4b8"
      "2" -> "#ffcccc"
      "3" -> "#ff9999"
      _ -> "#d4c4a8"
    end

    assigns = assign(assigns, :bg_color, bg_color)

    ~H"""
    <div class="p-3 text-center pixel-border" style={"background-color: #{@bg_color};"}>
      <div class="pixel-font text-stone-800 mb-1" style="font-size: 8px;">{@diff}</div>
      <div class="pixel-font text-red-700 mb-1" style="font-size: 12px;">{@damage} DMG</div>
      <div class="pixel-font text-stone-600" style="font-size: 6px;">{@result}</div>
    </div>
    """
  end
end
