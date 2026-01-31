defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup4 do
  @moduledoc "Movement & Orders - Pixel Art Style"
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
        <.nav_header title="MOVEMENT" />

        <div class="grid grid-cols-2 gap-6 mb-8">
          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">VALID MOVES</h2>
            <p class="pixel-font text-stone-600 mb-4" style="font-size: 7px;">GREEN = CAN MOVE THERE</p>

            <div class="flex justify-center">
              <svg viewBox="0 0 200 180" width="200" height="180" style="image-rendering: pixelated;">
                <.hex_outline x={100} y={30} valid={true} label="NE" />
                <.hex_outline x={150} y={60} valid={true} label="E" />
                <.hex_outline x={150} y={120} valid={true} label="SE" />
                <.hex_outline x={100} y={150} valid={false} label="" blocked={true} />
                <.hex_outline x={50} y={120} valid={true} label="SW" />
                <.hex_outline x={50} y={60} valid={true} label="W" />

                <polygon points="100,65 120,77 120,101 100,113 80,101 80,77" fill="#8b0000" />
                <polygon points="100,72 88,78" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <polygon points="100,72 112,78" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <text x="100" y="98" text-anchor="middle" fill="#f5f5dc" font-size="12" font-weight="bold">A</text>
              </svg>
            </div>
          </div>

          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">FACING CONSTRAINT</h2>
            <p class="pixel-font text-stone-600 mb-4" style="font-size: 7px;">RED = BLOCKED BY FACING</p>

            <div class="flex justify-center">
              <svg viewBox="0 0 200 180" width="200" height="180" style="image-rendering: pixelated;">
                <.hex_outline x={100} y={30} valid={false} label="" />
                <.hex_outline x={150} y={60} valid={true} label="E" />
                <.hex_outline x={150} y={120} valid={true} label="SE" />
                <.hex_outline x={100} y={150} valid={false} label="" />
                <.hex_outline x={50} y={120} valid={false} label="" />
                <.hex_outline x={50} y={60} valid={false} label="" />

                <polygon points="100,65 120,77 120,101 100,113 80,101 80,77" fill="#4a1259" />
                <polygon points="112,77 112,101" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <polygon points="112,82 116,89" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <text x="100" y="98" text-anchor="middle" fill="#f5f5dc" font-size="12" font-weight="bold">B</text>
              </svg>
            </div>

            <div class="mt-2 text-center">
              <span class="pixel-font text-stone-500" style="font-size: 6px;">UNIT FACES EAST - LIMITED OPTIONS</span>
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">KEYBOARD COMMANDS</h2>

          <div class="grid grid-cols-2 gap-8">
            <div>
              <h3 class="pixel-font text-amber-700 mb-3" style="font-size: 8px;">MOVEMENT</h3>
              <div class="grid grid-cols-2 gap-2">
                <.key_display key="W" action="NW" />
                <.key_display key="E" action="NE" />
                <.key_display key="A" action="WEST" />
                <.key_display key="D" action="EAST" />
                <.key_display key="S" action="SW" />
                <.key_display key="F" action="SE" />
              </div>
            </div>

            <div>
              <h3 class="pixel-font text-amber-700 mb-3" style="font-size: 8px;">ROTATION</h3>
              <div class="grid grid-cols-2 gap-2">
                <.key_display key="Q" action="CCW" />
                <.key_display key="R" action="CW" />
              </div>

              <h3 class="pixel-font text-amber-700 mb-3 mt-4" style="font-size: 8px;">ACTIONS</h3>
              <div class="grid grid-cols-2 gap-2">
                <.key_display key="ENTER" action="SUBMIT" wide={true} />
                <.key_display key="C" action="CANCEL" />
              </div>
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">ORDER PREVIEW</h2>

          <div class="flex items-center justify-center gap-8">
            <div class="text-center">
              <div class="pixel-font text-stone-600 mb-2" style="font-size: 7px;">BEFORE</div>
              <svg viewBox="0 0 48 56" width="48" height="56" style="image-rendering: pixelated;">
                <polygon points="24,0 48,14 48,42 24,56 0,42 0,14" fill="#8b0000" stroke="#5c4033" stroke-width="2" />
                <polygon points="24,8 12,14" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <polygon points="24,8 36,14" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <text x="24" y="38" text-anchor="middle" fill="#f5f5dc" font-size="12" font-weight="bold">C</text>
              </svg>
            </div>

            <div class="flex flex-col items-center">
              <svg viewBox="0 0 60 20" width="60" height="20">
                <polygon points="0,10 20,0 20,7 40,7 40,0 60,10 40,20 40,13 20,13 20,20" fill="#ffd700" />
              </svg>
              <div class="pixel-font text-amber-700 mt-1" style="font-size: 7px;">MOVE NE + CW</div>
            </div>

            <div class="text-center">
              <div class="pixel-font text-stone-600 mb-2" style="font-size: 7px;">AFTER</div>
              <svg viewBox="0 0 48 56" width="48" height="56" style="image-rendering: pixelated; opacity: 0.6;">
                <polygon points="24,0 48,14 48,42 24,56 0,42 0,14" fill="#8b0000" stroke="#ffd700" stroke-width="2" stroke-dasharray="4" />
                <polygon points="36,14 42,28" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <polygon points="36,14 36,28" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <text x="24" y="38" text-anchor="middle" fill="#f5f5dc" font-size="12" font-weight="bold">C</text>
              </svg>
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

  defp hex_outline(assigns) do
    assigns = assign_new(assigns, :valid, fn -> false end)
    assigns = assign_new(assigns, :blocked, fn -> false end)
    assigns = assign_new(assigns, :label, fn -> "" end)

    color = cond do
      assigns.blocked -> "#666666"
      assigns.valid -> "#228b22"
      true -> "#8b0000"
    end

    ~H"""
    <g>
      <polygon
        points={"#{@x},#{@y - 24} #{@x + 20},#{@y - 12} #{@x + 20},#{@y + 12} #{@x},#{@y + 24} #{@x - 20},#{@y + 12} #{@x - 20},#{@y - 12}"}
        fill="none"
        stroke={color}
        stroke-width="3"
        stroke-dasharray={if @valid || @blocked, do: "none", else: "4"}
      />
      <text :if={@label != ""} x={@x} y={@y + 4} text-anchor="middle" fill={color} font-size="10" font-weight="bold">
        {@label}
      </text>
      <text :if={@blocked} x={@x} y={@y + 4} text-anchor="middle" fill="#666" font-size="14">X</text>
    </g>
    """
  end

  defp key_display(assigns) do
    assigns = assign_new(assigns, :wide, fn -> false end)

    ~H"""
    <div class="flex items-center gap-2">
      <div class={"pixel-border flex items-center justify-center #{if @wide, do: "px-3", else: "w-8"} h-8"} style="background-color: #3a3a3a;">
        <span class="pixel-font text-amber-100" style="font-size: 8px;">{@key}</span>
      </div>
      <span class="pixel-font text-stone-600" style="font-size: 7px;">{@action}</span>
    </div>
    """
  end
end
