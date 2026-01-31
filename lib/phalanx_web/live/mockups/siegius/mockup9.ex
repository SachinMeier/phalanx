defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup9 do
  @moduledoc "Strength Calculation - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="Strength" />

        <div class="grid grid-cols-2 gap-6 mb-8">
          <.scroll_panel title="Attacker — Red Unit A">
            <div class="flex items-center gap-4 mb-6">
              <svg viewBox="0 0 100 115.47" width="55" height="64">
                <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#8b0000" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
                <polyline points="15,35.21 50,15 85,35.21" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" fill="none" />
                <polyline points="25,39.44 50,25 75,39.44" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" fill="none" />
                <polyline points="35,43.66 50,35 65,43.66" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" fill="none" />
                <text x="50" y="78" text-anchor="middle" fill="#fff8e7" font-size="24" font-weight="bold">A</text>
              </svg>
              <div>
                <div class="font-bold text-lg" style="color: #c94040;">Attacker</div>
                <div class="text-sm" style="color: #a08060;">Attacking from flank</div>
              </div>
            </div>

            <div class="space-y-2">
              <.calc_line label="Base Strength" value="+3" />
              <.calc_line label="Health Bonus" value="+2" note="(3 HP)" />
              <.calc_line label="Side Cohesion" value="+2" note="(2 allies)" />
              <.calc_line label="Depth Push" value="+1" note="(1 behind)" />
              <.calc_line label="Flank Bonus" value="+2" note="(side attack)" highlight={true} />
              <div class="h-px my-2" style="background: #8b6914;"></div>
              <.calc_line label="Total Strength" value="10" total={true} />
            </div>
          </.scroll_panel>

          <.scroll_panel title="Defender — Purple Unit X">
            <div class="flex items-center gap-4 mb-6">
              <svg viewBox="0 0 100 115.47" width="55" height="64" style="transform: rotate(90deg);">
                <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="#4a1259" stroke="#ff4444" stroke-width="3" style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));" />
                <polyline points="15,35.21 50,15 85,35.21" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" fill="none" />
                <polyline points="25,39.44 50,25 75,39.44" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" fill="none" />
                <text x="50" y="78" text-anchor="middle" fill="#fff8e7" font-size="24" font-weight="bold" transform="rotate(-90, 50, 78)">X</text>
              </svg>
              <div>
                <div class="font-bold text-lg" style="color: #7a5090;">Defender</div>
                <div class="text-sm" style="color: #a08060;">Exposed flank</div>
              </div>
            </div>

            <div class="space-y-2">
              <.calc_line label="Base Defense" value="+3" />
              <.calc_line label="Health Bonus" value="+1" note="(2 HP)" />
              <.calc_line label="Shield Wall" value="+0" note="(flanked)" muted={true} />
              <.calc_line label="Depth Brace" value="+1" note="(1 behind)" />
              <.calc_line label="Terrain" value="+0" note="(open)" muted={true} />
              <div class="h-px my-2" style="background: #8b6914;"></div>
              <.calc_line label="Total Defense" value="5" total={true} />
            </div>
          </.scroll_panel>
        </div>

        <.scroll_panel title="Combat Resolution">
          <div class="flex items-center justify-center gap-6 py-6">
            <div class="text-center">
              <div class="text-sm mb-2" style="color: #c94040;">Attacker</div>
              <div class="w-16 h-16 rounded flex items-center justify-center text-2xl font-bold" style="background: #8b0000; color: #fff8e7; font-family: 'Cinzel', serif;">
                10
              </div>
            </div>

            <div class="flex flex-col items-center">
              <span class="text-xl font-bold" style="color: #8b6914;">VS</span>
              <svg viewBox="0 0 80 24" width="80" height="24" class="mt-2">
                <polygon points="0,12 20,4 20,10 60,10 60,4 80,12 60,20 60,14 20,14 20,20" fill="#ffd700" />
              </svg>
            </div>

            <div class="text-center">
              <div class="text-sm mb-2" style="color: #7a5090;">Defender</div>
              <div class="w-16 h-16 rounded flex items-center justify-center text-2xl font-bold" style="background: #4a1259; color: #fff8e7; font-family: 'Cinzel', serif;">
                5
              </div>
            </div>

            <div class="text-center">
              <div class="text-sm mb-2" style="color: #6b4423;">Difference</div>
              <div class="w-16 h-16 rounded flex items-center justify-center text-xl font-bold" style="background: #22c55e; color: white; font-family: 'Cinzel', serif;">
                +5
              </div>
            </div>
          </div>

          <div class="p-4 rounded text-center" style="background: rgba(255, 100, 100, 0.2);">
            <span class="font-bold" style="color: #ff4444;">Attacker wins by 5 — Defender takes 2 damage + retreats</span>
          </div>
        </.scroll_panel>

        <.scroll_panel title="Damage Table">
          <div class="grid grid-cols-4 gap-4">
            <.damage_box range="0–2" damage="0" result="Tie" color="#666" />
            <.damage_box range="3–4" damage="1" result="Push" color="#eab308" />
            <.damage_box range="5–7" damage="2" result="Wound" color="#f97316" />
            <.damage_box range="8+" damage="3" result="Rout" color="#ef4444" />
          </div>
          <div class="mt-4 p-2 rounded text-center" style="background: rgba(61, 40, 23, 0.3);">
            <span class="text-sm" style="color: #a08060;">Current: Difference 5 = 2 damage + retreat</span>
          </div>
        </.scroll_panel>
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
          <h2 class="text-lg font-semibold mb-4" style="color: #3d2817; font-family: 'Cinzel', serif; border-bottom: 1px solid #8b6914; padding-bottom: 8px;">
            {@title}
          </h2>
          {render_slot(@inner_block)}
        </div>
        <div class="absolute -bottom-3 left-8 right-8 h-5 rounded-b-lg" style="background: linear-gradient(90deg, #6b4423, #8b6914, #6b4423);"></div>
      </div>
    </div>
    """
  end

  defp calc_line(assigns) do
    assigns = assign_new(assigns, :note, fn -> nil end)
    assigns = assign_new(assigns, :highlight, fn -> false end)
    assigns = assign_new(assigns, :total, fn -> false end)
    assigns = assign_new(assigns, :muted, fn -> false end)

    ~H"""
    <div class={"flex items-center justify-between p-2 rounded #{if @highlight, do: "border-l-4", else: ""}"} style={"background: #{if @total, do: "rgba(139, 105, 20, 0.3)", else: "rgba(61, 40, 23, 0.15)"}; border-color: #ffd700;"}>
      <div class="flex items-center gap-2">
        <span class={"#{if @total, do: "font-bold", else: ""} #{if @muted, do: "opacity-50", else: ""}"} style={"color: #{if @total, do: "#3d2817", else: "#6b4423"};"}>{@label}</span>
        <span :if={@note} class="text-xs" style="color: #a08060;">{@note}</span>
      </div>
      <span class={"font-bold #{if @muted, do: "opacity-50", else: ""}"} style={"color: #{if @total, do: "#8b6914", else: "#3d2817"}; font-size: #{if @total, do: "18px", else: "14px"};"}>{@value}</span>
    </div>
    """
  end

  defp damage_box(assigns) do
    ~H"""
    <div class="p-4 rounded text-center" style="background: rgba(61, 40, 23, 0.3);">
      <div class="font-bold mb-1" style={"color: #{@color};"}>{@range}</div>
      <div class="text-xl font-bold mb-1" style="color: #e8d4b8;">{@damage} dmg</div>
      <div class="text-xs" style="color: #a08060;">{@result}</div>
    </div>
    """
  end
end
