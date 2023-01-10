defmodule Alternis.GameSettings do
  @moduledoc "Structure contains game settings"

  defstruct [:secret, :source]

  @type t :: %__MODULE__{}
end
