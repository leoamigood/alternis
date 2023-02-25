defmodule Alternis.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Alternis.Repo,
      {Oban, Application.fetch_env!(:alternis, Oban)},
      # Start the Telemetry supervisor
      AlternisWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Alternis.PubSub},
      {AlternisWeb.PlayersTracker,
       [name: AlternisWeb.PlayersTracker, pubsub_server: Alternis.PubSub]},
      # Start the Endpoint (http/https)
      AlternisWeb.Endpoint
      # Start a worker by calling: Alternis.Worker.start_link(arg)
      # {Alternis.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Alternis.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AlternisWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
