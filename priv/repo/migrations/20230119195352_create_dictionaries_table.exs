defmodule Alternis.Repo.Migrations.CreateDictionariesTable do
  use Ecto.Migration

  alias Alternis.Game.GameLanguage.English

  def change do
    alter table("games") do
      add :language, :string, null: false, default: English.value()
    end

    create table("dictionaries") do
      add :name, :string, null: false
      add :description, :string, null: true
      add :source, :string, null: true
      add :language, :string, null: false
    end

    create table("words") do
      add :dictionary_id, references(:dictionaries)
      add :lemma, :string, null: false
      add :frequency, :float, null: false
      add :r, :integer, null: false
      add :d, :integer, null: false
      add :doc, :integer, null: false
    end

    create index("words", [:lemma])
    create index("words", [:frequency])
  end
end
