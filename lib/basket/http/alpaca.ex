defmodule Basket.Http.Alpaca do
  @moduledoc """
  Interface for the Alpaca REST API.
  """

  @type news_filter :: [
          start_time: NaiveDateTime.t(),
          tickers: list(String.t())
        ]

  @callback latest_quote(ticker :: String.t()) :: {:ok, list(map())} | {:error, String.t()}
  @callback list_assets() :: {:ok, list(map())} | {:error, String.t()}
  @callback news(opts :: news_filter()) ::
              {:ok, list(map())} | {:error, String.t()}

  def latest_quote(ticker), do: impl().latest_quote(ticker)
  def list_assets, do: impl().list_assets()
  def news(opts), do: impl().news(opts)

  defp impl,
    do: Application.get_env(:basket, :alpaca_http_client, Basket.Http.Alpaca.Impl)
end
