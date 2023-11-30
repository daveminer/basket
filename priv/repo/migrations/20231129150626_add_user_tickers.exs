defmodule Basket.Repo.Migrations.AddUserTickers do
  use Ecto.Migration

  def change do
    create table(:user_tickers) do
      add :ticker, :string, null: false
      add :user, references("users", on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:user_tickers, [:ticker, :user])
  end
end
