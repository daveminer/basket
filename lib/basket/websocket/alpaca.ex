defmodule Basket.Websocket.Alpaca do
  @moduledoc """
  Implementation of the websocket client for Alpaca Finance.
  Currently only supports the "bars" feed on the minute.
  """

  use WebSockex

  require Logger

  @type subscription_fields :: %{
          :bars => list(String.t()),
          :quotes => list(String.t()),
          :trades => list(String.t())
        }

  @auth_success ~s([{\"T\":\"success\",\"msg\":\"authenticated\"}])
  @connection_success ~s([{\"T\":\"success\",\"msg\":\"connected\"}])
  @bars_topic "bars"

  @callback start_link(term()) :: {:ok, pid()} | {:error, term()}
  @callback subscribe(subscription_fields()) :: :ok
  @callback unsubscribe(subscription_fields()) :: :ok

  def start_link(state), do: impl().start_link(state)
  def subscribe(tickers), do: impl().subscribe(tickers)
  def unsubscribe(tickers), do: impl().unsubscribe(tickers)

  def bars_topic, do: @bars_topic

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
    case Jason.decode(msg) do
      {:ok, decoded_message} ->
        Enum.each(decoded_message, fn message ->
          case Map.get(message, "T") do
            "b" ->
              handle_bars(message)

            "d" ->
              handle_daily_bars(message)

            "u" ->
              handle_bar_updates(message)

            "error" ->
              Logger.error("Error message from Alpaca websocket connection: #{inspect(message)}")

            "subscription" ->
              Logger.info(
                "Subscription message from Alpaca websocket connection: #{inspect(message)}"
              )

            _ ->
              Logger.info("Unhandled websocket message: #{inspect(message)}")
          end
        end)

      {:error, error} ->
        Logger.error("Error decoding websocket message: #{inspect(error)}")
    end

    {:ok, state}
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

  defp impl, do: Application.get_env(:basket, :alpaca_ws_client, Basket.Websocket.Alpaca.Impl)
end
