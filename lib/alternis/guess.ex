defmodule Alternis.Guess do
  @moduledoc "Structure contains guess attempts"

  use Alternis.App, :domain_model

  import Ecto.Changeset

  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Game
  alias Alternis.Guess

  @type id :: Ecto.ShortUUID
  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "guesses" do
    belongs_to :game, Game, type: Ecto.ShortUUID

    field :word, :string
    field :bulls, {:array, :integer}
    field :cows, {:array, :integer}
    field :exact?, :boolean, source: :exact

    timestamps()
  end

  def changeset(schema) do
    schema
    |> change()
    |> validate_required([:word, :bulls, :cows])
  end

  def validate_word(game, attrs \\ %{}) do
    %Guess{}
    |> cast(attrs, [:word])
    |> validate_required([:word])
    |> validate_length(:word, is: String.length(game.secret))
    |> validate_in_dictionary(game.language)
  end

  defp validate_in_dictionary(changeset, _language) when length(changeset.errors) > 0 do
    changeset
  end

  defp validate_in_dictionary(changeset, language) do
    validate_change(changeset, :word, fn _field, word ->
      case DictionaryEngine.impl().find_word(word, language) do
        nil -> [{:word, "word not in dictionary"}]
        _ -> []
      end
    end)
  end
end
