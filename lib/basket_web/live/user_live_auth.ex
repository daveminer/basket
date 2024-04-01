defmodule BasketWeb.Live.UserLiveAuth do
  @moduledoc """
  Adds the user to the socket so it can be used in the liveviews. The user data is
  fetched every time to prevent stale data and expire sessions on time.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  alias Pow.Store.Backend.EtsCache
  alias Pow.Store.CredentialsCache

  def on_mount(:user, _params, session, socket) do
    socket =
      assign_new(socket, :user, fn ->
        get_user(socket, session)
      end)

    if socket.assigns.user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/session/new")}
    end
  end

  defp get_user(socket, session, config \\ [otp_app: :basket])

  defp get_user(socket, %{"basket_auth" => signed_token}, config) do
    conn = struct!(Plug.Conn, secret_key_base: socket.endpoint.config(:secret_key_base))
    salt = Atom.to_string(Pow.Plug.Session)

    with {:ok, token} <- Pow.Plug.verify_token(conn, salt, signed_token, config),
         {user, _metadata} <- CredentialsCache.get([backend: EtsCache], token) do
      user
    else
      _ -> nil
    end
  end

  defp get_user(_, _, _), do: nil
end
