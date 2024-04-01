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
  """
  @spec call(list(String.t()) | String.t(), String.t()) ::
          {:ok, %{bars: list(Bars.t()), tickers_not_found: list(String.t())}}
          | {:error, String.t()}
  def call(tickers, user_id) when is_list(tickers) do
    ticker_list = Enum.join(tickers, ",")
    case Http.Alpaca.latest_quote(ticker_list) do
      {:ok, %{"bars" => bar_list}} ->
        bars = Enum.map(bar_list, fn {k, v} -> Bars.new(k, v) end)
        returned_tickers = Enum.map(bars, fn b -> b.ticker end)

        subscribe_to_tickers(returned_tickers, user_id)

        {:ok, %{bars: bars, tickers_not_found: tickers -- returned_tickers}}

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
