defmodule PhalanxWeb.Live.Mockups.Ancient.Mockup7 do
  @moduledoc "Ancient theme: Order List & Submission"
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
            Order List & Submission
          </h1>
          <p class="text-lg" style="color: #9D8C71;">
            The general's scrolls — pending orders and ready states
          </p>
        </div>

        <div class="grid lg:grid-cols-3 gap-8">
          <%!-- Left Sidebar Mock --%>
          <div class="space-y-6">
            <%!-- Turn Info --%>
            <div class="rounded-xl p-4" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 1px solid rgba(206,137,70,0.3);">
              <div class="flex items-center justify-between mb-4">
                <span class="text-sm" style="color: #9D8C71;">Turn</span>
                <span class="text-3xl font-bold" style="font-family: 'Cinzel', serif; color: #FACD1E;">V</span>
              </div>
              <div class="h-2 rounded-full overflow-hidden" style="background: rgba(0,0,0,0.3);">
                <div class="h-full rounded-full" style="width: 60%; background: linear-gradient(90deg, #CE8946, #FACD1E);"></div>
              </div>
              <div class="text-xs mt-2 text-center" style="color: #9D8C71;">Order Phase</div>
            </div>

            <%!-- Unit List --%>
            <div class="rounded-xl p-4" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 1px solid rgba(206,137,70,0.3);">
              <h3 class="font-semibold mb-4" style="font-family: 'Cinzel', serif; color: #E5DBB7;">Your Units</h3>
              <div class="space-y-2">
                <.unit_row name="Α" health={3} energy={3} has_order={true} color="#D32929" />
                <.unit_row name="Β" health={2} energy={3} has_order={true} color="#D32929" />
                <.unit_row name="Γ" health={3} energy={2} has_order={false} color="#D32929" />
                <.unit_row name="Δ" health={3} energy={3} has_order={true} color="#D32929" />
                <.unit_row name="Ε" health={1} energy={1} has_order={false} color="#D32929" />
              </div>
            </div>
          </div>

          <%!-- Center: Order Queue --%>
          <div class="lg:col-span-2 space-y-6">
            <%!-- Order Queue Panel --%>
            <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(255,245,230,0.08) 0%, rgba(229,219,183,0.04) 100%); border: 2px solid rgba(206,137,70,0.4);">
              <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-semibold" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
                  Pending Orders
                </h3>
                <span class="px-3 py-1 rounded-full text-sm font-bold" style="background: rgba(206, 137, 70, 0.2); color: #CE8946;">
                  3 of 5 units
                </span>
              </div>

              <%!-- Orders list --%>
              <div class="space-y-3 mb-6">
                <.order_item unit="Α" action="Move NE" icon="→" />
                <.order_item unit="Β" action="Rotate CW" icon="↻" />
                <.order_item unit="Δ" action="Move E → NE" icon="→" compound={true} />
              </div>

              <%!-- Empty slots --%>
              <div class="space-y-3 mb-6">
                <div class="p-3 rounded-lg border-2 border-dashed flex items-center justify-center" style="border-color: rgba(157, 140, 113, 0.3);">
                  <span class="text-sm" style="color: #9D8C71;">Γ — No order (will hold)</span>
                </div>
                <div class="p-3 rounded-lg border-2 border-dashed flex items-center justify-center" style="border-color: rgba(157, 140, 113, 0.3);">
                  <span class="text-sm" style="color: #9D8C71;">Ε — No order (will hold)</span>
                </div>
              </div>

              <%!-- Action Buttons --%>
              <div class="flex gap-4">
                <button class="flex-1 py-3 rounded-lg font-semibold text-sm transition-all hover:brightness-110"
                        style="background: rgba(127, 33, 34, 0.2); color: #7F2122; border: 1px solid rgba(127, 33, 34, 0.4);">
                  Clear All
                </button>
                <button class="flex-1 py-3 rounded-lg font-semibold text-sm transition-all hover:brightness-110"
                        style="font-family: 'Cinzel', serif; background: linear-gradient(180deg, #22c55e 0%, #16a34a 100%); color: white; box-shadow: 0 2px 8px rgba(34, 197, 94, 0.3);">
                  Submit Orders ⏎
                </button>
              </div>
            </div>

            <%!-- Waiting State Example --%>
            <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(250, 205, 30, 0.05) 0%, rgba(229,219,183,0.02) 100%); border: 2px solid rgba(250, 205, 30, 0.3);">
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-full flex items-center justify-center animate-spin" style="background: rgba(250, 205, 30, 0.2); border: 2px solid #FACD1E; border-top-color: transparent;">
                </div>
                <div>
                  <h4 class="font-semibold" style="color: #FACD1E;">Awaiting Opponent</h4>
                  <p class="text-sm" style="color: #9D8C71;">Your orders are locked. Waiting for opponent to submit...</p>
                </div>
              </div>
            </div>

            <%!-- Ready State Example --%>
            <div class="rounded-xl p-6" style="background: linear-gradient(145deg, rgba(34, 197, 94, 0.08) 0%, rgba(229,219,183,0.02) 100%); border: 2px solid rgba(34, 197, 94, 0.4);">
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-full flex items-center justify-center" style="background: rgba(34, 197, 94, 0.2);">
                  <span class="text-2xl" style="color: #22c55e;">✓</span>
                </div>
                <div>
                  <h4 class="font-semibold" style="color: #22c55e;">Both Players Ready</h4>
                  <p class="text-sm" style="color: #9D8C71;">Resolving turn in 3... 2... 1...</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <%!-- Order Type Legend --%>
        <div class="mt-8 rounded-xl p-6" style="background: linear-gradient(135deg, rgba(206, 137, 70, 0.1) 0%, rgba(229, 219, 183, 0.05) 100%); border: 1px solid rgba(206, 137, 70, 0.3);">
          <h3 class="text-xl font-semibold mb-6" style="font-family: 'Cinzel', serif; color: #E5DBB7;">
            Order Types
          </h3>

          <div class="grid md:grid-cols-4 gap-4">
            <div class="p-3 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <div class="text-2xl mb-2">→</div>
              <div class="font-semibold text-sm" style="color: #E5DBB7;">Move</div>
              <div class="text-xs" style="color: #9D8C71;">One hex in valid direction</div>
            </div>
            <div class="p-3 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <div class="text-2xl mb-2">↻</div>
              <div class="font-semibold text-sm" style="color: #E5DBB7;">Rotate CW</div>
              <div class="text-xs" style="color: #9D8C71;">60° clockwise turn</div>
            </div>
            <div class="p-3 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <div class="text-2xl mb-2">↺</div>
              <div class="font-semibold text-sm" style="color: #E5DBB7;">Rotate CCW</div>
              <div class="text-xs" style="color: #9D8C71;">60° counter-clockwise</div>
            </div>
            <div class="p-3 rounded-lg" style="background: rgba(0,0,0,0.2);">
              <div class="text-2xl mb-2">⬡</div>
              <div class="font-semibold text-sm" style="color: #E5DBB7;">Hold</div>
              <div class="text-xs" style="color: #9D8C71;">Stay in position (default)</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp unit_row(assigns) do
    ~H"""
    <div class="flex items-center justify-between p-2 rounded-lg transition-all hover:brightness-110"
         style={"background: #{if @has_order, do: "rgba(34, 197, 94, 0.1)", else: "rgba(157, 140, 113, 0.1)"}; border: 1px solid #{if @has_order, do: "rgba(34, 197, 94, 0.3)", else: "rgba(157, 140, 113, 0.2)"};"}>
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 rounded flex items-center justify-center font-bold text-white text-sm" style={"background: #{@color};"}>
          <%= @name %>
        </div>
        <div class="flex gap-0.5">
          <%= for i <- 1..3 do %>
            <div class={"w-1.5 h-4 rounded-sm #{if i <= @health, do: "bg-green-500", else: "bg-stone-700"}"}></div>
          <% end %>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <div class="flex gap-0.5">
          <%= for i <- 1..3 do %>
            <div class={"w-1.5 h-1.5 rounded-full #{if i <= @energy, do: "bg-amber-500", else: "bg-stone-700"}"}></div>
          <% end %>
        </div>
        <span :if={@has_order} class="text-xs" style="color: #22c55e;">✓</span>
        <span :if={!@has_order} class="text-xs" style="color: #9D8C71;">—</span>
      </div>
    </div>
    """
  end

  defp order_item(assigns) do
    assigns = assign_new(assigns, :compound, fn -> false end)

    ~H"""
    <div class="flex items-center justify-between p-3 rounded-lg" style="background: rgba(34, 197, 94, 0.1); border: 1px solid rgba(34, 197, 94, 0.3);">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-lg flex items-center justify-center font-bold text-white" style="background: #D32929;">
          <%= @unit %>
        </div>
        <div>
          <div class="font-semibold" style="color: #E5DBB7;"><%= @action %></div>
          <div :if={@compound} class="text-xs" style="color: #FACD1E;">Compound order</div>
        </div>
      </div>
      <div class="flex items-center gap-3">
        <span class="text-2xl" style="color: #FACD1E;"><%= @icon %></span>
        <button class="w-8 h-8 rounded flex items-center justify-center transition-all hover:brightness-110" style="background: rgba(127, 33, 34, 0.2); color: #7F2122;">
          ✕
        </button>
      </div>
    </div>
    """
  end
end
