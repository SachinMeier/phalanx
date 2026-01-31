defmodule PhalanxWeb.Components.Hex do
  use PhalanxWeb, :html

  def hex_grid(assigns) do
    ~H"""
    <div class="hex-tile-grid-wrapper">
      <div class="hex-tile-grid">
        <%= for y <- 0..(@y_ct-1) do %>
          <%= for x <- 0..(@x_ct-1) do %>
            <.hex_tile current_unit={@current_unit} units={@units} x={x} y={y} />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  defp hex_tile(assigns) do
    ~H"""
    <div class="hex-tile" >
        <%= case Map.get(@units, {@x, @y}) do %>
          <% nil -> %>
            <div class="text-white text-center py-4">

            </div>
          <% unit -> %>
            <div class={"py-0 "}>
              <.unit_svg current_unit={@current_unit} x={@x} y={@y} unit={unit} />
            </div>
        <% end %>
    </div>
    """
  end

  @doc """
  Renders a unit as a regular hexagon with chevron health bars.

  The chevrons form an arrow pointing in the facing direction.
  Health bars are parallel to the top-left and top-right hex edges.

  ## Geometry
  - Regular pointy-top hexagon (all sides equal, all angles 120°)
  - ViewBox 100x115.47 for clean math (height = width × 2/√3)
  - Chevron slopes match hex edges exactly: ±1/√3 ≈ ±0.5774
  """
  attr :unit, :map, required: true
  attr :current_unit, :any, required: true
  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :size, :integer, default: 50

  def unit_svg(assigns) do
    ~H"""
    <svg
      viewBox="0 0 100 115.47"
      width={@size}
      height={@size * 1.1547}
      class={rotation_class(@unit.rotation)}
    >
      <%!-- Regular hexagon: 6 vertices at 60° intervals --%>
      <polygon
        points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87"
        fill={@unit.color}
      />

      <%!--
        Health chevrons: nested arrow formation indicating facing direction.
        Each chevron's arms are parallel to the top-left and top-right hex edges.
        Slope = ±1/√3 ≈ ±0.5774 (30° from horizontal)
      --%>

      <%!-- Outermost chevron (health >= 1) --%>
      <polyline
        :if={@unit.health > 0}
        points="15,35.21 50,15 85,35.21"
        stroke={bar_stroke(@current_unit, {@x, @y})}
        stroke-width="4"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
      />

      <%!-- Middle chevron (health >= 2) --%>
      <polyline
        :if={@unit.health > 1}
        points="25,39.44 50,25 75,39.44"
        stroke={bar_stroke(@current_unit, {@x, @y})}
        stroke-width="4"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
      />

      <%!-- Innermost chevron (health >= 3) --%>
      <polyline
        :if={@unit.health > 2}
        points="35,43.66 50,35 65,43.66"
        stroke={bar_stroke(@current_unit, {@x, @y})}
        stroke-width="4"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
      />

      <%!-- Unit name (counter-rotated to stay upright) --%>
      <text
        x="50"
        y="78"
        text-anchor="middle"
        dominant-baseline="middle"
        fill={bar_stroke(@current_unit, {@x, @y})}
        font-size="24"
        font-weight="bold"
        transform={"rotate(#{-@unit.rotation}, 50, 57.735)"}
      >
        <%= @unit.name %>
      </text>
    </svg>
    """
  end

  defp bar_stroke(current_unit, position) do
    if current_unit == position, do: "chartreuse", else: "white"
  end

  defp rotation_class(rotation) do
    case rotation do
      0 -> "rotate-0"
      60 -> "rotate-60"
      120 -> "rotate-120"
      180 -> "rotate-180"
      240 -> "rotate-240"
      300 -> "rotate-300"
      360 -> "rotate-360"
      _ -> "rotate-0"
    end
  end

  defp unit_color(color) do
    case color do
      "red" -> "text-red-500"
      "blue" -> "text-blue-500"
      "green" -> "text-green-500"
    end
  end

  defp active_class(current_unit, position) do
    if current_unit == position do
      "ring-2 ring-green-500"
    else
      ""
    end
  end

  defp active_fill(current_unit, position, default \\ "white") do
    if current_unit == position do
      "chartreuse"
    else
      default
    end
  end

  def compass_hex_grid(assigns) do
    ~H"""
    <div class="bg-gray-500 py-4">
      <div class="compass-hex-tile-grid-wrapper">
        <div class="compass-hex-tile-grid">
          <!-- Center hex -->
          <.compass_hex_tile content="" />
          <.compass_hex_tile content="W" />
          <.compass_hex_tile content="E" />
          <.compass_hex_tile content="" />
          <.compass_hex_tile content="A" />
          <.compass_hex_tile content="•" />
          <.compass_hex_tile content="F" />
          <.compass_hex_tile content="" />
          <.compass_hex_tile content="S" />
          <.compass_hex_tile content="D" />
          <.compass_hex_tile content="" />
        </div>
      </div>
    </div>
    """
  end

  attr :content, :string, required: true

  def compass_hex_tile(assigns) do
    ~H"""
    <div class="hex-tile">
      <div class="py-3 px-3">
        <%= @content %>
      </div>
    </div>
    """
  end

  def old_og_hex(assigns) do
    ~H"""
    <svg width="100" height="115.47" class={"#{rotation_class(@rotation)}"}>
      <polygon points="50,0 100,28.87 100,86.6 50,115.47 0,86.6 0,28.87" fill="dodgerblue" />
        <!-- Bottom-left edge (parallel to 0,86.6 to 0,28.87) -->
        <path d="M 8,80.87 L 8,33.87 L 50,8" stroke="white" stroke-width="2" fill="none" />
    </svg>
    """
  end
end
