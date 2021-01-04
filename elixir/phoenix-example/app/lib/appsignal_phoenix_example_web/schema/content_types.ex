defmodule AppsignalPhoenixExampleWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :age, :integer
    field :name, :string
  end
end
