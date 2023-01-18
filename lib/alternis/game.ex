defmodule Alternis.Game do
  @moduledoc "Domain model for game lifecycle"

  use Alternis.App, :domain_model
  use Alternis.EnumTypes

  import Ecto.Changeset

  alias Alternis.GameSettings
  alias Alternis.Repo

  @type id :: Ecto.ShortUUID
  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "games" do
    has_many :guesses, Alternis.Guess
    field :in_progress?, :boolean, virtual: true

    field :secret, :string
    field :source, GameSource, default: GameSource.default()
    field :state, GameState, default: GameState.default()

    timestamps()
  end

  def changeset(schema, changes \\ %{}) do
    schema
    |> cast(changes, [:secret, :state])
    |> validate_required([:secret, :state])
    |> GameState.validate(:state)
    |> GameSource.validate(:source)
  end

  def configure(settings = %GameSettings{}) do
    %__MODULE__{secret: settings.secret |> String.downcase()}
  end

  def validate_state(game) do
    case game.in_progress? do
      true -> :ok
      false -> {:error, %{reason: :action_in_state_error, game: game}}
    end
  end

  def update_state!(game, state) do
    game
    |> changeset(%{state: state})
    |> Repo.update!()
  end
end
