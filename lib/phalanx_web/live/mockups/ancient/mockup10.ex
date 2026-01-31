defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup10 do
  @moduledoc "Ancient theme: Game Setup"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen" style="background: linear-gradient(145deg, #2C2416 0%, #3D3225 50%, #2A2118 100%);">
      <div class="relative z-10 p-8 max-w-5xl mx-auto">
        <%!-- Header --%>
        <div class="mb-12">
          <.link navigate={~p"/mockups/ancient"} class="inline-flex items-center gap-2 text-amber-600 hover:text-amber-400 text-sm mb-6 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Ancient Mockups
          </.link>
          <h1 class="text-4xl font-bold mb-3" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Game Setup
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            Preparing for battle — team selection, unit naming, and initial formation
          </p>
        </div>

        <%!-- Game Creation Flow --%>
        <div class="space-y-8">
          <%!-- Step 1: Create Game --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 2px solid rgba(206,137,70,0.4);">
            <div class="flex items-center gap-4 mb-6">
              <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold" style="background: #CE8946; color: #2C2416;">
                1
              </div>
              <h3 class="text-xl font-semibold" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
                Create New Battle
              </h3>
            </div>

            <div class="grid md:grid-cols-2 gap-6">
              <div class="space-y-4">
                <div>
                  <label class="block text-sm mb-2" style="color: #9D8C71;">Battle Name</label>
                  <input type="text" value="Thermopylae" class="w-full px-4 py-3 rounded-lg font-semibold"
                         style="background: rgba(0,0,0,0.3); border: 1px solid rgba(206, 137, 70, 0.3); color: #E5DBB7; font-family: 'Cinzel', serif;"
                         placeholder="Enter battle name..." />
                </div>
                <div>
                  <label class="block text-sm mb-2" style="color: #9D8C71;">Game Mode</label>
                  <select class="w-full px-4 py-3 rounded-lg"
                          style="background: rgba(0,0,0,0.3); border: 1px solid rgba(206, 137, 70, 0.3); color: #E5DBB7;">
                    <option>Elimination (Standard)</option>
                    <option>Siege (Defender Holds)</option>
                    <option>King of the Hill</option>
                  </select>
                </div>
              </div>

              <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
                <h4 class="font-semibold mb-3" style="color: #FACD1E;">Elimination Mode</h4>
                <ul class="text-sm space-y-2" style="color: #9D8C71;">
                  <li>• Destroy all enemy units to win</li>
                  <li>• 5v5 symmetric start</li>
                  <li>• No turn limit</li>
                </ul>
              </div>
            </div>
          </div>

          <%!-- Step 2: Choose Side --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 2px solid rgba(206,137,70,0.4);">
            <div class="flex items-center gap-4 mb-6">
              <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold" style="background: #CE8946; color: #2C2416;">
                2
              </div>
              <h3 class="text-xl font-semibold" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
                Choose Your Side
              </h3>
            </div>

            <div class="grid md:grid-cols-2 gap-6">
              <%!-- Red Team --%>
              <div class="p-6 rounded-xl cursor-pointer transition-all hover:scale-105 ring-4 ring-transparent hover:ring-amber-500/50"
                   style="background: linear-gradient(145deg, rgba(211, 41, 41, 0.15) 0%, rgba(211, 41, 41, 0.05) 100%); border: 2px solid rgba(211, 41, 41, 0.4);">
                <div class="flex items-center gap-4 mb-4">
                  <div class="w-16 h-16 rounded-lg flex items-center justify-center" style="background: #D32929;">
                    <span class="text-3xl text-white font-bold" style="font-family: 'Cinzel', serif;">Λ</span>
                  </div>
                  <div>
                    <div class="text-xl font-bold" style="font-family: 'Cinzel', serif; color: #D32929;">Sparta</div>
                    <div class="text-sm" style="color: #9D8C71;">The Red Cloaks</div>
                  </div>
                </div>
                <p class="text-sm mb-4" style="color: #9D8C71;">
                  "Come back with your shield, or on it." Masters of the phalanx formation.
                </p>
                <div class="flex gap-2">
                  <span class="px-2 py-1 rounded text-xs" style="background: rgba(211, 41, 41, 0.2); color: #D32929;">5 Hoplites</span>
                  <span class="px-2 py-1 rounded text-xs" style="background: rgba(211, 41, 41, 0.2); color: #D32929;">South Start</span>
                </div>
              </div>

              <%!-- Purple Team --%>
              <div class="p-6 rounded-xl cursor-pointer transition-all hover:scale-105 ring-4 ring-transparent hover:ring-amber-500/50"
                   style="background: linear-gradient(145deg, rgba(93, 58, 142, 0.15) 0%, rgba(93, 58, 142, 0.05) 100%); border: 2px solid rgba(93, 58, 142, 0.4);">
                <div class="flex items-center gap-4 mb-4">
                  <div class="w-16 h-16 rounded-lg flex items-center justify-center" style="background: #5D3A8E;">
                    <span class="text-3xl text-white font-bold" style="font-family: 'Cinzel', serif;">Ξ</span>
                  </div>
                  <div>
                    <div class="text-xl font-bold" style="font-family: 'Cinzel', serif; color: #5D3A8E;">Persia</div>
                    <div class="text-sm" style="color: #9D8C71;">The Immortals</div>
                  </div>
                </div>
                <p class="text-sm mb-4" style="color: #9D8C71;">
                  "Our arrows will blot out the sun." The endless host of the Great King.
                </p>
                <div class="flex gap-2">
                  <span class="px-2 py-1 rounded text-xs" style="background: rgba(93, 58, 142, 0.2); color: #5D3A8E;">5 Immortals</span>
                  <span class="px-2 py-1 rounded text-xs" style="background: rgba(93, 58, 142, 0.2); color: #5D3A8E;">North Start</span>
                </div>
              </div>
            </div>
          </div>

          <%!-- Step 3: Name Your Units --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 2px solid rgba(206,137,70,0.4);">
            <div class="flex items-center gap-4 mb-6">
              <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold" style="background: #CE8946; color: #2C2416;">
                3
              </div>
              <h3 class="text-xl font-semibold" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
                Name Your Warriors
              </h3>
            </div>

            <div class="grid grid-cols-5 gap-4">
              <%= for {letter, name} <- [{"Α", "Alpha"}, {"Β", "Beta"}, {"Γ", "Gamma"}, {"Δ", "Delta"}, {"Ε", "Epsilon"}] do %>
                <div class="flex flex-col items-center">
                  <div class="w-16 h-16 rounded-lg flex items-center justify-center mb-3 font-bold text-2xl text-white" style="background: #D32929;">
                    <%= letter %>
                  </div>
                  <input type="text" value={name} class="w-full px-2 py-1 text-center rounded text-sm"
                         style="background: rgba(0,0,0,0.3); border: 1px solid rgba(206, 137, 70, 0.3); color: #E5DBB7;" />
                </div>
              <% end %>
            </div>
          </div>

          <%!-- Step 4: Initial Formation --%>
          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 2px solid rgba(206,137,70,0.4);">
            <div class="flex items-center gap-4 mb-6">
              <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold" style="background: #CE8946; color: #2C2416;">
                4
              </div>
              <h3 class="text-xl font-semibold" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
                Starting Formation
              </h3>
            </div>

            <div class="grid md:grid-cols-2 gap-6">
              <div class="flex justify-center">
                <svg viewBox="0 0 350 200" width="350" height="200">
                  <rect width="350" height="200" fill="#3D3225" rx="8"/>

                  <%!-- Grid hint --%>
                  <g stroke="rgba(157, 140, 113, 0.15)" stroke-width="1">
                    <%= for i <- 0..7 do %>
                      <line x1={i * 50} y1="0" x2={i * 50} y2="200" />
                    <% end %>
                    <%= for j <- 0..4 do %>
                      <line x1="0" y1={j * 50} x2="350" y2={j * 50} />
                    <% end %>
                  </g>

                  <%!-- Starting positions (line formation) --%>
                  <g transform="translate(45, 120)">
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="#D32929"/>
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="none" stroke="#FACD1E" stroke-width="2"/>
                    <text x="30" y="40" text-anchor="middle" fill="#FFF5E6" font-size="16" font-weight="bold">Α</text>
                  </g>
                  <g transform="translate(105, 120)">
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="#D32929"/>
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="none" stroke="#FACD1E" stroke-width="2"/>
                    <text x="30" y="40" text-anchor="middle" fill="#FFF5E6" font-size="16" font-weight="bold">Β</text>
                  </g>
                  <g transform="translate(165, 120)">
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="#D32929"/>
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="none" stroke="#FACD1E" stroke-width="2"/>
                    <text x="30" y="40" text-anchor="middle" fill="#FFF5E6" font-size="16" font-weight="bold">Γ</text>
                  </g>
                  <g transform="translate(225, 120)">
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="#D32929"/>
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="none" stroke="#FACD1E" stroke-width="2"/>
                    <text x="30" y="40" text-anchor="middle" fill="#FFF5E6" font-size="16" font-weight="bold">Δ</text>
                  </g>
                  <g transform="translate(285, 120)">
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="#D32929"/>
                    <polygon points="30,0 60,17.32 60,51.96 30,69.28 0,51.96 0,17.32" fill="none" stroke="#FACD1E" stroke-width="2"/>
                    <text x="30" y="40" text-anchor="middle" fill="#FFF5E6" font-size="16" font-weight="bold">Ε</text>
                  </g>

                  <%!-- Formation label --%>
                  <text x="175" y="30" text-anchor="middle" fill="#FACD1E" font-size="12" font-weight="bold">STARTING PHALANX</text>

                  <%!-- Direction indicator --%>
                  <text x="175" y="110" text-anchor="middle" fill="#9D8C71" font-size="10">All facing North</text>
                </svg>
              </div>

              <div class="space-y-4">
                <div class="p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
                  <h4 class="font-semibold mb-2" style="color: #FACD1E;">Starting Configuration</h4>
                  <ul class="text-sm space-y-1" style="color: #9D8C71;">
                    <li>• All 5 units in a line</li>
                    <li>• All facing enemy (North)</li>
                    <li>• Already in phalanx formation</li>
                    <li>• Maximum side cohesion bonus</li>
                  </ul>
                </div>

                <div class="p-4 rounded-lg" style="background: rgba(250, 205, 30, 0.1); border: 1px solid rgba(250, 205, 30, 0.3);">
                  <div class="flex items-center gap-2 mb-2">
                    <span style="color: #FACD1E;">⚔</span>
                    <span class="font-semibold" style="color: #FACD1E;">Phalanx Active</span>
                  </div>
                  <div class="text-sm" style="color: #9D8C71;">
                    Center units start with +2 formation bonus
                  </div>
                </div>
              </div>
            </div>
          </div>

          <%!-- Action Buttons --%>
          <div class="flex gap-4 justify-end">
            <button class="px-8 py-3 rounded-lg font-semibold transition-all hover:brightness-110"
                    style="background: rgba(157, 140, 113, 0.2); color: #9D8C71; border: 1px solid rgba(157, 140, 113, 0.3);">
              Cancel
            </button>
            <button class="px-8 py-3 rounded-lg font-semibold transition-all hover:brightness-110"
                    style="font-family: 'Cinzel', serif; background: linear-gradient(180deg, #CE8946 0%, #7F5522 100%); color: #FFF5E6; box-shadow: 0 2px 8px rgba(206, 137, 70, 0.3);">
              Begin Battle
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
