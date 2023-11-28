defmodule Basket.Websocket.Client do
  @moduledoc """
  Websocket client adapter.
  """

  @callback start_link(
              url :: String.t() | WebSockex.Conn.t(),
              module :: WebSockex.module(),
              term :: WebSockex.term(),
              options :: WebSockex.options()
            ) ::
              {:ok, pid()} | {:error, term()}
  @callback send_frame(WebSockex.client(), WebSockex.frame()) ::
              :ok
              | {:error,
                 %WebSockex.FrameEncodeError{
                   __exception__: true,
                   close_code: term(),
                   frame_payload: term(),
                   frame_type: term(),
                   reason: term()
                 }
                 | %WebSockex.ConnError{__exception__: true, original: term()}
                 | %WebSockex.NotConnectedError{__exception__: true, connection_state: term()}
                 | %WebSockex.InvalidFrameError{__exception__: true, frame: term()}}
              | none()

  def start_link(url, module, term, options), do: impl().start_link(url, module, term, options)
  def send_frame(client, frame), do: impl().send_frame(client, frame)

  def impl,
    do: Application.get_env(:basket, :websocket_client, WebSockex) |> IO.inspect(label: "CLIENT")
end
