defmodule Basket.Http.Alpaca.Impl do
  @moduledoc """
  Implmentation of the Alpaca API HTTP client.
  """
  use HTTPoison.Base

  @behaviour Basket.Http.Alpaca

  @assets_resource "/v2/assets"
  @latest_quotes_resource "/v2/stocks/bars/latest"

  @doc """
  Returns the latest quote for a ticker from the Alpaca API
  """
  @impl Basket.Http.Alpaca
  def latest_quote(tickers) do
    case get(
           "#{data_url()}#{@latest_quotes_resource}",
           [],
           params: %{feed: "iex", symbols: tickers}
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl Basket.Http.Alpaca
  def list_assets do
    case get(
           "#{market_url()}#{@assets_resource}",
           [],
           params: %{status: "active", asset_class: "us_equity"}
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl true
  def process_request_headers(headers) do
    headers ++ [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]
  end

  @impl true
  def process_response_body(body), do: Jason.decode!(body)

  defp data_url, do: Application.fetch_env!(:basket, :alpaca)[:data_http_url]

  defp market_url, do: Application.fetch_env!(:basket, :alpaca)[:market_http_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end
