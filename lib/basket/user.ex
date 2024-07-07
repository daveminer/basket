defmodule Basket.User do
  @moduledoc false

  use Ecto.Schema
  use Pow.Ecto.Schema

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation]

  alias Basket.Repo

  @type t :: %__MODULE__{}

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end

  def toggle_club_view!(user, value) when value in ["club", "individual"] do
    updated_settings = Map.put(user.settings, "ticker_view_toggle", value)
    changeset = Ecto.Changeset.change(user, settings: updated_settings)
    Repo.update!(changeset)
  end

  schema "users" do
    many_to_many :clubs, Basket.Club, join_through: "club_members"

    field :settings, :map

    pow_user_fields()

    timestamps()
  end
end
