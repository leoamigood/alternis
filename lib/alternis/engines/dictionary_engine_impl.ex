defmodule Alternis.Engines.DictionaryEngine.Impl do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query

  alias Alternis.Dictionary
  alias Alternis.Repo
  alias Alternis.Word

  @spec find_word(String.t()) :: Word.t() | nil
  def find_word(lemma) do
    from(
      w in Word,
      join: d in Dictionary,
      where: w.lemma == ^String.downcase(lemma),
      select_merge: %{language: d.language},
      order_by: w.frequency,
      limit: 1
    )
    |> Repo.one()
  end

  @spec validate_word(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate_word(changeset, field) when is_atom(field) and length(changeset.errors) > 0 do
    changeset
  end

  def validate_word(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn field, value ->
      case find_word(value) do
        nil -> [{field, "word not in dictionary"}]
        _ -> []
      end
    end)
  end
end
