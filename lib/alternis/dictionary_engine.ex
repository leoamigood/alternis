defmodule Alternis.Engines.DictionaryEngine do
  @moduledoc "Language corpus (dictionary) engine"

  alias Alternis.Word
  alias Ecto.Changeset

  @implementation Application.compile_env!(:alternis, :dictionary_engine)
  def impl, do: @implementation

  @callback find_word(String.t()) :: Word.t() | nil
  @callback validate_word(Changeset.t(), atom) :: Changeset.t()
end
