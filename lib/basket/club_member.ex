defmodule Basket.ClubMember do
  use Ecto.Schema
  import Ecto.Changeset

  alias Basket.{User, Club}

  schema "club_members" do
    belongs_to :user, User
    belongs_to :club, Club
  end

  @doc false
  def changeset(club_member, attrs) do
    club_member
    |> cast(attrs, [:user_id, :club_id])
    |> validate_required([:user_id, :club_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:club_id)
  end
end
