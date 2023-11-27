defmodule Basket.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IO.inspect("STARTING BASKET")

    children = [
      BasketWeb.Telemetry,
      Basket.Repo,
      {DNSCluster, query: Application.get_env(:basket, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Basket.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Basket.Finch},
      # Start a worker by calling: Basket.Worker.start_link(arg)
      # {Basket.Worker, arg},
      # Start to serve requests, typically the last entry
      BasketWeb.Endpoint,
      {Cachex, name: :assets},
      Basket.Websocket.Alpaca
    ]

    # children =
    #   if Mix.env() != :test do
    #     children ++ [Basket.Websocket.Alpaca]
    #   else
    #     children
    #   end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Basket.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BasketWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
