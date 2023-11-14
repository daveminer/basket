defmodule Basket.Websocket.Message do
  @moduledoc """
  Handles messages from anS Alpaca websocket connection.
  """
  require Logger

  @bars_topic "bars"

  @type subscription_fields :: %{
          :bars => list(String.t()),
          :quotes => list(String.t()),
          :trades => list(String.t())
        }

  @spec process(bitstring()) :: :ok
  def process(messages) do
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

    :ok
  end

  @spec market_data_subscription(subscription_fields) ::
          {:error, Jason.EncodeError.t() | Exception.t()}
          | {:ok, String.t()}
  def market_data_subscription(fields) do
    message =
      build_message(
        %{
          action: :subscribe
        },
        fields
      )

    case Jason.encode(message) do
      {:ok, encoded_message} ->
        {:ok, encoded_message}

      {:error, error} ->
        Logger.error("Error encoding market subscription message: #{error}")

        {:error, error}
    end
  end

  @spec market_data_remove_subscription(subscription_fields) ::
          {:error, Jason.EncodeError.t() | Exception.t()}
          | {:ok, String.t()}
  def market_data_remove_subscription(fields) do
    message =
      build_message(
        %{
          action: :unsubscribe
        },
        fields
      )

    case Jason.encode(message) do
      {:ok, encoded_message} ->
        {:ok, encoded_message}

      {:error, error} ->
        Logger.error("Error encoding market subscription message: #{error}")

        {:error, error}
    end
  end

  def bars_topic, do: @bars_topic

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
    Logger.info("Bars message received")
    BasketWeb.Endpoint.broadcast_from(self(), @bars_topic, "ticker-update", message)
  end

  defp handle_daily_bars(_message) do
    Logger.info("Daily bars message received.")
  end

  defp handle_bar_updates(_message) do
    Logger.info("Bar updates message received")
  end
end
