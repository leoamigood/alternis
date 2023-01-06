defmodule Alternis.Game do
  use Ecto.Schema
  use Alternis.EnumTypes

  import Ecto.Changeset

  @moduledoc "Structure contains game lifecycle properties"

  @type t :: %__MODULE__{}

  schema "games" do
    field :secret, :string
    field :source, :string
    field :state, GameStatus, default: GameStatus.default()

    timestamps()
  end

  def changeset(schema) do
    schema
    |> change()
    |> validate_required([:secret, :state])
    |> GameStatus.validate(:state)
  end
end
