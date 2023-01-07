defmodule Alternis.Game do
  @moduledoc "Structure contains game lifecycle properties"

  use Alternis.App, :domain_model
  use Alternis.EnumTypes

  import Ecto.Changeset

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "games" do
    field :secret, :string
    field :source, :string
    field :state, GameState, default: GameState.default()

    timestamps()
  end

  def changeset(schema) do
    schema
    |> change()
    |> validate_required([:secret, :state])
    |> GameState.validate(:state)
  end
end
