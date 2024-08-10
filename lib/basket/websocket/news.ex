defmodule Basket.Websocket.News do
  @moduledoc """
  Websocket client adapter for Alpaca Finance.
  Currently only supports the "bars" feed on the minute.
  """

  use WebSockex

  require Logger

  alias Basket.Websocket.Client

  @behaviour Client
  @type subscription_fields :: %{
          :news => list(String.t())
        }

  @auth_success_msg ~s([{\"T\":\"success\",\"msg\":\"authenticated\"}])
  @connection_success_msg ~s([{\"T\":\"success\",\"msg\":\"connected\"}])
  @news_topic "news"

  @impl true
  def send_frame(pid, message) do
    WebSockex.send_frame(pid, message)
  end

  def start_link(state) do
    Logger.info("Starting Alpaca news websocket client.")

    Client.start_link(
      url(),
      Basket.Websocket.News,
      state,
      extra_headers: auth_headers()
    )
  end

  @spec subscribe(subscription_fields) :: :error | :ok
  def subscribe(tickers) do
    decoded_message =
      build_message(Client.subscribe_msg(), tickers)
      |> Jason.encode!()

    case Client.send_frame(client_pid(), {:text, decoded_message}) do
      :ok ->
        Logger.debug("News subscription message sent: #{inspect(decoded_message)}")

      {:error, error} ->
        Logger.error("Error sending news subscription message: #{inspect(error)}")
        :error
    end
  end

  @spec unsubscribe(subscription_fields) :: :error | :ok
  def unsubscribe(tickers) do
    decoded_message = build_message(Client.unsubscribe_msg(), tickers) |> Jason.encode!()

    case Client.send_frame(client_pid(), {:text, decoded_message}) do
      :ok ->
        Logger.debug("News subscription removal message sent: #{inspect(decoded_message)}")

      {:error, error} ->
        Logger.error("Error sending news subscription removal message: #{inspect(error)}")
    end
  end

  def news_topic, do: @news_topic

  @impl true
  def handle_connect(_conn, state) do
    Logger.info("Alpaca News websocket connected.")
    {:ok, state}
  end

  @impl true
  def handle_disconnect(disconnect_map, state) do
    Logger.info("Alpaca News websocket disconnected.")
    super(disconnect_map, state)
  end

  @doc """
  Handles the messages sent by the Alpaca websocket server, responding if necessary.
  Besides processing messages as they arrive, this function will also set up the initial
  subscription once the authorization acknowledgement method is received.
  """
  @impl true
  def handle_frame({:text, @connection_success_msg}, state) do
    Logger.info("News connection message received.")

    {:ok, state}
  end

  @impl true
  def handle_frame({:text, @auth_success_msg}, state) do
    Logger.info("Alpaca websocket authenticated.")

    {:ok, state}
  end

  @impl true
  def handle_frame({:text, msg}, state) do
    case Jason.decode(msg) do
      {:ok, decoded_message} ->
        Enum.each(decoded_message, &process_message/1)

      {:error, error} ->
        Logger.error("Error decoding websocket message: #{inspect(error)}")
    end

    {:ok, state}
  end

  defp build_message(message, %{news: news}), do: Map.put(message, :news, news)

  defp client_pid do
    Supervisor.which_children(Basket.Supervisor)
    |> Enum.find(fn c ->
      case c do
        {Basket.Websocket.News, _pid, :worker, [Basket.Websocket.News]} ->
          true

        _ ->
          false
      end
    end)
    |> elem(1)
  end

  defp process_message(message) do
    case Map.get(message, "T") do
      "n" ->
        handle_news(message)

      "error" ->
        Logger.error("Error message from Alpaca websocket connection: #{inspect(message)}")

      "subscription" ->
        Logger.info("Subscription message from Alpaca websocket connection: #{inspect(message)}")

      _ ->
        Logger.info("Unhandled websocket message: #{inspect(message)}")
    end
  end

  defp handle_news(%{"T" => "n", "id" => _id, "headline" => headline}) do
    Logger.debug("News message received.")
    Logger.debug("Headline: #{headline}")
  end

  defp url,
    do: Application.fetch_env!(:basket, :alpaca)[:news_ws_url]

  defp auth_headers, do: [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]
end
