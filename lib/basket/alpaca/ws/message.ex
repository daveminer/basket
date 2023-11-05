defmodule Basket.Alpaca.Websocket.Message do
  require Logger

  # @default_subscription_msg "{\"action\":\"subscribe\",\"trades\":[\"AAPL\"],\"quotes\":[\"AMD\",\"CLDR\"],\
  #         \"bars\":[\"*\"]}"

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
    message = if bars, do: Map.put(message, :quotes, quotes), else: message
    message = if trades, do: Map.put(message, :trades, trades), else: message

    case Jason.encode(message) do
      {:ok, encoded_message} ->
        {:ok, encoded_message}

      {:error, reason} ->
        Logger.error("Error encoding market subscription message", reason: reason)

        {:error, reason}
    end
  end
end
