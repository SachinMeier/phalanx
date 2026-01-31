defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup7 do
  @moduledoc "Order List & Submission - Pixel Art Style"
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
      .scroll-roll {
        background: repeating-linear-gradient(180deg, #c4956a 0px, #c4956a 8px, #b4855a 8px, #b4855a 16px);
      }
    </style>
    <div class="min-h-screen p-6" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="ORDERS" />

        <div class="grid grid-cols-3 gap-6">
          <div class="col-span-2">
            <div class="pixel-border pixel-shadow parchment p-6 mb-6">
              <div class="flex items-center justify-between mb-4">
                <h2 class="pixel-font text-stone-800" style="font-size: 10px;">PENDING ORDERS</h2>
                <div class="flex items-center gap-2">
                  <div class="w-3 h-3" style="background-color: #ffd700;"></div>
                  <span class="pixel-font text-stone-600" style="font-size: 7px;">3 ORDERS</span>
                </div>
              </div>

              <div class="space-y-3">
                <.order_row unit="A" team="red" action="MOVE NE" />
                <.order_row unit="B" team="red" action="MOVE E + CW" />
                <.order_row unit="C" team="red" action="ROTATE CCW" />
              </div>

              <div class="mt-6 flex items-center justify-between">
                <div class="flex gap-2">
                  <button class="pixel-border px-4 py-2" style="background-color: #666666;">
                    <span class="pixel-font text-amber-100" style="font-size: 8px;">CLEAR ALL</span>
                  </button>
                </div>
                <button class="pixel-border px-6 py-3" style="background-color: #228b22;">
                  <span class="pixel-font text-amber-100" style="font-size: 10px;">SUBMIT [ENTER]</span>
                </button>
              </div>
            </div>

            <div class="pixel-border pixel-shadow parchment p-6">
              <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">UNITS WITHOUT ORDERS</h2>

              <div class="grid grid-cols-5 gap-3">
                <.idle_unit name="D" team="red" />
                <.idle_unit name="E" team="red" />
                <div class="flex flex-col items-center opacity-50">
                  <div class="w-10 h-10 flex items-center justify-center pixel-border" style="background-color: #666;">
                    <span class="pixel-font text-stone-400" style="font-size: 8px;">-</span>
                  </div>
                  <span class="pixel-font text-stone-500 mt-1" style="font-size: 6px;">EMPTY</span>
                </div>
                <div class="flex flex-col items-center opacity-50">
                  <div class="w-10 h-10 flex items-center justify-center pixel-border" style="background-color: #666;">
                    <span class="pixel-font text-stone-400" style="font-size: 8px;">-</span>
                  </div>
                  <span class="pixel-font text-stone-500 mt-1" style="font-size: 6px;">EMPTY</span>
                </div>
                <div class="flex flex-col items-center opacity-50">
                  <div class="w-10 h-10 flex items-center justify-center pixel-border" style="background-color: #666;">
                    <span class="pixel-font text-stone-400" style="font-size: 8px;">-</span>
                  </div>
                  <span class="pixel-font text-stone-500 mt-1" style="font-size: 6px;">EMPTY</span>
                </div>
              </div>

              <div class="mt-4 text-center">
                <span class="pixel-font text-stone-500" style="font-size: 7px;">UNITS WILL HOLD IF NO ORDER GIVEN</span>
              </div>
            </div>
          </div>

          <div class="space-y-6">
            <div class="relative">
              <div class="absolute -top-3 left-4 right-4 h-6 scroll-roll rounded-t-lg"></div>
              <div class="pixel-border parchment p-4 pt-6">
                <h3 class="pixel-font text-stone-800 mb-3" style="font-size: 9px;">PLAYER STATUS</h3>

                <div class="space-y-3">
                  <div class="flex items-center justify-between p-2" style="background-color: #cce5cc;">
                    <span class="pixel-font text-stone-700" style="font-size: 7px;">YOU</span>
                    <span class="pixel-font text-green-700" style="font-size: 7px;">PLANNING</span>
                  </div>
                  <div class="flex items-center justify-between p-2" style="background-color: #ffe4b8;">
                    <span class="pixel-font text-stone-700" style="font-size: 7px;">OPPONENT</span>
                    <span class="pixel-font text-amber-700" style="font-size: 7px;">WAITING...</span>
                  </div>
                </div>
              </div>
              <div class="absolute -bottom-3 left-4 right-4 h-6 scroll-roll rounded-b-lg"></div>
            </div>

            <div class="relative">
              <div class="absolute -top-3 left-4 right-4 h-6 scroll-roll rounded-t-lg"></div>
              <div class="pixel-border parchment p-4 pt-6">
                <h3 class="pixel-font text-stone-800 mb-3" style="font-size: 9px;">QUICK KEYS</h3>

                <div class="space-y-2">
                  <.quick_key keys="Y U I O P" label="RED UNITS" />
                  <.quick_key keys="H J K L M" label="PURPLE" />
                  <.quick_key keys="W E A S D F" label="MOVE" />
                  <.quick_key keys="Q R" label="ROTATE" />
                  <.quick_key keys="C" label="CANCEL" />
                  <.quick_key keys="ENTER" label="SUBMIT" />
                </div>
              </div>
              <div class="absolute -bottom-3 left-4 right-4 h-6 scroll-roll rounded-b-lg"></div>
            </div>

            <div class="pixel-border pixel-shadow p-4" style="background-color: #4a1259;">
              <div class="text-center">
                <div class="pixel-font text-amber-100 mb-2" style="font-size: 8px;">ENEMY ORDERS</div>
                <div class="pixel-font text-purple-300" style="font-size: 10px;">? ? ?</div>
                <div class="pixel-font text-purple-400 mt-2" style="font-size: 6px;">HIDDEN UNTIL RESOLVE</div>
              </div>
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

  defp order_row(assigns) do
    team_color = if assigns.team == "red", do: "#8b0000", else: "#4a1259"
    assigns = assign(assigns, :team_color, team_color)

    ~H"""
    <div class="flex items-center gap-4 p-3" style="background-color: #d4c4a8;">
      <div class="w-10 h-10 flex items-center justify-center pixel-border" style={"background-color: #{@team_color};"}>
        <span class="pixel-font text-amber-100" style="font-size: 10px;">{@unit}</span>
      </div>
      <div class="flex-1">
        <span class="pixel-font text-stone-700" style="font-size: 8px;">{@action}</span>
      </div>
      <button class="w-6 h-6 flex items-center justify-center" style="background-color: #8b0000;">
        <span class="pixel-font text-amber-100" style="font-size: 10px;">X</span>
      </button>
    </div>
    """
  end

  defp idle_unit(assigns) do
    team_color = if assigns.team == "red", do: "#8b0000", else: "#4a1259"
    assigns = assign(assigns, :team_color, team_color)

    ~H"""
    <div class="flex flex-col items-center">
      <div class="w-10 h-10 flex items-center justify-center pixel-border" style={"background-color: #{@team_color};"}>
        <span class="pixel-font text-amber-100" style="font-size: 10px;">{@name}</span>
      </div>
      <span class="pixel-font text-stone-600 mt-1" style="font-size: 6px;">HOLD</span>
    </div>
    """
  end

  defp quick_key(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <div class="pixel-font text-stone-800" style="font-size: 7px; min-width: 70px;">{@keys}</div>
      <div class="pixel-font text-stone-500" style="font-size: 6px;">{@label}</div>
    </div>
    """
  end
end
