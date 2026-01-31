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

    # Mockups hub (theme chooser)
    live "/mockups", Live.Mockups.MockupHub, :index

    # Ancient theme mockups
    live "/mockups/ancient", Live.Mockups.Ancient.Hub, :index
    live "/mockups/ancient/1", Live.Mockups.Ancient.Mockup1, :index
    live "/mockups/ancient/2", Live.Mockups.Ancient.Mockup2, :index
    live "/mockups/ancient/3", Live.Mockups.Ancient.Mockup3, :index
    live "/mockups/ancient/4", Live.Mockups.Ancient.Mockup4, :index
    live "/mockups/ancient/5", Live.Mockups.Ancient.Mockup5, :index
    live "/mockups/ancient/6", Live.Mockups.Ancient.Mockup6, :index
    live "/mockups/ancient/7", Live.Mockups.Ancient.Mockup7, :index
    live "/mockups/ancient/8", Live.Mockups.Ancient.Mockup8, :index
    live "/mockups/ancient/9", Live.Mockups.Ancient.Mockup9, :index
    live "/mockups/ancient/10", Live.Mockups.Ancient.Mockup10, :index

    # Modern theme mockups
    live "/mockups/modern", Live.Mockups.Modern.Hub, :index
    live "/mockups/modern/1", Live.Mockups.Modern.Mockup1, :index
    live "/mockups/modern/2", Live.Mockups.Modern.Mockup2, :index
    live "/mockups/modern/3", Live.Mockups.Modern.Mockup3, :index
    live "/mockups/modern/4", Live.Mockups.Modern.Mockup4, :index
    live "/mockups/modern/5", Live.Mockups.Modern.Mockup5, :index
    live "/mockups/modern/6", Live.Mockups.Modern.Mockup6, :index
    live "/mockups/modern/7", Live.Mockups.Modern.Mockup7, :index
    live "/mockups/modern/8", Live.Mockups.Modern.Mockup8, :index
    live "/mockups/modern/9", Live.Mockups.Modern.Mockup9, :index
    live "/mockups/modern/10", Live.Mockups.Modern.Mockup10, :index

    # Pixel art theme mockups
    live "/mockups/pixel", Live.Mockups.Pixel.Hub, :index
    live "/mockups/pixel/1", Live.Mockups.Pixel.Mockup1, :index
    live "/mockups/pixel/2", Live.Mockups.Pixel.Mockup2, :index
    live "/mockups/pixel/3", Live.Mockups.Pixel.Mockup3, :index
    live "/mockups/pixel/4", Live.Mockups.Pixel.Mockup4, :index
    live "/mockups/pixel/5", Live.Mockups.Pixel.Mockup5, :index
    live "/mockups/pixel/6", Live.Mockups.Pixel.Mockup6, :index
    live "/mockups/pixel/7", Live.Mockups.Pixel.Mockup7, :index
    live "/mockups/pixel/8", Live.Mockups.Pixel.Mockup8, :index
    live "/mockups/pixel/9", Live.Mockups.Pixel.Mockup9, :index
    live "/mockups/pixel/10", Live.Mockups.Pixel.Mockup10, :index

    # Siegius theme mockups
    live "/mockups/siegius", Live.Mockups.Siegius.Hub, :index
    live "/mockups/siegius/1", Live.Mockups.Siegius.Mockup1, :index
    live "/mockups/siegius/2", Live.Mockups.Siegius.Mockup2, :index
    live "/mockups/siegius/3", Live.Mockups.Siegius.Mockup3, :index
    live "/mockups/siegius/4", Live.Mockups.Siegius.Mockup4, :index
    live "/mockups/siegius/5", Live.Mockups.Siegius.Mockup5, :index
    live "/mockups/siegius/6", Live.Mockups.Siegius.Mockup6, :index
    live "/mockups/siegius/7", Live.Mockups.Siegius.Mockup7, :index
    live "/mockups/siegius/8", Live.Mockups.Siegius.Mockup8, :index
    live "/mockups/siegius/9", Live.Mockups.Siegius.Mockup9, :index
    live "/mockups/siegius/10", Live.Mockups.Siegius.Mockup10, :index

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
