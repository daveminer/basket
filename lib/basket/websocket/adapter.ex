defmodule Basket.Websocket.Adapter do
  @moduledoc """
  Abstract wrapper around WebSockex.
  """

  @doc """
  Handles the messages sent by the Alpaca websocket server, responding if necessary.
  Besides processing messages as they arrive, this function will also set up the initial
  subscription once the authorization acknowledgement method is received.
  """
  @callback on_msg(WebSockex.Frame.frame(), bitstring()) :: :ok

  defmacro __using__(_) do
    quote location: :keep do
      use WebSockex

      @behaviour Basket.Websocket.Adapter
    end
  end
end
