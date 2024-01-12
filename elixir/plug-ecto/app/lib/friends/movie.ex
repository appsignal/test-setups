defmodule Friends.Movie do
  use Ecto.Schema

  schema "movies" do
    field :title, :string
    field :tagline, :string
    has_many :characters, Friends.Character
    many_to_many :actors, Friends.Actor, join_through: "movies_actors"
  end
end
