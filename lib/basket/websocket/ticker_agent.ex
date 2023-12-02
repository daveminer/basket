defmodule Basket.Websocket.TickerAgent do
  @moduledoc """
  Tracks ticker bar subscriptions to reduces calls to the websocket server.
  """
  use Agent

  alias Basket.Websocket

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> MapSet.new() end, name: __MODULE__)
  end

  @doc """
  Adds a ticker to the set of subscribed tickers, if not already present.
  """
  @spec add(tickers :: list(String.t()) | String.t()) :: :ok
  def add(tickers) when is_list(tickers) do
    new_tickers =
      Agent.get(__MODULE__, fn state -> MapSet.new(tickers) |> MapSet.difference(state) end)

    :ok = Websocket.Alpaca.subscribe(%{bars: MapSet.to_list(new_tickers), quotes: [], trades: []})

    Agent.update(__MODULE__, fn state -> MapSet.union(new_tickers, state) end)
  end

  def add(tickers), do: add([tickers])

  @doc """
  Removes a ticker from the set of subscribed tickers, if present.
  """
  @spec remove(tickers :: list(String.t()) | String.t()) :: :ok
  def remove(tickers) when is_list(tickers) do
    tickers_to_remove =
      Agent.get(__MODULE__, fn state ->
        MapSet.intersection(MapSet.new(state), MapSet.new(tickers))
      end)

    :ok =
      Websocket.Alpaca.unsubscribe(%{
        bars: MapSet.to_list(tickers_to_remove),
        quotes: [],
        trades: []
      })

    Agent.update(__MODULE__, fn state -> MapSet.difference(state, tickers_to_remove) end)
  end

  def remove(tickers) do
    remove([tickers])
  end
end
