defmodule Basket.News do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  alias Basket.Repo

  @type t :: %__MODULE__{}

  schema "news" do
    field :article_id, :string
    field :author, :string
    field :content, :string
    field :creation_date, :utc_datetime
    field :images, :map
    field :source, :string
    field :summary, :string
    field :symbols, {:array, :string}
    field :updated_date, :utc_datetime
    field :url, :string

    timestamps()
  end

  @spec add!(params: map()) :: __MODULE__.t()
  def add!(params) do
    struct(__MODULE__, params)
    |> Repo.insert!()
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
