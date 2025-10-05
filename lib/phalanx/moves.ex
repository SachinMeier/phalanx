defmodule Phalanx.Moves do
  @moduledoc """
  This module contains the logic for the moving along an odd-r, pointy-top hex grid.
  """

  @even_row_moves [
      # east
      {1,0},
      # northeast
      {0, -1},
      # northwest
      {-1, -1},
      # west
      {-1, 0},
      # southeast
      {-1, 1},
      # southeast
      {0, 1}
    ]

  @odd_row_moves [
      # east
      {1, 0},
      # northeast
      {1, -1},
      # northwest
      {0, -1},
      # west
      {-1, 0},
      # southwest
      {0, 1},
      # southeast
      {1, 1}
    ]

  @moves [@even_row_moves, @odd_row_moves]

  @allowed_moves %{
    0 => [
      :east,
      :southeast,
      :west,
      :northwest
    ],
    60 => [
      :northeast,
      :northwest,
      :southeast,
      :southwest
    ],
    120 => [
      :northeast,
      :east,
      :west,
      :southwest
    ],
  }

  def direction_allowed?(rotation, abs_direction) do
    abs_direction in Map.get(@allowed_moves, rem(rotation, 180))
  end

  def tile_on_map?({map_x, map_y}, {x, y}) do
    x >= 0 and
      y >= 0 and
      x < map_x and
      y < map_y
  end

  def oddr_offset_neighbor(map_dimensions, {x, y}, rotation, abs_direction) do
    parity = rem(y, 2)
    # abs_direction = rel_to_abs_direction(rotation, rel_direction)
    {dx, dy} = Enum.at(@moves, parity) |> Enum.at(direction_to_idx(abs_direction))
    {x + dx, y + dy}
  end

  def move(map_dimensions, current_position, rotation, abs_direction) do
    new_position = oddr_offset_neighbor(map_dimensions, current_position, rotation, abs_direction)

    cond do
      not direction_allowed?(rotation, abs_direction) ->
        {:error, "invalid move"}

      not tile_on_map?(map_dimensions, new_position) ->
        {:error, "tile not on map"}

      true ->
        {:ok, new_position}
    end
  end

  defp direction_to_idx(direction) do
    case direction do
      :east -> 0
      :northeast -> 1
      :northwest -> 2
      :west -> 3
      :southwest -> 4
      :southeast -> 5
    end
  end

  @absolute_directions [
    :east,      # 0
    :northeast, # 1
    :northwest, # 2
    :west,      # 3
    :southwest, # 4
    :southeast  # 5
  ]

  defp relative_direction_to_absolute(rotation, rel_direction) do
    rotation_offset = trunc((rotation - 60) / 60)

    rel_direction_idx =
      case rel_direction do
        :fwd_left -> 2
        :fwd_right -> 1
        :bck_left -> 4
        :bck_right -> 5
      end

      Enum.at(@absolute_directions, rem(rel_direction_idx + rotation_offset, 6))
  end

  # TODO: this could be simplified to a more elegant equation
  defp rel_to_abs_direction(rotation, rel_direction) do
    case {rotation, rel_direction} do
      {0, :fwd_left} -> :west           # 3
      {0, :fwd_right} -> :northwest     # 2
      {0, :bck_left} -> :southeast      # 5
      {0, :bck_right} -> :east          # 0

      {60, :fwd_left} -> :northwest     # 2
      {60, :fwd_right} -> :northeast    # 1
      {60, :bck_left} -> :southwest     # 4
      {60, :bck_right} -> :southeast    # 5

      {120, :fwd_left} -> :northeast    # 1
      {120, :fwd_right} -> :east        # 1
      {120, :bck_left} -> :west         # 4
      {120, :bck_right} -> :southwest   # 5

      {180, :fwd_left} -> :east         # 1
      {180, :fwd_right} -> :southeast   # 1
      {180, :bck_left} -> :northwest    # 4
      {180, :bck_right} -> :west   # 5

      {240, :fwd_left} -> :southeast    # 2
      {240, :fwd_right} -> :southwest   # 1
      {240, :bck_left} -> :northeast    # 4
      {240, :bck_right} -> :northwest   # 5

      {300, :fwd_left} -> :southwest    # 2
      {300, :fwd_right} -> :west        # 1
      {300, :bck_left} -> :east         # 4
      {300, :bck_right} -> :northeast   # 5
    end
  end

end
