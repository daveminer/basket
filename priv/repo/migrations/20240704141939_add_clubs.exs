defmodule Basket.Repo.Migrations.AddClubs do
  use Ecto.Migration

  def change do
    create table(:clubs) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:clubs, [:name])

    create table(:club_members) do
      add :club_id, references(:clubs, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:club_members, [:club_id, :user_id])

    create table(:club_officers) do
      add :club_id, references(:clubs, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:club_officers, [:club_id, :user_id])

    create table(:club_tickers) do
      add :ticker, :string, null: false
      add :club_id, references(:clubs, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:club_tickers, [:club_id, :ticker])

    alter table(:users) do
      add :settings, :map, default: %{}, null: false
    end
  end
end
