defmodule AppsignalPhoenixExampleWeb.Schema do
  use Absinthe.Schema
  import_types AppsignalPhoenixExampleWeb.Schema.ContentTypes

  query do
    @desc "Get all users"
    field :users, list_of(:user) do
      resolve fn(_, _) ->
         {:ok, AppsignalPhoenixExample.Accounts.list_users()}
      end
    end
  end
end
