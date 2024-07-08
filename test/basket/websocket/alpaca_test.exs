defmodule Basket.Websocket.AlpacaTest do
  @moduledoc false

  use ExUnit.Case, async: false

  import Mox

  alias Basket.Websocket.Alpaca

  describe "Alpaca websocket client lifecycle" do
    test "start_link/1" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      assert {:ok, _pid} = Alpaca.start_link(%{})
    end

    test "subscribe/1" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      expect(Basket.Websocket.MockClient, :send_frame, fn _, {:text, message} ->
        case Jason.decode!(message) do
          %{"action" => "subscribe", "bars" => bars, "quotes" => quotes, "trades" => trades}
          when bars == ["ALPHA"] and quotes == [] and trades == [] ->
            :ok

          _ ->
            raise "Unexpected message format or content"
        end
      end)

      {:ok, _pid} = Alpaca.start_link(%{})

      assert :ok == Alpaca.subscribe(%{bars: ["ALPHA"], quotes: [], trades: []})
    end

    test "unsubscribe/1" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      expect(Basket.Websocket.MockClient, :send_frame, fn _, {:text, message} ->
        case Jason.decode!(message) do
          %{"action" => "unsubscribe", "bars" => bars, "quotes" => quotes, "trades" => trades}
          when bars == ["ALPHA"] and quotes == [] and trades == [] ->
            :ok

          _ ->
            raise "Unexpected message format or content"
        end
      end)

      {:ok, _pid} = Alpaca.start_link(%{})

      assert :ok == Alpaca.unsubscribe(%{bars: ["ALPHA"], quotes: [], trades: []})
    end
  end

  describe "Alpaca websocket client events" do
    test "handle_connect/2" do
      {:ok, %{}} = Alpaca.handle_connect(%{}, %{})
    end

    test "handle_disconnect/2" do
      {:ok, %{}} = Alpaca.handle_disconnect(%{}, %{})
    end

    test "handle_frame/2 connection success" do
      {:ok, _state} =
        Alpaca.handle_frame({:text, ~s([{\"T\":\"success\",\"msg\":\"connected\"}])}, %{})
    end

    test "handle_frame/2 authentication success" do
      {:ok, _state} =
        Alpaca.handle_frame({:text, ~s([{\"T\":\"success\",\"msg\":\"connected\"}])}, %{})
    end

    test "handle_frame/2 message" do
      {:ok, _state} =
        Alpaca.handle_frame({:text, ~s([{\"T\":\"success\",\"msg\":\"connected\"}])}, %{})
    end
  end
end
