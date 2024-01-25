defmodule Friends.Repo.Migrations.AddExampleData do
  use Ecto.Migration
  alias Friends.{Actor, Movie}

  def change do
    repo = repo()

    movie = %Movie{title: "Ready Player One", tagline: "Something about video games"}
    movie = repo.insert!(movie)

    character = Ecto.build_assoc(movie, :characters, %{name: "Wade Watts"})
    character = repo.insert!(character)

    actor = %Actor{name: "Tyler Sheridan"}
    actor = repo.insert!(actor)

    movie = repo.preload(movie, [:characters, :actors])
    movie_changeset = Ecto.Changeset.change(movie)
    movie_actor_changeset = Ecto.Changeset.put_assoc(movie_changeset, :actors, [actor])
    repo.update!(movie_actor_changeset)

    movie_actor_changeset = Ecto.Changeset.put_assoc(movie_changeset, :actors, [%{name: "Gary"}])
    repo.update!(movie_actor_changeset)
  end
end
