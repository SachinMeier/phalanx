defmodule PhalanxWeb.Router do
  use PhalanxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhalanxWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PhalanxWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/sandbox", Live.Sandbox, :index

    live "/find", Live.Find, :find

    live "/new_game", Live.NewGame, :new

    live "/game/:id/join", Live.JoinGame, :join

    get "/game/:id/join_game", GameController, :join_game

    post "/game/new", GameController, :new

    live_session :game, on_mount: [{PhalanxWeb.GameSession, :new}] do
      live "/game/:id", Live.Game, :index
    end

    get "/clear", GameController, :clear
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhalanxWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:phalanx, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PhalanxWeb.Telemetry
    end
  end
end
