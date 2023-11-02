defmodule Basket.Alpaca.WsClient do
  use WebSockex
  require Logger

  def start_link(state) do
    IO.puts("Starting WS Client: #{iex_feed()}")

    auth_headers = [
      {"APCA-API-KEY-ID", api_key()},
      {"APCA-API-SECRET-KEY", api_secret()}
    ]

    # WebSockex.start_link(iex_feed(), __MODULE__, state, extra_headers: auth_headers)
    WebSockex.start_link(iex_feed(), __MODULE__, state)
  end

  def handle_connect(conn, state) do
    Logger.info("Connected! #{inspect(conn)} ::: #{state}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    Logger.info("Local close")
    # Logger.info("Local close with reason: #{inspect(disconnect_map)}")
    super(disconnect_map, state)
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Cast state: #{state}")
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  @doc """
  Receive a connection success message and respond with an authentication attempt.
  """
  def handle_frame({type, "[{\"T\":\"success\",\"msg\":\"connected\"}]"}, state) do
    Logger.info("Connection Message Received.")

    # Logger.info("API KEY: #{api_key()}")
    # Logger.info("API SECRET: #{api_secret()}")

    msg = Jason.encode!(%{"action" => "auth", "key" => api_key(), "secret" => api_secret()})
    IO.inspect("MSG: #{msg}")
    # IO.inspect("REsult: #{result}, Sending: #{msg}")
    # msg = "{\"action\":\"subscribe\",\"trades\":[\"AAPL\"],\"quotes\":[\"AMD\",\"CLDR\"],\
    #       \"bars\":[\"*\"]}"
    {:reply, {type, msg}, state}
    # {:ok, state}
  end

  def handle_frame({type, "[{\"T\":\"success\",\"msg\":\"authenticated\"}]"}, state) do
    Logger.info("Authenticated!")

    msg = "{\"action\":\"subscribe\",\"trades\":[\"AAPL\"],\"quotes\":[\"AMD\",\"CLDR\"],\
      \"bars\":[\"*\"]}"
    {:reply, {type, msg}, state}
    # {:ok, state}
  end

  def handle_frame({_type, msg}, state) do
    Logger.info("Received Message: #{msg}")

    Logger.info("State: #{state}")
    {:reply, {:text, msg}, :fake_state}
  end

  defp iex_feed, do: "#{ws_server_url()}/iex"

  defp ws_server_url, do: Application.fetch_env!(:basket, :alpaca)[:ws_server_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end
