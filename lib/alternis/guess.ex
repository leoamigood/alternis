defmodule Alternis.Guess do
  @moduledoc "Structure contains guess attempts"

  use Alternis.App, :domain_model

  import Ecto.Changeset

  alias Alternis.Accounts.User
  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Game
  alias Alternis.Guess

  @type id :: binary
  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "guesses" do
    belongs_to :user, User
    belongs_to :game, Game, type: Ecto.ShortUUID

    field :word, :string
    field :bulls, {:array, :integer}
    field :cows, {:array, :integer}
    field :exact?, :boolean, source: :exact

    timestamps()
  end

  def changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:word, :bulls, :cows, :exact?])
    |> validate_required([:word, :bulls, :cows, :exact?])
  end

  def validate_word(attrs \\ %{}) do
    %Guess{}
    |> cast(attrs, [:word])
    |> validate_required([:word])
  end

  def validate_word_length(changeset, exact_length) do
    changeset
    |> validate_length(:word, is: exact_length)
  end

  def validate_word_in_dictionary(changeset, _language) when length(changeset.errors) > 0 do
    changeset
  end

  def validate_word_in_dictionary(changeset, language) do
    validate_change(changeset, :word, fn _field, word ->
      case DictionaryEngine.impl().find_word(word, language) do
        nil -> [{:word, "word not in dictionary"}]
        _ -> []
      end
    end)
  end
end
