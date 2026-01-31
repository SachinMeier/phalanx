defmodule PhalanxWeb.Live.Mockups.Pixel.Mockup6 do
  @moduledoc "Turn Phase Timeline - Pixel Art Style"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      @import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap');
      .pixel-font { font-family: 'Press Start 2P', monospace; }
      .pixel-border { border: 4px solid #5c4033; box-shadow: inset 0 0 0 2px #d4a574, inset 0 0 0 4px #8b6914; }
      .pixel-shadow { box-shadow: 4px 4px 0 #1a0f08; }
      .parchment { background: #e8d4b8; }
      @keyframes phase-pulse { 0%, 100% { box-shadow: 0 0 0 0 rgba(255, 215, 0, 0.7); } 50% { box-shadow: 0 0 0 8px rgba(255, 215, 0, 0); } }
      .phase-active { animation: phase-pulse 1.5s infinite; }
    </style>
    <div class="min-h-screen p-6" style="background-color: #2a1810; image-rendering: pixelated;">
      <div class="max-w-5xl mx-auto">
        <.nav_header title="TURN PHASES" />

        <div class="pixel-border pixel-shadow parchment p-6 mb-8">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">CURRENT TURN: 5</h2>

          <div class="flex items-center justify-between gap-2">
            <.phase_box number={1} name="ORDERS" status="complete" />
            <.phase_arrow />
            <.phase_box number={2} name="MOVEMENT" status="complete" />
            <.phase_arrow />
            <.phase_box number={3} name="COMBAT" status="active" />
            <.phase_arrow />
            <.phase_box number={4} name="RETREAT" status="pending" />
            <.phase_arrow />
            <.phase_box number={5} name="CLEANUP" status="pending" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-6 mb-8">
          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">PHASE 1: ORDERS</h2>
            <div class="space-y-3">
              <.phase_detail icon="pencil" text="BOTH PLAYERS GIVE ORDERS" />
              <.phase_detail icon="clock" text="SIMULTANEOUS PLANNING" />
              <.phase_detail icon="eye" text="ORDERS HIDDEN UNTIL SUBMIT" />
            </div>
            <div class="mt-4 p-2 text-center" style="background-color: #cce5cc;">
              <span class="pixel-font text-green-800" style="font-size: 7px;">PRESS ENTER TO SUBMIT</span>
            </div>
          </div>

          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">PHASE 2: MOVEMENT</h2>
            <div class="space-y-3">
              <.phase_detail icon="arrow" text="ALL MOVES EXECUTE AT ONCE" />
              <.phase_detail icon="block" text="COLLISIONS RESOLVED" />
              <.phase_detail icon="rotate" text="ROTATIONS APPLIED" />
            </div>
            <div class="mt-4 p-2 text-center" style="background-color: #cce5ff;">
              <span class="pixel-font text-blue-800" style="font-size: 7px;">AUTOMATIC - NO INPUT</span>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-3 gap-6 mb-8">
          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">PHASE 3: COMBAT</h2>
            <div class="space-y-2">
              <.phase_detail icon="sword" text="CALCULATE STRENGTH" />
              <.phase_detail icon="shield" text="APPLY DAMAGE" />
            </div>
          </div>

          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">PHASE 4: RETREAT</h2>
            <div class="space-y-2">
              <.phase_detail icon="flee" text="LOSERS PUSHED BACK" />
              <.phase_detail icon="chain" text="CASCADES RESOLVED" />
            </div>
          </div>

          <div class="pixel-border pixel-shadow parchment p-6">
            <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">PHASE 5: CLEANUP</h2>
            <div class="space-y-2">
              <.phase_detail icon="skull" text="REMOVE DEAD UNITS" />
              <.phase_detail icon="check" text="CHECK WIN CONDITION" />
            </div>
          </div>
        </div>

        <div class="pixel-border pixel-shadow parchment p-6">
          <h2 class="pixel-font text-stone-800 mb-4" style="font-size: 10px;">TURN HISTORY</h2>

          <div class="space-y-2">
            <.turn_log turn={5} events={["Red A attacks Purple X", "Purple X takes 2 damage", "Combat phase..."]} current={true} />
            <.turn_log turn={4} events={["Red moves NE", "Purple holds position", "No combat"]} />
            <.turn_log turn={3} events={["Both sides maneuver", "Formations established"]} />
            <.turn_log turn={2} events={["Initial advance"]} />
            <.turn_log turn={1} events={["Battle begins"]} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp nav_header(assigns) do
    ~H"""
    <div class="mb-6 flex items-center justify-between">
      <.link navigate={~p"/mockups/pixel"} class="pixel-font text-amber-200 hover:text-amber-100" style="font-size: 8px;">
        &lt; BACK
      </.link>
      <h1 class="pixel-font text-amber-100" style="font-size: 14px; text-shadow: 2px 2px 0 #1a0f08;">
        {@title}
      </h1>
      <div style="width: 60px;"></div>
    </div>
    """
  end

  defp phase_box(assigns) do
    bg_color = case assigns.status do
      "complete" -> "#228b22"
      "active" -> "#ffd700"
      "pending" -> "#666666"
    end

    text_color = case assigns.status do
      "active" -> "#1a0f08"
      _ -> "#f5f5dc"
    end

    assigns = assign(assigns, :bg_color, bg_color)
    assigns = assign(assigns, :text_color, text_color)

    ~H"""
    <div class={"flex flex-col items-center #{if @status == "active", do: "phase-active"}"}>
      <div class="pixel-border w-12 h-12 flex items-center justify-center" style={"background-color: #{@bg_color};"}>
        <span class="pixel-font" style={"font-size: 12px; color: #{@text_color};"}>{@number}</span>
      </div>
      <span class="pixel-font text-stone-700 mt-2" style="font-size: 6px;">{@name}</span>
    </div>
    """
  end

  defp phase_arrow(assigns) do
    ~H"""
    <svg viewBox="0 0 20 10" width="20" height="10" style="image-rendering: pixelated;">
      <polygon points="0,5 10,0 10,3 20,3 20,7 10,7 10,10" fill="#5c4033" />
    </svg>
    """
  end

  defp phase_detail(assigns) do
    icon_map = %{
      "pencil" => "P",
      "clock" => "T",
      "eye" => "E",
      "arrow" => ">",
      "block" => "X",
      "rotate" => "R",
      "sword" => "S",
      "shield" => "D",
      "flee" => "<",
      "chain" => "C",
      "skull" => "*",
      "check" => "V"
    }

    assigns = assign(assigns, :icon_char, icon_map[assigns.icon] || "?")

    ~H"""
    <div class="flex items-center gap-3">
      <div class="w-6 h-6 flex items-center justify-center" style="background-color: #5c4033;">
        <span class="pixel-font text-amber-100" style="font-size: 8px;">{@icon_char}</span>
      </div>
      <span class="pixel-font text-stone-600" style="font-size: 7px;">{@text}</span>
    </div>
    """
  end

  defp turn_log(assigns) do
    assigns = assign_new(assigns, :current, fn -> false end)

    ~H"""
    <div class={"p-3 #{if @current, do: "border-l-4", else: ""}"} style={"background-color: #{if @current, do: "#ffe4b8", else: "#d4c4a8"}; border-color: #ffd700;"}>
      <div class="flex items-center gap-2 mb-1">
        <span class="pixel-font text-stone-800" style="font-size: 8px;">TURN {@turn}</span>
        <span :if={@current} class="pixel-font text-amber-700" style="font-size: 6px;">[CURRENT]</span>
      </div>
      <div class="space-y-1">
        <p :for={event <- @events} class="pixel-font text-stone-600" style="font-size: 6px;">
          > {event}
        </p>
      </div>
    </div>
    """
  end
end
