defmodule PlugOban.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def up do
    Oban.Migrations.up(prefix: "some_prefix", version: 11)
  end

  # We specify `version: 1` in `down`, ensuring that we'll roll all the way back down if
  # necessary, regardless of which version we've migrated `up` to.
  def down do
    Oban.Migrations.down(prefix: "some_prefix", version: 1)
  end
end
