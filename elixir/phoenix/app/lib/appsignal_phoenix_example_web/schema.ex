defmodule AppsignalPhoenixExampleWeb.Schema do
  use Absinthe.Schema

  @desc "An item"
  object :item do
    field(:id, :id)
    field(:name, :string)
  end

  @items %{
    "foo" => %{id: "foo", name: "Foo"},
    "bar" => %{id: "bar", name: "Bar"}
  }

  query do
    field :item, :item do
      arg(:id, non_null(:id))

      resolve(fn %{id: item_id}, _ ->
        raise "query error!"

        {:ok, @items[item_id]}
      end)
    end
  end

  mutation do
    field :do_thing, type: :item do
      arg(:id, non_null(:id))
      arg(:name, non_null(:string))

      resolve(fn %{id: item_id}, _ ->
        {:ok, @items[item_id]}
      end)
    end
  end
end
