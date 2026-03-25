defmodule WorldTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        WorldTrackerWeb.Telemetry,
        WorldTracker.Repo,
        {DNSCluster, query: Application.get_env(:world_tracker, :dns_cluster_query) || :ignore},
        {Oban, Application.fetch_env!(:world_tracker, Oban)},
        {Phoenix.PubSub, name: WorldTracker.PubSub},
        WorldTracker.Shipping.AisStreamClient,
        WorldTrackerWeb.Endpoint
      ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WorldTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WorldTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
