defmodule Alternis.GameSettings do
  @moduledoc "Structure contains game settings"

  @type t :: %__MODULE__{}

  use Ecto.Schema

  import Ecto.Changeset

  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Game.GameLanguage
  alias Alternis.Game.GameSource

  @primary_key false
  embedded_schema do
    field :secret, :string
    field :source, GameSource, default: GameSource.default()
    field :language, GameLanguage
    field :expires_at, :utc_datetime, default: nil
  end

  def changeset(schema, changes \\ %{}) do
    schema
    |> cast(changes, [:secret, :language])
    |> validate_required(:language)
    |> GameLanguage.validate(:language)
  end

  def validate_in_dictionary(changeset, _field) when length(changeset.errors) > 0 do
    changeset
  end

  def validate_in_dictionary(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn field, secret ->
      case DictionaryEngine.impl().find_word(secret, changeset.changes.language) do
        nil -> [{field, "word not in dictionary"}]
        _ -> []
      end
    end)
  end
end
