defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup1 do
  @moduledoc "Unit Health & Energy States - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="Unit Status" />

        <.scroll_panel title="Health States">
          <div class="grid grid-cols-4 gap-6">
            <.unit_display name="A" team="red" health={3} energy={3} label="Healthy" desc="Full strength, all ranks ready" />
            <.unit_display name="B" team="red" health={2} energy={3} label="Damaged" desc="One rank fallen" />
            <.unit_display name="C" team="red" health={1} energy={3} label="Critical" desc="Last stand" />
            <.unit_display name="D" team="gray" health={0} energy={0} label="Fallen" desc="Unit destroyed" dead={true} />
          </div>
        </.scroll_panel>

        <.scroll_panel title="Energy States">
          <div class="grid grid-cols-4 gap-6">
            <.unit_display name="E" team="purple" health={3} energy={3} label="Fresh" desc="Full movement available" />
            <.unit_display name="F" team="purple" health={3} energy={2} label="Winded" desc="Limited actions" />
            <.unit_display name="G" team="purple" health={3} energy={1} label="Tired" desc="Nearly spent" />
            <.unit_display name="H" team="purple" health={3} energy={0} label="Exhausted" desc="Cannot act" exhausted={true} />
          </div>
        </.scroll_panel>

        <.scroll_panel title="Combined States">
          <div class="grid grid-cols-4 gap-6">
            <.unit_display name="I" team="red" health={2} energy={1} label="Wounded" desc="2 HP, 1 Energy" />
            <.unit_display name="J" team="purple" health={1} energy={2} label="Battered" desc="1 HP, 2 Energy" />
            <.unit_display name="K" team="red" health={1} energy={1} label="Desperate" desc="1 HP, 1 Energy" />
            <.unit_display name="L" team="purple" health={1} energy={0} label="Doomed" desc="1 HP, 0 Energy" exhausted={true} />
          </div>
        </.scroll_panel>

        <.info_scroll>
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div class="flex items-center gap-3">
              <span style="color: #ffd700;">▲▲▲</span>
              <span><strong>Chevrons</strong> — Ranks of fighters (health)</span>
            </div>
            <div class="flex items-center gap-3">
              <span style="color: #ffd700;">●●●</span>
              <span><strong>Pips</strong> — Energy for movement</span>
            </div>
            <div class="flex items-center gap-3">
              <span style="color: #ff4444;">⚠</span>
              <span><strong>Red glow</strong> — Exhaustion warning</span>
            </div>
            <div class="flex items-center gap-3">
              <span style="color: #666;">✕</span>
              <span><strong>Crossed</strong> — Unit destroyed</span>
            </div>
          </div>
        </.info_scroll>
      </div>
    </div>
    """
  end

  defp nav_header(assigns) do
    ~H"""
    <div class="mb-8 flex items-center justify-between">
      <.link navigate={~p"/mockups/siegius"} class="text-amber-600 hover:text-amber-400 text-sm transition-colors">
        ← Back to Mockups
      </.link>
      <h1 class="text-2xl font-bold" style="color: #e8d4b8; font-family: 'Cinzel', serif;">
        {@title}
      </h1>
      <div class="w-24"></div>
    </div>
    """
  end

  defp scroll_panel(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="relative">
        <div class="absolute -top-3 left-8 right-8 h-5 rounded-t-lg" style="background: linear-gradient(90deg, #6b4423, #8b6914, #6b4423);"></div>
        <div class="pt-4 pb-6 px-6 rounded" style="background: linear-gradient(180deg, #e8d4b8 0%, #ddd0ba 100%); border: 2px solid #8b6914;">
          <h2 class="text-lg font-semibold mb-6" style="color: #3d2817; font-family: 'Cinzel', serif; border-bottom: 1px solid #8b6914; padding-bottom: 8px;">
            {@title}
          </h2>
          {render_slot(@inner_block)}
        </div>
        <div class="absolute -bottom-3 left-8 right-8 h-5 rounded-b-lg" style="background: linear-gradient(90deg, #6b4423, #8b6914, #6b4423);"></div>
      </div>
    </div>
    """
  end

  defp info_scroll(assigns) do
    ~H"""
    <div class="mt-12 px-6 py-4 rounded" style="background: rgba(232, 212, 184, 0.1); border: 1px solid rgba(139, 105, 20, 0.4);">
      <div style="color: #c9b99d;">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp unit_display(assigns) do
    assigns = assign_new(assigns, :dead, fn -> false end)
    assigns = assign_new(assigns, :exhausted, fn -> false end)

    team_colors = %{"red" => "#8b0000", "purple" => "#4a1259", "gray" => "#4a4a4a"}
    assigns = assign(assigns, :color, team_colors[assigns.team])

    ~H"""
    <div class="flex flex-col items-center p-4 rounded" style="background: rgba(61, 40, 23, 0.3);">
      <div class={"relative #{if @exhausted, do: "animate-pulse"}"}>
        <div :if={@exhausted && !@dead} class="absolute inset-0 flex items-center justify-center">
          <div class="absolute w-20 h-20 rounded-full blur-xl" style="background: rgba(255, 68, 68, 0.3);"></div>
        </div>

        <svg viewBox="0 0 100 115.47" width="70" height="81" class="relative z-10">
          <polygon
            points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
            fill={@color}
            opacity={if @dead, do: "0.3", else: "1"}
            style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.4));"
          />

          <polyline :if={@health > 0 && !@dead}
            points="15,35.21 50,15 85,35.21"
            stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"
          />
          <polyline :if={@health > 1 && !@dead}
            points="25,39.44 50,25 75,39.44"
            stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"
          />
          <polyline :if={@health > 2 && !@dead}
            points="35,43.66 50,35 65,43.66"
            stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"
          />

          <path :if={@dead} d="M 25,35 L 75,80" stroke="#aa0000" stroke-width="5" fill="none" stroke-linecap="round" />
          <path :if={@dead} d="M 75,35 L 25,80" stroke="#aa0000" stroke-width="5" fill="none" stroke-linecap="round" />

          <text x="50" y="78" text-anchor="middle" dominant-baseline="middle"
                fill={if @dead, do: "#666", else: "#fff8e7"}
                font-size="24" font-weight="bold" style="font-family: 'Cinzel', serif;">
            {@name}
          </text>
        </svg>

        <div class="flex justify-center gap-1.5 mt-2">
          <%= for i <- 1..3 do %>
            <div class={"w-2.5 h-2.5 rounded-full #{pip_class(i, @energy, @exhausted, @dead)}"}></div>
          <% end %>
        </div>

        <div :if={@exhausted && !@dead} class="text-center mt-1">
          <span class="text-xs font-bold" style="color: #ff4444;">EXHAUSTED</span>
        </div>
      </div>

      <div class="mt-3 text-center">
        <div class="font-semibold" style={"color: #{if @dead, do: "#666", else: "#e8d4b8"}; font-family: 'Cinzel', serif;"}>
          {@label}
        </div>
        <div class="text-xs mt-1" style="color: #a08060;">{@desc}</div>
      </div>
    </div>
    """
  end

  defp pip_class(i, energy, exhausted, dead) do
    cond do
      dead -> "bg-stone-600"
      i <= energy && exhausted -> "bg-red-500"
      i <= energy -> "bg-amber-400"
      true -> "bg-stone-600"
    end
  end
end
