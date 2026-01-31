defmodule PhalanxWeb.Live.Mockups.Siegius.Hub do
  @moduledoc "Siegius theme hub - Roman war aesthetic with parchment scrolls"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto p-8">
        <div class="mb-6">
          <.link navigate={~p"/mockups"} class="text-amber-600 hover:text-amber-400 text-sm transition-colors">
            ← All Themes
          </.link>
        </div>

        <div class="text-center mb-12">
          <.scroll_banner>
            <h1 class="text-3xl font-bold tracking-wide" style="color: #3d2817; font-family: 'Cinzel', serif;">
              PHALANX
            </h1>
            <p class="text-sm mt-1" style="color: #6b4423;">Siegius Edition</p>
          </.scroll_banner>
        </div>

        <div class="grid grid-cols-2 gap-6">
          <.mockup_link number={1} title="Unit Status" desc="Health and energy states" />
          <.mockup_link number={2} title="Formations" desc="Phalanx bonds and depth" />
          <.mockup_link number={3} title="Combat" desc="Attack angles and damage" />
          <.mockup_link number={4} title="Movement" desc="Valid moves and orders" />
          <.mockup_link number={5} title="Retreat" desc="Dislodgement and cascade" />
          <.mockup_link number={6} title="Turn Phases" desc="Resolution timeline" />
          <.mockup_link number={7} title="Order List" desc="Pending orders panel" />
          <.mockup_link number={8} title="Battle" desc="Full combat scene" />
          <.mockup_link number={9} title="Strength" desc="Force calculation" />
          <.mockup_link number={10} title="Game Setup" desc="Army deployment" />
        </div>

        <div class="mt-12 text-center">
          <.parchment_note>
            Inspired by Siegius • Roman warfare aesthetic • Scroll-styled UI
          </.parchment_note>
        </div>
      </div>
    </div>
    """
  end

  defp scroll_banner(assigns) do
    ~H"""
    <div class="relative inline-block">
      <div class="absolute -left-6 top-0 bottom-0 w-5 rounded-l-full" style="background: linear-gradient(90deg, #8b6914, #a67c1a);"></div>
      <div class="absolute -right-6 top-0 bottom-0 w-5 rounded-r-full" style="background: linear-gradient(270deg, #8b6914, #a67c1a);"></div>
      <div class="px-12 py-6" style="background: linear-gradient(180deg, #e8d4b8 0%, #d4c4a8 50%, #c9b99d 100%); border-top: 3px solid #8b6914; border-bottom: 3px solid #8b6914;">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp mockup_link(assigns) do
    ~H"""
    <a href={~p"/mockups/siegius/#{@number}"} class="group block">
      <div class="relative p-5 rounded transition-all group-hover:-translate-y-1 group-hover:shadow-lg"
           style="background: linear-gradient(180deg, #e8d4b8 0%, #ddd0ba 100%); border: 2px solid #8b6914; box-shadow: 0 3px 0 #5c4033;">
        <div class="absolute top-0 left-0 right-0 h-1" style="background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);"></div>

        <div class="flex items-center gap-4">
          <div class="w-10 h-10 rounded flex items-center justify-center font-bold text-amber-100"
               style="background: linear-gradient(180deg, #8b0000, #6b0000); border: 2px solid #ffd700; font-family: 'Cinzel', serif;">
            {@number}
          </div>
          <div>
            <h2 class="font-semibold" style="color: #3d2817; font-family: 'Cinzel', serif;">{@title}</h2>
            <p class="text-sm" style="color: #6b4423;">{@desc}</p>
          </div>
        </div>

        <div class="absolute bottom-0 left-4 right-4 h-px" style="background: repeating-linear-gradient(90deg, #8b6914 0px, #8b6914 8px, transparent 8px, transparent 16px);"></div>
      </div>
    </a>
    """
  end

  defp parchment_note(assigns) do
    ~H"""
    <div class="inline-block px-6 py-3 rounded" style="background: rgba(232, 212, 184, 0.15); border: 1px solid rgba(139, 105, 20, 0.3);">
      <p class="text-sm" style="color: #a67c1a;">{render_slot(@inner_block)}</p>
    </div>
    """
  end
end
