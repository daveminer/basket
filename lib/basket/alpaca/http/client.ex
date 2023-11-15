defmodule Basket.Alpaca.HttpClient do
  @moduledoc """
  HTTP client for Alpaca API.
  """

  use HTTPoison.Base

  require Logger

  @assets_resource "/v2/assets"
  @latest_quotes_resource "/v2/stocks/bars/latest"

  def process_request_headers(headers) do
    headers ++ [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]
  end

  @spec latest_quote(String.t()) :: {:error, any()} | {:ok, map()}
  def latest_quote(ticker) do
    case get("#{data_url()}#{@latest_quotes_resource}", [],
           params: %{feed: "iex", symbols: ticker}
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec list_assets() :: {:error, any()} | {:ok, list(map())}
  def list_assets do
    case get("#{market_url()}#{@assets_resource}", [],
           params: %{status: "active", asset_class: "us_equity"}
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}
    end
  end

  def process_response_body(body) do
    Jason.decode!(body)
  end

  defp data_url, do: Application.fetch_env!(:basket, :alpaca)[:data_http_url]

  defp market_url, do: Application.fetch_env!(:basket, :alpaca)[:market_http_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end
