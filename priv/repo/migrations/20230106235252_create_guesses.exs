defmodule Alternis.Repo.Migrations.CreateGuesses do
  use Ecto.Migration

  def change do
    create table("guesses", primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :word, :string, null: false
      add :bulls, {:array, :integer}
      add :cows, {:array, :integer}
      add :game_id, references(:games, type: :uuid)

      timestamps()
    end
  end
end
