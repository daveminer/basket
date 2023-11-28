defmodule Basket.Websocket.Alpaca.Impl do
  @moduledoc """
  Implementation of the Alpaca websocket client.
  """

  use ExUnit.Case, async: false

  require Logger

  @behaviour Basket.Websocket.Alpaca

  @subscribe_message %{
    action: :subscribe
  }
  @unsubscribe_message %{
    action: :unsubscribe
  }

  @impl true
  def start_link(state, url \\ nil) do
    Logger.info("Starting Alpaca websocket client.")

    url = if url == nil, do: iex_feed(), else: url

    WebSockex.start_link(url, Basket.Websocket.Alpaca, state, extra_headers: auth_headers())
  end

  @impl true
  @spec subscribe(%{:bars => any(), :quotes => any(), :trades => any(), optional(any()) => any()}) ::
          :ok
  def subscribe(tickers, client \\ nil) do
    client = if client == nil, do: client_pid(), else: client

    decoded_message = Jason.encode!(build_message(@subscribe_message, tickers))

    case WebSockex.send_frame(client, {:text, decoded_message}) do
      :ok ->
        Logger.debug("Subscription message sent: #{inspect(decoded_message)}")

      {:error, error} ->
        Logger.error("Error sending subscription message: #{inspect(error)}")
        :error
    end
  end

  @impl true
  def unsubscribe(tickers) do
    decoded_message = Jason.encode!(build_message(@unsubscribe_message, tickers))

    case WebSockex.send_frame(client_pid(), {:text, decoded_message}) do
      :ok ->
        Logger.debug("Subscription removal message sent: #{inspect(decoded_message)}")

      {:error, error} ->
        Logger.error("Error sending subscription removal message: #{inspect(error)}")
    end
  end

  def wait_for_message do
    assert_receive :text, 3000
  end

  defp auth_headers, do: [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]

  defp iex_feed, do: "#{url()}/iex"

  defp url,
    do: Application.fetch_env!(:basket, :alpaca)[:market_ws_url] |> IO.inspect(label: "URL")

  defp client_pid do
    Supervisor.which_children(Basket.Supervisor)
    |> IO.inspect(label: "CLIENT PID")
    |> Enum.find(fn c ->
      case c do
        {Basket.Websocket.Alpaca, _pid, :worker, [Basket.Websocket.Alpaca]} ->
          true

        _ ->
          false
      end
    end)
    |> elem(1)
  end

  defp build_message(message, %{bars: bars, quotes: quotes, trades: trades}) do
    message = if bars, do: Map.put(message, :bars, bars), else: message
    message = if quotes, do: Map.put(message, :quotes, quotes), else: message
    if trades, do: Map.put(message, :trades, trades), else: message
  end
end
