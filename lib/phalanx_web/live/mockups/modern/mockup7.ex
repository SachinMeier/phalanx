defmodule PhalanxWeb.Live.Mockups.Modern.Mockup7 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    orders = [
      %{unit: "Y", action: "Move East", status: :ready},
      %{unit: "U", action: "Rotate Clockwise", status: :ready},
      %{unit: "I", action: "Move Northeast", status: :pending},
      %{unit: "O", action: "Hold", status: :hold},
      %{unit: "P", action: "Move West", status: :ready}
    ]

    socket =
      socket
      |> assign(:orders, orders)
      |> assign(:submitted, false)
      |> assign(:opponent_ready, false)

    {:ok, socket}
  end

  def handle_event("submit", _, socket) do
    {:noreply, assign(socket, submitted: true)}
  end

  def handle_event("toggle_opponent", _, socket) do
    {:noreply, assign(socket, opponent_ready: !socket.assigns.opponent_ready)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-indigo-950 via-purple-950 to-slate-900 p-8">
      <div class="max-w-2xl mx-auto space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-indigo-100">Order List & Submission</h1>
            <p class="text-indigo-300/70">Pending orders panel, ready state, waiting state</p>
          </div>
          <a href={~p"/mockups/modern"} class="btn btn-ghost text-indigo-300">← Back to Mockups</a>
        </div>

        <!-- Demo Controls -->
        <div class="card bg-slate-800/50 border border-slate-700">
          <div class="card-body p-4">
            <div class="text-xs text-slate-400 mb-2">Demo Controls</div>
            <div class="flex gap-2">
              <button phx-click="submit" class="btn btn-sm btn-outline btn-info" disabled={@submitted}>
                <%= if @submitted, do: "Submitted", else: "Simulate Submit" %>
              </button>
              <button phx-click="toggle_opponent" class="btn btn-sm btn-outline btn-warning">
                Toggle Opponent Ready
              </button>
            </div>
          </div>
        </div>

        <!-- Order Panel -->
        <div class="card bg-indigo-950/50 border-2 border-indigo-700">
          <div class="card-body">
            <div class="flex items-center justify-between mb-4">
              <h2 class="card-title text-indigo-100">Your Orders</h2>
              <div class="badge badge-lg badge-primary">Turn 5</div>
            </div>

            <!-- Order List -->
            <div class="space-y-3">
              <%= for order <- @orders do %>
                <.order_card order={order} />
              <% end %>
            </div>

            <!-- Submit Section -->
            <div class="mt-6 pt-4 border-t border-indigo-800">
              <%= if !@submitted do %>
                <button class="btn btn-primary btn-lg w-full" phx-click="submit">
                  <span class="mr-2">Submit All Orders</span>
                  <kbd class="kbd kbd-sm bg-primary-content text-primary">Enter</kbd>
                </button>
                <p class="text-center text-indigo-300/60 text-sm mt-2">
                  Press Enter to submit orders for all units
                </p>
              <% else %>
                <%= if @opponent_ready do %>
                  <div class="alert bg-green-900/50 border-2 border-green-500">
                    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6 text-green-400" fill="none" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <div>
                      <h3 class="font-bold text-green-200">Both Players Ready!</h3>
                      <div class="text-sm text-green-300">Resolving turn...</div>
                    </div>
                  </div>
                <% else %>
                  <div class="alert bg-amber-900/50 border-2 border-amber-500">
                    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6 text-amber-400 animate-spin" fill="none" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                    <div>
                      <h3 class="font-bold text-amber-200">Waiting for opponent...</h3>
                      <div class="text-sm text-amber-300">Your orders are locked in</div>
                    </div>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Opponent Status -->
        <div class="card bg-purple-950/50 border border-purple-700">
          <div class="card-body p-4">
            <div class="flex items-center justify-between">
              <span class="text-purple-200 font-semibold">Opponent Status</span>
              <%= if @opponent_ready do %>
                <div class="badge badge-success gap-1">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  Ready
                </div>
              <% else %>
                <div class="badge badge-warning gap-1 animate-pulse">
                  <span class="loading loading-dots loading-xs"></span>
                  Planning...
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Legend -->
        <div class="card bg-slate-800/30 border border-slate-700">
          <div class="card-body p-4">
            <h3 class="font-semibold text-slate-200 mb-3">Status Legend</h3>
            <div class="grid grid-cols-3 gap-4 text-sm">
              <div class="flex items-center gap-2">
                <div class="badge badge-success badge-sm">Ready</div>
                <span class="text-slate-400">Valid order set</span>
              </div>
              <div class="flex items-center gap-2">
                <div class="badge badge-warning badge-sm">Pending</div>
                <span class="text-slate-400">Incomplete</span>
              </div>
              <div class="flex items-center gap-2">
                <div class="badge badge-ghost badge-sm">Hold</div>
                <span class="text-slate-400">No action</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp order_card(assigns) do
    {badge_class, badge_text} =
      case assigns.order.status do
        :ready -> {"badge-success", "Ready"}
        :pending -> {"badge-warning", "Pending"}
        :hold -> {"badge-ghost", "Hold"}
      end

    assigns = assign(assigns, badge_class: badge_class, badge_text: badge_text)

    ~H"""
    <div class={["flex items-center gap-4 p-3 rounded-lg border transition-all", @order.status == :ready && "bg-indigo-900/30 border-indigo-600", @order.status == :pending && "bg-amber-900/20 border-amber-600/50", @order.status == :hold && "bg-slate-800/30 border-slate-600"]}>
      <div class={["w-10 h-10 rounded flex items-center justify-center font-bold text-lg", @order.status == :hold && "bg-slate-700 text-slate-400", @order.status != :hold && "bg-red-700 text-white"]}>
        <%= @order.unit %>
      </div>
      <div class="flex-1">
        <div class="font-semibold text-indigo-100"><%= @order.action %></div>
        <div class="text-xs text-indigo-300/60">Unit <%= @order.unit %></div>
      </div>
      <div class={"badge #{@badge_class}"}><%= @badge_text %></div>
    </div>
    """
  end
end
