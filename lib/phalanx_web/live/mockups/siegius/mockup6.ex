defmodule PhalanxWeb.Live.Mockups.Siegius.Mockup6 do
  @moduledoc "Turn Phase Timeline - Siegius theme"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen p-6" style="background: #1e1308;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="Turn Phases" />

        <.scroll_panel title="Current Turn: 5">
          <div class="flex items-center justify-between gap-2 py-2">
            <.phase_marker number={1} name="Orders" status="complete" />
            <.phase_connector />
            <.phase_marker number={2} name="Movement" status="complete" />
            <.phase_connector />
            <.phase_marker number={3} name="Combat" status="active" />
            <.phase_connector />
            <.phase_marker number={4} name="Retreat" status="pending" />
            <.phase_connector />
            <.phase_marker number={5} name="Cleanup" status="pending" />
          </div>
        </.scroll_panel>

        <div class="grid grid-cols-2 gap-6 mb-8">
          <.scroll_panel title="Phase 1: Orders">
            <div class="space-y-3">
              <.phase_item icon="✎" text="Both players give orders" />
              <.phase_item icon="⏱" text="Simultaneous planning" />
              <.phase_item icon="👁" text="Orders hidden until submit" />
            </div>
            <div class="mt-4 p-2 rounded text-center" style="background: rgba(34, 197, 94, 0.15);">
              <span class="text-sm" style="color: #22c55e;">Press Enter to submit</span>
            </div>
          </.scroll_panel>

          <.scroll_panel title="Phase 2: Movement">
            <div class="space-y-3">
              <.phase_item icon="→" text="All moves execute at once" />
              <.phase_item icon="⚡" text="Collisions resolved" />
              <.phase_item icon="↻" text="Rotations applied" />
            </div>
            <div class="mt-4 p-2 rounded text-center" style="background: rgba(59, 130, 246, 0.15);">
              <span class="text-sm" style="color: #3b82f6;">Automatic — no input needed</span>
            </div>
          </.scroll_panel>
        </div>

        <div class="grid grid-cols-3 gap-6 mb-8">
          <.scroll_panel title="Phase 3: Combat">
            <div class="space-y-2">
              <.phase_item icon="⚔" text="Calculate strength" small={true} />
              <.phase_item icon="🛡" text="Apply damage" small={true} />
            </div>
          </.scroll_panel>

          <.scroll_panel title="Phase 4: Retreat">
            <div class="space-y-2">
              <.phase_item icon="←" text="Losers pushed back" small={true} />
              <.phase_item icon="⛓" text="Cascades resolved" small={true} />
            </div>
          </.scroll_panel>

          <.scroll_panel title="Phase 5: Cleanup">
            <div class="space-y-2">
              <.phase_item icon="☠" text="Remove dead units" small={true} />
              <.phase_item icon="✓" text="Check win condition" small={true} />
            </div>
          </.scroll_panel>
        </div>

        <.scroll_panel title="Turn History">
          <div class="space-y-2">
            <.turn_entry turn={5} current={true}>
              <li>Red A attacks Purple X</li>
              <li>Purple X takes 2 damage</li>
              <li>Combat phase resolving...</li>
            </.turn_entry>
            <.turn_entry turn={4}>
              <li>Red moves NE</li>
              <li>Purple holds position</li>
              <li>No combat</li>
            </.turn_entry>
            <.turn_entry turn={3}>
              <li>Both sides maneuver</li>
              <li>Formations established</li>
            </.turn_entry>
            <.turn_entry turn={2}>
              <li>Initial advance</li>
            </.turn_entry>
            <.turn_entry turn={1}>
              <li>Battle begins</li>
            </.turn_entry>
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

  defp phase_marker(assigns) do
    {bg, text_color, ring} = case assigns.status do
      "complete" -> {"#22c55e", "#fff", "none"}
      "active" -> {"#ffd700", "#3d2817", "0 0 0 3px rgba(255, 215, 0, 0.4)"}
      "pending" -> {"#666", "#aaa", "none"}
    end

    assigns = assign(assigns, :bg, bg)
    assigns = assign(assigns, :text_color, text_color)
    assigns = assign(assigns, :ring, ring)

    ~H"""
    <div class="flex flex-col items-center">
      <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold" style={"background: #{@bg}; color: #{@text_color}; box-shadow: #{@ring};"}>
        {@number}
      </div>
      <span class="text-xs mt-1" style="color: #6b4423;">{@name}</span>
    </div>
    """
  end

  defp phase_connector(assigns) do
    ~H"""
    <div class="flex-1 h-0.5 mx-1" style="background: linear-gradient(90deg, #8b6914, #a67c1a, #8b6914);"></div>
    """
  end

  defp phase_item(assigns) do
    assigns = assign_new(assigns, :small, fn -> false end)

    ~H"""
    <div class="flex items-center gap-3">
      <span class={"#{if @small, do: "text-base", else: "text-lg"}"}>{@icon}</span>
      <span class={"#{if @small, do: "text-sm", else: ""}"} style="color: #6b4423;">{@text}</span>
    </div>
    """
  end

  defp turn_entry(assigns) do
    assigns = assign_new(assigns, :current, fn -> false end)

    ~H"""
    <div class={"p-3 rounded #{if @current, do: "border-l-4", else: ""}"} style={"background: #{if @current, do: "rgba(255, 215, 0, 0.1)", else: "rgba(61, 40, 23, 0.2)"}; border-color: #ffd700;"}>
      <div class="flex items-center gap-2 mb-1">
        <span class="font-semibold" style="color: #3d2817;">Turn {@turn}</span>
        <span :if={@current} class="text-xs px-2 py-0.5 rounded" style="background: #ffd700; color: #3d2817;">CURRENT</span>
      </div>
      <ul class="text-sm space-y-0.5" style="color: #6b4423;">
        {render_slot(@inner_block)}
      </ul>
    </div>
    """
  end
end
