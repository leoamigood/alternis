defmodule Alternis.Engines.DictionaryEngine.Impl do
  @moduledoc false

  import Ecto.Query

  alias Alternis.Dictionary
  alias Alternis.Game.GameLanguage
  alias Alternis.Repo
  alias Alternis.Word

  @spec find_word(String.t(), GameLanguage.t()) :: Word.t() | nil
  def find_word(lemma, language) do
    from(
      w in Word,
      join: d in Dictionary,
      on: d.id == w.dictionary_id,
      where:
        d.language == ^language and
          w.lemma == ^String.downcase(lemma),
      select_merge: %{language: d.language},
      order_by: w.frequency,
      limit: 1
    )
    |> Repo.one()
  end
end
