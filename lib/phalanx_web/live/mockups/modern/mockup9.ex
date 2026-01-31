defmodule PhalanxWeb.Live.Mockups.Modern.Mockup9 do
  use PhalanxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-zinc-900 via-neutral-900 to-zinc-900 p-8">
      <div class="max-w-4xl mx-auto space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-3xl font-bold text-zinc-100">Strength Calculation</h1>
            <p class="text-zinc-400 mt-1">Detailed breakdown tooltip, attacker vs defender</p>
          </div>
          <a href={~p"/mockups/modern"} class="btn btn-ghost text-zinc-300">← Back to Mockups</a>
        </div>

        <!-- Battle Context -->
        <div class="card bg-zinc-800 border border-zinc-700">
          <div class="card-body">
            <h2 class="card-title text-zinc-100 text-sm">Battle Context</h2>
            <div class="flex items-center justify-center py-4">
              <div class="relative">
                <div class="flex items-center gap-8">
                  <!-- Attacker formation -->
                  <div class="text-center">
                    <div class="text-xs text-red-400 mb-2 font-semibold">ATTACKERS</div>
                    <div class="flex flex-col gap-1">
                      <div class="flex gap-1">
                        <.mini_unit color="red" name="A" />
                        <.mini_unit color="red" name="B" />
                      </div>
                      <div class="flex gap-1">
                        <.mini_unit color="red" name="C" active={true} />
                        <.mini_unit color="red" name="D" />
                      </div>
                    </div>
                    <div class="text-xs text-zinc-500 mt-2">Unit C attacking</div>
                  </div>

                  <div class="text-4xl text-amber-500">→</div>

                  <!-- Defender formation -->
                  <div class="text-center">
                    <div class="text-xs text-purple-400 mb-2 font-semibold">DEFENDERS</div>
                    <div class="flex flex-col gap-1">
                      <div class="flex gap-1">
                        <.mini_unit color="purple" name="X" />
                      </div>
                      <div class="flex gap-1">
                        <.mini_unit color="purple" name="Y" active={true} />
                        <.mini_unit color="purple" name="Z" />
                      </div>
                    </div>
                    <div class="text-xs text-zinc-500 mt-2">Unit Y defending</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Main Strength Calculation -->
        <div class="card bg-zinc-800 border-2 border-amber-500 shadow-2xl shadow-amber-500/20">
          <div class="card-body">
            <h2 class="card-title text-amber-400 text-lg flex items-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path d="M11 3a1 1 0 10-2 0v1a1 1 0 102 0V3zM15.657 5.757a1 1 0 00-1.414-1.414l-.707.707a1 1 0 001.414 1.414l.707-.707zM18 10a1 1 0 01-1 1h-1a1 1 0 110-2h1a1 1 0 011 1zM5.05 6.464A1 1 0 106.464 5.05l-.707-.707a1 1 0 00-1.414 1.414l.707.707zM5 10a1 1 0 01-1 1H3a1 1 0 110-2h1a1 1 0 011 1zM8 16v-1h4v1a2 2 0 11-4 0zM12 14c.015-.34.208-.646.477-.859a4 4 0 10-4.954 0c.27.213.462.519.476.859h4.002z" />
              </svg>
              Strength Calculation
            </h2>

            <div class="grid grid-cols-2 gap-6 mt-4">
              <!-- Attacker Column -->
              <div class="space-y-3">
                <div class="flex items-center gap-2 pb-2 border-b border-red-900">
                  <span class="text-lg font-bold text-red-400">ATTACKER</span>
                  <span class="text-xs text-zinc-500">(Unit C)</span>
                </div>

                <div class="space-y-2">
                  <.strength_line label="Base" value={1} active={true} />
                  <.strength_line label="Side Cohesion" value={2} active={true} detail="Units B, D" />
                  <.strength_line label="Depth" value={1} active={true} detail="Unit A behind" />
                  <.strength_line label="Support" value={1} active={true} detail="Unit D pushing" />
                </div>

                <div class="divider my-2"></div>

                <div class="flex items-center justify-between text-xl font-bold">
                  <span class="text-red-400">TOTAL</span>
                  <span class="text-red-400">5</span>
                </div>
              </div>

              <!-- Defender Column -->
              <div class="space-y-3">
                <div class="flex items-center gap-2 pb-2 border-b border-purple-900">
                  <span class="text-lg font-bold text-purple-400">DEFENDER</span>
                  <span class="text-xs text-zinc-500">(Unit Y)</span>
                </div>

                <div class="space-y-2">
                  <.strength_line label="Base" value={1} active={true} />
                  <.strength_line label="Side Cohesion" value={1} active={true} detail="Unit Z" />
                  <.strength_line label="Depth" value={1} active={true} detail="Unit X behind" />
                  <.strength_line label="Support" value={1} active={false} detail="CUT by Unit D" />
                </div>

                <div class="divider my-2"></div>

                <div class="flex items-center justify-between text-xl font-bold">
                  <span class="text-purple-400">TOTAL</span>
                  <span class="text-purple-400">3</span>
                </div>
              </div>
            </div>

            <!-- Comparison & Outcome -->
            <div class="mt-6 pt-4 border-t border-zinc-700">
              <div class="flex items-center justify-center gap-4 mb-3">
                <span class="text-3xl font-bold text-red-400">5</span>
                <span class="text-2xl text-zinc-500">vs</span>
                <span class="text-3xl font-bold text-purple-400">3</span>
              </div>

              <div class="text-center">
                <div class="inline-flex items-center gap-2 px-4 py-2 bg-red-950 border border-red-500 rounded-lg">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                  <span class="text-lg font-bold text-red-300">ATTACKER WINS</span>
                </div>
                <div class="text-sm text-zinc-400 mt-2">
                  Defender takes <span class="text-amber-400 font-semibold">2 damage</span> (5 - 3 = 2)
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Explanation Card -->
        <div class="card bg-zinc-800 border border-zinc-700">
          <div class="card-body">
            <h3 class="font-semibold text-zinc-100 text-sm">Strength Components</h3>
            <div class="text-sm text-zinc-400 space-y-2">
              <div class="flex gap-3">
                <span class="text-emerald-400">✓</span>
                <div><span class="font-semibold text-zinc-300">Base:</span> Every unit starts with strength 1</div>
              </div>
              <div class="flex gap-3">
                <span class="text-emerald-400">✓</span>
                <div><span class="font-semibold text-zinc-300">Side Cohesion:</span> +1 per adjacent ally with same facing (max +2)</div>
              </div>
              <div class="flex gap-3">
                <span class="text-emerald-400">✓</span>
                <div><span class="font-semibold text-zinc-300">Depth:</span> +1 per ally directly behind with same facing</div>
              </div>
              <div class="flex gap-3">
                <span class="text-emerald-400">✓</span>
                <div><span class="font-semibold text-zinc-300">Support:</span> +1 per adjacent ally attacking same target (attacker only)</div>
              </div>
              <div class="flex gap-3">
                <span class="text-red-400">✗</span>
                <div><span class="font-semibold text-zinc-300">Cut Support:</span> Support negated if enemy flanks the supporter</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp mini_unit(assigns) do
    assigns = assign_new(assigns, :active, fn -> false end)
    bg = if assigns.color == "red", do: "bg-red-900", else: "bg-purple-900"
    border = if assigns.active, do: "border-amber-400", else: (if assigns.color == "red", do: "border-red-600", else: "border-purple-600")
    text = if assigns.color == "red", do: "text-red-300", else: "text-purple-300"
    assigns = assign(assigns, bg: bg, border: border, text: text)

    ~H"""
    <div class={"w-10 h-10 rounded border-2 flex items-center justify-center text-xs font-bold #{@bg} #{@border} #{@text}"}>
      <%= @name %>
    </div>
    """
  end

  defp strength_line(assigns) do
    assigns = assign_new(assigns, :detail, fn -> nil end)

    ~H"""
    <div class={"flex items-center justify-between text-sm #{if @active, do: "text-zinc-100", else: "text-zinc-600"}"}>
      <div class="flex items-center gap-2">
        <%= if @active do %>
          <span class="text-emerald-400">✓</span>
        <% else %>
          <span class="text-red-500">✗</span>
        <% end %>
        <span class={unless @active, do: "line-through"}><%= @label %></span>
        <%= if @detail do %>
          <span class="text-xs text-zinc-500">(<%= @detail %>)</span>
        <% end %>
      </div>
      <span class={"font-mono font-semibold #{unless @active, do: "line-through"}"}>+<%= @value %></span>
    </div>
    """
  end
end
