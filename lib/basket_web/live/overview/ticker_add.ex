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
  @spec call(ticker :: String.t()) :: :no_data | :market_closed | Map.t()
  def call(ticker) do
    case Http.Alpaca.latest_quote(ticker) do
      {:ok, response} ->
        build_ticker_bars(response)

      {:error, error} ->
        {:error, error}
    end
  end

  defp build_ticker_bars(%{"bars" => nil}), do: :no_data

  defp build_ticker_bars(%{"bars" => ticker_bars}) do
    new_ticker_bars = Map.to_list(ticker_bars) |> List.first()

    case new_ticker_bars do
      nil ->
        :no_data

      map when map_size(map) == 0 ->
        :market_closed

      {ticker, bars} ->
        new_bars =
          Enum.reduce(bars, %{}, fn {k, v}, acc ->
            Map.put(acc, k, %TickerBar{value: v})
          end)

        Map.merge(new_bars, %{"S" => %TickerBar{value: ticker}})
    end
  end
end
