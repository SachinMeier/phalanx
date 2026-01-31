defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup10 do
  @moduledoc "Game Setup - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <div class="text-center mb-8">
          <.banner_scroll>
            <h1 class="text-3xl font-bold" style="color: #3d2817; font-family: 'Cinzel', serif;">PHALANX</h1>
            <p class="text-sm mt-1" style="color: #6b4423;">Prepare for Battle</p>
          </.banner_scroll>
        </div>

        <div class="grid grid-cols-3 gap-6 mb-8">
          <.option_scroll title="Game Mode">
            <.option_item name="Elimination" desc="Destroy all enemies" selected={true} />
            <.option_item name="Siege" desc="Hold your ground" />
            <.option_item name="Capture" desc="Take the flag" />
          </.option_scroll>

          <.option_scroll title="Map Size">
            <.option_item name="Small" desc="8×8 hexes" />
            <.option_item name="Medium" desc="10×10 hexes" selected={true} />
            <.option_item name="Large" desc="12×12 hexes" />
          </.option_scroll>

          <.option_scroll title="Army Size">
            <.option_item name="Skirmish" desc="3 units" />
            <.option_item name="Battle" desc="5 units" selected={true} />
            <.option_item name="War" desc="8 units" />
          </.option_scroll>
        </div>

        <.scroll_panel title="Choose Your Side">
          <div class="grid grid-cols-2 gap-6">
            <.faction_card
              name="Red Legion"
              color="#8b0000"
              units={~w(A B C D E)}
              trait="Disciplined Infantry"
              bonus="+1 Formation bonus"
              selected={true}
            />
            <.faction_card
              name="Purple Horde"
              color="#4a1259"
              units={~w(V W X Y Z)}
              trait="Fierce Warriors"
              bonus="+1 Attack power"
            />
          </div>
        </.scroll_panel>

        <.scroll_panel title="Deployment Zone">
          <div class="flex justify-center py-4">
            <svg viewBox="0 0 400 180" width="400" height="180">
              <rect x="0" y="0" width="400" height="50" fill="rgba(139, 0, 0, 0.2)" stroke="#8b0000" stroke-width="2" stroke-dasharray="8" />
              <text x="200" y="30" text-anchor="middle" fill="#8b0000" font-size="12" font-weight="bold">RED DEPLOYMENT</text>

              <rect x="0" y="60" width="400" height="60" fill="rgba(45, 74, 45, 0.3)" />
              <text x="200" y="95" text-anchor="middle" fill="#3d5c3d" font-size="12">BATTLEFIELD</text>

              <rect x="0" y="130" width="400" height="50" fill="rgba(74, 18, 89, 0.2)" stroke="#4a1259" stroke-width="2" stroke-dasharray="8" />
              <text x="200" y="160" text-anchor="middle" fill="#4a1259" font-size="12" font-weight="bold">PURPLE DEPLOYMENT</text>

              <.deploy_unit x={80} y={25} name="A" />
              <.deploy_unit x={130} y={25} name="B" />
              <.deploy_unit x={180} y={25} name="C" />
              <.deploy_unit x={230} y={25} name="D" />
              <.deploy_unit x={280} y={25} name="E" />
            </svg>
          </div>
          <p class="text-center text-sm" style="color: #a08060;">Drag units to position • Click to rotate</p>
        </.scroll_panel>

        <div class="flex justify-center gap-6 mt-8">
          <button class="px-8 py-3 rounded font-semibold" style="background: #555; color: #ccc;">
            Back
          </button>
          <button class="px-10 py-4 rounded font-bold text-lg" style="background: linear-gradient(180deg, #22c55e, #16a34a); color: white; box-shadow: 0 4px 0 #15803d; font-family: 'Cinzel', serif;">
            Start Battle
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp banner_scroll(assigns) do
    ~H"""
    <div class="relative inline-block">
      <div class="absolute -left-5 top-0 bottom-0 w-4 rounded-l-full" style="background: linear-gradient(90deg, #8b6914, #a67c1a);"></div>
      <div class="absolute -right-5 top-0 bottom-0 w-4 rounded-r-full" style="background: linear-gradient(270deg, #8b6914, #a67c1a);"></div>
      <div class="px-10 py-5" style="background: linear-gradient(180deg, #e8d4b8 0%, #d4c4a8 50%, #c9b99d 100%); border-top: 3px solid #8b6914; border-bottom: 3px solid #8b6914;">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp option_scroll(assigns) do
    ~H"""
    <div class="relative">
      <div class="absolute -top-2 left-4 right-4 h-4 rounded-t-lg" style="background: linear-gradient(90deg, #5a3a1d, #8b6914, #5a3a1d);"></div>
      <div class="pt-3 pb-4 px-4 rounded" style="background: linear-gradient(180deg, #e8d4b8 0%, #ddd0ba 100%); border: 2px solid #8b6914;">
        <h3 class="font-semibold mb-3 pb-2" style="color: #3d2817; font-family: 'Cinzel', serif; font-size: 14px; border-bottom: 1px solid #8b6914;">
          {@title}
        </h3>
        <div class="space-y-2">
          {render_slot(@inner_block)}
        </div>
      </div>
      <div class="absolute -bottom-2 left-4 right-4 h-4 rounded-b-lg" style="background: linear-gradient(90deg, #5a3a1d, #8b6914, #5a3a1d);"></div>
    </div>
    """
  end

  defp option_item(assigns) do
    assigns = assign_new(assigns, :selected, fn -> false end)

    ~H"""
    <div class={"p-2 rounded cursor-pointer #{if @selected, do: "border-l-4", else: ""}"} style={"background: #{if @selected, do: "rgba(139, 105, 20, 0.3)", else: "rgba(61, 40, 23, 0.15)"}; border-color: #ffd700;"}>
      <div class="flex items-center justify-between">
        <span class="font-semibold text-sm" style="color: #3d2817;">{@name}</span>
        <span class="text-xs" style="color: #a08060;">{@desc}</span>
      </div>
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

  defp faction_card(assigns) do
    assigns = assign_new(assigns, :selected, fn -> false end)

    ~H"""
    <div class={"p-5 rounded cursor-pointer transition-all #{if @selected, do: "ring-2 ring-offset-2", else: "hover:opacity-90"}"} style={"background: #{@color}; ring-color: #ffd700; ring-offset-color: #e8d4b8;"}>
      <div class="flex items-center justify-between mb-4">
        <span class="font-bold text-lg" style="color: #fff8e7; font-family: 'Cinzel', serif;">{@name}</span>
        <div :if={@selected} class="w-5 h-5 rounded flex items-center justify-center" style="background: #ffd700; color: #3d2817;">✓</div>
      </div>

      <div class="flex gap-2 mb-4">
        <%= for unit <- @units do %>
          <div class="w-9 h-9 rounded flex items-center justify-center font-bold text-sm" style="background: rgba(0,0,0,0.3); color: #fff8e7;">
            {unit}
          </div>
        <% end %>
      </div>

      <p class="text-sm mb-1" style="color: rgba(255, 248, 231, 0.8);">{@trait}</p>
      <p class="text-sm font-semibold" style="color: #ffd700;">{@bonus}</p>
    </div>
    """
  end

  defp deploy_unit(assigns) do
    ~H"""
    <g>
      <polygon
        points={"#{@x},#{@y - 15} #{@x + 15},#{@y - 7} #{@x + 15},#{@y + 7} #{@x},#{@y + 15} #{@x - 15},#{@y + 7} #{@x - 15},#{@y - 7}"}
        fill="#8b0000"
        stroke="#ffd700"
        stroke-width="2"
        style="filter: drop-shadow(0 2px 3px rgba(0,0,0,0.3));"
      />
      <text x={@x} y={@y + 4} text-anchor="middle" fill="#fff8e7" font-size="11" font-weight="bold">
        {@name}
      </text>
    </g>
    """
  end
end
