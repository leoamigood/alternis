defmodule Alternis.Repo.Migrations.AddExactGuessColumn do
  use Ecto.Migration

  def change do
    alter table("guesses") do
      add :exact, :boolean, null: false, default: false
    end
  end
end
