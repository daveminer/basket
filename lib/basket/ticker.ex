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

  @spec active_ticker_list() :: list(String.t())
  def active_ticker_list() do
    tickers_query = from(t in "tickers", select: t.ticker)
    club_tickers_query = from(ct in "club_tickers", select: ct.ticker)

    from(t in subquery(union(tickers_query, ^club_tickers_query)),
      distinct: true,
      select: t.ticker
    )
    |> Repo.all()
  end

  @spec add!(user :: User.t(), ticker: String.t()) :: __MODULE__.t()
  def add!(user, ticker) do
    ticker = %__MODULE__{ticker: ticker, user_id: user.id}
    Repo.insert!(ticker)
  end

  @spec for_user(user_or_users :: User.t() | [User.t()]) :: [Basket.Ticker.t()]
  def for_user(nil), do: []

  def for_user(users) do
    users =
      if is_list(users) do
        users
      else
        [users]
      end

    user_ids = Enum.map(users, & &1.id)

    from(t in __MODULE__,
      where: t.user_id in ^user_ids
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
