defmodule Alternis.Engines.GameFlow do
  @moduledoc "Logic for game life cycle"

  alias Alternis.Game
  alias Alternis.Game.GameAction

  @implementation Application.compile_env!(:alternis, :game_flow)
  def impl, do: @implementation

  @callback execute(Game.t(), GameAction.t(), term) :: {:ok, Game.t()} | {:error, map}
end
