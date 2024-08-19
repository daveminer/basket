defmodule Basket.News do
  @moduledoc false

  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias Basket.Repo

  @type t :: %__MODULE__{
          article_id: String.t(),
          author: String.t(),
          content: String.t(),
          creation_date: DateTime.t(),
          headline: String.t(),
          id: integer(),
          images: map(),
          inserted_at: DateTime.t(),
          sentiment: String.t(),
          sentiment_confidence: Decimal.t(),
          sentiment_id: integer(),
          source: String.t(),
          summary: String.t(),
          symbols: list(String.t()),
          updated_at: DateTime.t(),
          updated_date: DateTime.t(),
          url: String.t()
        }

  schema "news" do
    field :article_id, :string
    field :author, :string
    field :content, :string
    field :creation_date, :utc_datetime
    field :headline, :string
    field :images, {:array, :map}, type: :jsonb
    field :sentiment, :string
    field :sentiment_confidence, :float
    field :sentiment_id, :integer
    field :source, :string
    field :summary, :string
    field :symbols, {:array, :string}
    field :updated_date, :utc_datetime
    field :url, :string

    timestamps()
  end

  @doc ~S"""
  Create a new Bars instance from a ticker update message.
  The 'id' field is used for tracking updates in the LiveView stream.

  ## Example
    iex> new("AAA", %{"c" => 1.0, "h" => 1.0, "l" => 1.0, "n" => 1, "o" => 1.0, "t" => "2023-11-15T20:59:00Z", "v" => 1, "vw" => 1.0})
    %Bars{id: "AAA", ticker: "AAA", close: 1.0, open: 1.0, high: 1.0, low: 1.0, volume: 1, timestamp: ~U[2023-11-15 20:59:00Z], count: 1, vwap: 1.0}
  """
  @spec add!(params: map()) :: __MODULE__.t()
  def add!(params) do
    struct(__MODULE__, params)
    |> Repo.insert!()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(news, params \\ %{}) do
    news
    |> cast(params, [
      :article_id,
      :author,
      :content,
      :creation_date,
      :headline,
      :images,
      :sentiment,
      :sentiment_confidence,
      :sentiment_id,
      :source,
      :summary,
      :symbols,
      :updated_date,
      :url
    ])
    |> validate_required([
      :article_id,
      :author,
      :creation_date,
      :source,
      :symbols,
      :updated_date,
      :url
    ])
  end

  @spec for_ticker(ticker :: String.t()) :: [__MODULE__.t()]
  def for_ticker(nil), do: []

  def for_ticker(ticker) do
    from(t in __MODULE__,
      where: ^ticker in t.symbols,
      order_by: [desc: t.creation_date]
    )
    |> Repo.all()
  end
end
