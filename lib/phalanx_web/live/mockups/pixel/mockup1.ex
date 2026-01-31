defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup1 do
  @moduledoc "Unit Health & Energy States - Pixel Art Style"
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
      .greek-key {
        background-image: repeating-linear-gradient(90deg, #5c4033 0px, #5c4033 4px, transparent 4px, transparent 8px);
        height: 8px;
      }
    </style>
    <div class="min-h-screen p-6" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="UNIT STATUS" />

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-6" style="font-size: 12px;">HEALTH STATES</h2>
          <div class="grid grid-cols-4 gap-6">
            <.pixel_unit name="A" team="red" health={3} energy={3} label="HEALTHY" sublabel="3 HP" />
            <.pixel_unit name="B" team="red" health={2} energy={3} label="DAMAGED" sublabel="2 HP" />
            <.pixel_unit name="C" team="red" health={1} energy={3} label="CRITICAL" sublabel="1 HP" />
            <.pixel_unit name="D" team="gray" health={0} energy={0} label="FALLEN" sublabel="0 HP" dead={true} />
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-6" style="font-size: 12px;">ENERGY STATES</h2>
          <div class="grid grid-cols-4 gap-6">
            <.pixel_unit name="E" team="purple" health={3} energy={3} label="FRESH" sublabel="3 EN" />
            <.pixel_unit name="F" team="purple" health={3} energy={2} label="WINDED" sublabel="2 EN" />
            <.pixel_unit name="G" team="purple" health={3} energy={1} label="TIRED" sublabel="1 EN" />
            <.pixel_unit name="H" team="purple" health={3} energy={0} label="EXHAUSTED" sublabel="0 EN" exhausted={true} />
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6">
          <h2 class="pixel-font text-stone-800 mb-6" style="font-size: 12px;">COMBINED STATES</h2>
          <div class="grid grid-cols-4 gap-6">
            <.pixel_unit name="I" team="red" health={2} energy={1} label="WOUNDED" sublabel="2HP 1EN" />
            <.pixel_unit name="J" team="purple" health={1} energy={2} label="BATTERED" sublabel="1HP 2EN" />
            <.pixel_unit name="K" team="red" health={1} energy={1} label="DESPERATE" sublabel="1HP 1EN" />
            <.pixel_unit name="L" team="purple" health={1} energy={0} label="DOOMED" sublabel="1HP 0EN" exhausted={true} />
          </div>
        </div>

        <.scroll_note>
          <p><span class="text-amber-700">SHIELDS:</span> HEALTH REMAINING</p>
          <p><span class="text-amber-700">DOTS:</span> ENERGY FOR ACTIONS</p>
          <p><span class="text-amber-700">RED FLASH:</span> EXHAUSTION WARNING</p>
        </.scroll_note>
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

  defp scroll_note(assigns) do
    ~H"""
    <div class="mt-8 relative">
      <div class="absolute -top-2 left-8 right-8 h-4 rounded-t-lg" style="background-color: #8b6914;"></div>
      <div class="pixel-border parchment p-4 mx-4" style="border-radius: 0;">
        <div class="pixel-font text-stone-700 space-y-2" style="font-size: 8px;">
          {render_slot(@inner_block)}
        </div>
      </div>
      <div class="absolute -bottom-2 left-8 right-8 h-4 rounded-b-lg" style="background-color: #8b6914;"></div>
    </div>
    """
  end

  defp pixel_unit(assigns) do
    assigns = assign_new(assigns, :dead, fn -> false end)
    assigns = assign_new(assigns, :exhausted, fn -> false end)

    team_colors = %{
      "red" => "#8b0000",
      "purple" => "#4a1259",
      "gray" => "#4a4a4a"
    }

    assigns = assign(assigns, :color, team_colors[assigns.team])

    ~H"""
    <div class="flex flex-col items-center">
      <div class={"relative #{if @exhausted, do: "animate-pulse"}"}>
        <svg viewBox="0 0 64 74" width="64" height="74" style="image-rendering: pixelated;">
          <rect x="8" y="0" width="48" height="58" fill={@color} />
          <rect x="4" y="4" width="4" height="50" fill={@color} />
          <rect x="56" y="4" width="4" height="50" fill={@color} />
          <rect x="0" y="8" width="4" height="42" fill={@color} />
          <rect x="60" y="8" width="4" height="42" fill={@color} />

          <rect :if={@health >= 1 && !@dead} x="16" y="8" width="32" height="4" fill="#f5f5dc" />
          <rect :if={@health >= 2 && !@dead} x="20" y="16" width="24" height="4" fill="#f5f5dc" />
          <rect :if={@health >= 3 && !@dead} x="24" y="24" width="16" height="4" fill="#f5f5dc" />

          <text :if={@dead} x="32" y="32" text-anchor="middle" fill="#ff0000" font-size="20" font-weight="bold">X</text>

          <text x="32" y="48" text-anchor="middle" fill="#f5f5dc" font-size="14" font-weight="bold" font-family="'Press Start 2P', monospace">
            {@name}
          </text>

          <rect :for={i <- 0..2} x={22 + i * 8} y="60" width="6" height="6"
            fill={if i < @energy, do: (if @exhausted, do: "#ff0000", else: "#ffd700"), else: "#3a3a3a"} />
        </svg>

        <div :if={@exhausted && !@dead} class="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-red-500 animate-ping"></div>
      </div>
      <div class="mt-2 text-center">
        <div class="pixel-font text-stone-800" style="font-size: 8px;">{@label}</div>
        <div class="pixel-font text-stone-500" style="font-size: 6px;">{@sublabel}</div>
      </div>
    </div>
    """
  end
end
