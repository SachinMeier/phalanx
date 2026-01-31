defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup2 do
  @moduledoc "Phalanx Formations - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="Formations" />

        <div class="grid grid-cols-2 gap-6 mb-8">
          <.scroll_panel title="Side Cohesion">
            <p class="text-sm mb-4" style="color: #6b4423;">Units facing the same direction form a shield wall</p>
            <div class="flex justify-center items-center gap-0 py-4">
              <.formation_hex name="A" team="red" bond_right={true} />
              <.formation_hex name="B" team="red" bond_left={true} bond_right={true} />
              <.formation_hex name="C" team="red" bond_left={true} />
            </div>
            <div class="flex items-center justify-center gap-2 mt-4 text-sm" style="color: #a08060;">
              <div class="w-8 h-1 rounded" style="background: #ffd700;"></div>
              <span>Shield bond (+1 strength each)</span>
            </div>
          </.scroll_panel>

          <.scroll_panel title="Depth Bonus">
            <p class="text-sm mb-4" style="color: #6b4423;">Units behind add push power to the front</p>
            <div class="flex flex-col items-center gap-0 py-4">
              <.formation_hex name="D" team="purple" depth_front={true} />
              <.formation_hex name="E" team="purple" depth_back={true} depth_front={true} />
              <.formation_hex name="F" team="purple" depth_back={true} />
            </div>
            <div class="flex items-center justify-center gap-2 mt-4 text-sm" style="color: #a08060;">
              <div class="w-1 h-6 rounded" style="background: #22c55e;"></div>
              <span>Depth link (+1 strength each)</span>
            </div>
          </.scroll_panel>
        </div>

        <.scroll_panel title="Full Phalanx Formation">
          <p class="text-sm mb-6" style="color: #6b4423;">Side cohesion + depth = maximum strength</p>

          <div class="flex justify-center mb-6">
            <div class="grid gap-0" style="grid-template-columns: repeat(3, 60px);">
              <.formation_hex name="G" team="red" bond_right={true} depth_front={true} small={true} />
              <.formation_hex name="H" team="red" bond_left={true} bond_right={true} depth_front={true} small={true} />
              <.formation_hex name="I" team="red" bond_left={true} depth_front={true} small={true} />
              <.formation_hex name="J" team="red" bond_right={true} depth_back={true} small={true} />
              <.formation_hex name="K" team="red" bond_left={true} bond_right={true} depth_back={true} small={true} />
              <.formation_hex name="L" team="red" bond_left={true} depth_back={true} small={true} />
            </div>
          </div>

          <div class="flex items-center justify-center gap-4 p-4 rounded" style="background: rgba(61, 40, 23, 0.3);">
            <.strength_box label="Base" value="6" />
            <span class="text-xl" style="color: #8b6914;">+</span>
            <.strength_box label="Side" value="4" color="#ffd700" />
            <span class="text-xl" style="color: #8b6914;">+</span>
            <.strength_box label="Depth" value="3" color="#22c55e" />
            <span class="text-xl" style="color: #8b6914;">=</span>
            <.strength_box label="Total" value="13" color="#e8d4b8" large={true} />
          </div>
        </.scroll_panel>

        <.scroll_panel title="Broken Formation">
          <p class="text-sm mb-4" style="color: #6b4423;">Different facing = no formation bonus</p>
          <div class="flex justify-center items-center gap-1 py-4">
            <.formation_hex name="M" team="purple" />
            <.formation_hex name="N" team="purple" rotation={60} />
            <.formation_hex name="O" team="purple" />
          </div>
          <div class="text-center mt-4">
            <span class="text-sm font-semibold" style="color: #aa4444;">No bonus — Unit N faces wrong direction</span>
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

  defp formation_hex(assigns) do
    assigns = assign_new(assigns, :bond_left, fn -> false end)
    assigns = assign_new(assigns, :bond_right, fn -> false end)
    assigns = assign_new(assigns, :depth_front, fn -> false end)
    assigns = assign_new(assigns, :depth_back, fn -> false end)
    assigns = assign_new(assigns, :rotation, fn -> 0 end)
    assigns = assign_new(assigns, :small, fn -> false end)

    team_colors = %{"red" => "#8b0000", "purple" => "#4a1259"}
    assigns = assign(assigns, :color, team_colors[assigns.team])
    size = if assigns.small, do: 55, else: 70

    ~H"""
    <div class="relative" style={"width: #{size}px;"}>
      <div :if={@bond_left} class="absolute left-0 top-1/2 -translate-x-1 w-2 h-1 rounded" style="background: #ffd700;"></div>
      <div :if={@bond_right} class="absolute right-0 top-1/2 w-2 h-1 rounded" style="background: #ffd700;"></div>
      <div :if={@depth_front} class="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-1 w-1 h-2 rounded" style="background: #22c55e;"></div>
      <div :if={@depth_back} class="absolute bottom-0 left-1/2 -translate-x-1/2 w-1 h-2 rounded" style="background: #22c55e;"></div>

      <svg viewBox="0 0 100 115.47" width={size} height={size * 1.1547} style={"transform: rotate(#{@rotation}deg);"}>
        <polygon
          points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
          fill={@color}
          style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));"
        />
        <polyline points="15,35.21 50,15 85,35.21" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
        <polyline points="25,39.44 50,25 75,39.44" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
        <polyline points="35,43.66 50,35 65,43.66" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
        <text x="50" y="78" text-anchor="middle" dominant-baseline="middle"
              fill="#fff8e7" font-size="24" font-weight="bold"
              style="font-family: 'Cinzel', serif;"
              transform={"rotate(#{-@rotation}, 50, 78)"}>
          {@name}
        </text>
      </svg>
    </div>
    """
  end

  defp strength_box(assigns) do
    assigns = assign_new(assigns, :color, fn -> "#a08060" end)
    assigns = assign_new(assigns, :large, fn -> false end)

    ~H"""
    <div class="text-center">
      <div class={"font-bold #{if @large, do: "text-2xl", else: "text-xl"}"} style={"color: #{@color};"}>{@value}</div>
      <div class="text-xs" style="color: #6b4423;">{@label}</div>
    </div>
    """
  end
end
