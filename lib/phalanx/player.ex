defmodule Phalanx.Player do
  @type t :: %__MODULE__{
    name: String.t(),
    token: String.t(),
  }

  defstruct [
    :name,
    :token,
  ]

  def new(name, token) do
    %__MODULE__{
      name: name,
      token: token,
    }
  end
end
