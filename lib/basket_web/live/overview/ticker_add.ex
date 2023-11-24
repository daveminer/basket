defmodule BasketWeb.Live.Overview.TickerAdd do
  @moduledoc """
  Creates a new ticker in the table.
  """

  alias Basket.Http
  alias BasketWeb.Live.Overview.TickerBar

  require Logger

  @doc """
  Creates a row to be added to the ticker bar table.
  """
  def call(ticker) do
    case Http.Alpaca.latest_quote(ticker) do
      {:ok, response} ->
        case build_ticker_bars(response) do
          :no_data ->
            # TODO: info flash
            :no_data

          :market_closed ->
            :market_closed

          bars ->
            bars
        end

      {:error, error} ->
        # TODO: error flash
        Logger.error("Could not subscribe to ticker: #{error}")
    end
  end

  defp build_ticker_bars(%{"bars" => nil}) do
  end

  defp build_ticker_bars(%{"bars" => ticker_bars}) do
    # TODO: check first
    new_ticker_bars = Map.to_list(ticker_bars) |> List.first()

    case new_ticker_bars do
      nil ->
        :no_data

      %{} ->
        :market_closed

      bars ->
        Enum.reduce(bars, %{}, fn {k, v}, acc ->
          Map.put(acc, k, %TickerBar{value: v})
        end)

        # TODO: check
        # Map.merge(new_bars, %{"S" => %TickerBar{value: ticker}})
    end
  end
end
