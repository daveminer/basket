defmodule Basket.Http.Alpaca do
  @callback latest_quote(ticker :: String.t()) :: {:ok, map} | {:error, String.t()}
  @callback list_assets() :: {:ok, map} | {:error, String.t()}

  def latest_quote(ticker), do: impl().latest_quote(ticker)
  def list_assets(), do: impl().list_assets()

  defp impl,
    do: Application.get_env(:basket, :alpaca_http_client, Basket.Http.Alpaca.Impl)
end
