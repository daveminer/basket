defmodule Basket.Repo.Migrations.AddNewsArticles do
  use Ecto.Migration

  def change do
    create table(:news) do
      add :article_id, :string, null: false
      add :author, :string
      add :content, :string, null: false
      add :creation_date, :utc_datetime, null: false
      add :images, :jsonb, default: fragment("'[]'::jsonb")
      add :source, :string
      add :summary, :string, null: false
      add :symbols, {:array, :string}
      add :updated_date, :utc_datetime, null: false
      add :url, :string

      timestamps()
    end
  end
end
