defmodule Alternis.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table("games") do
      add :secret, :string, null: false
      add :source, :string, null: false
      add :state, :string, null: false

      timestamps()
    end
  end
end
