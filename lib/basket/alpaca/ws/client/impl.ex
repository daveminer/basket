defmodule Basket.Alpaca.Websocket.Client.Impl do
  @moduledoc """
  Instantiates an Alpaca websocket connection and processes the incoming messages.
  Currently only handles "bars" messages.
  """
  use WebSockex
  require Logger

  alias Basket.Alpaca.Websocket.Client
  alias Basket.Alpaca.Websocket.Client.Message

  @behaviour Client

  @auth_success ~s([{\"T\":\"success\",\"msg\":\"authenticated\"}])
  @connection_success ~s([{\"T\":\"success\",\"msg\":\"connected\"}])

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
  Handles the messages sent by the Alpaca websocket server, responding if necessary.
  Besides processing messages as they arrive, this function will also set up the initial
  subscription once the authorization acknowledgement method is received.
  """

  def handle_frame({_type, @connection_success}, state) do
    Logger.info("Connection message received.")

    {:ok, state}
  end

  def handle_frame({_type, @auth_success}, state) do
    Logger.info("Alpaca websocket authenticated.")

    {:ok, state}
  end

  def handle_frame({_tpe, msg}, state) do
    case Jason.decode(msg) do
      {:ok, message} ->
        Message.process(message)

      {:error, error} ->
        Logger.error("Error decoding message: #{inspect(error)}")
    end

    {:ok, state}
  end

  def subscribe_to_market_data(tickers) do
    case Message.market_data_subscription(tickers) do
      {:ok, message} ->
        WebSockex.send_frame(client_pid(), {:text, message})
        Logger.debug("Subscription message sent: #{inspect(message)}")

      {:error, error} ->
        Logger.error("Error sending subscription message: #{inspect(error)}")
    end
  end

  def unsubscribe_to_market_data(tickers) do
    case Message.market_data_remove_subscription(tickers) do
      {:ok, message} ->
        Logger.info("Sending subscription removal message: #{inspect(message)}")

        WebSockex.send_frame(client_pid(), {:text, message})
        Logger.info("Subscription removal message sent: #{inspect(message)}")

      {:error, error} ->
        Logger.error("Error sending subscription removal message: #{inspect(error)}")
    end
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
          {Basket.Alpaca.Websocket.Client, _pid, :worker, [Basket.Alpaca.Websocket.Client]} ->
            true

          _ ->
            false
        end
      end)
      |> elem(1)
end
