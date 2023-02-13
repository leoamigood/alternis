defmodule Alternis.Engines.DictionaryEngine.Impl do
  @moduledoc false

  import Ecto.Query

  alias Alternis.Dictionary
  alias Alternis.Game.GameLanguage
  alias Alternis.Repo
  alias Alternis.Word

  def find_word(language, opts \\ %{min: 4, max: 9})

  @spec find_word(GameLanguage.t(), map) :: Word.t() | nil
  def find_word(language, %{min: min, max: max}) do
    condition =
      dynamic(fragment("LENGTH(lemma) > ?", ^min) and fragment("LENGTH(lemma) < ?", ^max))

    conditionally_find_word(language, condition)
  end

  @spec find_word(GameLanguage.t(), String.t()) :: Word.t() | nil
  def find_word(language, word) when not is_nil(word) do
    condition = dynamic([w], w.lemma == ^String.downcase(word))
    conditionally_find_word(language, condition)
  end

  defp conditionally_find_word(language, condition) do
    Repo.one(
      from w in Word,
        join: d in Dictionary,
        on: d.id == w.dictionary_id,
        where: ^condition,
        where: d.language == ^language,
        select_merge: %{language: d.language},
        order_by: fragment("RANDOM()"),
        limit: 1
    )
  end
end
