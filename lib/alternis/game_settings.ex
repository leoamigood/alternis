defmodule Alternis.GameSettings do
  @moduledoc "Structure contains game settings"

  @type t :: %__MODULE__{}

  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :secret, :string
    field :source, :string
  end

  def changeset(schema, changes \\ %{}) do
    schema
    |> cast(changes, [:secret])
    |> validate_required([:secret])
  end
end
