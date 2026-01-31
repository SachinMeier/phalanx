defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup7 do
  @moduledoc "Order List & Submission - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="Order List" />

        <div class="grid grid-cols-3 gap-6">
          <div class="col-span-2 space-y-6">
            <.scroll_panel title="Pending Orders">
              <div class="flex items-center justify-between mb-4">
                <span class="text-sm" style="color: #6b4423;">3 orders queued</span>
                <div class="flex items-center gap-2">
                  <div class="w-3 h-3 rounded-full" style="background: #ffd700;"></div>
                  <span class="text-sm" style="color: #a08060;">Ready to submit</span>
                </div>
              </div>

              <div class="space-y-2">
                <.order_row unit="A" team="red" action="Move Northeast" />
                <.order_row unit="B" team="red" action="Move East + Rotate CW" />
                <.order_row unit="C" team="red" action="Rotate Counter-clockwise" />
              </div>

              <div class="flex items-center justify-between mt-6 pt-4" style="border-top: 1px solid #8b6914;">
                <button class="px-4 py-2 rounded font-semibold" style="background: #555; color: #ccc;">
                  Clear All
                </button>
                <button class="px-6 py-3 rounded font-semibold" style="background: linear-gradient(180deg, #22c55e, #16a34a); color: white; box-shadow: 0 3px 0 #15803d;">
                  Submit Orders [Enter]
                </button>
              </div>
            </.scroll_panel>

            <.scroll_panel title="Units Without Orders">
              <div class="grid grid-cols-5 gap-3">
                <.idle_unit name="D" team="red" />
                <.idle_unit name="E" team="red" />
                <.empty_slot />
                <.empty_slot />
                <.empty_slot />
              </div>
              <p class="text-sm text-center mt-4" style="color: #a08060;">Units without orders will hold position</p>
            </.scroll_panel>
          </div>

          <div class="space-y-6">
            <.side_scroll title="Player Status">
              <div class="space-y-2">
                <div class="flex items-center justify-between p-2 rounded" style="background: rgba(34, 197, 94, 0.15);">
                  <span style="color: #6b4423;">You</span>
                  <span class="font-semibold" style="color: #22c55e;">Planning</span>
                </div>
                <div class="flex items-center justify-between p-2 rounded" style="background: rgba(255, 215, 0, 0.15);">
                  <span style="color: #6b4423;">Opponent</span>
                  <span class="font-semibold" style="color: #ffd700;">Waiting...</span>
                </div>
              </div>
            </.side_scroll>

            <.side_scroll title="Quick Reference">
              <div class="space-y-2 text-sm">
                <div class="flex justify-between" style="color: #6b4423;">
                  <span>Y U I O P</span>
                  <span style="color: #a08060;">Red units</span>
                </div>
                <div class="flex justify-between" style="color: #6b4423;">
                  <span>H J K L M</span>
                  <span style="color: #a08060;">Purple units</span>
                </div>
                <div class="flex justify-between" style="color: #6b4423;">
                  <span>W E A S D F</span>
                  <span style="color: #a08060;">Move</span>
                </div>
                <div class="flex justify-between" style="color: #6b4423;">
                  <span>Q R</span>
                  <span style="color: #a08060;">Rotate</span>
                </div>
                <div class="flex justify-between" style="color: #6b4423;">
                  <span>C</span>
                  <span style="color: #a08060;">Cancel</span>
                </div>
                <div class="flex justify-between" style="color: #6b4423;">
                  <span>Enter</span>
                  <span style="color: #a08060;">Submit</span>
                </div>
              </div>
            </.side_scroll>

            <div class="p-4 rounded" style="background: rgba(74, 18, 89, 0.5); border: 1px solid #7a5090;">
              <h3 class="font-semibold mb-2" style="color: #c9a0dc; font-family: 'Cinzel', serif;">Enemy Orders</h3>
              <div class="text-center py-4">
                <span class="text-2xl tracking-widest" style="color: #7a5090;">? ? ?</span>
              </div>
              <p class="text-xs text-center" style="color: #9070a0;">Hidden until resolution</p>
            </div>
          </div>
        </div>
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
    """
  end

  defp side_scroll(assigns) do
    ~H"""
    <div class="relative">
      <div class="absolute -top-2 left-4 right-4 h-4 rounded-t-lg" style="background: linear-gradient(90deg, #5a3a1d, #8b6914, #5a3a1d);"></div>
      <div class="pt-3 pb-4 px-4 rounded" style="background: linear-gradient(180deg, #e8d4b8 0%, #ddd0ba 100%); border: 2px solid #8b6914;">
        <h3 class="font-semibold mb-3" style="color: #3d2817; font-family: 'Cinzel', serif; font-size: 14px;">
          {@title}
        </h3>
        {render_slot(@inner_block)}
      </div>
      <div class="absolute -bottom-2 left-4 right-4 h-4 rounded-b-lg" style="background: linear-gradient(90deg, #5a3a1d, #8b6914, #5a3a1d);"></div>
    </div>
    """
  end

  defp order_row(assigns) do
    team_color = if assigns.team == "red", do: "#8b0000", else: "#4a1259"
    assigns = assign(assigns, :team_color, team_color)

    ~H"""
    <div class="flex items-center gap-4 p-3 rounded" style="background: rgba(61, 40, 23, 0.2);">
      <div class="w-10 h-10 rounded flex items-center justify-center font-bold" style={"background: #{@team_color}; color: #fff8e7; font-family: 'Cinzel', serif;"}>
        {@unit}
      </div>
      <div class="flex-1">
        <span style="color: #3d2817;">{@action}</span>
      </div>
      <button class="w-8 h-8 rounded flex items-center justify-center" style="background: #aa4444; color: white;">
        ×
      </button>
    </div>
    """
  end

  defp idle_unit(assigns) do
    team_color = if assigns.team == "red", do: "#8b0000", else: "#4a1259"
    assigns = assign(assigns, :team_color, team_color)

    ~H"""
    <div class="flex flex-col items-center">
      <div class="w-12 h-12 rounded flex items-center justify-center font-bold" style={"background: #{@team_color}; color: #fff8e7; font-family: 'Cinzel', serif;"}>
        {@name}
      </div>
      <span class="text-xs mt-1" style="color: #a08060;">Hold</span>
    </div>
    """
  end

  defp empty_slot(assigns) do
    ~H"""
    <div class="flex flex-col items-center opacity-40">
      <div class="w-12 h-12 rounded flex items-center justify-center" style="background: #555; color: #888;">
        —
      </div>
      <span class="text-xs mt-1" style="color: #666;">Empty</span>
    </div>
    """
  end
end
