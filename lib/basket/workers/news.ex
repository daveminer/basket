defmodule Basket.Worker.News do
  @moduledoc """
  Designed to run under the Supervisor, this worker will periodically
  check the Alpaca API for new news articles and insert them into the
  data. If the sentiment service is active, it will also queue a job
  to classifiy the sentiment of the article.
  """
  use GenServer

  import Ecto.Query

  require Logger

  alias Basket.{Http.Alpaca, News, Repo, Ticker, Worker.Sentiment}

  @interval Application.compile_env(:basket, :news)[:ms_between_checks]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    :timer.send_interval(@interval, :work)

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    latest_updated_time =
      from(n in News, order_by: [desc: n.updated_date], limit: 1, select: [:updated_date])
      |> Repo.one()

    start_time =
      case latest_updated_time do
        %{updated_date: updated_time} -> updated_time |> DateTime.add(1, :second)
        _ -> NaiveDateTime.utc_now() |> NaiveDateTime.add(-30, :day)
      end

    tickers = Ticker.active_ticker_list()

    write_article_batch_to_db(tickers, start_time)

    {:noreply, state}
  end

  def write_article_batch_to_db(tickers, start_time, page_token \\ nil) do
    {:ok, %{"news" => news, "next_page_token" => next_page_token} = _response} =
      Alpaca.news(
        start_time: start_time,
        page_token: page_token,
        tickers: tickers
      )

    Logger.info("Attempting to write #{length(news)} articles to the database.")

    now = NaiveDateTime.utc_now(:second)

    articles =
      Enum.map(news, fn article ->
        %{
          "id" => article_id,
          "author" => author,
          "content" => content,
          "headline" => headline,
          "images" => images,
          "source" => source,
          "summary" => summary,
          "symbols" => symbols,
          "url" => url,
          "created_at" => created_at,
          "updated_at" => updated_at
        } = article

        {:ok, creation_date, 0} = DateTime.from_iso8601(created_at)
        {:ok, updated_date, 0} = DateTime.from_iso8601(updated_at)

        %{
          article_id: Integer.to_string(article_id),
          author: author,
          content: content,
          headline: headline,
          source: source,
          summary: summary,
          symbols: symbols,
          images: images,
          url: url,
          creation_date: creation_date,
          updated_date: updated_date,
          inserted_at: now,
          updated_at: now
        }
      end)

    {rows_updated, _term} = Repo.insert_all(News, articles, on_conflict: :nothing)

    rows_not_updated = length(news) - rows_updated

    if rows_not_updated != 0 do
      Logger.info("#{rows_not_updated} rows were not inserted during the news batch insert.")
    end

    if sentiment_service_active?() do
      Enum.map(articles, fn article ->
        Sentiment.new(%{
          article_id: article.article_id
        })
      end)
      |> Oban.insert_all(on_conflict: :nothing)
    end

    if next_page_token do
      write_article_batch_to_db(tickers, start_time, next_page_token)
    else
      :ok
    end
  end

  defp sentiment_service_active? do
    Application.get_env(:basket, :news)[:sentiment_service_active]
  end
end
