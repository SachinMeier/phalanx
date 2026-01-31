defmodule PhalanxWeb.Live.Mockups.Modern.Mockup3 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-red-950 via-stone-900 to-amber-950 p-8">
      <div class="max-w-6xl mx-auto space-y-8">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-4xl font-bold text-amber-200 mb-2">Combat Resolution</h1>
            <p class="text-amber-100/70">Attack angles, strength comparison, damage display</p>
          </div>
          <a href={~p"/mockups/modern"} class="btn btn-outline btn-warning">← Back to Mockups</a>
        </div>

        <div class="card bg-stone-800/50 backdrop-blur border-2 border-amber-600/30">
          <div class="card-body">
            <h2 class="card-title text-2xl text-amber-200 mb-6">Flank Attack in Progress</h2>

            <div class="relative w-full h-96 bg-stone-900/50 rounded-lg overflow-hidden">
              <svg class="absolute inset-0 w-full h-full opacity-20">
                <defs>
                  <pattern id="hex-grid" patternUnits="userSpaceOnUse" width="60" height="52">
                    <polygon points="30,0 60,15 60,37 30,52 0,37 0,15" fill="none" stroke="currentColor" stroke-width="0.5" class="text-amber-600" />
                  </pattern>
                </defs>
                <rect width="100%" height="100%" fill="url(#hex-grid)" />
              </svg>

              <div class="absolute" style="left: 45%; top: 40%; transform: translate(-50%, -50%);">
                <.unit_hex color="purple" name="H" health={2} />
              </div>

              <div class="absolute" style="left: 25%; top: 50%; transform: translate(-50%, -50%);">
                <.unit_hex color="red" name="Y" health={3} />
              </div>

              <svg class="absolute inset-0 w-full h-full pointer-events-none">
                <defs>
                  <marker id="arrowhead" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                    <polygon points="0 0, 10 3, 0 6" fill="#ef4444" />
                  </marker>
                </defs>
                <line x1="28%" y1="50%" x2="42%" y2="42%" stroke="#ef4444" stroke-width="4" marker-end="url(#arrowhead)" class="drop-shadow-lg" />
              </svg>

              <div class="absolute" style="left: 45%; top: 25%;">
                <div class="badge badge-error badge-lg font-bold text-lg px-4 py-3 shadow-2xl animate-pulse">FLANK ATTACK!</div>
              </div>

              <div class="absolute animate-bounce" style="left: 45%; top: 55%;">
                <div class="text-6xl font-black text-yellow-400 drop-shadow-[0_0_10px_rgba(234,179,8,0.8)]">-1</div>
              </div>

              <div class="absolute" style="left: 15%; top: 60%; transform: translate(-50%, -50%);">
                <.unit_hex color="red" name="U" health={3} size="small" />
              </div>

              <div class="absolute" style="left: 15%; top: 72%;">
                <div class="badge badge-sm bg-red-900/80 text-red-200 border-red-500">+1 Support</div>
              </div>
            </div>

            <div class="grid grid-cols-3 gap-6 mt-8">
              <div class="card bg-red-950/50 border-2 border-red-600">
                <div class="card-body p-4">
                  <h3 class="text-lg font-bold text-red-200 mb-3">Attacker (Y)</h3>
                  <div class="space-y-2 text-sm">
                    <div class="flex justify-between"><span class="text-red-200/70">Base:</span><span class="font-mono text-red-100">1</span></div>
                    <div class="flex justify-between"><span class="text-red-200/70">Formation:</span><span class="font-mono text-red-100">0</span></div>
                    <div class="flex justify-between"><span class="text-red-200/70">Support (U):</span><span class="font-mono text-red-100">+1</span></div>
                    <div class="flex justify-between"><span class="text-red-200/70">Flank Bonus:</span><span class="font-mono text-red-100">+1</span></div>
                    <div class="divider my-1"></div>
                    <div class="flex justify-between text-lg font-bold"><span class="text-red-200">Total:</span><span class="font-mono text-red-100">3</span></div>
                  </div>
                </div>
              </div>

              <div class="flex items-center justify-center">
                <div class="text-6xl font-black text-amber-400 drop-shadow-lg">VS</div>
              </div>

              <div class="card bg-purple-950/50 border-2 border-purple-600">
                <div class="card-body p-4">
                  <h3 class="text-lg font-bold text-purple-200 mb-3">Defender (H)</h3>
                  <div class="space-y-2 text-sm">
                    <div class="flex justify-between"><span class="text-purple-200/70">Base:</span><span class="font-mono text-purple-100">1</span></div>
                    <div class="flex justify-between"><span class="text-purple-200/70">Formation:</span><span class="font-mono text-purple-100">0</span></div>
                    <div class="flex justify-between text-purple-200/50"><span>Support:</span><span class="font-mono">-</span></div>
                    <div class="flex justify-between text-purple-200/50"><span>Flank Bonus:</span><span class="font-mono">-</span></div>
                    <div class="divider my-1"></div>
                    <div class="flex justify-between text-lg font-bold"><span class="text-purple-200">Total:</span><span class="font-mono text-purple-100">1</span></div>
                  </div>
                </div>
              </div>
            </div>

            <div class="alert bg-gradient-to-r from-red-900/50 to-amber-900/50 border-2 border-amber-600 mt-6">
              <div class="flex items-center gap-4 w-full">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-amber-400 shrink-0 w-8 h-8">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <div class="flex-1">
                  <h3 class="font-bold text-amber-200 text-lg">Attack Succeeds!</h3>
                  <div class="text-amber-100/80 text-sm">Y dislodges H (Strength 3 > 1). H takes 1 damage from flank and retreats southwest. H now at 1 HP.</div>
                </div>
              </div>
            </div>

            <div class="grid grid-cols-3 gap-4 mt-8">
              <div class="card bg-stone-700/30 border border-stone-600">
                <div class="card-body p-3">
                  <div class="text-center">
                    <div class="font-bold text-green-300 mb-1">Frontal</div>
                    <div class="text-2xl font-black text-stone-400">0</div>
                    <div class="text-xs text-stone-400">damage (shields block)</div>
                  </div>
                </div>
              </div>
              <div class="card bg-stone-700/30 border border-yellow-600">
                <div class="card-body p-3">
                  <div class="text-center">
                    <div class="font-bold text-yellow-300 mb-1">Flank</div>
                    <div class="text-2xl font-black text-yellow-400">-1</div>
                    <div class="text-xs text-yellow-300">damage</div>
                  </div>
                </div>
              </div>
              <div class="card bg-stone-700/30 border border-red-600">
                <div class="card-body p-3">
                  <div class="text-center">
                    <div class="font-bold text-red-300 mb-1">Rear</div>
                    <div class="text-2xl font-black text-red-400">-2</div>
                    <div class="text-xs text-red-300">damage</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp unit_hex(assigns) do
    assigns = assign_new(assigns, :size, fn -> "normal" end)
    {width, height} = if assigns.size == "small", do: {35, 40}, else: {50, 57.7}
    fill = if assigns.color == "red", do: "#991b1b", else: "#581c87"
    stroke = if assigns.color == "red", do: "#dc2626", else: "#9333ea"
    font_size = if assigns.size == "small", do: 16, else: 24
    assigns = assign(assigns, width: width, height: height, fill: fill, stroke: stroke, font_size: font_size)

    ~H"""
    <svg viewBox="0 0 100 115.47" width={@width} height={@height} class="drop-shadow-xl">
      <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill={@fill} stroke={@stroke} stroke-width="3" />
      <%!-- Chevron health bars --%>
      <polyline :if={@health >= 1} points="15,35.21 50,15 85,35.21" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
      <polyline :if={@health >= 2} points="25,39.44 50,25 75,39.44" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
      <polyline :if={@health >= 3} points="35,43.66 50,35 65,43.66" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
      <text x="50" y="78" text-anchor="middle" fill="white" font-size={@font_size} font-weight="bold" class="select-none"><%= @name %></text>
    </svg>
    """
  end
end
