defmodule Alternis.Word do
  @moduledoc false

  use Alternis.App, :domain_model

  alias Alternis.Dictionary

  schema "words" do
    belongs_to :dictionary, Dictionary
    field :lemma, :string
    field :frequency, :float
  end
end
