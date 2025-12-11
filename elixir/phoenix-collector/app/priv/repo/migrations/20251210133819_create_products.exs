defmodule ElixirPhoenixOpentelemetry.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 10, scale: 2
      add :quantity, :integer, default: 0

      timestamps()
    end

    create index(:products, [:name])
  end
end
