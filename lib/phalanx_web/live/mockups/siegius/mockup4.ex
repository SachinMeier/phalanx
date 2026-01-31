defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup4 do
  @moduledoc "Movement & Orders - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="Movement" />

        <div class="grid grid-cols-2 gap-6 mb-8">
          <.scroll_panel title="Valid Moves">
            <p class="text-sm mb-4" style="color: #6b4423;">Green hexes show valid destinations</p>
            <div class="flex justify-center py-4">
              <svg viewBox="0 0 200 180" width="220" height="198">
                <.hex_outline x={100} y={30} valid={true} label="NE" />
                <.hex_outline x={145} y={55} valid={true} label="E" />
                <.hex_outline x={145} y={105} valid={true} label="SE" />
                <.hex_outline x={100} y={130} blocked={true} />
                <.hex_outline x={55} y={105} valid={true} label="SW" />
                <.hex_outline x={55} y={55} valid={true} label="W" />

                <polygon points="100,60 120,72 120,96 100,108 80,96 80,72" fill="#8b0000"
                         style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
                <polyline points="87,76 100,66 113,76" stroke="#fff8e7" stroke-width="3" stroke-linecap="round" fill="none" />
                <text x="100" y="92" text-anchor="middle" fill="#fff8e7" font-size="16" font-weight="bold">A</text>
              </svg>
            </div>
          </.scroll_panel>

          <.scroll_panel title="Facing Constraint">
            <p class="text-sm mb-4" style="color: #6b4423;">Red = blocked by current facing</p>
            <div class="flex justify-center py-4">
              <svg viewBox="0 0 200 180" width="220" height="198">
                <.hex_outline x={100} y={30} blocked={true} />
                <.hex_outline x={145} y={55} valid={true} label="E" />
                <.hex_outline x={145} y={105} valid={true} label="SE" />
                <.hex_outline x={100} y={130} blocked={true} />
                <.hex_outline x={55} y={105} blocked={true} />
                <.hex_outline x={55} y={55} blocked={true} />

                <polygon points="100,60 120,72 120,96 100,108 80,96 80,72" fill="#4a1259"
                         style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
                <polyline points="117,72 117,96" stroke="#fff8e7" stroke-width="3" stroke-linecap="round" fill="none" />
                <text x="100" y="92" text-anchor="middle" fill="#fff8e7" font-size="16" font-weight="bold">B</text>
              </svg>
            </div>
            <p class="text-xs text-center mt-2" style="color: #a08060;">Unit faces East — limited movement options</p>
          </.scroll_panel>
        </div>

        <.scroll_panel title="Keyboard Commands">
          <div class="grid grid-cols-2 gap-8">
            <div>
              <h3 class="font-semibold mb-3" style="color: #6b4423; font-family: 'Cinzel', serif;">Movement</h3>
              <div class="grid grid-cols-2 gap-2">
                <.key_row key="W" action="Northwest" />
                <.key_row key="E" action="Northeast" />
                <.key_row key="A" action="West" />
                <.key_row key="D" action="East" />
                <.key_row key="S" action="Southwest" />
                <.key_row key="F" action="Southeast" />
              </div>
            </div>
            <div>
              <h3 class="font-semibold mb-3" style="color: #6b4423; font-family: 'Cinzel', serif;">Rotation</h3>
              <div class="grid grid-cols-2 gap-2 mb-4">
                <.key_row key="Q" action="Counter-clockwise" />
                <.key_row key="R" action="Clockwise" />
              </div>
              <h3 class="font-semibold mb-3" style="color: #6b4423; font-family: 'Cinzel', serif;">Actions</h3>
              <div class="grid grid-cols-2 gap-2">
                <.key_row key="Enter" action="Submit orders" wide={true} />
                <.key_row key="C" action="Cancel" />
              </div>
            </div>
          </div>
        </.scroll_panel>

        <.scroll_panel title="Order Preview">
          <div class="flex items-center justify-center gap-8 py-4">
            <div class="text-center">
              <p class="text-xs mb-2" style="color: #6b4423;">Before</p>
              <svg viewBox="0 0 100 115.47" width="60" height="69">
                <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#8b0000" stroke="#8b6914" stroke-width="2" />
                <polyline points="15,35.21 50,15 85,35.21" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" fill="none" />
                <text x="50" y="78" text-anchor="middle" fill="#fff8e7" font-size="24" font-weight="bold">C</text>
              </svg>
            </div>

            <div class="flex flex-col items-center">
              <svg viewBox="0 0 80 30" width="80" height="30">
                <polygon points="0,15 25,5 25,11 55,11 55,5 80,15 55,25 55,19 25,19 25,25" fill="#ffd700" />
              </svg>
              <span class="text-sm mt-1" style="color: #ffd700;">Move NE + Rotate CW</span>
            </div>

            <div class="text-center">
              <p class="text-xs mb-2" style="color: #6b4423;">After</p>
              <svg viewBox="0 0 100 115.47" width="60" height="69" style="opacity: 0.6;">
                <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#8b0000" stroke="#ffd700" stroke-width="2" stroke-dasharray="6" />
                <polyline points="70,35.21 85,57.74 70,80.27" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" fill="none" />
                <text x="50" y="78" text-anchor="middle" fill="#fff8e7" font-size="24" font-weight="bold">C</text>
              </svg>
            </div>
          </div>
        </.scroll_panel>
      </div>
    </div>
    """
  end

  defp nav_header(assigns) do
    ~H"""
    <div class="mb-8 flex items-center justify-between">
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

  defp scroll_panel(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="relative">
        <div class="absolute -top-3 left-8 right-8 h-5 rounded-t-lg" style="background: linear-gradient(90deg, #6b4423, #8b6914, #6b4423);"></div>
        <div class="pt-4 pb-6 px-6 rounded" style="background: linear-gradient(180deg, #e8d4b8 0%, #ddd0ba 100%); border: 2px solid #8b6914;">
          <h2 class="text-lg font-semibold mb-4" style="color: #3d2817; font-family: 'Cinzel', serif; border-bottom: 1px solid #8b6914; padding-bottom: 8px;">
            {@title}
          </h2>
          {render_slot(@inner_block)}
        </div>
        <div class="absolute -bottom-3 left-8 right-8 h-5 rounded-b-lg" style="background: linear-gradient(90deg, #6b4423, #8b6914, #6b4423);"></div>
      </div>
    </div>
    """
  end

  defp hex_outline(assigns) do
    assigns = assign_new(assigns, :valid, fn -> false end)
    assigns = assign_new(assigns, :blocked, fn -> false end)
    assigns = assign_new(assigns, :label, fn -> "" end)

    color = cond do
      assigns.blocked -> "#aa4444"
      assigns.valid -> "#22c55e"
      true -> "#666"
    end

    ~H"""
    <g>
      <polygon
        points={"#{@x},#{@y - 20} #{@x + 17},#{@y - 10} #{@x + 17},#{@y + 10} #{@x},#{@y + 20} #{@x - 17},#{@y + 10} #{@x - 17},#{@y - 10}"}
        fill="none"
        stroke={color}
        stroke-width="2"
        stroke-dasharray={if @valid || @blocked, do: "none", else: "4"}
      />
      <text :if={@label != ""} x={@x} y={@y + 4} text-anchor="middle" fill={color} font-size="12" font-weight="bold">
        {@label}
      </text>
      <text :if={@blocked} x={@x} y={@y + 5} text-anchor="middle" fill="#aa4444" font-size="16">×</text>
    </g>
    """
  end

  defp key_row(assigns) do
    assigns = assign_new(assigns, :wide, fn -> false end)

    ~H"""
    <div class="flex items-center gap-2">
      <div class={"rounded flex items-center justify-center font-mono font-bold text-sm #{if @wide, do: "px-3 py-1.5", else: "w-8 h-8"}"} style="background: #3d2817; color: #e8d4b8;">
        {@key}
      </div>
      <span class="text-sm" style="color: #6b4423;">{@action}</span>
    </div>
    """
  end
end
