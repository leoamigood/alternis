defmodule Alternis.Guess do
  @moduledoc "Structure contains guess attempts"

  use Alternis.App, :domain_model

  import Ecto.Changeset

  alias Alternis.Game

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
end
