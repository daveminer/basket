defmodule Basket.Http.Alpaca.Impl do
  @moduledoc """
  Implmentation of the Alpaca API HTTP client.
  """
  use HTTPoison.Base

  @behaviour Basket.Http.Alpaca

  @assets_resource "/v2/assets"
  @latest_quotes_resource "/v2/stocks/bars/latest"
  @news_resource "/v1beta1/news"

  @doc """
  Returns the latest quote for a ticker from the Alpaca API
  """
  @impl true
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

  @impl true
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
  def news(opts) do
    page_token = Keyword.get(opts, :page_token, [])
    start_time = Keyword.get(opts, :start_time)
    tickers = Keyword.get(opts, :tickers, [])

    params = %{include_content: true, limit: 50}

    params =
      if Enum.empty?(tickers) do
        params
      else
        Map.put(params, :symbols, Enum.join(tickers, ","))
      end

    params =
      if is_nil(start_time) do
        params
      else
        {:ok, start_time} = DateTime.from_naive(start_time, "Etc/UTC")
        Map.put(params, :start, DateTime.to_iso8601(start_time))
      end

    params =
      if is_nil(page_token) do
        params
      else
        Map.put(params, :page_token, page_token)
      end

    case get(
           "#{data_url()}#{@news_resource}",
           [],
           params: params
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        {:error, body}

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
