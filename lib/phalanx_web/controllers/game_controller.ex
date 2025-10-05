defmodule PhalanxWeb.GameController do
  use PhalanxWeb, :controller

  alias Phalanx.Game

  def new(conn, _params) do
    # Create the game
    {:ok, game_id} = Phalanx.DynamicSupervisor.new_game()

    conn
    |> clear_session()
    |> redirect(to: ~p"/game/#{game_id}/join")
  end

  def join_game(%{params: %{"id" => game_id}} = conn, %{"player_name" => player_name} = _params) do
    player_token = Phalanx.PlayerService.new_player_token()

    case Phalanx.Game.join_game(game_id, player_name, player_token) do
      :ok ->
        conn
        |> put_session("game_id", game_id)
        |> put_session("player_name", player_name)
        |> put_session("player_token", player_token)
        |> redirect(to: ~p"/game/#{game_id}")

      {:error, err} ->
        IO.inspect(err, label: "error")
        # on error, redirect back to the join page with the error message
        conn
        |> put_flash(:error, "Error joining game: #{inspect(err)}")
        |> redirect(to: ~p"/game/#{game_id}/join")
    end
  end

  def clear(conn, params) do
    new_game_id = params["new_game_id"]
    _to = params["to"] || "/"

    conn =
      conn
      |> clear_session()

    cond do
      new_game_id && String.length(new_game_id) > 1 ->
        redirect(conn, to: ~p"/game/#{new_game_id}/join")

      true ->
        redirect(conn, to: ~p"/")
    end
  end
end
