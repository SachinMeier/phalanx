defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup6 do
  @moduledoc "Ancient theme: Turn Phase Timeline"
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen" style="background: linear-gradient(145deg, #2C2416 0%, #3D3225 50%, #2A2118 100%);">
      <div class="relative z-10 p-8 max-w-7xl mx-auto">
        <%!-- Header --%>
        <div class="mb-12">
          <.link navigate={~p"/mockups/ancient"} class="inline-flex items-center gap-2 text-amber-600 hover:text-amber-400 text-sm mb-6 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
            Back to Ancient Mockups
          </.link>
          <h1 class="text-4xl font-bold mb-3" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Turn Phase Timeline
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            The rhythm of battle — from orders to resolution
          </p>
        </div>

        <%!-- Main Timeline --%>
        <div class="mb-16">
          <div class="flex items-center gap-4 mb-8">
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
            <h2 class="text-2xl font-semibold px-4" style="font-family: 'Cinzel', serif; color: #CE8946;">
              Turn Structure
            </h2>
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
          </div>

          <%!-- Timeline visualization --%>
          <div class="relative">
            <%!-- Timeline line --%>
            <div class="absolute top-12 left-0 right-0 h-1 rounded" style="background: linear-gradient(90deg, #CE8946, #FACD1E, #CE8946);"></div>

            <div class="grid grid-cols-4 gap-4 relative z-10">
              <.phase_card
                number={1}
                title="Order Phase"
                status="active"
                duration="Untimed"
                description="Both players issue orders to their units. Orders are hidden from opponent."
                details={["Select units", "Assign movement", "Queue rotations", "Form phalanxes"]}
              />
              <.phase_card
                number={2}
                title="Submit Phase"
                status="pending"
                duration="Waiting"
                description="Players confirm orders and wait for opponent to submit."
                details={["Review orders", "Lock in decisions", "Wait for opponent", "No changes allowed"]}
              />
              <.phase_card
                number={3}
                title="Resolution Phase"
                status="pending"
                duration="~3 sec"
                description="Orders execute simultaneously. Conflicts resolved by strength."
                details={["Move execution", "Conflict detection", "Strength comparison", "Dislodge & damage"]}
              />
              <.phase_card
                number={4}
                title="Cleanup Phase"
                status="pending"
                duration="~1 sec"
                description="Apply results and prepare for next turn."
                details={["Execute retreats", "Remove destroyed", "Check win condition", "Increment turn"]}
              />
            </div>
          </div>
        </div>

        <%!-- Resolution Pipeline Detail --%>
        <div class="mb-16">
          <div class="flex items-center gap-4 mb-8">
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
            <h2 class="text-2xl font-semibold px-4" style="font-family: 'Cinzel', serif; color: #CE8946;">
              Resolution Pipeline
            </h2>
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
          </div>

          <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <div class="flex flex-wrap items-center justify-center gap-3">
              <.pipeline_step step={1} label="Populate Holds" active={true} />
              <.pipeline_arrow />
              <.pipeline_step step={2} label="Detect Conflicts" active={true} />
              <.pipeline_arrow />
              <.pipeline_step step={3} label="Calculate Strength" active={false} />
              <.pipeline_arrow />
              <.pipeline_step step={4} label="Resolve Dislodge" active={false} />
              <.pipeline_arrow />
              <.pipeline_step step={5} label="Apply Damage" active={false} />
              <.pipeline_arrow />
              <.pipeline_step step={6} label="Execute Retreats" active={false} />
            </div>

            <div class="mt-8 p-4 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <div class="flex items-center gap-3 mb-3">
                <span class="w-8 h-8 rounded-full flex items-center justify-center font-bold" style="background: #22c55e; color: #2C2416;">2</span>
                <span class="font-semibold" style="color: #E5DBB7;">Detect Conflicts</span>
                <span class="text-xs px-2 py-1 rounded" style="background: rgba(34, 197, 94, 0.2); color: #22c55e;">IN PROGRESS</span>
              </div>
              <p class="text-sm" style="color: #9D8C71;">
                Identifying hexes targeted by multiple units. 3 conflicts detected this turn.
              </p>
            </div>
          </div>
        </div>

        <%!-- Turn Counter Examples --%>
        <div class="grid md:grid-cols-3 gap-8 mb-16">
          <div class="rounded-xl p-6 text-center" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <div class="text-6xl font-bold mb-2" style="font-family: 'Cinzel', serif; color: #FACD1E;">
              I
            </div>
            <div class="text-sm" style="color: #9D8C71;">Turn 1</div>
            <div class="text-xs mt-2" style="color: #CE8946;">Opening moves</div>
          </div>

          <div class="rounded-xl p-6 text-center" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <div class="text-6xl font-bold mb-2" style="font-family: 'Cinzel', serif; color: #FACD1E;">
              VII
            </div>
            <div class="text-sm" style="color: #9D8C71;">Turn 7</div>
            <div class="text-xs mt-2" style="color: #CE8946;">Mid-battle</div>
          </div>

          <div class="rounded-xl p-6 text-center" style="background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 1px solid rgba(206,137,70,0.2);">
            <div class="text-6xl font-bold mb-2" style="font-family: 'Cinzel', serif; color: #7F2122;">
              XII
            </div>
            <div class="text-sm" style="color: #9D8C71;">Turn 12</div>
            <div class="text-xs mt-2" style="color: #7F2122;">Decisive moment</div>
          </div>
        </div>

        <%!-- Player Status Indicators --%>
        <div class="rounded-xl p-6" style="background: linear-gradient(135deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.05) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <h3 class="text-xl font-semibold mb-6" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Player Status
          </h3>

          <div class="grid md:grid-cols-2 gap-8">
            <%!-- Player 1 --%>
            <div class="p-4 rounded-lg" style="background: rgba(211, 41, 41, 0.1); border: 1px solid rgba(211, 41, 41, 0.3);">
              <div class="flex items-center justify-between mb-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full flex items-center justify-center" style="background: #D32929;">
                    <span class="text-white font-bold">Λ</span>
                  </div>
                  <div>
                    <div class="font-semibold" style="color: #E5DBB7;">Leonidas</div>
                    <div class="text-xs" style="color: #D32929;">Spartan Legion</div>
                  </div>
                </div>
                <div class="flex items-center gap-2">
                  <span class="w-3 h-3 rounded-full bg-green-500 animate-pulse"></span>
                  <span class="text-sm" style="color: #22c55e;">READY</span>
                </div>
              </div>
              <div class="text-sm" style="color: #9D8C71;">
                5 units remaining • 3 orders queued
              </div>
            </div>

            <%!-- Player 2 --%>
            <div class="p-4 rounded-lg" style="background: rgba(93, 58, 142, 0.1); border: 1px solid rgba(93, 58, 142, 0.3);">
              <div class="flex items-center justify-between mb-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full flex items-center justify-center" style="background: #5D3A8E;">
                    <span class="text-white font-bold">Ξ</span>
                  </div>
                  <div>
                    <div class="font-semibold" style="color: #E5DBB7;">Xerxes</div>
                    <div class="text-xs" style="color: #5D3A8E;">Persian Host</div>
                  </div>
                </div>
                <div class="flex items-center gap-2">
                  <span class="w-3 h-3 rounded-full bg-amber-500 animate-pulse"></span>
                  <span class="text-sm" style="color: #FACD1E;">PLANNING</span>
                </div>
              </div>
              <div class="text-sm" style="color: #9D8C71;">
                4 units remaining • awaiting orders...
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp phase_card(assigns) do
    border_color = case assigns.status do
      "active" -> "#22c55e"
      "complete" -> "#FACD1E"
      _ -> "rgba(206, 137, 70, 0.3)"
    end

    assigns = assign(assigns, :border_color, border_color)

    ~H"""
    <div class="flex flex-col items-center">
      <%!-- Number circle --%>
      <div class={"w-10 h-10 rounded-full flex items-center justify-center font-bold mb-4 " <> if @status == "active", do: "ring-4 ring-green-500/50", else: ""}
           style={"background: #{if @status == "active", do: "#22c55e", else: "#CE8946"}; color: #2C2416;"}>
        <%= @number %>
      </div>

      <%!-- Card --%>
      <div class="rounded-xl p-4 h-full" style={"background: linear-gradient(145deg, rgba(255,245,230,0.06) 0%, rgba(229,219,183,0.03) 100%); border: 2px solid #{@border_color};"}>
        <div class="flex items-center justify-between mb-2">
          <h3 class="font-semibold" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            <%= @title %>
          </h3>
        </div>
        <div class="text-xs mb-3 px-2 py-1 rounded inline-block" style={"background: #{if @status == "active", do: "rgba(34, 197, 94, 0.2)", else: "rgba(157, 140, 113, 0.2)"}; color: #{if @status == "active", do: "#22c55e", else: "#9D8C71"};"}>
          <%= @duration %>
        </div>
        <p class="text-sm mb-3" style="color: #9D8C71;">
          <%= @description %>
        </p>
        <ul class="text-xs space-y-1" style="color: #CE8946;">
          <%= for detail <- @details do %>
            <li class="flex items-center gap-1">
              <span>•</span>
              <span><%= detail %></span>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp pipeline_step(assigns) do
    ~H"""
    <div class={"flex items-center gap-2 px-3 py-2 rounded-lg " <> if @active, do: "ring-2 ring-green-500/50", else: ""}
         style={"background: #{if @active, do: "rgba(34, 197, 94, 0.15)", else: "rgba(206, 137, 70, 0.1)"}; border: 1px solid #{if @active, do: "rgba(34, 197, 94, 0.4)", else: "rgba(206, 137, 70, 0.3)"};"}>
      <span class="w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold"
            style={"background: #{if @active, do: "#22c55e", else: "#CE8946"}; color: #2C2416;"}>
        <%= @step %>
      </span>
      <span class="text-sm" style={"color: #{if @active, do: "#22c55e", else: "#9D8C71"};"}><%= @label %></span>
    </div>
    """
  end

  defp pipeline_arrow(assigns) do
    ~H"""
    <span class="text-xl hidden md:inline" style="color: #CE8946;">→</span>
    """
  end
end
