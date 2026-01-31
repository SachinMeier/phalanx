defmodule PhalanxWeb.Live.Mockups.Ancient.Hub do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-8">
        <div class="flex items-center justify-between">
          <.header>
            <span style="font-family: 'Cinzel', serif;">Ancient Theme Mockups</span>
            <:subtitle>Parchment, bronze, and the commander's sand table</:subtitle>
          </.header>
          <.link navigate={~p"/mockups"} class="btn btn-ghost">← All Themes</.link>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <.mockup_card
            number={1}
            title="Unit Health & Energy"
            description="Units at different health levels and energy states"
          />
          <.mockup_card
            number={2}
            title="Phalanx Formations"
            description="Formation bonds, side cohesion, depth indicators"
          />
          <.mockup_card
            number={3}
            title="Combat Resolution"
            description="Attack angles, strength comparison, damage display"
          />
          <.mockup_card
            number={4}
            title="Movement & Orders"
            description="Valid moves, order previews, hotkey overlay"
          />
          <.mockup_card
            number={5}
            title="Retreat & Dislodgement"
            description="Retreat arrows, blocked hexes, cascade effects"
          />
          <.mockup_card
            number={6}
            title="Turn Phase Timeline"
            description="Resolution phases, step indicator, progress display"
          />
          <.mockup_card
            number={7}
            title="Order List & Submission"
            description="Pending orders panel, ready state, waiting state"
          />
          <.mockup_card
            number={8}
            title="Full Battle Scene"
            description="Mid-game battle with multiple formations clashing"
          />
          <.mockup_card
            number={9}
            title="Strength Calculation"
            description="Detailed breakdown tooltip, attacker vs defender"
          />
          <.mockup_card
            number={10}
            title="Game Setup"
            description="Team selection, unit naming, initial formation"
          />
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp mockup_card(assigns) do
    ~H"""
    <a
      href={~p"/mockups/ancient/#{@number}"}
      class="card hover:shadow-lg transition-all cursor-pointer border-2 border-stone-300 hover:border-amber-600"
      style="background: linear-gradient(135deg, #FFF5E6 0%, #E5DBB7 100%);"
    >
      <div class="card-body">
        <div class="flex items-center gap-3">
          <span class="badge badge-lg font-mono text-white" style="background: #CE8946; border-color: #CE8946;">{@number}</span>
          <h2 class="card-title text-lg" style="color: #603C18; font-family: 'Cinzel', serif;">{@title}</h2>
        </div>
        <p class="text-sm" style="color: #9D8C71;">{@description}</p>
      </div>
    </a>
    """
  end
end
