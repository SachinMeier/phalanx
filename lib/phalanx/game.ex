defmodule Phalanx.Game do
  use GenServer

  import Phalanx.Helpers

  alias Phalanx.Config
  alias Phalanx.Player
  alias Phalanx.PlayerService
  alias Phalanx.Engine

  @type status :: :waiting | :running | :finished

  @type t :: %__MODULE__{
    id: String.t(),
    status: status(),
    turn: non_neg_integer(),
    players: list(Phalanx.Player.t()),
    units: map(),
    map_dimensions: {pos_integer(), pos_integer()},
  }

  defstruct [
    :id,
    :status,
    :turn,
    :players,
    :units,
    :map_dimensions,
  ]

  @doc """
  Creates a new game.
  """
  @spec new_game(String.t()) :: t()
  def new_game(id) do
    %{
      units: units,
      map_dimensions: map_dimensions,
    } = Phalanx.Helpers.default_game()

    %__MODULE__{
      id: id,
      status: :playing,
      players: [],
      turn: 0,
      units: units,
      map_dimensions: map_dimensions,
    }
  end

  @spec state_topic(String.t()) :: String.t()
  def state_topic(id), do: "game-state:#{id}"

  @impl true
  def init(id) do
    state = new_game(id)
    {:ok, state}
  end

  @doc """
  Generates a new game ID.
  """
  @spec new_game_id() :: String.t()
  def new_game_id() do
    :crypto.strong_rand_bytes(4)
    |> Base.encode32(padding: false)
    |> String.upcase()
  end

  @spec start_link(String.t(), t() | nil) :: {:ok, pid()} | {:error, any()}
  def start_link(id, state \\ nil) do
    if state == nil do
      GenServer.start_link(__MODULE__, id, name: via_tuple(id))
    else
      GenServer.start_link(__MODULE__, state, name: via_tuple(id))
    end
  end

  def via_tuple(id) do
    {:via, Registry, {Phalanx.Game.Registry, id}}
  end

  def broadcast_state(state) do
    Phoenix.PubSub.broadcast(Phalanx.PubSub, state_topic(state.id), {:state, state})
  end

  @impl true
  def handle_info(:stop, state) do
    # IO.inspect(state, label: "stopping game #{state.id}")
    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    # IO.puts("Game #{state.id} timed out")
    {:stop, :normal, state}
  end

  @impl true
  def terminate(reason, _state) do
    # IO.puts("Game #{state.id} terminated: #{inspect(reason)}")

    :ok
  end

  # Handle Calls

  @impl true
  def handle_call(:get_state, _from, state) do
    # IO.inspect(state, label: "get_state")
    reply(state, state)
  end

  def handle_call({:join, player_name, player_token}, _from, state) do
    player_name_len = String.length(player_name)
    cond do
      # error if the game is full.
      PlayerService.count_unquit_players(state) >= Config.max_players() ->
        reply(state, {:error, :game_full})

      # error if the player name is too short
      player_name_len < Config.min_player_name() ->
        reply(state, {:error, :player_name_too_short})

      # error if the player name is too long
      player_name_len > Config.max_player_name() ->
        reply(state, {:error, :player_name_too_long})

      # error if the player name is already taken
      !PlayerService.player_is_unique?(state, player_name, player_token) ->
        reply(state, {:error, :duplicate_player})

      true ->
        new_player = Player.new(player_name, player_token)

        with %{} = new_state <- PlayerService.add_player(state, new_player) do
          # {result, new_state} = assign_new_player_to_team(state, new_player)
          broadcast_state(new_state)
          reply(new_state, :ok)
        end
    end
  end

  def handle_call({:join, _player_name, _player_token}, _from, %{status: :playing} = state) do
    reply(state, {:error, :game_already_started})
  end

  def handle_call({:rejoin, _player_name, player_token}, _from, state) do
    # ensure player is in the game.
    # TODO: This doesn't prevent token duplication
    # (player using multiple clients by copying over the token)
    case PlayerService.find_player(state, player_token) do
      nil ->
        reply(state, {:error, :not_found})

      _ ->
        reply(state, :ok)
    end
  end

  def handle_call({:quit, player_token}, _from, state) do
    # TODO: For now just remove the player from the game.
    new_players =
      Enum.filter(state.players, fn %{token: token} ->
        token != player_token
      end)

    # Check that there are remaining players still playing
    if new_players == [] do
      # if there are no players left, kill the game (don't calculate scores)
      Process.send_after(self(), :stop, 1000)
      reply(state, :ok)
    else
      reply(state, :ok)
      |> Map.put(:players, new_players)
      |> broadcast_state()
      |> reply(:ok)
    end
  end

  def handle_call({:handle_orders, orders}, _from, state) do
    new_state = Engine.execute_orders(state, orders)
    broadcast_state(new_state)
    reply(new_state, :ok)
  end

  # PLAYER API #

  def find_by_id(game_id) do
    case Registry.lookup(Phalanx.Game.Registry, game_id) do
      [{pid, _}] -> :ok
      [] -> {:error, :not_found}
    end
  end

  def get_state(game_id) do
    case find_by_id(game_id) do
      :ok ->
        {:ok, genserver_call(game_id, :get_state)}

      {:error, :not_found} -> {:error, :not_found}
    end
  end

  def join_game(game_id, player_name, player_token) do
    case find_by_id(game_id) do
      :ok ->
        genserver_call(game_id, {:join, player_name, player_token})


      _ ->
        {:error, :not_found}
    end
  end

  def rejoin_game(game_id, player_name, player_token) do
    case find_by_id(game_id) do
      :ok ->
        genserver_call(game_id, {:rejoin, player_name, player_token})

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def quit_game(game_id, player_token) do
    case find_by_id(game_id) do
      :ok ->
        genserver_call(game_id, {:quit, player_token})

      _ ->
        {:error, :not_found}
    end
  end

  def handle_orders(game_id, orders) do
    case find_by_id(game_id) do
      :ok ->
        genserver_call(game_id, {:handle_orders, orders})

      _ ->
        {:error, :not_found}
    end
  end

  defp genserver_call(game_id, data) do
    game_id
    |> via_tuple()
    |> GenServer.call(data)
  end
end
