defmodule Basket.Websocket.Client do
  @moduledoc """
  Websocket client adapter.
  """

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

  @auth_success_msg ~s([{\"T\":\"success\",\"msg\":\"authenticated\"}])
  @connection_success_msg ~s([{\"T\":\"success\",\"msg\":\"connected\"}])
  @subscribe_message %{action: :subscribe}
  @unsubscribe_message %{action: :unsubscribe}

  def auth_success_msg, do: @auth_success_msg
  def connection_success_msg, do: @connection_success_msg

  def subscribe_msg, do: @subscribe_message
  def unsubscribe_msg, do: @unsubscribe_message

  @doc """
  start_link/4 is not a callback because it crosses start_link/4
  and start_link/1 from the WebSockex and Supervisor APIs rather than
  providing a true behaviour implementation
  """
  def start_link(url, module, term, options), do: impl().start_link(url, module, term, options)
  def send_frame(client, frame), do: impl().send_frame(client, frame)

  def impl, do: Application.get_env(:basket, :websocket_client, WebSockex)
end
