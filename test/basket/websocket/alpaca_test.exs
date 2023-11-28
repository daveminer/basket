defmodule Basket.Websocket.AlpacaTest do
  use ExUnit.Case, async: false

  import Mox

  alias Basket.Websocket.Alpaca

  describe "Alpaca websocket client" do
    test "connects with authorization" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)

      assert {:ok, _pid} = Alpaca.start_link(%{})
    end

    test "subscribes to a ticker" do
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)
      expect(Basket.Websocket.MockClient, :send_frame, fn _, _ -> :ok end)

      {:ok, _pid} = Alpaca.start_link(%{})

      assert :ok == Alpaca.subscribe(%{bars: ["XYZ"], quotes: [], trades: []})
    end
  end
end
