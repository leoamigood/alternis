defmodule Alternis.Engines.GameFlow.Impl do
  @moduledoc """
    Implements logic for game life cycle
  """

  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameAction
  alias Alternis.Game.GameAction.AbortAction
  alias Alternis.Game.GameAction.GuessAction
  alias Alternis.Game.GameState

  @spec execute(Game.t(), GameAction.t(), term) :: {:ok, Game.t()} | {:error, map}
  def execute(game = %Game{}, GuessAction, word) do
    {:ok, guess} = GameEngine.impl().guess(game, word)

    case MatchEngine.impl().exact?(guess) do
      true -> GameState.Finished
      false -> GameState.Running
    end
    |> GameEngine.impl().update_state(game)
  end

  def execute(game = %Game{}, AbortAction) do
    GameEngine.impl().update_state(GameState.Aborted, game)
  end
end
