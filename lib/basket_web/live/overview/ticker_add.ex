defmodule BasketWeb.Live.Overview.TickerAdd do
  @moduledoc """
  Creates a new ticker in the table.
  """

  alias Basket.Http
  alias BasketWeb.Live.Overview.TickerBar

  require Logger

  @doc """
  Creates a row to be added to the ticker bar table. Deserializes the data into TickerBar instances
  before returning.

  ## Example
    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => %{"XYZ" => %{"o" => "100.0"}}}} end)
    iex> TickerAdd.call("XYZ")
    %{"S" => %TickerBar{value: "XYZ", prev_value: nil}, "o" => %TickerBar{value: "100.0", prev_value: nil}}

    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => nil}} end)
    iex> TickerAdd.call("XYZ")
    :no_data

    iex> Mox.expect(Basket.Http.MockAlpaca, :latest_quote, fn _ -> {:ok, %{"bars" => %{}}} end)
    iex> TickerAdd.call("XYZ")
    :market_closed

  """
  @spec call(ticker :: String.t()) :: :no_data | :market_closed | map() | {:error, String.t()}
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
