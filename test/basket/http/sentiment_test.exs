defmodule Basket.Http.SentimentTest do
  use ExUnit.Case, async: false

  import Basket.Factory

  alias Basket.Http.Sentiment

  describe "get_sentiment/1" do
    test "gets a sentiment by id" do
      sentiment_payload = build(:sentiment_payload)

      TestServer.add("/1",
        via: :get,
        to: fn conn ->
          Plug.Conn.resp(conn, 200, Jason.encode!(sentiment_payload))
        end
      )

      config = Application.get_env(:basket, :news)
      config = Keyword.put(config, :sentiment_service_url, TestServer.url())
      Application.put_env(:basket, :news, config)

      assert {
               :ok,
               ^sentiment_payload
             } = Sentiment.Impl.get_sentiment(1)
    end
  end

  describe "run_sentiment/3" do
    test "queues a run of a sentiment job" do
      TestServer.add("/sentiment/new",
        via: :post,
        to: fn conn ->
          Plug.Conn.resp(conn, 201, "{}")
        end
      )

      config = Application.get_env(:basket, :news)
      config = Keyword.put(config, :sentiment_service_url, TestServer.url())
      Application.put_env(:basket, :news, config)

      assert :ok = Sentiment.Impl.run_sentiment("1", ["TESTTAG"], "This is a test")
    end
  end
end
