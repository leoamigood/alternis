defmodule Alternis.Game do
  @moduledoc "Domain model for game lifecycle"

  use Alternis.App, :domain_model
  use Alternis.EnumTypes

  import Ecto.Changeset

  alias Alternis.GameSettings

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "games" do
    has_many :guesses, Alternis.Guess

    field :secret, :string
    field :source, GameSource, default: GameSource.default()
    field :state, GameState, default: GameState.default()

    timestamps()
  end

  def setup(game_setup = %GameSettings{}) do
    %__MODULE__{secret: game_setup.secret}
  end

  def changeset(schema) do
    schema
    |> change()
    |> validate_required([:secret, :state])
    |> GameState.validate(:state)
    |> GameSource.validate(:source)
  end
end
