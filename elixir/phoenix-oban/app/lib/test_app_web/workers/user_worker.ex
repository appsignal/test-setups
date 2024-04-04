defmodule TestApp.UserWorker do
  use Oban.Worker

  alias TestApp.Repo
  alias TestApp.User

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    Enum.each(1..4, fn _ -> Repo.all(User) end)

    IO.puts "UserWorker run!"
    IO.inspect args

    Repo.transaction(fn ->
      Enum.each(1..6, fn _ -> Repo.all(User) end)
      Repo.transaction(fn ->
        Enum.each(1..4, fn _ -> Repo.all(User) end)
      end)
    end)

    user =
      %User{}
      |> User.changeset(args)

    case Repo.insert(user) do
      {:ok, user} ->
        IO.puts "User created!"
        IO.inspect user
        Repo.transaction(fn ->
          Enum.each(1..10, fn _ -> Repo.all(User) end)
        end)

        Repo.transaction(fn ->
          user
          |> User.changeset(%{email: "nottom@example.com"})
          |> Repo.update()

          Enum.each(1..10, fn _ -> Repo.all(User) end)
          Repo.delete(user)
          Enum.each(1..10, fn _ -> Repo.all(User) end)
        end)
        :ok

        {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts "Error creating user!"
        :error
    end
  end
end
