defmodule Alternis.GameSettings do
  @moduledoc "Structure contains game settings"

  @type t :: %__MODULE__{}

  use Ecto.Schema

  import Ecto.Changeset

  alias Alternis.Game.GameLanguage
  alias Alternis.Game.GameSource

  @primary_key false
  embedded_schema do
    field :secret, :string
    field :source, GameSource, default: GameSource.default()
    field :expires_at, :utc_datetime, default: nil
    field :language, GameLanguage
  end

  def changeset(schema, changes \\ %{}) do
    schema
    |> cast(changes, [:secret, :language])
    |> validate_required([:secret, :language])
    |> GameLanguage.validate(:language)
  end
end
