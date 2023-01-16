defmodule Alternis.Guess do
  @moduledoc "Structure contains guess attempts"

  use Alternis.App, :domain_model

  import Ecto.Changeset

  alias Alternis.Game
  alias Alternis.Guess

  @type id :: Ecto.ShortUUID
  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "guesses" do
    belongs_to :game, Game, type: Ecto.ShortUUID

    field :word, :string
    field :bulls, {:array, :integer}
    field :cows, {:array, :integer}

    timestamps()
  end

  def changeset(schema) do
    schema
    |> change()
    |> validate_required([:word, :bulls, :cows])
  end

  def change_secret(secret \\ "", attrs \\ %{}) do
    %Guess{}
    |> cast(attrs, [:word])
    |> validate_required([:word])
    |> validate_length(:word, is: String.length(secret))
    |> validate_format(:word, ~r/^[[:alpha:]]+$/, message: "Guess must contain only letters.")
  end
end
