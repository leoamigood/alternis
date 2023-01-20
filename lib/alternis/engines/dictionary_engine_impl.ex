defmodule Alternis.Engines.DictionaryEngine.Impl do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query

  alias Alternis.Repo
  alias Alternis.Word

  @spec validate(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate(changeset, field) when is_atom(field) and length(changeset.errors) > 0 do
    changeset
  end

  def validate(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn field, value ->
      case member?(value) do
        true -> []
        false -> [{field, "word not in dictionary"}]
      end
    end)
  end

  def member?(word) do
    from(
      w in Word,
      where: w.lemma == ^word
    )
    |> Repo.exists?()
  end
end
