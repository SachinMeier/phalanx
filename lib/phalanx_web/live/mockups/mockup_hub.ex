defmodule PhalanxWeb.Live.Mockups.MockupHub do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-8">
        <.header>
          Phalanx UI Themes
          <:subtitle>Choose a visual style to explore</:subtitle>
        </.header>

        <div class="grid grid-cols-2 gap-6 max-w-4xl mx-auto">
          <!-- Modern Theme Card -->
          <a href={~p"/mockups/modern"} class="group relative overflow-hidden rounded-xl border-2 border-slate-700 hover:border-amber-500 transition-all duration-300">
            <div class="absolute inset-0 bg-gradient-to-br from-slate-900 via-blue-950 to-slate-900"></div>
            <div class="relative p-6 text-center">
              <div class="text-4xl mb-3">🌃</div>
              <h2 class="text-xl font-bold text-amber-100 mb-2">Modern</h2>
              <p class="text-slate-400 text-xs mb-3">Sleek dark gradients with neon accents</p>
              <div class="flex justify-center gap-2">
                <div class="w-3 h-3 rounded-full bg-red-500"></div>
                <div class="w-3 h-3 rounded-full bg-purple-500"></div>
                <div class="w-3 h-3 rounded-full bg-amber-500"></div>
                <div class="w-3 h-3 rounded-full bg-emerald-500"></div>
              </div>
              <div class="mt-3 text-xs text-slate-500">10 mockups</div>
            </div>
            <div class="absolute inset-0 bg-amber-500/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
          </a>

          <!-- Ancient Theme Card -->
          <a href={~p"/mockups/ancient"} class="group relative overflow-hidden rounded-xl border-2 border-stone-600 hover:border-amber-600 transition-all duration-300">
            <div class="absolute inset-0 bg-gradient-to-br from-amber-50 via-stone-100 to-amber-100"></div>
            <div class="relative p-6 text-center">
              <div class="text-4xl mb-3">🏛️</div>
              <h2 class="text-xl font-bold text-stone-800 mb-2" style="font-family: 'Cinzel', serif;">Ancient</h2>
              <p class="text-stone-600 text-xs mb-3">Parchment & bronze, commander's sand table</p>
              <div class="flex justify-center gap-2">
                <div class="w-3 h-3 rounded-full" style="background: #D32929;"></div>
                <div class="w-3 h-3 rounded-full" style="background: #5D3A8E;"></div>
                <div class="w-3 h-3 rounded-full" style="background: #CE8946;"></div>
                <div class="w-3 h-3 rounded-full" style="background: #FACD1E;"></div>
              </div>
              <div class="mt-3 text-xs text-stone-500">10 mockups</div>
            </div>
            <div class="absolute inset-0 bg-amber-600/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
          </a>

          <!-- Siegius Theme Card -->
          <a href={~p"/mockups/siegius"} class="group relative overflow-hidden rounded-xl border-2 hover:border-amber-400 transition-all duration-300" style="border-color: #8b6914;">
            <div class="absolute inset-0" style="background: #1e1308;"></div>
            <div class="relative p-6 text-center">
              <div class="text-4xl mb-3">⚔️</div>
              <h2 class="text-xl font-bold mb-2" style="font-family: 'Cinzel', serif; color: #e8d4b8;">Siegius</h2>
              <p class="text-xs mb-3" style="color: #a67c1a;">Roman warfare, parchment scrolls</p>
              <div class="flex justify-center gap-2">
                <div class="w-3 h-3 rounded" style="background: #8b0000;"></div>
                <div class="w-3 h-3 rounded" style="background: #4a1259;"></div>
                <div class="w-3 h-3 rounded" style="background: #e8d4b8;"></div>
                <div class="w-3 h-3 rounded" style="background: #ffd700;"></div>
              </div>
              <div class="mt-3 text-xs" style="color: #6b4423;">10 mockups</div>
            </div>
            <div class="absolute inset-0 bg-amber-400/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
          </a>

          <!-- Pixel Art Theme Card -->
          <a href={~p"/mockups/pixel"} class="group relative overflow-hidden rounded-xl border-2 hover:border-amber-400 transition-all duration-300" style="border-color: #5c4033;">
            <div class="absolute inset-0" style="background-color: #2a1810;"></div>
            <div class="relative p-6 text-center">
              <div class="text-4xl mb-3" style="image-rendering: pixelated;">🎮</div>
              <h2 class="text-xl font-bold mb-2" style="font-family: 'Press Start 2P', monospace; color: #d4a574; font-size: 14px;">Pixel</h2>
              <p class="text-xs mb-3" style="color: #8b6914;">Retro pixel art, Game Boy style</p>
              <div class="flex justify-center gap-2">
                <div class="w-3 h-3" style="background: #8b0000;"></div>
                <div class="w-3 h-3" style="background: #4a1259;"></div>
                <div class="w-3 h-3" style="background: #d4a574;"></div>
                <div class="w-3 h-3" style="background: #ffd700;"></div>
              </div>
              <div class="mt-3 text-xs" style="color: #5c4033;">10 mockups</div>
            </div>
            <div class="absolute inset-0 bg-amber-400/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
          </a>
        </div>

        <div class="text-center text-sm text-base-content/60 mt-8">
          <p>Each theme contains 10 mockups exploring different UI states:</p>
          <p class="mt-1">Units, Formations, Combat, Movement, Retreat, Phases, Orders, Battle, Strength, Setup</p>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
