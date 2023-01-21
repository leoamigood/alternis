defmodule Alternis.Dictionary do
  @moduledoc false

  use Alternis.App, :domain_model

  alias Alternis.Game.GameLanguage
  alias Alternis.Word

  schema "dictionaries" do
    has_many :words, Word
    field :name, :string
    field :description, :string
    field :source, :string
    field :language, GameLanguage
  end
end
