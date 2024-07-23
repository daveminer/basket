defmodule BasketWeb.InviteController do
  use BasketWeb, :controller

  @email_regex ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  @settings_path "/settings"

  def create(conn, %{"email" => email}) do
    conn = put_flash(conn, :info, "Invitation sent!")

    if Regex.match?(@email_regex, email) do
      # send_invitation(conn, email)
      # {:ok, _, _conn} = PowInvitation.Plug.create_user(conn, %{email: email})
      invited_by = conn.assigns.current_user
      IO.inspect(invited_by, label: "invited_by")
      # config = BasketWeb.PowConfig.invitation_config()
      {:ok, _user} =
        PowInvitation.Ecto.Context.create(invited_by, %{email: email},
          repo: Basket.Repo,
          user: Basket.User
        )

      redirect(conn, to: @settings_path)
    else
      conn
      |> put_flash(:error, "Invalid email format")
      |> redirect(to: @settings_path)
    end
  end

  # def send_invitation(conn, email_address) do
  #   email = InvitationEmail.create_invite_email(email_address)

  #   # Handle the response accordingly
  #   case Api.deliver(email) do
  #     {:ok, _response} ->
  #       conn
  #       |> put_flash(:info, "Invitation sent successfully.")
  #       |> redirect(to: "/some-path")

  #     {:error, reason} ->
  #       conn
  #       |> put_flash(:error, "Failed to send invitation: #{reason}")
  #       |> redirect(to: "/error-path")
  #   end
  # end
end
