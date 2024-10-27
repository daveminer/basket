defmodule BasketWeb.PowInvitation.InvitationController do
  use BasketWeb, :controller

  import Phoenix.VerifiedRoutes

  alias Basket.Repo
  alias Pow.{Config, Plug}

  plug :load_user when action in [:create]

  @doc """
  This custom PowInvitation controller allows for a custom redirect after invitation and
  creation of a club membership for the new user, based on the inviting user's office.
  This controller assumes the inviting user only has one office.
  """
  def create(%{assigns: %{current_user: invited_by}} = conn, %{"user" => user_params}) do
    case create_user(conn, user_params) do
      {:ok, user, conn} ->
        url = path(conn, BasketWeb.Router, ~p"/invitations/#{user.invitation_token}/edit")
        email = PowInvitation.Phoenix.Mailer.invitation(conn, user, invited_by, url)
        Pow.Phoenix.Mailer.deliver(conn, email)

        conn
        |> put_flash(:info, "Invitation sent successfully.")
        |> redirect(to: path(conn, BasketWeb.Router, ~p"/settings"))

      {:error, changeset, conn} ->
        error_message = format_changeset_errors(changeset)

        conn
        |> put_flash(:error, error_message)
        |> redirect(to: path(conn, BasketWeb.Router, ~p"/settings"))
    end
  end

  defp create_user(conn, user_params) do
    config = Plug.fetch_config(conn)

    user =
      conn
      |> Plug.current_user()
      |> Repo.preload(:offices)

    user_mod = Config.user!(config)

    user_params =
      Map.put(user_params, :email, user_params["email"])
      |> Map.delete("email")

    user_mod
    |> struct()
    |> user_mod.invite_changeset(user, user_params)
    |> Ecto.Changeset.put_assoc(:clubs, [hd(user.offices)])
    |> Repo.insert()
    |> case do
      {:ok, user} -> {:ok, user, conn}
      {:error, changeset} -> {:error, changeset, conn}
    end
  end

  defp format_changeset_errors(changeset) do
    Enum.map(changeset.errors, fn
      {:email, {"has already been taken", _}} ->
        "That email address has already been invited."

      {field, {message, _}} ->
        "#{humanize(field)} #{message}"
    end)
    |> Enum.join(", ")
  end

  defp humanize(field) do
    field
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp load_user(conn, _opts) do
    user = Pow.Plug.current_user(conn)
    assign(conn, :current_user, user)
  end
end
