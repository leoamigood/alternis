defmodule Alternis.Engines.GameFlow.ImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.GameFlow
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameAction.AbortAction
  alias Alternis.Game.GameAction.GuessAction
  alias Alternis.Game.GameState

  import Alternis.Factory

  import Hammox
  setup :verify_on_exit!

  describe "execute/1 guess action with exact guess" do
    setup do
      Mock.allow_to_call_impl(GameEngine, :guess, 2)
      Mock.allow_to_call_impl(MatchEngine, :match, 2, WordleImpl)
      Mock.allow_to_call_impl(MatchEngine, :exact?, 1, WordleImpl)
      Mock.allow_to_call_impl(GameEngine, :update_state, 2)

      {:ok, game: insert(:game, state: GameState.Created)}
    end

    test "updates game state to running", %{game: game = %Game{id: game_id}} do
      GameFlow.Impl.execute(game, GuessAction, "dialog")

      assert %Game{id: ^game_id, state: GameState.Running} = Alternis.Repo.get(Game, game_id)
    end

    test "updates game state to finished", %{game: game = %Game{id: game_id}} do
      GameFlow.Impl.execute(game, GuessAction, "secret")

      assert %Game{id: ^game_id, state: GameState.Finished} = Alternis.Repo.get(Game, game_id)
    end
  end

  describe "execute/1 abort game action" do
    setup do
      Mock.allow_to_call_impl(GameEngine, :update_state, 2)

      {:ok, game: insert(:game, state: GameState.Created)}
    end

    test "updates game state to aborted", %{game: game = %Game{id: game_id}} do
      GameFlow.Impl.execute(game, AbortAction)

      assert %Game{id: ^game_id, state: GameState.Aborted} = Alternis.Repo.get(Game, game_id)
    end
  end
end
