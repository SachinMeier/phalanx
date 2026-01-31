defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup3 do
  @moduledoc "Combat Resolution - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="Combat" />

        <div class="grid grid-cols-2 gap-6 mb-8">
          <.scroll_panel title="Frontal Assault">
            <p class="text-sm mb-4" style="color: #6b4423;">Shields deflect — reduced damage</p>
            <div class="flex items-center justify-center gap-6 py-4">
              <.combat_unit name="A" team="red" label="STR: 5" />
              <.attack_arrow direction="front" />
              <.combat_unit name="X" team="purple" label="DEF: 6" />
            </div>
            <.result_banner type="neutral">Attacker bounces — no damage</.result_banner>
          </.scroll_panel>

          <.scroll_panel title="Flank Attack">
            <p class="text-sm mb-4" style="color: #6b4423;">Exposed side — bonus damage</p>
            <div class="flex items-center justify-center gap-6 py-4">
              <.combat_unit name="B" team="red" label="STR: 5" />
              <.attack_arrow direction="flank" />
              <.combat_unit name="Y" team="purple" rotation={90} label="DEF: 3" hit={true} />
            </div>
            <.result_banner type="damage">Flank hit! 4 damage dealt</.result_banner>
          </.scroll_panel>
        </div>

        <.scroll_panel title="Rear Attack">
          <p class="text-sm mb-4" style="color: #6b4423;">Devastating — maximum damage multiplier</p>
          <div class="flex items-center justify-center gap-8 py-6">
            <.combat_unit name="C" team="red" label="STR: 4" attacking={true} />
            <.attack_arrow direction="rear" />
            <.combat_unit name="Z" team="purple" rotation={180} label="DEF: 1" critical={true} />
          </div>
          <.result_banner type="critical">Critical hit! Unit destroyed!</.result_banner>
        </.scroll_panel>

        <.scroll_panel title="Attack Angle Reference">
          <div class="grid grid-cols-3 gap-4">
            <.angle_card angle="Front" multiplier="×1.0" desc="Shields absorb impact" color="#22c55e" />
            <.angle_card angle="Flank" multiplier="×1.5" desc="Side is exposed" color="#eab308" />
            <.angle_card angle="Rear" multiplier="×2.0" desc="Completely undefended" color="#ef4444" />
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

  defp combat_unit(assigns) do
    assigns = assign_new(assigns, :rotation, fn -> 0 end)
    assigns = assign_new(assigns, :attacking, fn -> false end)
    assigns = assign_new(assigns, :hit, fn -> false end)
    assigns = assign_new(assigns, :critical, fn -> false end)

    team_colors = %{"red" => "#8b0000", "purple" => "#4a1259"}
    assigns = assign(assigns, :color, team_colors[assigns.team])

    ~H"""
    <div class="text-center">
      <div class={"relative #{if @critical, do: "animate-pulse"}"}>
        <div :if={@attacking} class="absolute -top-2 -right-2 w-5 h-5 rounded-full flex items-center justify-center text-white text-xs font-bold" style="background: #ff6600;">!</div>

        <svg viewBox="0 0 100 115.47" width="60" height="69" style={"transform: rotate(#{@rotation}deg); #{if @critical, do: "opacity: 0.5;", else: ""}"}>
          <polygon
            points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
            fill={@color}
            stroke={if @hit || @critical, do: "#ff4444", else: "none"}
            stroke-width="3"
            style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));"
          />
          <polyline points="15,35.21 50,15 85,35.21" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
          <polyline points="25,39.44 50,25 75,39.44" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
          <polyline points="35,43.66 50,35 65,43.66" stroke="#fff8e7" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none" />
          <text x="50" y="78" text-anchor="middle" dominant-baseline="middle"
                fill="#fff8e7" font-size="24" font-weight="bold"
                transform={"rotate(#{-@rotation}, 50, 78)"}>
            {@name}
          </text>
        </svg>

        <div :if={@hit && !@critical} class="absolute inset-0 flex items-center justify-center">
          <span class="text-lg font-bold" style="color: #ff4444; text-shadow: 0 1px 2px rgba(0,0,0,0.5);">-1</span>
        </div>
        <div :if={@critical} class="absolute inset-0 flex items-center justify-center">
          <span class="text-sm font-bold" style="color: #ff4444;">DEAD</span>
        </div>
      </div>
      <div class="mt-2 text-sm font-semibold" style={"color: #{if @team == "red", do: "#c94040", else: "#7a5090"};"}>{@label}</div>
    </div>
    """
  end

  defp attack_arrow(assigns) do
    color = case assigns.direction do
      "front" -> "#22c55e"
      "flank" -> "#eab308"
      "rear" -> "#ef4444"
      _ -> "#a08060"
    end

    label = case assigns.direction do
      "front" -> "FRONT"
      "flank" -> "+2 FLANK"
      "rear" -> "+4 REAR"
      _ -> ""
    end

    assigns = assign(assigns, :color, color)
    assigns = assign(assigns, :label, label)

    ~H"""
    <div class="flex flex-col items-center">
      <svg viewBox="0 0 60 24" width="60" height="24">
        <polygon points="0,12 20,4 20,9 45,9 45,4 60,12 45,20 45,15 20,15 20,20" fill={@color} />
      </svg>
      <span class="text-xs font-semibold mt-1" style={"color: #{@color};"}>{@label}</span>
    </div>
    """
  end

  defp result_banner(assigns) do
    bg = case assigns.type do
      "neutral" -> "rgba(61, 40, 23, 0.3)"
      "damage" -> "rgba(255, 200, 200, 0.3)"
      "critical" -> "rgba(255, 100, 100, 0.4)"
      _ -> "rgba(61, 40, 23, 0.3)"
    end

    text_color = case assigns.type do
      "neutral" -> "#a08060"
      "damage" -> "#aa4444"
      "critical" -> "#ff4444"
      _ -> "#a08060"
    end

    assigns = assign(assigns, :bg, bg)
    assigns = assign(assigns, :text_color, text_color)

    ~H"""
    <div class="mt-4 p-3 rounded text-center" style={"background: #{@bg};"}>
      <span class="font-semibold" style={"color: #{@text_color};"}>{render_slot(@inner_block)}</span>
    </div>
    """
  end

  defp angle_card(assigns) do
    ~H"""
    <div class="p-4 rounded text-center" style="background: rgba(61, 40, 23, 0.3);">
      <div class="text-lg font-bold mb-1" style={"color: #{@color};"}>{@angle}</div>
      <div class="text-xl font-bold mb-2" style="color: #e8d4b8;">{@multiplier}</div>
      <div class="text-xs" style="color: #a08060;">{@desc}</div>
    </div>
    """
  end
end
