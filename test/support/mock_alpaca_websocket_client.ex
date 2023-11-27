defmodule Basket.Support.MockAlpacaWebsocketClient do
  @moduledoc false

  require Logger

  @behaviour Basket.Websocket.Alpaca

  @impl true
  def start_link(state) do
    {:ok, self()}
  end

  @impl true
  @spec subscribe(
          %{:bars => any(), :quotes => any(), :trades => any(), optional(any()) => any()},
          any()
        ) :: :ok
  def subscribe(tickers, client_pid \\ nil) do
    # client_pid = if client_pid == nil, do: client_pid(), else: client_pid
    IO.inspect(client_pid(), label: "CLIENTPID")
    decoded_message = Jason.encode!(build_message(@subscribe_message, tickers))
    IO.inspect(decoded_message, label: "DECOD")

    case WebSockex.send_frame(client_pid, {:text, decoded_message}) do
      :ok -> Logger.debug("Subscription message sent: #{inspect(decoded_message)}")
      {:error, error} -> Logger.error("Error sending subscription message: #{inspect(error)}")
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

  defp api_key, do: Application.fetch_env!(:basket, :alpaca)[:api_key]

  defp api_secret, do: Application.fetch_env!(:basket, :alpaca)[:api_secret]

  defp url, do: Application.fetch_env!(:basket, :alpaca)[:market_ws_url]

  defp client_pid do
    Supervisor.which_children(Basket.Supervisor)
    |> Enum.find(fn c ->
      IO.inspect(c, label: "C IS")

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
