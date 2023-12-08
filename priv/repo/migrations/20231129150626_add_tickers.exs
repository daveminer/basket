defmodule Basket.Repo.Migrations.AddTickers do
  use Ecto.Migration

  def change do
    create table(:tickers) do
      add :ticker, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:tickers, [:ticker, :user_id])
  end
end
