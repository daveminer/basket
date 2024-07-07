defmodule Basket.Club do
  @moduledoc false

  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "clubs" do
    many_to_many :users, Basket.User, join_through: "club_members"

    timestamps()
  end
end
