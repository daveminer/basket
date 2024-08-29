defmodule Basket.Websocket.NewsTest do
  @moduledoc false

  use ExUnit.Case, async: false

  import Mox

  alias Basket.Websocket.News

  describe "Stock ticker websocket client lifecycle" do
    test "start_link/1" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      assert {:ok, _pid} = News.start_link(%{})
    end

    test "subscribe/1" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      expect(Basket.Websocket.MockClient, :send_frame, fn _, {:text, message} ->
        case Jason.decode!(message) do
          %{"action" => "subscribe", "news" => ["ALPHA", "BETA"]} ->
            :ok

          _ ->
            raise "Unexpected message format or content"
        end
      end)

      {:ok, _pid} = News.start_link(%{})

      assert :ok == News.subscribe(%{news: ["ALPHA", "BETA"]})
    end

    test "unsubscribe/1" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      expect(Basket.Websocket.MockClient, :send_frame, fn _, {:text, message} ->
        case Jason.decode!(message) do
          %{"action" => "unsubscribe", "news" => ["ALPHA", "BETA"]} ->
            :ok

          _ ->
            raise "Unexpected message format or content"
        end
      end)

      {:ok, _pid} = News.start_link(%{})

      assert :ok == News.unsubscribe(%{news: ["ALPHA", "BETA"]})
    end
  end

  describe "Alpaca websocket client events" do
    test "handle_connect/2" do
      {:ok, %{}} = News.handle_connect(%{}, %{})
    end

    test "handle_disconnect/2" do
      {:ok, %{}} = News.handle_disconnect(%{}, %{})
    end

    test "handle_frame/2 connection success" do
      {:ok, _state} =
        News.handle_frame({:text, ~s([{\"T\":\"success\",\"msg\":\"connected\"}])}, %{})
    end

    test "handle_frame/2 authentication success" do
      {:ok, _state} =
        News.handle_frame({:text, ~s([{\"T\":\"success\",\"msg\":\"connected\"}])}, %{})
    end

    test "handle_frame/2 message" do
      {:ok, _state} =
        News.handle_frame({:text, ~s([{\"T\":\"success\",\"msg\":\"connected\"}])}, %{})
    end
  end
end
