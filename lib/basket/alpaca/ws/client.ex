defmodule Basket.Alpaca.Websocket.Client do
  @moduledoc """
  Implementation of the Alpaca websocket client.
  """

  @callback start(bitstring()) :: {:error, any()} | {:ok, pid()}
  @callback on_connect(WebSockex.Conn.t(), bitstring()) :: {:ok, bitstring()}
  @callback on_disconnect(map(), bitstring()) :: {:ok, bitstring()}
  @doc """
  Handles the messages sent by the Alpaca websocket server, responding if necessary.
  Besides processing messages as they arrive, this function will also set up the initial
  subscription once the authorization acknowledgement method is received.
  """
  @callback on_msg(WebSockex.Frame.frame(), bitstring()) :: {:ok, bitstring()}
  @callback subscribe(Message.subscription_fields()) :: :ok
  @callback unsubscribe(Message.subscription_fields()) :: :ok

  @auth_success ~s([{\"T\":\"success\",\"msg\":\"authenticated\"}])
  @connection_success ~s([{\"T\":\"success\",\"msg\":\"connected\"}])

  def start(state), do: impl().start(state)
  def on_connect(conn, state), do: impl().on_connect(conn, state)

  def on_disconnect(disconnect_map, state),
    do: impl().on_disconnect(disconnect_map, state)

  def on_msg(frame, state), do: impl().on_msg(frame, state)
  def subscribe(tickers), do: impl().subscribe(tickers)
  def unsubscribe(tickers), do: impl().unsubscribe(tickers)

  defp impl(),
    do:
      Application.get_env(:basket, :alpaca_websocket_client, Basket.Alpaca.Websocket.Client.Impl)
end
