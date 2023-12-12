defmodule BasketWeb.Live.Overview.TickerAdd do
  @moduledoc """
  Creates a new ticker in the table. Will also track the Presence and subscribe to the
  channel for each ticker.
  """

  alias Basket.Http
  alias Basket.Http.Alpaca.Bars
  alias BasketWeb.Presence

  require Logger

  @doc """
  Creates a row to be added to the ticker bar table. Deserializes the data into TickerBar instances
  before returning.

  ## Example
    iex> Mox.set_mox_global()
    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => []}} end)
    iex> Mox.expect(Basket.Websocket.MockClient, :send_frame, fn _, _ -> :ok end)
    iex> TickerAdd.call("ABC", 1)
    {:ok, {[], ["ABC"]}}
    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => build(:bars_payload, ticker: "ABC")}} end)
    iex> Mox.expect(Basket.Websocket.MockClient, :send_frame, fn _, _ -> :ok end)
    iex> TickerAdd.call("ABC", 1)
    {:ok, {[%Basket.Http.Alpaca.Bars{ticker: "ABC", close: 187.15, open: 187.11, high: 187.15, low: 187.05, volume: 43025, timestamp: "2023-11-15T20:59:00Z", count: 357, vwap: 187.117416}], []}}
    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => Map.merge(build(:bars_payload, ticker: "ABC"), build(:bars_payload))}} end)
    iex> Mox.expect(Basket.Websocket.MockClient, :send_frame, 2, fn _, _ -> :ok end)
    iex> TickerAdd.call(["ABC", "XYZ"], 1)
    {:ok, {[%Basket.Http.Alpaca.Bars{ticker: "ABC", close: 187.15, open: 187.11, high: 187.15, low: 187.05, volume: 43025, timestamp: "2023-11-15T20:59:00Z", count: 357, vwap: 187.117416}, %Basket.Http.Alpaca.Bars{ticker: "XYZ", close: 187.15, open: 187.11, high: 187.15, low: 187.05, volume: 43025, timestamp: "2023-11-15T20:59:00Z", count: 357, vwap: 187.117416}], []}}
  """
  @spec call(list(String.t()) | String.t(), String.t()) ::
          {:ok, {list(Bars.t()), list(String.t())}} | {:error, String.t()}
  def call(tickers, user_id) when is_list(tickers) do
    ticker_list = Enum.join(tickers, ",")

    case Http.Alpaca.latest_quote(ticker_list) do
      {:ok, %{"bars" => bar_list}} ->
        bars = Enum.map(bar_list, fn {k, v} -> Bars.new(k, v) end)
        returned_tickers = Enum.map(bars, fn b -> b.ticker end)

        subscribe_to_tickers(returned_tickers, user_id)

        {:ok, {bars, tickers -- returned_tickers}}

      {:error, %{"message" => error}} ->
        {:error, error}
    end
  end

  def call(ticker, user_id), do: call([ticker], user_id)

  defp subscribe_to_tickers(tickers, user_id),
    do:
      Enum.each(tickers, fn ticker ->
        Presence.track(self(), "bars-#{ticker}", user_id, %{})

        case BasketWeb.Endpoint.subscribe("bars-#{ticker}") do
          :ok -> :ok
          {:error, error} -> Logger.error("Could not subscribe to ticker: #{error}")
        end
      end)
end
