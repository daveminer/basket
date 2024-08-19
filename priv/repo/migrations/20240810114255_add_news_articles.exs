defmodule Basket.Repo.Migrations.AddNewsArticles do
  use Ecto.Migration

  def change do
    execute "CREATE TYPE sentiment AS ENUM ('positive', 'neutral', 'negative')"

    create table(:news) do
      add :article_id, :string, null: false
      add :author, :string
      add :content, :text
      add :creation_date, :utc_datetime, null: false
      add :headline, :text, null: false
      add :images, :jsonb, default: fragment("'[]'::jsonb")
      add :sentiment, :sentiment
      add :sentiment_confidence, :decimal
      add :sentiment_id, :integer
      add :source, :string
      add :summary, :text
      add :symbols, {:array, :string}
      add :updated_date, :utc_datetime, null: false
      add :url, :text

      timestamps()
    end

    create index(:news, [:article_id], unique: true)
    create index(:news, [:images], using: :gin)
  end
end
