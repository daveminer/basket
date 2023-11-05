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

  def handle_cast(msg, state) do
    IO.inspect("handle_cast: #{inspect(msg)}")
    res = super(msg, state)
    IO.inspect(res, label: "RES")
    res
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

    # {:reply, {type, Message.default_subscription()}, state}
    {:ok, state}
  end

  def handle_frame({_type, msg}, state) do
    IO.inspect("handle_frame: #{inspect(msg)}")

    case Jason.decode(msg) do
      {:ok, message} ->
        if Map.get(List.first(message), "T") == "q" do
          handle_quote_message(List.first(message))
        else
          Logger.info("Message received: #{inspect(message)}")
        end

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
        # pid = Process.whereis(Basket.Alpaca.Websocket.Client)
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

        IO.inspect("PROCESS: #{inspect(pid)}")
        # WebSockex.cast(pid, {:text, message})
        WebSockex.send_frame(pid, {:text, message})
        Logger.info("Subscription message sent.")

      {:error, reason} ->
        Logger.error("Error sending subscription message.", reason: reason)
    end
  end

  defp handle_quote_message(message) do
    Logger.info("Quote message: #{inspect(message)}")
  end

  defp auth_headers, do: [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]

  defp iex_feed, do: "#{url()}/iex"

  defp url, do: Application.fetch_env!(:basket, :alpaca)[:market_ws_url]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end
