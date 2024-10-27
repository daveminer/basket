defmodule Basket.Club do
  @moduledoc false

  import Ecto.Changeset

  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "clubs" do
    many_to_many :users, Basket.User, join_through: "club_members"
    field :name, :string

    timestamps()
  end

  def changeset(club, attrs) do
    club
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
