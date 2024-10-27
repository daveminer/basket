defmodule BasketWeb.PowInvitation.InvitationControllerTest do
  use BasketWeb.ConnCase

  import Phoenix.VerifiedRoutes

  alias Basket.{Repo, User}
  alias Basket.Factory

  setup do
    # Create an inviting user with an office
    invited_by = Factory.insert(:user)
    office = Factory.insert(:club)
    Repo.insert!(%Basket.ClubOfficer{user_id: invited_by.id, club_id: office.id})

    {:ok, invited_by: invited_by, office: office}
  end

  test "successfully creates a user and sends an invitation", %{
    conn: conn,
    invited_by: invited_by,
    office: office
  } do
    conn =
      assign(conn, :current_user, invited_by)
      |> post(path(conn, BasketWeb.Router, ~p"/invitations"), %{
        "user" => %{
          "email" => "newuser@example.com"
        }
      })

    assert redirected_to(conn) == path(conn, BasketWeb.Router, ~p"/settings")
    assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Invitation sent successfully."

    user = Repo.get_by(User, email: "newuser@example.com")
    assert user
    assert Repo.get_by(Basket.ClubMember, user_id: user.id, club_id: office.id)
  end

  test "fails to create a user with invalid data", %{conn: conn, invited_by: invited_by} do
    conn =
      assign(conn, :current_user, invited_by)
      |> post(path(conn, BasketWeb.Router, ~p"/invitations"), %{
        "user" => %{
          "email" => "invalid"
        }
      })

    assert redirected_to(conn) == path(conn, BasketWeb.Router, ~p"/settings")
    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Email has invalid format"
  end
end
