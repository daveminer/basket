defmodule Basket.Websocket.AlpacaTest do
  use ExUnit.Case, async: false

  import Mox

  alias Basket.Websocket.Alpaca

  describe "Alpaca websocket client lifecycle" do
    test "start_link/1" do
      # TODO: verify expects signatures
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      assert {:ok, _pid} = Alpaca.start_link(%{})
    end

    test "subscribe/1" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      expect(Basket.Websocket.MockClient, :send_frame, fn _,
                                                          {:text,
                                                           "{\"action\":\"subscribe\",\"bars\":[\"XYZ\"],\"quotes\":[],\"trades\":[]}"} ->
        :ok
      end)

      {:ok, _pid} = Alpaca.start_link(%{})

      assert :ok == Alpaca.subscribe(%{bars: ["XYZ"], quotes: [], trades: []})
    end

    test "unsubscribe/1" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      expect(Basket.Websocket.MockClient, :send_frame, fn _,
                                                          {:text,
                                                           "{\"action\":\"unsubscribe\",\"bars\":[\"XYZ\"],\"quotes\":[],\"trades\":[]}"} ->
        :ok
      end)

      {:ok, _pid} = Alpaca.start_link(%{})

      assert :ok == Alpaca.unsubscribe(%{bars: ["XYZ"], quotes: [], trades: []})
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
