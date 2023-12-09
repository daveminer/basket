defmodule Basket.Websocket.TickerAgent do
  @moduledoc """
  Tracks ticker bar subscriptions to reduces calls to the websocket server.
  """
  use Agent

  alias Basket.Websocket

  def start_link(_opts) do
    Agent.start_link(fn -> MapSet.new() end, name: __MODULE__)
  end

  @doc """
  Clients use this function to add a ticker to their set of subscribed tickers.
  TickerAgent will maintain a set of tickers that aggregate all users' subscriptions
  into one set of tickers for the websocket client to manage against the websocket server.
  """
  @spec add(tickers :: list(String.t()) | String.t()) :: :ok
  def add(tickers) when is_list(tickers) do
    new_tickers =
      Agent.get(__MODULE__, fn state ->
        MapSet.new(tickers) |> MapSet.difference(state)
      end)

    if Enum.empty?(new_tickers) do
      :ok
    else
      # Client requested a ticker that is not already in the subscription set. Add that ticker
      # to the set and subscribe to it.
      Agent.update(__MODULE__, fn state -> MapSet.union(new_tickers, state) end)

      :ok =
        Websocket.Alpaca.subscribe(%{bars: MapSet.to_list(new_tickers), quotes: [], trades: []})
    end
  end

  def add(tickers), do: add([tickers])

  @doc """
  Removes a ticker from the set of subscribed tickers, if needed.
  """
  @spec remove(tickers :: list(String.t()) | String.t()) :: :ok
  def remove(tickers) when is_list(tickers) do
    tickers_to_remove =
      Agent.get(__MODULE__, fn state ->
        MapSet.intersection(MapSet.new(state), MapSet.new(tickers))
      end)

    if Enum.empty?(tickers_to_remove) do
      :ok
    else
      :ok =
        Websocket.Alpaca.unsubscribe(%{
          bars: MapSet.to_list(tickers_to_remove),
          quotes: [],
          trades: []
        })

      Agent.update(__MODULE__, fn state -> MapSet.difference(state, tickers_to_remove) end)
    end
  end

  def remove(tickers) do
    remove([tickers])
  end
end
