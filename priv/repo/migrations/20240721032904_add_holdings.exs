defmodule YourApp.Repo.Migrations.AddHoldings do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE direction AS ENUM ('buy', 'sell')"

    create table(:holdings) do
      add :ticker, :string, null: false
      add :club_id, references(:clubs, on_delete: :delete_all)
      add :amount, :float, null: false
      add :price, :float, null: false
      add :direction, :direction, null: false

      timestamps()
    end

    alter table(:clubs) do
      add :cash, :float, default: 0.0, null: false
    end
  end

  def down do
    drop table(:holdings)

    execute "DROP TYPE direction"

    modify table(:clubs) do
      remove :cash
    end
  end
end
