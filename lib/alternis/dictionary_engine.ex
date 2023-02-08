defmodule Alternis.Engines.DictionaryEngine do
  @moduledoc "Language corpus (dictionary) engine"

  alias Alternis.Game.GameLanguage
  alias Alternis.Word

  @implementation Application.compile_env!(:alternis, :dictionary_engine)
  def impl, do: @implementation

  @callback find_word(GameLanguage.t()) :: Word.t() | nil
  @callback find_word(GameLanguage.t(), word :: String.t()) :: Word.t() | nil
  @callback find_word(GameLanguage.t(), options :: map) :: Word.t() | nil
end
