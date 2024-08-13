defmodule Basket.News do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  alias Basket.Repo

  @type t :: %__MODULE__{
          article_id: String.t(),
          author: String.t(),
          content: String.t(),
          creation_date: DateTime.t(),
          images: map,
          source: String.t(),
          summary: String.t(),
          symbols: list(String.t()),
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

  @spec new(map()) :: __MODULE__.t()
  def new(%{
        "id" => article_id,
        "author" => author,
        "content" => content,
        "created_at" => creation_date,
        "images" => images,
        "source" => source,
        "summary" => summary,
        # "symbols" => symbols,
        "updated_at" => updated_date,
        "url" => url
      }) do
    %__MODULE__{
      article_id: article_id,
      author: author,
      content: content,
      creation_date: creation_date,
      images: images,
      source: source,
      summary: summary,
      symbols: [],
      # symbols: symbols,
      updated_date: updated_date,
      url: url
    }
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
