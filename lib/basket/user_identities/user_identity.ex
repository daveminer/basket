defmodule Basket.UserIdentities.UserIdentity do
  @moduledoc false

  use Ecto.Schema
  use PowAssent.Ecto.UserIdentities.Schema, user: Basket.User

  schema "user_identities" do
    pow_assent_user_identity_fields()

    timestamps()
  end
end
