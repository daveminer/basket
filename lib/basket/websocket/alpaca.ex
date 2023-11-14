defmodule Basket.Websocket.Alpaca do
  @moduledoc """
  Implementation of the websocket client for Alpaca Finance.
  Currently only supports the "bars" feed on the minute.
  """

  use Basket.Websocket.Adapter

  require Logger

  @type subscription_fields :: %{
          :bars => list(String.t()),
          :quotes => list(String.t()),
          :trades => list(String.t())
        }

  @auth_success ~s([{\"T\":\"success\",\"msg\":\"authenticated\"}])
  @connection_success ~s([{\"T\":\"success\",\"msg\":\"connected\"}])
  @bars_topic "bars"
  @subscribe_message %{
    action: :subscribe
  }
  @unsubscribe_message %{
    action: :unsubscribe
  }

  def start_link(state) do
    Logger.info("Starting Alpaca websocket client.")

    WebSockex.start_link(iex_feed(), __MODULE__, state, extra_headers: auth_headers())
  end

  @impl true
  def on_msg(messages, _state) do
    Enum.each(messages, fn message ->
      case Map.get(message, "T") do
        "b" ->
          handle_bars(message)

        "d" ->
          handle_daily_bars(message)

        "u" ->
          handle_bar_updates(message)

        "error" ->
          Logger.error("Error message from Alpaca websocket connection: #{message}")

        "subscription" ->
          Logger.info("Subscription message from Alpaca websocket connection: #{message}")

        _ ->
          Logger.info("Unhandled websocket message: #{message}")
      end
    end)
  end

  @spec subscribe(subscription_fields()) :: :ok
  def subscribe(tickers) do
    decoded_message = Jason.encode!(build_message(@subscribe_message, tickers))

    case WebSockex.send_frame(client_pid(), {:text, decoded_message}) do
      :ok -> Logger.debug("Subscription message sent: #{inspect(decoded_message)}")
      {:error, error} -> Logger.error("Error sending subscription message: #{inspect(error)}")
    end
  end

  @spec unsubscribe(subscription_fields()) :: :ok
  def unsubscribe(tickers) do
    decoded_message = Jason.encode!(build_message(@unsubscribe_message, tickers))

    case WebSockex.send_frame(client_pid(), {:text, decoded_message}) do
      :ok ->
        Logger.debug("Subscription removal message sent: #{inspect(decoded_message)}")

      {:error, error} ->
        Logger.error("Error sending subscription removal message: #{inspect(error)}")
    end
  end

  @impl true
  def handle_connect(_conn, state) do
    Logger.info("Alpaca websocket connected.")
    {:ok, state}
  end

  @impl true
  def handle_disconnect(disconnect_map, state) do
    Logger.info("Alpaca websocket disconnected.")
    super(disconnect_map, state)
  end

  @doc """
  Handles the messages sent by the Alpaca websocket server, responding if necessary.
  Besides processing messages as they arrive, this function will also set up the initial
  subscription once the authorization acknowledgement method is received.
  """
  @impl true
  def handle_frame({_type, @connection_success}, state) do
    Logger.info("Connection message received.")

    {:ok, state}
  end

  @impl true
  def handle_frame({_type, @auth_success}, state) do
    Logger.info("Alpaca websocket authenticated.")

    {:ok, state}
  end

  @impl true
  def handle_frame({_tpe, msg}, state) do
    Jason.decode!(msg)
    |> on_msg(state)

    {:ok, state}
  end

  defp auth_headers, do: [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]

  defp iex_feed, do: "#{url()}/iex"

  defp url, do: Application.fetch_env!(:basket, :alpaca)[:market_ws_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]

  defp client_pid,
    do:
      Supervisor.which_children(Basket.Supervisor)
      |> Enum.find(fn c ->
        case c do
          {Basket.Websocket.Alpaca, _pid, :worker, [Basket.Websocket.Alpaca]} ->
            true

          _ ->
            false
        end
      end)
      |> elem(1)

  defp build_message(message, %{bars: bars, quotes: quotes, trades: trades}) do
    message = if bars, do: Map.put(message, :bars, bars), else: message
    message = if quotes, do: Map.put(message, :quotes, quotes), else: message
    if trades, do: Map.put(message, :trades, trades), else: message
  end

  defp handle_bars(
         %{
           "S" => _symbol,
           "o" => _open,
           "h" => _high,
           "l" => _low,
           "c" => _close,
           "v" => _volume,
           "t" => _timestamp
         } = message
       ) do
    Logger.debug("Bars message received")
    BasketWeb.Endpoint.broadcast_from(self(), @bars_topic, "ticker-update", message)
  end

  defp handle_daily_bars(_message) do
    Logger.debug("Daily bars message received.")
  end

  defp handle_bar_updates(_message) do
    Logger.debug("Bar updates message received")
  end
end
