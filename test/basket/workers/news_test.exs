defmodule Basket.Worker.NewsTest do
  @moduledoc false

  use Basket.DataCase, async: true
  import Mox

  alias Basket.Worker.News
  alias Basket.{News, Repo, Ticker}

  describe "handle_info/2" do
    setup do
      _ticker = Basket.Repo.insert!(%Ticker{ticker: "AAPL"})
      :ok
    end

    test "fetches and inserts articles into the database" do
      news_data = %{
        "news" => [
          %{
            "id" => 1,
            "author" => "Author",
            "content" => "Content",
            "headline" => "Headline",
            "images" => [],
            "source" => "Source",
            "summary" => "Summary",
            "symbols" => ["AAPL"],
            "url" => "http://example.com",
            "created_at" => "2022-01-01T00:00:00Z",
            "updated_at" => "2022-01-01T00:00:00Z"
          }
        ],
        "next_page_token" => nil
      }

      Basket.Http.MockAlpaca
      |> expect(:news, fn _ -> {:ok, news_data} end)

      Basket.Http.MockSentiment
      |> expect(:run_sentiment, fn _, _, _ -> :ok end)

      before_count = Repo.all(News) |> length()

      assert {:noreply, _} = Basket.Worker.News.handle_info(:work, %{})

      after_count = Repo.all(News) |> length()

      assert after_count == before_count + 1
    end

    test "handles no new articles gracefully" do
      Basket.Http.MockAlpaca
      |> expect(:news, fn _params -> {:ok, %{"news" => [], "next_page_token" => nil}} end)

      assert {:noreply, _} = Basket.Worker.News.handle_info(:work, %{})
    end
  end
end
