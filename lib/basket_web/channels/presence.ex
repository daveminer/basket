defmodule BasketWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :basket,
    pubsub_server: Basket.PubSub

  require Logger

  alias Basket.Websocket

  @doc """
  Keeps track of ticker subscription state within the process.
  """
  def init(_opts) do
    {:ok, %{}}
  end

  @doc """
  Tracks subscriptions to ticker channels, subscribing and unsubscribing from
  the external ticker server as needed.

  ## Example
    iex> join = %{joins: %{"1" => %{metas: [%{phx_ref: "F5-vJ_d1tq0argHC"}]}}, leaves: %{}}
    iex> presence = %{"1" => [%{phx_ref: "F5-vJ_d1tq0argHC"}], "2" => [%{phx_ref: "F5-vPC7mhaUargKC"}]}
    iex> state = %{}
    iex> Presence.handle_metas("bars-ABC", join, presence, state)
    {:ok, %{}}
  """
  def handle_metas("bars-" <> ticker, %{joins: joins, leaves: leaves}, presences, state) do
    if first_to_join(joins, presences) do
      Websocket.Stock.subscribe(%{bars: [ticker], quotes: [], trades: []})
      Websocket.News.subscribe(%{news: [ticker]})
    end

    if last_to_leave(leaves, presences) do
      Websocket.Stock.unsubscribe(%{bars: [ticker], quotes: [], trades: []})
      Websocket.News.unsubscribe(%{news: [ticker]})
    end

    {:ok, state}
  end

  defp first_to_join(joins, presences) do
    join_count = map_size(joins)
    join_count > 0 && map_size(presences) == join_count
  end

  defp last_to_leave(leaves, presences) do
    map_size(leaves) > 0 && map_size(presences) == 0
  end
end
