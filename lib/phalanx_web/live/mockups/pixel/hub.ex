defmodule PhalanxWeb.Live.Mockups.Pixel.Hub do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      @import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap');
      .pixel-font { font-family: 'Press Start 2P', monospace; }
      .pixel-border {
        border: 4px solid #5c4033;
        box-shadow: inset 0 0 0 2px #d4a574, inset 0 0 0 4px #8b6914;
      }
      .greek-key-border {
        background-image:
          repeating-linear-gradient(90deg, #5c4033 0px, #5c4033 4px, transparent 4px, transparent 8px),
          repeating-linear-gradient(180deg, #5c4033 0px, #5c4033 4px, transparent 4px, transparent 8px);
        background-size: 8px 4px, 4px 8px;
        background-position: 0 0, 100% 0;
        background-repeat: repeat-x, repeat-y;
      }
    </style>
    <div class="min-h-screen p-8" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-4xl mx-auto">
        <div class="mb-8 flex items-center justify-between">
          <.link navigate={~p"/mockups"} class="pixel-font text-amber-200 hover:text-amber-100" style="font-size: 10px;">
            &lt; ALL THEMES
          </.link>
        </div>

        <div class="text-center mb-12">
          <div class="pixel-border p-8 inline-block" style="background: linear-gradient(180deg, #d4a574 0%, #c4956a 50%, #b4855a 100%);">
            <h1 class="pixel-font text-stone-900 mb-4" style="font-size: 20px; text-shadow: 2px 2px 0 #d4a574;">
              PHALANX
            </h1>
            <p class="pixel-font text-stone-700" style="font-size: 8px;">
              PIXEL WARRIOR EDITION
            </p>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-6">
          <.scroll_card number={1} title="UNIT STATUS" description="Health and energy states" />
          <.scroll_card number={2} title="FORMATIONS" description="Phalanx bonds and depth" />
          <.scroll_card number={3} title="COMBAT" description="Attack angles and damage" />
          <.scroll_card number={4} title="MOVEMENT" description="Valid moves and orders" />
          <.scroll_card number={5} title="RETREAT" description="Dislodgement and cascade" />
          <.scroll_card number={6} title="TURN PHASES" description="Resolution timeline" />
          <.scroll_card number={7} title="ORDER LIST" description="Pending orders panel" />
          <.scroll_card number={8} title="BATTLE" description="Full combat scene" />
          <.scroll_card number={9} title="STRENGTH" description="Force calculation" />
          <.scroll_card number={10} title="GAME SETUP" description="Army deployment" />
        </div>

        <div class="mt-12 text-center">
          <div class="pixel-border inline-block p-4" style="background-color: #c4956a;">
            <p class="pixel-font text-stone-800" style="font-size: 8px;">
              INSPIRED BY SIEGIUS &amp; CLASSIC STRATEGY GAMES
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp scroll_card(assigns) do
    ~H"""
    <a href={~p"/mockups/pixel/#{@number}"} class="group block">
      <div class="relative transition-transform group-hover:-translate-y-1">
        <div class="absolute -top-2 left-1/2 -translate-x-1/2 w-3/4 h-3 rounded-full" style="background-color: #8b6914; box-shadow: 0 2px 0 #5c4033;"></div>
        <div class="pixel-border p-4" style="background: linear-gradient(180deg, #e8d4b8 0%, #d4c4a8 20%, #c4b498 80%, #b4a488 100%);">
          <div class="flex items-center gap-3 mb-2">
            <div class="w-8 h-8 flex items-center justify-center pixel-border" style="background-color: #8b0000;">
              <span class="pixel-font text-amber-100" style="font-size: 10px;">{@number}</span>
            </div>
            <h2 class="pixel-font text-stone-800" style="font-size: 10px;">{@title}</h2>
          </div>
          <p class="pixel-font text-stone-600" style="font-size: 7px;">{@description}</p>
          <div class="mt-3 h-1" style="background: repeating-linear-gradient(90deg, #5c4033 0px, #5c4033 4px, transparent 4px, transparent 8px);"></div>
        </div>
        <div class="absolute -bottom-2 left-1/2 -translate-x-1/2 w-3/4 h-3 rounded-full" style="background-color: #8b6914; box-shadow: 0 -2px 0 #5c4033;"></div>
      </div>
    </a>
    """
  end
end
