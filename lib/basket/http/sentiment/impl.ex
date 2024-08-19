defmodule Basket.Http.Sentiment.Impl do
  @moduledoc """
  Implmentation of the Alpaca API HTTP client.
  """
  use HTTPoison.Base

  @behaviour Basket.Http.Sentiment

  @doc false
  @impl true
  def get_sentiment(id) do
    case get("#{url()}/#{id}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404, body: body}} ->
        {:error, body}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Runs a sentiment analysis job on the provided text. Returns
  immediately with an id, and the Sentiment service will send
  a callback that references this id when the job is complete.
  """
  @impl true
  def run_sentiment(article_id, tags, text) do
    encoded_text = text |> HtmlEntities.encode()

    case post(
           "#{url()}/sentiment/new?callback_url=#{Application.fetch_env!(:basket, :host)}/sentiment/new/callback",
           Jason.encode!([%{article_id: article_id, tags: tags, text: encoded_text}])
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
    headers ++ [{"Content-Type", "application/json"}]
  end

  @impl true
  def process_response_body(body), do: Jason.decode!(body)

  defp url, do: Application.fetch_env!(:basket, :news)[:sentiment_service_url]
end
