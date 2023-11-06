defmodule Basket.Alpaca.Websocket.Message do
  require Logger

  @spec process(bitstring())
  def process(messages) do
    Enum.map(messages, fn message ->
      case Map.get(message, "T") do
        "b" ->
          handle_bars(message)

        "d" ->
          handle_daily_bars(message)

        "u" ->
          handle_bar_updates(message)

        "error" ->
          Logger.error("Error message from Alpaca websocket connection.", message: message)
      end
    end)
  end

  @spec market_data_subscription(%{
          :bars => list(String.t()),
          :quotes => list(String.t()),
          :trades => list(String.t())
        }) ::
          {:error, Jason.EncodeError.t() | Exception.t()}
          | {:ok, String.t()}
  def market_data_subscription(%{bars: bars, quotes: quotes, trades: trades}) do
    message = %{
      action: :subscribe
    }

    message = if bars, do: Map.put(message, :bars, bars), else: message
    message = if quotes, do: Map.put(message, :quotes, quotes), else: message
    message = if trades, do: Map.put(message, :trades, trades), else: message

    case Jason.encode(message) do
      {:ok, encoded_message} ->
        {:ok, encoded_message}

      {:error, reason} ->
        Logger.error("Error encoding market subscription message", reason: reason)

        {:error, reason}
    end
  end

  defp handle_bars(message) do
    # TODO: send to Liveview
    Logger.info("Bars message received", message: message)
  end

  defp handle_daily_bars(message) do
    Logger.info("Daily bars message received", message: message)
  end

  defp handle_bar_updates(message) do
    Logger.info("Bar updates message received", message: message)
  end
end
