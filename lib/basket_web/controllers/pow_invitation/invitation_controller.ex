defmodule BasketWeb.PowInvitation.InvitationController do
  use BasketWeb, :controller

  import Phoenix.VerifiedRoutes

  alias Basket.{Repo, User}
  alias Pow.{Config, Plug}

  plug :require_office when action in [:create]

  @doc """
  Creates a user record for the invited user with membership to the inviting user's club,
  then sends an email invitation to the invited user.

  This custom PowInvitation controller action allows for a custom redirect after
  invitation and creation of a club membership for the new user, based on the
  inviting user's office. This controller assumes the inviting user only has one office.
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

  @doc """
  Loads the view to collect the rest of the user information.
  """
  def edit(conn, _params) do
    conn
    |> assign(:changeset, User.empty_changeset())
    |> render("edit.html")
  end

  @doc """
  Completes the user's account and the invitation process.
  """
  def update(conn, %{"id" => invitation_id, "user" => user_params}) do
    changeset =
      User.get_by_invitation_token(invitation_id)
      |> User.invitation_complete_changeset(user_params)

    if changeset.valid? do
      User.update!(changeset)

      conn
      |> put_flash(:info, "Welcome! You may now log in.")
      |> redirect(to: "/session/new")
    else
      # Render the edit page with the changeset if there are validation errors
      conn
      |> put_flash(:error, "Please correct the errors below.")
      |> render("edit.html", changeset: changeset)
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
    Enum.map_join(changeset.errors, ", ", fn
      {:email, {"has already been taken", _}} ->
        "That email address has already been invited."

      {field, {message, _}} ->
        "#{humanize(field)} #{message}"
    end)
  end

  defp humanize(field) do
    field
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp require_office(conn, _opts) do
    %{id: id} = Pow.Plug.current_user(conn)
    user = User.get(id, [:offices])

    if Enum.empty?(user.offices) do
      conn
      |> put_flash(:error, "You must be an officer to make this action.")
      |> redirect(to: "/settings")
      |> halt()
    else
      assign(conn, :current_user, user)
    end
  end
end
