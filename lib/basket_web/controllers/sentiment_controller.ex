defmodule BasketWeb.SentimentController do
  use BasketWeb, :controller

  require Logger
  alias Basket.{News, Repo}

  @spec callback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def callback(conn, %{"results" => sentiments}) do
    Enum.each(sentiments, fn sentiment ->
      %{"article_id" => article_id} = sentiment

      article_id = if is_integer(article_id), do: Integer.to_string(article_id), else: article_id

      case Repo.get_by(News, article_id: article_id) do
        nil ->
          Logger.warning("Article ID not found during sentiment callback", %{
            article_id: article_id
          })

        record ->
          %{
            "article_id" => id,
            "sentiment" => %{
              "label" => label,
              "score" => score,
              "tags" => _tags
            }
          } = sentiment

          changeset =
            News.changeset(record, %{
              sentiment: label |> String.downcase(),
              sentiment_id: id,
              sentiment_confidence: score
            })

          Repo.update!(changeset)
      end
    end)

    put_status(conn, :ok)
    |> json(%{message: "ok"})
  end
end
