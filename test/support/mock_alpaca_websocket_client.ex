defmodule Basket.Support.MockAlpacaWebsocketClient do
  @moduledoc false

  require Logger

  @behaviour Basket.Websocket.Alpaca

  @subscribe_message %{
    action: :subscribe
  }
  @unsubscribe_message %{
    action: :unsubscribe
  }

  @impl true
  def start_link(_state) do
    # Make the supervisor happy on test server startup

    {:ok, self()}
  end

  @impl true
  @spec subscribe(%{:bars => any(), :quotes => any(), :trades => any(), optional(any()) => any()}) ::
          :ok
  def subscribe(_tickers) do
    # # client_pid = if client_pid == nil, do: client_pid(), else: client_pid
    # decoded_message = Jason.encode!(build_message(@subscribe_message, tickers))
    # # IO.inspect(decoded_message, label: "DECOD")

    # case WebSockex.send_frame(client_pid(), {:text, decoded_message}) do
    #   :ok -> Logger.debug("Subscription message sent: #{inspect(decoded_message)}")
    #   {:error, error} -> Logger.error("Error sending subscription message: #{inspect(error)}")
    # end
    :ok
  end

  @impl true
  def unsubscribe(_tickers) do
    # decoded_message = Jason.encode!(build_message(@unsubscribe_message, tickers))

    # case WebSockex.send_frame(client_pid(), {:text, decoded_message}) do
    #   :ok ->
    #     Logger.debug("Subscription removal message sent: #{inspect(decoded_message)}")

    #   {:error, error} ->
    #     Logger.error("Error sending subscription removal message: #{inspect(error)}")
    # end
    :ok
  end
end
