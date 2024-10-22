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
    field :sentiment_confidence, :decimal
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
  The 'id' field is used to track updates in the LiveView stream.

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

  @spec get_news(String.t(), String.t() | nil) :: list(__MODULE__.t())
  def get_news(ticker, sentiment_filter) do
    query =
      from(n in __MODULE__,
        where: ^ticker in n.symbols,
        where: n.creation_date > ago(30, "day")
      )

    case sentiment_filter do
      nil ->
        query

      _ ->
        query
        |> where([n], n.sentiment == ^sentiment_filter)
    end
    |> Repo.all()
  end

  @doc """
  Returns the counts of news articles per ticker and per sentiment. This creates a resulting map of maps of
  the form `%{"AAPL" => %{"negative" => 1, "neutral" => 14, "positive" => 10}}`.
  """
  @spec sentiment_for_tickers(ticker :: String.t() | [String.t()]) :: [__MODULE__.t()]
  def sentiment_for_tickers(ticker) when is_binary(ticker), do: sentiment_for_tickers([ticker])

  def sentiment_for_tickers(tickers) when is_list(tickers) do
    results =
      from(t in __MODULE__,
        where: fragment("? && ?", t.symbols, ^tickers),
        where: t.sentiment_confidence >= 0.65,
        where: t.creation_date > ago(30, "day"),
        group_by: [t.symbols, t.sentiment],
        select: {t.symbols, t.sentiment, count(t.id)}
      )
      |> Repo.all()

    results
    |> Enum.flat_map(fn {symbols, sentiment, count} ->
      Enum.filter(symbols, fn symbol -> symbol in tickers end)
      |> Enum.map(fn symbol -> {symbol, sentiment, count} end)
    end)
    |> Enum.group_by(fn {symbol, _sentiment, _count} -> symbol end, fn {_symbol, sentiment, count} ->
      {sentiment, count}
    end)
    |> Enum.map(fn {symbol, sentiment_counts} ->
      sentiment_map =
        sentiment_counts
        |> Enum.group_by(fn {sentiment, _count} -> sentiment end, fn {_sentiment, count} ->
          count
        end)
        |> Enum.map(fn {sentiment, counts} -> {sentiment, Enum.sum(counts)} end)
        |> Enum.into(%{})

      {symbol, sentiment_map}
    end)
    |> Enum.into(%{})
  end

  def sentiment_enabled? do
    Application.get_env(:basket, :news)[:sentiment_service_enabled]
  end
end
