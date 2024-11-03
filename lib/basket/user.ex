defmodule Basket.User do
  @moduledoc false

  import Ecto.Changeset

  use Ecto.Schema
  use Pow.Ecto.Schema

  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation, PowInvitation]

  alias Basket.Repo

  @type t :: %__MODULE__{}

  schema "users" do
    pow_user_fields()

    field :first_name, :string
    field :last_name, :string
    field :settings, :map

    many_to_many :clubs, Basket.Club, join_through: "club_members"
    many_to_many :offices, Basket.Club, join_through: "club_officers"

    timestamps()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> cast(attrs, [:first_name, :last_name, :password])
    |> validate_required([:first_name, :last_name, :password])
    |> validate_length(:first_name, min: 2, max: 50)
    |> validate_length(:last_name, min: 2, max: 50)
    |> validate_length(:password, min: 12)
    |> validate_confirmation(:password)
  end

  def empty_changeset(), do: Ecto.Changeset.change(%__MODULE__{})

  def invitation_complete_changeset(user, attrs) do
    dbg(user)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    user
    |> changeset(attrs)
    |> cast(attrs, [:first_name, :last_name, :password])
    |> put_change(:email_confirmed_at, now)
    |> put_change(:invitation_accepted_at, now)
    |> validate_required([:first_name, :last_name, :password])
    |> validate_length(:first_name, min: 2, max: 50)
    |> validate_length(:last_name, min: 2, max: 50)
    |> validate_length(:password, min: 12)
    |> validate_confirmation(:password)
  end

  def get_by_invitation_token(token), do: Repo.get_by(__MODULE__, invitation_token: token)

  def toggle_club_view!(user, value) when value in ["club", "individual"] do
    updated_settings = Map.put(user.settings, "ticker_view_toggle", value)
    changeset = Ecto.Changeset.change(user, settings: updated_settings)
    Repo.update!(changeset)
  end

  def officer?(user), do: Enum.any?(user.offices)

  def update!(changeset), do: Repo.update!(changeset)
end
