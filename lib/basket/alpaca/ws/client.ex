defmodule Basket.Alpaca.Websocket.Client do
  use WebSockex
  require Logger

  alias Basket.Alpaca.Websocket.Message

  @auth_success "[{\"T\":\"success\",\"msg\":\"authenticated\"}]"
  @connection_success "[{\"T\":\"success\",\"msg\":\"connected\"}]"

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

      {:error, reason} ->
        Logger.error("Error decoding message.", reason: reason)
    end

    {:ok, state}
  end

  @spec subscribe_to_market_data(%{
          :bars => list(String.t()),
          :quotes => list(String.t()),
          :trades => list(String.t())
        }) :: :ok
  def subscribe_to_market_data(tickers) do
    case Message.market_data_subscription(tickers) do
      {:ok, message} ->
        Logger.info("Sending subscription message: #{inspect(message)}")

        pid =
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

        WebSockex.send_frame(pid, {:text, message})
        Logger.info("Subscription message sent.")

      {:error, reason} ->
        Logger.error("Error sending subscription message.", reason: reason)
    end
  end

  defp auth_headers, do: [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]

  defp iex_feed, do: "#{url()}/iex"

  defp url, do: Application.fetch_env!(:basket, :alpaca)[:market_ws_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end
