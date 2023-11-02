defmodule Basket.Alpaca.WsClient do
  use WebSockex
  require Logger

  @default_subscription_msg "{\"action\":\"subscribe\",\"trades\":[\"AAPL\"],\"quotes\":[\"AMD\",\"CLDR\"],\
          \"bars\":[\"*\"]}"
  @auth_success_msg "[{\"T\":\"success\",\"msg\":\"authenticated\"}]"
  @connection_success_msg "[{\"T\":\"success\",\"msg\":\"connected\"}]"

  @spec start_link(bitstring()) :: {:error, any()} | {:ok, pid()}
  def start_link(state) do
    Logger.info("Starting Alpaca websocket client.")

    WebSockex.start_link(iex_feed(), __MODULE__, state, extra_headers: auth_headers())
  end

  @spec handle_connect(WebsockEx.Conn.t(), bitstring()) :: {:ok, bitstring()}
  def handle_connect(_conn, state) do
    Logger.info("Alpaca websocket connected.")
    {:ok, state}
  end

  @spec handle_disconnect(map(), bitstring()) :: {:ok, bitstring()}
  def handle_disconnect(disconnect_map, state) do
    Logger.info("Alpaca websocket disconnected.")
    super(disconnect_map, state)
  end

  @doc """
  Handles the messages sent by the Alpaca websocket server, responding if necessary.
  Besides processing messages as they arrive, this function will also set up the initial
  subscription once the authorization acknowledgement method is received.
  """
  @spec handle_frame(WebSockex.Frame.frame(), bitstring()) :: {:ok, bitstring()}
  def handle_frame({_type, @connection_success_msg}, state) do
    Logger.info("Connection Message Received.")

    {:ok, state}
  end

  def handle_frame({type, @auth_success_msg}, state) do
    Logger.info("Alpaca websocket authenticated.")

    {:reply, {type, @default_subscription_msg}, state}
  end

  def handle_frame({_type, msg}, state) do
    message =
      case Jason.decode(msg) do
        {:ok, message} -> message
        {:error, reason} -> Logger.error("Error decoding message.", reason: reason)
      end

    if message["T"] == "q", do: handle_quote_message(message),
      else: Logger.info("Message received: #{message}")

    {:ok, state}
  end

  defp handle_quote_message(message) do
    Logger.info("Quote Message: #{message}")
  end

  defp auth_headers, do: [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]

  defp iex_feed, do: "#{ws_server_url()}/iex"

  defp ws_server_url, do: Application.fetch_env!(:basket, :alpaca)[:ws_server_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end()
