defmodule Alternis.Engines.DictionaryEngine do
  @moduledoc "Language corpus (dictionary) engine"

  alias Alternis.Game.GameLanguage
  alias Alternis.Word

  @implementation Application.compile_env!(:alternis, :dictionary_engine)
  def impl, do: @implementation

  @callback find_word(String.t(), GameLanguage.t()) :: Word.t() | nil
end
