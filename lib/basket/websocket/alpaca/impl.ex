defmodule Basket.Websocket.Alpaca.Impl do
  @moduledoc """
  Implementation of the Alpaca websocket client.
  """

  require Logger

  @subscribe_message %{
    action: :subscribe
  }
  @unsubscribe_message %{
    action: :unsubscribe
  }

  def start_link(state) do
    Logger.info("Starting Alpaca websocket client.")

    WebSockex.start_link(iex_feed(), Basket.Websocket.Alpaca, state, extra_headers: auth_headers())
  end

  def subscribe(tickers) do
    decoded_message = Jason.encode!(build_message(@subscribe_message, tickers))

    case WebSockex.send_frame(client_pid(), {:text, decoded_message}) do
      :ok -> Logger.debug("Subscription message sent: #{inspect(decoded_message)}")
      {:error, error} -> Logger.error("Error sending subscription message: #{inspect(error)}")
    end
  end

  def unsubscribe(tickers) do
    decoded_message = Jason.encode!(build_message(@unsubscribe_message, tickers))

    case WebSockex.send_frame(client_pid(), {:text, decoded_message}) do
      :ok ->
        Logger.debug("Subscription removal message sent: #{inspect(decoded_message)}")

      {:error, error} ->
        Logger.error("Error sending subscription removal message: #{inspect(error)}")
    end
  end

  defp auth_headers, do: [{"APCA-API-KEY-ID", api_key()}, {"APCA-API-SECRET-KEY", api_secret()}]

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]

  defp iex_feed, do: "#{url()}/iex"

  defp url, do: Application.fetch_env!(:basket, :alpaca)[:market_ws_url]

  defp client_pid do
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
  end

  defp build_message(message, %{bars: bars, quotes: quotes, trades: trades}) do
    message = if bars, do: Map.put(message, :bars, bars), else: message
    message = if quotes, do: Map.put(message, :quotes, quotes), else: message
    if trades, do: Map.put(message, :trades, trades), else: message
  end
end
