defmodule Basket.Worker.SentimentTest do
  @moduledoc false

  use Basket.DataCase, async: false

  import ExUnit.CaptureLog
  import Mox
  import Basket.Factory

  alias Basket.Worker.Sentiment
  alias Oban.Job

  setup :verify_on_exit!

  describe "perform/1" do
    test "logs a warning when no text is found for the article" do
      article_id = "nonexistent_article_id"
      insert(:news, article_id: article_id, content: nil)

      assert capture_log(fn ->
               Sentiment.perform(%Job{args: %{"article_id" => article_id}})
             end) =~ "No text found for article #{article_id}"
    end

    test "runs sentiment analysis and logs info when text is found" do
      article_id = "existing_article_id"
      content = "This is a sample article content."
      symbols = ["AAPL", "GOOG"]
      insert(:news, article_id: article_id, content: content, symbols: symbols)

      expect(Basket.Http.MockSentiment, :run_sentiment, fn ^article_id, ^symbols, ^content ->
        :ok
      end)

      assert :ok = Sentiment.perform(%Job{args: %{"article_id" => article_id}})
    end
  end
end
