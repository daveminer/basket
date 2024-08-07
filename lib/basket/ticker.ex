defmodule Basket.Ticker do
  @moduledoc """
  Tracks the stock tickers that are active on a user's dashboard.
  """

  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias Basket.Repo
  alias Basket.User

  @type t :: %__MODULE__{}

  schema "tickers" do
    field :ticker, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(ticker_or_changeset, attrs) do
    ticker_or_changeset
    |> Ecto.Changeset.change()
    |> cast(attrs, [:ticker, :user_id])
    |> validate_required([:ticker, :user_id])
    |> unique_constraint([:ticker, :user_id])
  end

  @spec add!(user :: User.t(), ticker: String.t()) :: __MODULE__.t()
  def add!(user, ticker) do
    ticker = %__MODULE__{ticker: ticker, user_id: user.id}
    Repo.insert!(ticker)
  end

  @spec for_user(user :: User.t()) :: [Basket.Ticker.t()]
  def for_user(nil), do: []

  def for_user(user) do
    from(t in __MODULE__,
      where: t.user_id == ^user.id
    )
    |> Repo.all()
  end

  @spec remove(user :: User.t(), ticker: String.t()) :: {non_neg_integer(), nil | [term()]}
  def remove(user, ticker) do
    from(t in __MODULE__,
      where: t.user_id == ^user.id and t.ticker == ^ticker
    )
    |> Repo.delete_all()
  end
end
