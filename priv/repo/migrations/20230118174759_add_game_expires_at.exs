defmodule Alternis.Repo.Migrations.AddGameExpiresAt do
  use Ecto.Migration

  def change do
    alter table("games") do
      add :expires_at, :utc_datetime, default: nil
    end
  end
end
