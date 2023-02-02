defmodule Alternis.Repo.Migrations.AddUsernameColumn do
  use Ecto.Migration

  alias Alternis.Accounts.User

  def change do
    alter table(:users) do
      add :username, :citext, null: false, default: ""
    end
  end
end
