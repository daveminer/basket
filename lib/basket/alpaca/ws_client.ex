defmodule Basket.Alpaca.WsClient do
  use WebSockex
  require Logger

  @default_subscription_msg "{\"action\":\"subscribe\",\"trades\":[\"AAPL\"],\"quotes\":[\"AMD\",\"CLDR\"],\
          \"bars\":[\"*\"]}"
  def start_link(state) do
    Logger.info("Starting Alpaca websocket client.")

    WebSockex.start_link(iex_feed(), __MODULE__, state, extra_headers: auth_headers())
  end

  def handle_connect(_conn, state) do
    Logger.info("Alpaca websocket connected.")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    Logger.info("Alpaca websocket disconnected.")
    super(disconnect_map, state)
  end

  @doc """
  Receive a connection success message and respond with an authentication attempt.
  """
  def handle_frame({_type, "[{\"T\":\"success\",\"msg\":\"connected\"}]"}, state) do
    Logger.info("Connection Message Received.")

    {:ok, state}
  end

  def handle_frame({type, "[{\"T\":\"success\",\"msg\":\"authenticated\"}]"}, state) do
    Logger.info("Alpaca websocket authenticated.")

    {:reply, {type, @default_subscription_msg}, state}
  end

  def handle_frame({_type, msg}, state) do
    Logger.info("Received Message: #{msg}")

    {:ok, state}
  end

  defp auth_headers, do: [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]

  defp iex_feed, do: "#{ws_server_url()}/iex"

  defp ws_server_url, do: Application.fetch_env!(:basket, :alpaca)[:ws_server_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end
