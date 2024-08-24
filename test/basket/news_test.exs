defmodule Basket.NewsTest do
  use ExUnit.Case, async: true
  use Basket.DataCase

  alias Basket.{News, Repo}

  @valid_params %{
    article_id: "123",
    author: "Jane Doe",
    content: "This is a test article",
    creation_date: ~U[2024-08-23 10:00:00Z],
    headline: "Test Headline",
    images: [%{"url" => "http://example.com/image.png"}],
    sentiment: "positive",
    sentiment_confidence: Decimal.new("0.8"),
    sentiment_id: 1,
    source: "Example Source",
    summary: "Test Summary",
    symbols: ["AAA", "BBB"],
    updated_date: ~U[2024-08-23 10:00:00Z],
    url: "http://example.com/article"
  }

  describe "changeset/2" do
    test "creates a valid changeset with valid params" do
      changeset = News.changeset(%News{}, @valid_params)
      assert changeset.valid?
    end

    test "requires mandatory fields" do
      invalid_params =
        Map.drop(@valid_params, [
          :article_id,
          :author,
          :creation_date,
          :source,
          :symbols,
          :updated_date,
          :url
        ])

      changeset = News.changeset(%News{}, invalid_params)
      refute changeset.valid?

      assert %{
               article_id: ["can't be blank"],
               author: ["can't be blank"],
               creation_date: ["can't be blank"],
               source: ["can't be blank"],
               symbols: ["can't be blank"],
               updated_date: ["can't be blank"],
               url: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "add!/1" do
    test "successfully adds a valid news article" do
      news =
        Map.put(@valid_params, :article_id, "101")
        |> News.add!()

      assert news.id
      assert Repo.get(News, news.id)
    end

    test "raises an error with invalid params" do
      invalid_params = Map.drop(@valid_params, [:article_id])

      assert_raise Postgrex.Error, fn ->
        News.add!(invalid_params)
      end
    end
  end

  describe "sentiment_for_tickers/1" do
    setup do
      news1 =
        Map.put(@valid_params, :symbols, ["AAA"])
        |> News.add!()

      news2 =
        Map.put(@valid_params, :symbols, ["BBB"])
        |> Map.put(:article_id, "124")
        |> News.add!()

      news3 =
        Map.put(@valid_params, :symbols, ["AAA", "BBB"])
        |> Map.put(:article_id, "125")
        |> News.add!()

      {:ok, news1: news1, news2: news2, news3: news3}
    end

    test "returns news articles for a single ticker" do
      result = News.sentiment_for_tickers("AAA")
      assert [{"AAA", "positive", 2}] = result
    end

    test "returns aggregated results for a list of tickers" do
      result = News.sentiment_for_tickers(["AAA", "BBB"])

      assert Enum.any?(result, fn {symbol, sentiment, count} ->
               symbol == "AAA" and sentiment == "positive" and count == 2
             end)

      assert Enum.any?(result, fn {symbol, sentiment, count} ->
               symbol == "BBB" and sentiment == "positive" and count == 2
             end)
    end
  end

  describe "sentiment_enabled?/0" do
    test "returns true if sentiment service is enabled" do
      Application.put_env(:basket, :news, sentiment_service_enabled: true)
      assert News.sentiment_enabled?() == true
    end

    test "returns false if sentiment service is disabled" do
      Application.put_env(:basket, :news, sentiment_service_enabled: false)
      assert News.sentiment_enabled?() == false
    end
  end
end
