defmodule Phalanx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhalanxWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phalanx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Phalanx.PubSub},
      # Start a worker by calling: Phalanx.Worker.start_link(arg)
      {Registry, keys: :unique, name: Phalanx.Game.Registry},
      {Phalanx.DynamicSupervisor, name: Phalanx.DynamicSupervisor},
      # Start to serve requests, typically the last entry
      PhalanxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phalanx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhalanxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
