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

  attr :unit, :map, required: true
  attr :current_unit, :any, required: true
  attr :x, :integer, required: true
  attr :y, :integer, required: true

  def unit_svg(assigns) do
    assigns = assign(assigns, :w, 50)
    ~H"""
    <svg width={@w} height={"#{@w*1.1547}"} class={"#{rotation_class(@unit.rotation)}"}>
      <polygon points={"#{@w*0.5},0 #{@w},#{@w*0.2887} #{@w},#{@w*0.866} #{@w*0.5},#{@w*1.1547} 0,#{@w*0.866} 0,#{@w*0.2887}"} fill={@unit.color} />

        <path :if={@unit.health > 0} d={"M 4,#{@w*0.8} L 4,#{@w*0.34} L #{@w*0.5},4"} stroke={active_fill(@current_unit, {@x, @y})} stroke-width="2" fill="none" />
        <path :if={@unit.health > 1} d={"M 8,#{@w*0.8} L 8,#{@w*0.38} L #{@w*0.55},7"} stroke={active_fill(@current_unit, {@x, @y})} stroke-width="2" fill="none" />
        <path :if={@unit.health > 2} d={"M 12,#{@w*0.8} L 12,#{@w*0.42} L #{@w*0.6},11"} stroke={active_fill(@current_unit, {@x, @y})} stroke-width="2" fill="none" />

        <text x={"#{@w*0.5}"} y={"#{@w*0.577}"} text-anchor="middle" dominant-baseline="middle" fill={active_fill(@current_unit, {@x, @y})} font-size="12" font-weight="bold" transform={"rotate(#{-@unit.rotation}, #{@w*0.5}, #{@w*0.577})"}>
          <%= @unit.name %>
        </text>
    </svg>
    """
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
