defmodule CloseTheLoop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CloseTheLoopWeb.Telemetry,
      CloseTheLoop.Repo,
      {DNSCluster, query: Application.get_env(:close_the_loop, :dns_cluster_query) || :ignore},
      {Oban,
       AshOban.config(
         Application.fetch_env!(:close_the_loop, :ash_domains),
         Application.fetch_env!(:close_the_loop, Oban)
       )},
      {Phoenix.PubSub, name: CloseTheLoop.PubSub},
      # Start a worker by calling: CloseTheLoop.Worker.start_link(arg)
      # {CloseTheLoop.Worker, arg},
      # Start to serve requests, typically the last entry
      CloseTheLoopWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :close_the_loop]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CloseTheLoop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CloseTheLoopWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
