defmodule PhalanxWeb.Helpers do
  # LiveView
  def ok(), do: :ok
  def ok(value), do: {:ok, value}

  def noreply(socket), do: {:noreply, socket}

  def reply(socket, value), do: {:reply, value, socket}

  # Movement & Rotation

  @move_keys ["a", "w", "e", "s", "d", "f"]
  def move_keys(), do: @move_keys

  @rotation_keys ["q", "r"]
  def rotation_keys(), do: @rotation_keys

  @unit_keys ["y", "u", "i", "h", "j", "k", "o", "p", "l", "m", "c"]
  def unit_keys(), do: @unit_keys

  @rotation_per_key 60

  def key_to_abs_direction(key) do
    case key do
      "a" -> :west
      "w" -> :northwest
      "e" -> :northeast
      "s" -> :southwest
      "d" -> :southeast
      "f" -> :east
    end
  end

  def key_to_rel_direction(key) do
    case key do
      "w" -> :fwd_left
      "e" -> :fwd_right
      "d" -> :bck_right
      "s" -> :bck_left
    end
  end

  def key_to_rotation_order(key) do
    case key do
      "q" -> :counterclockwise
      "r" -> :clockwise
    end
  end

  def key_to_unit_rotation(unit, key) do
    rotation_dir =
      case key do
        "q" -> -1
        "r" -> 1
      end
    new_rotation = normalize_rotation(unit.rotation + (rotation_dir * @rotation_per_key))
  end

  defp normalize_rotation(rotation) do
    if rotation < 0 do
      rotation + 360
    else
      rotation
    end
    |> rem(360)
    |> IO.inspect(label: "normalized rotation")
  end

  def rotation_class(rotation) do
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

  def unit_letter_to_color(letter) do
    case letter do
      "Y" -> "text-red-500"
      "U" -> "text-red-500"
      "I" -> "text-red-500"
      "O" -> "text-red-500"
      "P" -> "text-red-500"

      "H" -> "text-purple-500"
      "J" -> "text-purple-500"
      "K" -> "text-purple-500"
      "L" -> "text-purple-500"
      "M" -> "text-purple-500"
      _ -> ""
    end
  end
end
