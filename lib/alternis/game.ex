defmodule Alternis.Game do
  @moduledoc "Domain model for game lifecycle"

  use Alternis.App, :domain_model
  use Alternis.EnumTypes

  import Ecto.Changeset

  alias Alternis.Game.GameLanguage
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
    field :expires_at, :utc_datetime, default: nil
    field :language, GameLanguage, default: GameLanguage.default()

    timestamps()
  end

  def changeset(schema, changes \\ %{}) do
    schema
    |> change(changes)
    |> validate_required([:secret, :state, :language])
    |> GameState.validate(:state)
    |> GameSource.validate(:source)
    |> GameLanguage.validate(:language)
  end

  def configure(settings = %GameSettings{}) do
    %__MODULE__{
      secret: settings.secret |> String.downcase(),
      expires_at: settings.expires_at,
      language: settings.language
    }
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
