defmodule BasketWeb.Live.Overview.TickerAdd do
  @moduledoc """
  Creates a new ticker in the table.
  """

  alias Basket.Http
  alias Basket.Websocket.TickerAgent

  require Logger

  @doc """
  Creates a row to be added to the ticker bar table. Deserializes the data into TickerBar instances
  before returning.

  ## Example
    bars = build(:new_bars)
    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => {}}} end)
    iex> TickerAdd.call("ABC")
    []

    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => %{"ABC" => ^bars}}} end)
    iex> TickerAdd.call("ABC")
    [%Bars{value: "ABC", prev_value: nil}, "o" => %TickerBar{value: "100.0", prev_value: nil}}]

    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => %{"ABC" => ^bars, "XYZ" => ^bars}}} end)
    iex> TickerAdd.call(["ABC", "XYZ"])
    %{"S" => %BarS{value: "ABC", prev_value: nil}, "o" => %TickerBar{value: "100.0", prev_value: nil}}
  """
  @spec call(list(String.t()) | String.t()) ::
          {:ok, {list(Http.Alpaca.Bars.t()), list(String.t())}} | {:error, String.t()}
  def call(tickers) when is_list(tickers) do
    ticker_list = Enum.join(tickers, ",")

    case Http.Alpaca.latest_quote(ticker_list) do
      {:ok, %{"bars" => bar_list}} ->
        bars = Enum.map(bar_list, fn {k, v} -> Http.Alpaca.Bars.new(k, v) end)

        returned_tickers = Enum.map(bars, fn b -> b.ticker end)
        :ok = TickerAgent.add(returned_tickers)
        subscribe_to_tickers(returned_tickers)

        {:ok, {bars, tickers -- returned_tickers}}

      {:error, %{"message" => error}} ->
        {:error, error}
    end
  end

  def call(ticker), do: call([ticker])

  defp subscribe_to_tickers(tickers),
    do:
      Enum.each(tickers, fn ticker ->
        case BasketWeb.Endpoint.subscribe("bars-#{ticker}") do
          :ok -> :ok
          {:error, error} -> Logger.error("Could not subscribe to ticker: #{error}")
        end
      end)
end
