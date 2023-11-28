defmodule Basket.Websocket.AlpacaTest do
  use ExUnit.Case, async: false

  import Mox

  alias Basket.Websocket.Alpaca
  alias Basket.Support.MockWebsocketServer

  # setup do
  #   # {:ok, {pid, server_ref, url}} = MockWebsocketServer.start(self())
  #   # on_exit(fn -> MockWebsocketServer.shutdown(server_ref) end)
  #   {:ok, socket} = TestServer.websocket_init("/iex")

  #   {:ok, %{socket: socket}}
  # end

  describe "Alpaca websocket client" do
    test "connects with authorization" do
      # IO.inspect(server_ref, label: "SERVER_REF")
      # IO.inspect(url, label: "URL")
      # config = Application.get_env(:basket, :alpaca)
      # config = Keyword.put(config, :market_ws_url, TestServer.url())
      # IO.inspect(config, label: "CONFIG")
      # Application.put_env(:basket, :alpaca, config)
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)
      assert {:ok, _pid} = Alpaca.start_link(%{})
    end

    test "subscribes to a ticker" do
      # config = Application.get_env(:basket, :alpaca)
      # config = Keyword.put(config, :market_ws_url, TestServer.url())
      # Application.put_env(:basket, :alpaca, config)
      # IO.inspect(socket, label: "SOCKER")
      # IO.inspect(pid, label: "PID")
      expect(Basket.Websocket.MockClient, :start_link, fn _, _, _, _ -> {:ok, self()} end)
      expect(Basket.Websocket.MockClient, :send_frame, fn _, _ -> :ok end)
      # :ok =
      #   TestServer.websocket_handle(socket,
      #     match: fn
      #       {:"$websockex_send", {pid, [:alias | _]}, {:text, message}}, _state ->
      #         %{}
      #     end
      #   )

      {:ok, pidd} = Alpaca.start_link(%{})

      # :ok =
      #   TestServer.websocket_handle(
      #     # ,
      #     socket,
      #     # match: fn {:text, message}, _state -> true end
      #     to: fn {:text,
      #             "{\"action\":\"subscribe\",\"bars\":[\"XYZ\"],\"quotes\":[],\"trades\":[]}"},
      #            state ->
      #       {:reply,
      #        {:text,
      #         ~s([{"T":"subscription","trades":["AAPL"],"quotes":["AMD","CLDR"],"bars":["*"],"updatedBars":[],"dailyBars":["VOO"],"statuses":["*"],"lulds":[],"corrections":["AAPL"],"cancelErrors":["AAPL"]}])},
      #        state}
      #     end
      #   )

      result = Alpaca.subscribe(%{bars: ["XYZ"], quotes: [], trades: []})
      # Alpaca.Impl.wait_for_message()
      # :ok = WebSockex.cast(pidd, {:system_get_state, self()})
      # TestServer.IO.inspect(inst, label: "INST")
      # :timer.sleep(1000)
      # info = :erlang.process_info(pidd)
      # IO.inspect(info, label: "INFO")
      # assert_received {:ok, ^pidd, response}, 5000
      # IO.inspect(response, label: "RESULT")
    end
  end
end
