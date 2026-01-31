defmodule PhalanxWeb.Live.Mockups.Modern.Mockup5 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-amber-950 via-orange-950 to-red-950 p-8">
      <div class="max-w-6xl mx-auto">
        <div class="mb-8 flex items-center justify-between">
          <div>
            <h1 class="text-4xl font-bold text-amber-100 mb-2">Retreat & Dislodgement</h1>
            <p class="text-amber-300">When an attacker wins combat, the defender is dislodged and must retreat</p>
          </div>
          <a href={~p"/mockups/modern"} class="btn btn-ghost text-amber-100">← Back to Mockups</a>
        </div>

        <div class="grid grid-cols-2 gap-8">
          <!-- Simple Retreat -->
          <div class="card bg-amber-950/40 backdrop-blur border-2 border-amber-800/50">
            <div class="card-body">
              <h2 class="card-title text-amber-100">Simple Retreat</h2>
              <p class="text-amber-300 text-sm mb-4">Purple unit is dislodged and must retreat away from attacker</p>

              <svg viewBox="0 0 400 300" class="w-full">
                <defs>
                  <marker id="arrowhead-red" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                    <polygon points="0 0, 10 3, 0 6" fill="#dc2626" />
                  </marker>
                  <marker id="arrowhead-retreat" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                    <polygon points="0 0, 10 3, 0 6" fill="#fbbf24" />
                  </marker>
                </defs>

                <!-- Valid retreat hex -->
                <polygon points="200,173 243.3,198 243.3,248 200,273 156.7,248 156.7,198" fill="#065f46" fill-opacity="0.3" stroke="#10b981" stroke-width="2" stroke-dasharray="4,4" />
                <text x="200" y="233" text-anchor="middle" fill="#10b981" font-size="10" font-weight="bold">VALID</text>

                <!-- Attacker -->
                <polygon points="150,100 193.3,125 193.3,175 150,200 106.7,175 106.7,125" fill="#dc2626" opacity="0.7" />
                <text x="150" y="150" text-anchor="middle" fill="white" font-size="16" font-weight="bold">R1</text>

                <!-- Attack arrow -->
                <path d="M 170,150 L 230,150" stroke="#dc2626" stroke-width="3" marker-end="url(#arrowhead-red)" />

                <!-- Defender (dislodged) -->
                <polygon points="250,100 293.3,125 293.3,175 250,200 206.7,175 206.7,125" fill="#9333ea" opacity="0.8" stroke="#fbbf24" stroke-width="3" stroke-dasharray="6,3" />
                <text x="250" y="145" text-anchor="middle" fill="white" font-size="16" font-weight="bold">P1</text>
                <text x="250" y="165" text-anchor="middle" fill="#fbbf24" font-size="9" font-weight="bold">DISLODGED</text>

                <!-- Retreat arrow -->
                <path d="M 240,180 Q 230,200 210,220" stroke="#fbbf24" stroke-width="3" fill="none" marker-end="url(#arrowhead-retreat)" stroke-dasharray="5,5" />
                <text x="215" y="195" fill="#fbbf24" font-size="10" font-style="italic">retreat</text>
              </svg>
            </div>
          </div>

          <!-- Blocked Retreat -->
          <div class="card bg-amber-950/40 backdrop-blur border-2 border-amber-800/50">
            <div class="card-body">
              <h2 class="card-title text-amber-100">Blocked Retreat</h2>
              <p class="text-amber-300 text-sm mb-4">Retreat hex is occupied—dislodged unit is destroyed</p>

              <svg viewBox="0 0 400 300" class="w-full">
                <!-- Blocked retreat hex -->
                <polygon points="200,173 243.3,198 243.3,248 200,273 156.7,248 156.7,198" fill="#7f1d1d" fill-opacity="0.4" stroke="#dc2626" stroke-width="2" />
                <line x1="170" y1="208" x2="230" y2="258" stroke="#dc2626" stroke-width="4" />
                <line x1="230" y1="208" x2="170" y2="258" stroke="#dc2626" stroke-width="4" />
                <text x="200" y="233" text-anchor="middle" fill="#dc2626" font-size="10" font-weight="bold">BLOCKED</text>

                <!-- Attacker -->
                <polygon points="150,100 193.3,125 193.3,175 150,200 106.7,175 106.7,125" fill="#dc2626" opacity="0.7" />
                <text x="150" y="150" text-anchor="middle" fill="white" font-size="16" font-weight="bold">R2</text>

                <!-- Attack arrow -->
                <path d="M 170,150 L 230,150" stroke="#dc2626" stroke-width="3" marker-end="url(#arrowhead-red)" />

                <!-- Defender (destroyed) -->
                <g opacity="0.5">
                  <polygon points="250,100 293.3,125 293.3,175 250,200 206.7,175 206.7,125" fill="#9333ea" stroke="#dc2626" stroke-width="3" />
                  <text x="250" y="145" text-anchor="middle" fill="white" font-size="16" font-weight="bold">P2</text>
                  <text x="250" y="165" text-anchor="middle" fill="#dc2626" font-size="9" font-weight="bold">DESTROYED</text>
                </g>

                <!-- Blocking unit -->
                <polygon points="200,173 243.3,198 243.3,248 200,273 156.7,248 156.7,198" fill="#9333ea" opacity="0.8" />
                <text x="200" y="233" text-anchor="middle" fill="white" font-size="16" font-weight="bold">P3</text>
              </svg>
            </div>
          </div>

          <!-- Cascade Retreat (full width) -->
          <div class="card bg-amber-950/40 backdrop-blur border-2 border-amber-800/50 col-span-2">
            <div class="card-body">
              <h2 class="card-title text-amber-100">Cascade Retreat</h2>
              <p class="text-amber-300 text-sm mb-4">Unit A is dislodged and retreats into B, forcing B to retreat into C</p>

              <svg viewBox="0 0 800 300" class="w-full">
                <defs>
                  <marker id="arrowhead-cascade" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                    <polygon points="0 0, 10 3, 0 6" fill="#fb923c" />
                  </marker>
                </defs>

                <!-- Attacker (Red) -->
                <polygon points="120,125 163.3,150 163.3,200 120,225 76.7,200 76.7,150" fill="#dc2626" opacity="0.7" />
                <text x="120" y="180" text-anchor="middle" fill="white" font-size="20" font-weight="bold">R</text>

                <!-- Attack arrow -->
                <path d="M 145,175 L 185,175" stroke="#dc2626" stroke-width="4" marker-end="url(#arrowhead-red)" />

                <!-- Unit A (dislodged) -->
                <polygon points="206.6,125 249.9,150 249.9,200 206.6,225 163.3,200 163.3,150" fill="#9333ea" opacity="0.8" stroke="#fbbf24" stroke-width="3" stroke-dasharray="6,3" />
                <text x="206.6" y="165" text-anchor="middle" fill="white" font-size="20" font-weight="bold">A</text>
                <text x="206.6" y="185" text-anchor="middle" fill="#fbbf24" font-size="9" font-weight="bold">DISLODGED</text>

                <!-- Unit B -->
                <polygon points="293.2,125 336.5,150 336.5,200 293.2,225 249.9,200 249.9,150" fill="#9333ea" opacity="0.8" stroke="#fb923c" stroke-width="2" stroke-dasharray="4,4" />
                <text x="293.2" y="180" text-anchor="middle" fill="white" font-size="20" font-weight="bold">B</text>

                <!-- Unit C -->
                <polygon points="379.8,125 423.1,150 423.1,200 379.8,225 336.5,200 336.5,150" fill="#9333ea" opacity="0.8" stroke="#fb923c" stroke-width="2" stroke-dasharray="4,4" />
                <text x="379.8" y="180" text-anchor="middle" fill="white" font-size="20" font-weight="bold">C</text>

                <!-- Empty final hex -->
                <polygon points="466.4,125 509.7,150 509.7,200 466.4,225 423.1,200 423.1,150" fill="#065f46" fill-opacity="0.2" stroke="#10b981" stroke-width="1" stroke-dasharray="3,3" />

                <!-- Sequence numbers -->
                <circle cx="206.6" cy="210" r="12" fill="#fbbf24" />
                <text x="206.6" y="215" text-anchor="middle" fill="#000" font-size="12" font-weight="bold">1</text>

                <circle cx="293.2" cy="210" r="12" fill="#fb923c" />
                <text x="293.2" y="215" text-anchor="middle" fill="#000" font-size="12" font-weight="bold">2</text>

                <circle cx="379.8" cy="210" r="12" fill="#fb923c" />
                <text x="379.8" y="215" text-anchor="middle" fill="#000" font-size="12" font-weight="bold">3</text>

                <!-- Retreat arrows -->
                <path d="M 230,175 L 270,175" stroke="#fbbf24" stroke-width="3" fill="none" marker-end="url(#arrowhead-cascade)" stroke-dasharray="5,5" />
                <path d="M 316,175 L 356,175" stroke="#fb923c" stroke-width="3" fill="none" marker-end="url(#arrowhead-cascade)" stroke-dasharray="5,5" />
                <path d="M 403,175 L 443,175" stroke="#fb923c" stroke-width="3" fill="none" marker-end="url(#arrowhead-cascade)" stroke-dasharray="5,5" />

                <!-- Labels -->
                <text x="550" y="150" fill="#fbbf24" font-size="14" font-weight="bold">Cascade Sequence:</text>
                <text x="550" y="170" fill="#fbbf24" font-size="12">1. A dislodged by R</text>
                <text x="550" y="190" fill="#fb923c" font-size="12">2. A retreats into B</text>
                <text x="550" y="210" fill="#fb923c" font-size="12">3. B retreats into C</text>
                <text x="550" y="230" fill="#fb923c" font-size="12">4. C retreats to empty</text>
              </svg>
            </div>
          </div>
        </div>

        <!-- Legend -->
        <div class="card bg-amber-950/40 backdrop-blur border-2 border-amber-800/50 mt-8">
          <div class="card-body">
            <h3 class="text-xl font-bold text-amber-100 mb-4">Retreat Mechanics</h3>
            <div class="grid grid-cols-2 gap-6 text-amber-200">
              <div>
                <h4 class="font-bold text-amber-100 mb-2">Rules</h4>
                <ul class="space-y-1 text-sm">
                  <li>• Retreat direction: away from attacker (opposite facing)</li>
                  <li>• If retreat hex is empty: unit moves there</li>
                  <li>• If retreat hex is occupied: cascade retreat</li>
                  <li>• If retreat hex is off-map or blocked: unit destroyed</li>
                </ul>
              </div>
              <div>
                <h4 class="font-bold text-amber-100 mb-2">Visual Indicators</h4>
                <ul class="space-y-1 text-sm">
                  <li><span class="text-yellow-400">●</span> Dashed yellow outline = dislodged unit</li>
                  <li><span class="text-green-400">●</span> Green dashed hex = valid retreat target</li>
                  <li><span class="text-red-400">●</span> Red X = blocked retreat (destruction)</li>
                  <li><span class="text-orange-400">●</span> Orange outline = cascade retreat</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
