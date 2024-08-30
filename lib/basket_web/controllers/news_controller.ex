defmodule BasketWeb.NewsController do
  use BasketWeb, :controller

  require Logger
  alias Basket.News

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, %{"ticker" => ticker} = params) do
    news = News.get_news(ticker, params["sentiment"])

    assign(conn, :news, news)
    |> render("index.html")
  end
end
