defmodule ElixirPhoenixOpentelemetry.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :quantity, :integer

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :quantity])
    |> validate_required([:name])
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
  end
end
