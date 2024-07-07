defmodule Basket.ClubTicker do
  @moduledoc """
  These tickers belong to a club; every club member can view the club's
  portfolio.
  """

  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias Basket.{Club, Repo}

  @type t :: %__MODULE__{}

  schema "club_tickers" do
    field :ticker, :string
    belongs_to :club, Club

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

  @spec add!(club :: Club.t(), ticker: String.t()) :: __MODULE__.t()
  def add!(club, ticker) do
    ticker = %__MODULE__{ticker: ticker, club_id: club.id}
    Repo.insert!(ticker)
  end

  @spec for_club(user :: Club.t()) :: [Basket.Ticker.t()]
  def for_club(nil), do: []

  def for_club(club) do
    from(t in __MODULE__,
      where: t.club_id == ^club.id
    )
    |> Repo.all()
  end

  @spec remove(club :: Club.t(), ticker: String.t()) :: {non_neg_integer(), nil | [term()]}
  def remove(club, ticker) do
    from(t in __MODULE__,
      where: t.club_id == ^club.id and t.ticker == ^ticker
    )
    |> Repo.delete_all()
  end
end
