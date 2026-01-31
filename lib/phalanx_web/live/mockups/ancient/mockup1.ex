defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup1 do
  @moduledoc "Ancient theme: Unit Health & Energy States"
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
            Unit Health & Energy States
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            The lifeblood and vigor of the phalanx — track your warriors' condition
          </p>
        </div>

        <%!-- Health States Section --%>
        <div class="mb-16">
          <div class="flex items-center gap-4 mb-8">
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
            <h2 class="text-2xl font-semibold px-4" style="font-family: 'Cinzel', serif; color: #CE8946;">
              Health States
            </h2>
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
          </div>

          <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
            <.unit_card
              name="Α"
              color="#D32929"
              health={3}
              energy={3}
              label="Full Strength"
              description="All three ranks ready. Shields locked, spears leveled."
            />
            <.unit_card
              name="Β"
              color="#D32929"
              health={2}
              energy={3}
              label="Bloodied"
              description="One rank fallen. The line holds but wavers."
            />
            <.unit_card
              name="Γ"
              color="#D32929"
              health={1}
              energy={3}
              label="Critical"
              description="Final stand. One spear between victory and death."
            />
            <.unit_card
              name="Δ"
              color="#4a4a4a"
              health={0}
              energy={0}
              label="Destroyed"
              description="The unit is no more. Their shields lie scattered."
              dead={true}
            />
          </div>
        </div>

        <%!-- Energy States Section --%>
        <div class="mb-16">
          <div class="flex items-center gap-4 mb-8">
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
            <h2 class="text-2xl font-semibold px-4" style="font-family: 'Cinzel', serif; color: #CE8946;">
              Energy States
            </h2>
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
          </div>

          <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
            <.unit_card
              name="Ε"
              color="#5D3A8E"
              health={3}
              energy={3}
              label="Fresh"
              description="Full vigor. Move freely, wheel sharply."
            />
            <.unit_card
              name="Ζ"
              color="#5D3A8E"
              health={3}
              energy={2}
              label="Winded"
              description="Breath grows short. Actions cost more."
            />
            <.unit_card
              name="Η"
              color="#5D3A8E"
              health={3}
              energy={1}
              label="Fatigued"
              description="Muscles burn. One move left in them."
            />
            <.unit_card
              name="Θ"
              color="#5D3A8E"
              health={3}
              energy={0}
              label="Exhausted"
              description="No strength remains. Vulnerable to collapse."
              exhausted={true}
            />
          </div>
        </div>

        <%!-- Combined States Section --%>
        <div class="mb-16">
          <div class="flex items-center gap-4 mb-8">
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
            <h2 class="text-2xl font-semibold px-4" style="font-family: 'Cinzel', serif; color: #CE8946;">
              Battle-Worn States
            </h2>
            <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, #CE8946, transparent);"></div>
          </div>

          <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
            <.unit_card
              name="Ι"
              color="#D32929"
              health={3}
              energy={1}
              label="Tired but Ready"
              description="Full ranks, empty lungs. Need rest."
            />
            <.unit_card
              name="Κ"
              color="#5D3A8E"
              health={2}
              energy={2}
              label="Evenly Worn"
              description="Balanced degradation. Still effective."
            />
            <.unit_card
              name="Λ"
              color="#D32929"
              health={1}
              energy={1}
              label="Last Gasp"
              description="One rank, one move. Desperate valor."
            />
            <.unit_card
              name="Μ"
              color="#5D3A8E"
              health={1}
              energy={0}
              label="Doomed"
              description="Cannot move. Cannot fight. Only die."
              exhausted={true}
            />
          </div>
        </div>

        <%!-- Design Notes --%>
        <div class="rounded-lg p-6" style="background: linear-gradient(135deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.08) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <h3 class="text-xl font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Reading the Markers
          </h3>
          <div class="grid md:grid-cols-2 gap-4 text-sm" style="color: #9D8C71;">
            <div class="flex items-start gap-3">
              <span style="color: #CE8946;">▲</span>
              <span><strong style="color: #E5DBB7;">Chevrons</strong> — Each chevron is a rank of fighters. Three chevrons means full strength.</span>
            </div>
            <div class="flex items-start gap-3">
              <span style="color: #CE8946;">●</span>
              <span><strong style="color: #E5DBB7;">Energy Pips</strong> — The dots below show remaining vigor for movement.</span>
            </div>
            <div class="flex items-start gap-3">
              <span style="color: #7F2122;">⚠</span>
              <span><strong style="color: #E5DBB7;">Exhaustion</strong> — When pips run out, the unit glows with warning.</span>
            </div>
            <div class="flex items-start gap-3">
              <span style="color: #666;">✕</span>
              <span><strong style="color: #E5DBB7;">Destruction</strong> — Crossed lines mark a fallen unit.</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp unit_card(assigns) do
    assigns = assign_new(assigns, :dead, fn -> false end)
    assigns = assign_new(assigns, :exhausted, fn -> false end)

    ~H"""
    <div class="flex flex-col items-center p-6 rounded-lg transition-all hover:scale-105"
         style={"background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 1px solid #{if @dead, do: "rgba(100,100,100,0.3)", else: "rgba(206,137,70,0.3)"}; box-shadow: inset 0 1px 0 rgba(255,255,255,0.05), 0 4px 20px rgba(0,0,0,0.3);"}>

      <%!-- Unit SVG --%>
      <div class={"relative #{if @exhausted, do: "animate-pulse"}"}>
        <%!-- Exhaustion glow --%>
        <div :if={@exhausted && !@dead} class="absolute inset-0 flex items-center justify-center">
          <div class="absolute w-24 h-24 rounded-full blur-xl" style="background: rgba(127, 33, 34, 0.4);"></div>
        </div>

        <svg viewBox="0 0 100 115.47" width="80" height="92" class="relative z-10">
          <%!-- Hexagon body --%>
          <polygon
            points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
            fill={@color}
            opacity={if @dead, do: "0.25", else: "1"}
            style="filter: drop-shadow(0 2px 4px rgba(0,0,0,0.5));"
          />

          <%!-- Health chevrons --%>
          <polyline :if={@health > 0 && !@dead}
            points="15,35.21 50,15 85,35.21"
            stroke="#FFF5E6"
            stroke-width="4"
            stroke-linecap="round"
            stroke-linejoin="round"
            fill="none"
            opacity="0.9"
          />
          <polyline :if={@health > 1 && !@dead}
            points="25,39.44 50,25 75,39.44"
            stroke="#FFF5E6"
            stroke-width="4"
            stroke-linecap="round"
            stroke-linejoin="round"
            fill="none"
            opacity="0.9"
          />
          <polyline :if={@health > 2 && !@dead}
            points="35,43.66 50,35 65,43.66"
            stroke="#FFF5E6"
            stroke-width="4"
            stroke-linecap="round"
            stroke-linejoin="round"
            fill="none"
            opacity="0.9"
          />

          <%!-- Death X --%>
          <path :if={@dead} d="M 25,35 L 75,80" stroke="#7F2122" stroke-width="5" fill="none" stroke-linecap="round" />
          <path :if={@dead} d="M 75,35 L 25,80" stroke="#7F2122" stroke-width="5" fill="none" stroke-linecap="round" />

          <%!-- Unit name (Greek letter) --%>
          <text
            x="50"
            y="78"
            text-anchor="middle"
            dominant-baseline="middle"
            fill={if @dead, do: "#666", else: "#FFF5E6"}
            font-size="26"
            font-weight="bold"
            style="font-family: 'Cinzel', serif;"
          >
            <%= @name %>
          </text>
        </svg>

        <%!-- Energy pips --%>
        <div class="flex justify-center gap-1.5 mt-3">
          <%= for i <- 1..3 do %>
            <div class={"w-2.5 h-2.5 rounded-full transition-all #{pip_class(i, @energy, @exhausted, @dead)}"}></div>
          <% end %>
        </div>

        <%!-- Exhaustion warning --%>
        <div :if={@exhausted && !@dead} class="text-center mt-2">
          <span class="text-xs font-bold tracking-wider animate-pulse" style="color: #7F2122;">
            EXHAUSTED
          </span>
        </div>
      </div>

      <%!-- Label and description --%>
      <div class="mt-5 text-center">
        <div class="font-semibold mb-1" style={"font-family: 'Cinzel', serif; color: #{if @dead, do: "#666", else: "#E5DBB7"};"}>
          <%= @label %>
        </div>
        <div class="text-xs leading-relaxed" style="color: #9D8C71; max-width: 140px;">
          <%= @description %>
        </div>
      </div>
    </div>
    """
  end

  defp pip_class(i, energy, exhausted, dead) do
    cond do
      dead -> "bg-stone-700"
      i <= energy && exhausted -> "bg-red-600"
      i <= energy -> "bg-amber-500"
      true -> "bg-stone-700"
    end
  end
end
