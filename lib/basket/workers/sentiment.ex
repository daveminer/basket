defmodule Basket.Worker.Sentiment do
  @moduledoc """
  Begins a new sentiment analysis job for a given article.
  """

  use Oban.Worker, queue: :news

  require Logger

  import Ecto.Query

  alias Basket.{Http.Sentiment, News, Repo}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"article_id" => article_id}}) do
    {content, symbols} =
      from(n in News, where: n.article_id == ^article_id, select: {n.content, n.symbols})
      |> Repo.one()

    case content do
      nil ->
        Logger.warning("No text found for article #{article_id}")

      content ->
        :ok = Sentiment.run_sentiment(article_id, symbols, content)

        Logger.info("Sentiment analysis completed for article #{article_id}")
    end
  end
end
