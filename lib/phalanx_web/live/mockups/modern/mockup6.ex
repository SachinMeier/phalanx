defmodule PhalanxWeb.Live.Mockups.Modern.Mockup6 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_phase: 3)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-zinc-900 to-slate-900 p-8">
      <div class="max-w-4xl mx-auto space-y-8">
        <div class="text-center space-y-2">
          <h1 class="text-4xl font-bold text-slate-100">Turn Phase Timeline</h1>
          <p class="text-slate-400">Simultaneous resolution process</p>
          <div class="inline-block px-4 py-2 bg-slate-800 rounded-lg border border-slate-700">
            <span class="text-slate-300 font-mono">Turn 3</span>
          </div>
        </div>

        <div class="bg-slate-800/50 rounded-xl p-8 border border-slate-700">
          <div class="space-y-6">
            <%= for {phase, index} <- Enum.with_index(phases(), 1) do %>
              <.phase_step phase={phase} number={index} current={index == @current_phase} completed={index < @current_phase} />
            <% end %>
          </div>
        </div>

        <div class="flex justify-center gap-8 text-sm">
          <div class="flex items-center gap-2">
            <div class="w-3 h-3 rounded-full bg-emerald-500"></div>
            <span class="text-slate-400">Completed</span>
          </div>
          <div class="flex items-center gap-2">
            <div class="w-3 h-3 rounded-full bg-amber-500"></div>
            <span class="text-slate-400">Current</span>
          </div>
          <div class="flex items-center gap-2">
            <div class="w-3 h-3 rounded-full bg-slate-600"></div>
            <span class="text-slate-400">Pending</span>
          </div>
        </div>

        <div class="text-center">
          <a href={~p"/mockups/modern"} class="inline-flex items-center gap-2 text-slate-400 hover:text-slate-300 transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            Back to Mockups
          </a>
        </div>
      </div>
    </div>
    """
  end

  defp phase_step(assigns) do
    ~H"""
    <div class="flex items-start gap-4">
      <div class="flex flex-col items-center">
        <div class={[
          "w-10 h-10 rounded-full flex items-center justify-center font-bold transition-all",
          @completed && "bg-emerald-500 text-white",
          @current && "bg-amber-500 text-white ring-4 ring-amber-500/30",
          !@completed && !@current && "bg-slate-700 text-slate-500"
        ]}>
          <%= if @completed do %>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
          <% else %>
            <span class="font-mono text-sm"><%= roman_numeral(@number) %></span>
          <% end %>
        </div>
        <%= if @number < 9 do %>
          <div class={["w-0.5 h-12 mt-1", @completed && "bg-emerald-500/30", @current && "bg-amber-500/30", !@completed && !@current && "bg-slate-700"]}></div>
        <% end %>
      </div>

      <div class={["flex-1 pb-4 transition-all", @current && "transform scale-105"]}>
        <div class={[
          "rounded-lg p-4 border transition-all",
          @completed && "bg-slate-800/30 border-emerald-500/30",
          @current && "bg-amber-500/10 border-amber-500 shadow-lg shadow-amber-500/20",
          !@completed && !@current && "bg-slate-800/30 border-slate-700"
        ]}>
          <div class="flex items-center gap-3 mb-2">
            <div class={["text-2xl", @current && "grayscale-0", !@current && "grayscale opacity-60"]}><%= @phase.icon %></div>
            <h3 class={["text-lg font-semibold", @completed && "text-emerald-400", @current && "text-amber-400", !@completed && !@current && "text-slate-500"]}><%= @phase.name %></h3>
          </div>
          <p class={["text-sm leading-relaxed", @current && "text-slate-300", !@current && "text-slate-500"]}><%= @phase.description %></p>
        </div>
      </div>
    </div>
    """
  end

  defp phases do
    [
      %{name: "Order Collection", icon: "📝", description: "Both players submit movement, rotation, and combat orders for their units."},
      %{name: "Phalanx Detection", icon: "🛡️", description: "Formations identified based on side cohesion (adjacent + same facing) and depth (units behind)."},
      %{name: "Conflict Detection", icon: "⚔️", description: "Identify contested hexes where multiple units attempt to move to the same position."},
      %{name: "Strength Calculation", icon: "💪", description: "Calculate effective strength considering formation bonuses, support, and attack angle."},
      %{name: "Combat Resolution", icon: "🎯", description: "Determine winners of contested hexes. Strongest unit claims position, others balk or retreat."},
      %{name: "Movement Execution", icon: "🚶", description: "Winning units move to their target hexes. Balked units remain in place."},
      %{name: "Damage & Retreat", icon: "💔", description: "HP reduced for losing combatants. Dislodged units retreat to valid adjacent hexes."},
      %{name: "Rotation", icon: "🔄", description: "Facing changes applied to all units that issued rotation orders."},
      %{name: "Energy Update", icon: "⚡", description: "Energy costs deducted for actions. Stationary units recover energy."}
    ]
  end

  defp roman_numeral(n) do
    case n do
      1 -> "I"
      2 -> "II"
      3 -> "III"
      4 -> "IV"
      5 -> "V"
      6 -> "VI"
      7 -> "VII"
      8 -> "VIII"
      9 -> "IX"
      _ -> to_string(n)
    end
  end
end
