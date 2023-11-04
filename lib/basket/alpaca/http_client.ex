defmodule Basket.Alpaca.HttpClient do
  alias Mint.HTTPError
  use HTTPoison.Base

  require Logger

  @resource "/v2/assets"

  def process_request_headers(headers) do
    headers ++ [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]
  end

  @spec list_assets() :: {:error, any()} | {:ok, list(map())}
  def list_assets() do
    case get(@resource) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec list_tickers() :: list(String.t()) | {:error, any()}
  def list_tickers() do
    case list_assets() do
      {:ok, body} ->
        Enum.map(body, fn asset ->
          asset["symbol"]
        end)

      {:error, error} ->
        {:error, error}
    end
  end

  def process_request_params(params) do
    Map.put(params, :status, "active")
    |> Map.put(:asset_class, "us_equity")
  end

  def process_request_url(resource) do
    "#{url()}#{resource}"
  end

  def process_response_body(body) do
    Jason.decode!(body)
  end

  defp url, do: Application.fetch_env!(:basket, :alpaca)[:market_http_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end
