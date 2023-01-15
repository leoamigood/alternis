defmodule Alternis.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table("games", primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :secret, :string, null: false
      add :source, :string, null: false
      add :state, :string, null: false

      timestamps()
    end
  end
end
