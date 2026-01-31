defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup5 do
  @moduledoc "Retreat & Dislodgement - Pixel Art Style"
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
      @keyframes retreat-flash { 0%, 100% { transform: translateX(0); } 50% { transform: translateX(-4px); } }
      .retreating { animation: retreat-flash 0.3s infinite; }
    </style>
    <div class="min-h-screen p-6" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="RETREAT" />

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">FORCED RETREAT</h2>
          <p class="pixel-font text-stone-600 mb-6" style="font-size: 7px;">LOSER PUSHED BACK ONE HEX</p>

          <div class="flex justify-center">
            <svg viewBox="0 0 280 100" width="280" height="100" style="image-rendering: pixelated;">
              <polygon points="60,25 80,37 80,61 60,73 40,61 40,37" fill="#8b0000" />
              <polygon points="60,32 48,38" fill="none" stroke="#f5f5dc" stroke-width="2" />
              <polygon points="60,32 72,38" fill="none" stroke="#f5f5dc" stroke-width="2" />
              <text x="60" y="58" text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">A</text>
              <text x="60" y="90" text-anchor="middle" fill="#228b22" font-size="8" font-weight="bold">STR 8</text>

              <polygon points="95,35 110,35 110,30 125,50 110,70 110,65 95,65" fill="#ff6600" />

              <g class="retreating">
                <polygon points="140,25 160,37 160,61 140,73 120,61 120,37" fill="#4a1259" opacity="0.5" stroke="#ff0000" stroke-width="2" stroke-dasharray="4" />
                <polygon points="140,32 152,38" fill="none" stroke="#f5f5dc" stroke-width="2" opacity="0.5" />
                <text x="140" y="58" text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold" opacity="0.5">B</text>
              </g>

              <polygon points="175,35 190,35 190,30 205,50 190,70 190,65 175,65" fill="#ff0000" />

              <polygon points="220,25 240,37 240,61 220,73 200,61 200,37" fill="#4a1259" />
              <polygon points="232,37 232,61" fill="none" stroke="#f5f5dc" stroke-width="2" />
              <text x="220" y="58" text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">B</text>
              <text x="220" y="90" text-anchor="middle" fill="#ff0000" font-size="8" font-weight="bold">STR 5</text>
            </svg>
          </div>

          <div class="mt-4 text-center">
            <span class="pixel-font text-red-700" style="font-size: 8px;">B LOSES - RETREATS EAST</span>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-6 mb-8">
          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">BLOCKED RETREAT</h2>
            <p class="pixel-font text-stone-600 mb-4" style="font-size: 7px;">NO ESCAPE = EXTRA DAMAGE</p>

            <div class="flex justify-center">
              <svg viewBox="0 0 160 120" width="160" height="120" style="image-rendering: pixelated;">
                <polygon points="80,20 100,32 100,56 80,68 60,56 60,32" fill="#4a1259" />
                <text x="80" y="52" text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">C</text>

                <polygon points="115,35 130,35 130,30 145,50 130,70 130,65 115,65" fill="#ff0000" opacity="0.3" />
                <text x="130" y="55" text-anchor="middle" fill="#ff0000" font-size="12" font-weight="bold">X</text>

                <polygon points="130,50 150,62 150,86 130,98 110,86 110,62" fill="#666666" stroke="#333" stroke-width="2" />
                <text x="130" y="82" text-anchor="middle" fill="#333" font-size="8">WALL</text>

                <polygon points="40,20 60,32 60,56 40,68 20,56 20,32" fill="#8b0000" />
                <polygon points="40,27 52,33" fill="none" stroke="#f5f5dc" stroke-width="2" />
                <text x="40" y="52" text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">D</text>
              </svg>
            </div>

            <div class="mt-4 p-2 text-center" style="background-color: #ffcccc;">
              <span class="pixel-font text-red-700" style="font-size: 7px;">+1 DAMAGE FROM BEING TRAPPED</span>
            </div>
          </div>

          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">CASCADE RETREAT</h2>
            <p class="pixel-font text-stone-600 mb-4" style="font-size: 7px;">RETREAT INTO ALLY = CHAIN</p>

            <div class="flex justify-center">
              <svg viewBox="0 0 160 100" width="160" height="100" style="image-rendering: pixelated;">
                <polygon points="40,25 60,37 60,61 40,73 20,61 20,37" fill="#8b0000" />
                <text x="40" y="55" text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">E</text>

                <polygon points="65,35 75,35 75,30 85,50 75,70 75,65 65,65" fill="#ffd700" />

                <polygon points="100,25 120,37 120,61 100,73 80,61 80,37" fill="#4a1259" class="retreating" />
                <text x="100" y="55" text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">F</text>

                <polygon points="125,35 135,35 135,30 145,50 135,70 135,65 125,65" fill="#ffd700" />

                <polygon points="160,25 180,37 180,61 160,73 140,61 140,37" fill="#4a1259" class="retreating" style="animation-delay: 0.15s;" />
                <text x="160" y="55" text-anchor="middle" fill="#f5f5dc" font-size="10" font-weight="bold">G</text>
              </svg>
            </div>

            <div class="mt-4 text-center">
              <span class="pixel-font text-amber-700" style="font-size: 7px;">F RETREATS INTO G - G ALSO RETREATS</span>
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">RETREAT PRIORITY</h2>

          <div class="grid grid-cols-3 gap-4 text-center">
            <div class="p-3" style="background-color: #d4c4a8;">
              <div class="pixel-font text-stone-800 mb-2" style="font-size: 8px;">1ST</div>
              <div class="pixel-font text-stone-600" style="font-size: 7px;">AWAY FROM ATTACKER</div>
            </div>
            <div class="p-3" style="background-color: #d4c4a8;">
              <div class="pixel-font text-stone-800 mb-2" style="font-size: 8px;">2ND</div>
              <div class="pixel-font text-stone-600" style="font-size: 7px;">TOWARD OWN LINES</div>
            </div>
            <div class="p-3" style="background-color: #d4c4a8;">
              <div class="pixel-font text-stone-800 mb-2" style="font-size: 8px;">3RD</div>
              <div class="pixel-font text-stone-600" style="font-size: 7px;">EMPTY HEX ONLY</div>
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
end
