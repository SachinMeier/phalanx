defmodule PhalanxWeb.Live.Mockups.Modern.Mockup4 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-emerald-950 via-stone-900 to-teal-950 p-8">
      <div class="max-w-4xl mx-auto">
        <div class="mb-6">
          <.link navigate={~p"/mockups/modern"} class="text-emerald-400 hover:text-emerald-300">← Back to Mockups</.link>
        </div>

        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-emerald-100 mb-2">Movement & Orders</h1>
          <p class="text-emerald-300/70">Valid moves, order previews, hotkey overlay</p>
        </div>

        <div class="flex justify-center items-center">
          <svg width="400" height="400" viewBox="0 0 400 400" class="drop-shadow-2xl">
            <defs>
              <pattern id="invalid-pattern" patternUnits="userSpaceOnUse" width="4" height="4" patternTransform="rotate(45)">
                <line x1="0" y1="0" x2="0" y2="4" stroke="#1f2937" stroke-width="1" />
              </pattern>
              <marker id="arrowhead" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto" fill="#fbbf24">
                <polygon points="0 0, 10 3, 0 6" />
              </marker>
              <filter id="glow">
                <feGaussianBlur stdDeviation="4" result="coloredBlur" />
                <feMerge><feMergeNode in="coloredBlur" /><feMergeNode in="SourceGraphic" /></feMerge>
              </filter>
            </defs>

            <!-- Center hex - selected unit with chevron health bars -->
            <g transform="translate(175, 171)">
              <svg viewBox="0 0 100 115.47" width="50" height="57.7">
                <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#fbbf24" opacity="0.3" filter="url(#glow)" />
                <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#dc2626" stroke="#fbbf24" stroke-width="4" />
                <!-- Chevron health bars -->
                <polyline points="15,35.21 50,15 85,35.21" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
                <polyline points="25,39.44 50,25 75,39.44" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
                <polyline points="35,43.66 50,35 65,43.66" stroke="white" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
                <text x="50" y="78" text-anchor="middle" fill="white" font-size="24" font-weight="bold">Y</text>
              </svg>
            </g>

            <!-- NE (valid, -1E) -->
            <g transform="translate(218, 96)">
              <polygon points="25,0 50,14.4 50,43.3 25,57.7 0,43.3 0,14.4" fill="#065f46" stroke="#10b981" stroke-width="2" opacity="0.6" />
              <rect x="32" y="5" width="16" height="12" rx="2" fill="#7c2d12" stroke="#fdba74" stroke-width="1" />
              <text x="40" y="14" text-anchor="middle" fill="#fdba74" font-size="8" font-weight="bold">-1E</text>
              <text x="8" y="14" text-anchor="middle" fill="#86efac" font-size="10" font-weight="bold">E</text>
            </g>

            <!-- NW (valid, -1E) -->
            <g transform="translate(132, 96)">
              <polygon points="25,0 50,14.4 50,43.3 25,57.7 0,43.3 0,14.4" fill="#065f46" stroke="#10b981" stroke-width="2" opacity="0.6" />
              <rect x="32" y="5" width="16" height="12" rx="2" fill="#7c2d12" stroke="#fdba74" stroke-width="1" />
              <text x="40" y="14" text-anchor="middle" fill="#fdba74" font-size="8" font-weight="bold">-1E</text>
              <text x="8" y="14" text-anchor="middle" fill="#86efac" font-size="10" font-weight="bold">W</text>
            </g>

            <!-- SE (valid, 0E) -->
            <g transform="translate(218, 246)">
              <polygon points="25,0 50,14.4 50,43.3 25,57.7 0,43.3 0,14.4" fill="#065f46" stroke="#10b981" stroke-width="2" opacity="0.6" />
              <rect x="32" y="5" width="14" height="12" rx="2" fill="#065f46" stroke="#86efac" stroke-width="1" />
              <text x="39" y="14" text-anchor="middle" fill="#86efac" font-size="8" font-weight="bold">0E</text>
              <text x="8" y="14" text-anchor="middle" fill="#86efac" font-size="10" font-weight="bold">D</text>
            </g>

            <!-- SW (valid, 0E) -->
            <g transform="translate(132, 246)">
              <polygon points="25,0 50,14.4 50,43.3 25,57.7 0,43.3 0,14.4" fill="#065f46" stroke="#10b981" stroke-width="2" opacity="0.6" />
              <rect x="32" y="5" width="14" height="12" rx="2" fill="#065f46" stroke="#86efac" stroke-width="1" />
              <text x="39" y="14" text-anchor="middle" fill="#86efac" font-size="8" font-weight="bold">0E</text>
              <text x="8" y="14" text-anchor="middle" fill="#86efac" font-size="10" font-weight="bold">A</text>
            </g>

            <!-- E (invalid) -->
            <g transform="translate(261, 171)">
              <polygon points="25,0 50,14.4 50,43.3 25,57.7 0,43.3 0,14.4" fill="url(#invalid-pattern)" stroke="#374151" stroke-width="2" opacity="0.4" />
              <line x1="5" y1="5" x2="45" y2="52" stroke="#4b5563" stroke-width="2" opacity="0.6" />
              <line x1="45" y1="5" x2="5" y2="52" stroke="#4b5563" stroke-width="2" opacity="0.6" />
              <text x="8" y="14" text-anchor="middle" fill="#6b7280" font-size="10" font-weight="bold">F</text>
            </g>

            <!-- W (invalid) -->
            <g transform="translate(89, 171)">
              <polygon points="25,0 50,14.4 50,43.3 25,57.7 0,43.3 0,14.4" fill="url(#invalid-pattern)" stroke="#374151" stroke-width="2" opacity="0.4" />
              <line x1="5" y1="5" x2="45" y2="52" stroke="#4b5563" stroke-width="2" opacity="0.6" />
              <line x1="45" y1="5" x2="5" y2="52" stroke="#4b5563" stroke-width="2" opacity="0.6" />
              <text x="8" y="14" text-anchor="middle" fill="#6b7280" font-size="10" font-weight="bold">S</text>
            </g>

            <!-- Order preview arrow -->
            <line x1="200" y1="186" x2="237" y2="126" stroke="#fbbf24" stroke-width="3" stroke-dasharray="8,4" marker-end="url(#arrowhead)" opacity="0.8" />
          </svg>
        </div>

        <div class="mt-12 max-w-2xl mx-auto">
          <div class="bg-stone-900/50 rounded-lg p-6 border border-emerald-800/30">
            <h2 class="text-xl font-semibold text-emerald-100 mb-4">Movement Rules</h2>
            <div class="space-y-3 text-emerald-200/80">
              <div class="flex items-start gap-3">
                <div class="w-20 shrink-0 text-emerald-400 font-mono text-sm">Forward:</div>
                <div>4 of 6 hex directions available based on facing. Costs 1 energy.</div>
              </div>
              <div class="flex items-start gap-3">
                <div class="w-20 shrink-0 text-emerald-400 font-mono text-sm">Backward:</div>
                <div>2 hexes directly behind. Free movement (0 energy).</div>
              </div>
              <div class="flex items-start gap-3">
                <div class="w-20 shrink-0 text-emerald-400 font-mono text-sm">Blocked:</div>
                <div>2 hexes perpendicular to facing. Cannot move here.</div>
              </div>
              <div class="flex items-start gap-3">
                <div class="w-20 shrink-0 text-emerald-400 font-mono text-sm">Order:</div>
                <div>Yellow dashed arrow shows pending move. Press Enter to submit all orders.</div>
              </div>
            </div>
          </div>

          <div class="bg-stone-900/50 rounded-lg p-6 border border-emerald-800/30 mt-4">
            <h2 class="text-xl font-semibold text-emerald-100 mb-4">Keyboard Controls</h2>
            <div class="grid grid-cols-2 gap-3 text-emerald-200/80 text-sm">
              <div class="flex items-center gap-2"><kbd class="kbd kbd-sm bg-emerald-900/50 border-emerald-700">W</kbd><span>Move NW</span></div>
              <div class="flex items-center gap-2"><kbd class="kbd kbd-sm bg-emerald-900/50 border-emerald-700">E</kbd><span>Move NE</span></div>
              <div class="flex items-center gap-2"><kbd class="kbd kbd-sm bg-emerald-900/50 border-emerald-700">A</kbd><span>Move SW</span></div>
              <div class="flex items-center gap-2"><kbd class="kbd kbd-sm bg-emerald-900/50 border-emerald-700">D</kbd><span>Move SE</span></div>
              <div class="flex items-center gap-2"><kbd class="kbd kbd-sm bg-emerald-900/50 border-emerald-700">S</kbd><span>Move W</span></div>
              <div class="flex items-center gap-2"><kbd class="kbd kbd-sm bg-emerald-900/50 border-emerald-700">F</kbd><span>Move E</span></div>
              <div class="flex items-center gap-2"><kbd class="kbd kbd-sm bg-yellow-900/50 border-yellow-700">Q</kbd><span>Rotate CCW</span></div>
              <div class="flex items-center gap-2"><kbd class="kbd kbd-sm bg-yellow-900/50 border-yellow-700">R</kbd><span>Rotate CW</span></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
