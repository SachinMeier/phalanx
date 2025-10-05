defmodule Phalanx.Order do
  # TODO: consider dropping the position field and just having move & rotation fields.
  @type t :: %__MODULE__{
    position: {integer(), integer()},
    move: atom(),
    rotation: atom(),
  }

  defstruct [
    :position,
    :move,
    :rotation,
  ]

  def null_order(position) do
    %__MODULE__{
      position: position,
      move: nil,
      rotation: nil,
    }
  end

  def new(position, move, rotation) do
    %__MODULE__{
      position: position,
      move: move,
      rotation: rotation,
    }
  end

  def upsert(nil, curr_position, move_or_rotation) do
    case order_type(move_or_rotation) do
      :move ->
        new(curr_position, move_or_rotation, nil)
      :rotation ->
        new(curr_position, nil, move_or_rotation)
    end
  end

  def upsert(%__MODULE__{position: curr_position, move: existing_move, rotation: existing_rotation}, curr_position, move_or_rotation) do
    case order_type(move_or_rotation) do
      # A move must always be declared first, so overwrite the existing order
      :move ->
        new(curr_position, move_or_rotation, nil)

      :rotation ->
        # A rotation can be assigned after a move, so only overwrite the rotation
        if existing_rotation == nil do
          new(curr_position, existing_move, move_or_rotation)
        else
          # if there is an existing rotation, overwrite the whole order to ONLY rotate.
          new(curr_position, nil, move_or_rotation)
        end
    end
  end

  def order_type(move) do
    case move do
      :northeast -> :move
      :northwest -> :move
      :southeast -> :move
      :southwest -> :move
      :east -> :move
      :west -> :move
      :clockwise -> :rotation
      :counterclockwise -> :rotation
    end
  end

  def to_string(order) do
    "(#{order.move}) & (#{order.rotation})"
  end
end
