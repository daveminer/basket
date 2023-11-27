defmodule Basket.Websocket.AlpacaTest do
  use ExUnit.Case, async: false

  alias Basket.Websocket.Alpaca
  alias Basket.Support.MockWebsocketServer

  # setup do
  #   {:ok, socket} = TestServer.websocket_init("/iex")
  #   {:ok, socket: socket}
  # end

  setup do
    {:ok, {pid, server_ref, url}} = MockWebsocketServer.start(self())
    on_exit(fn -> MockWebsocketServer.shutdown(server_ref) end)

    %{pid: pid, url: url, server_ref: server_ref}
  end

  describe "Alpaca websocket client" do
    test "connects with authorization" do
      # IO.inspect(server_ref, label: "SERVER_REF")
      # IO.inspect(url, label: "URL")
      # config = Application.get_env(:basket, :alpaca)
      # config = Keyword.put(config, :market_ws_url, url)
      # Application.put_env(:basket, :alpaca, config)

      {:ok, _pid} = Alpaca.start_link("XYZ")
    end

    test "subscribes to a ticker", %{pid: pid, server_ref: server_ref, url: url} do
      # config = Application.get_env(:basket, :alpaca)
      # config = Keyword.put(config, :market_ws_url, url)
      # Application.put_env(:basket, :alpaca, config)
      # IO.inspect(elem(socket, 0), label: "SOCKER")
      IO.inspect(pid, label: "PID")

      # ,
      # :ok =
      #   TestServer.websocket_handle(
      #     socket
      #     # to: fn {:text,
      #     #         "{\"action\":\"subscribe\",\"bars\":[\"XYZ\"],\"quotes\":[],\"trades\":[]}"},
      #     #        state ->
      #     #   {:reply, {:text, "pong"}, state}
      #     # end
      #   )

      # :ok =
      #   TestServer.websocket_handle(socket,
      #     match: fn
      #       {:"$websockex_send", {pid, [:alias | _]}, {:text, message}}, _state ->
      #         %{}
      #     end
      #   )

      result = Alpaca.subscribe(%{bars: ["XYZ"], quotes: [], trades: []})

      IO.inspect(result, label: "RESULT")
    end
  end
end
