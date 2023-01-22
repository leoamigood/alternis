defmodule Alternis.Word do
  @moduledoc false

  use Alternis.App, :domain_model

  alias Alternis.Dictionary

  schema "words" do
    belongs_to :dictionary, Dictionary
    field :lemma, :string
    field :frequency, :float
    field :r, :integer
    field :d, :integer
    field :doc, :integer
    field :language, :string, virtual: true
  end
end
