defmodule Alternis.Repo.Migrations.AddGuessUser do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end

    alter table(:guesses) do
      add :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
