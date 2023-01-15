defmodule Alternis.GameTest do
  use Alternis.DataCase, async: true

  alias Alternis.Game
  alias Alternis.Game.GameState

  import Alternis.Factory

  test "creates game with game state created" do
    assert %Game{secret: "secret", state: GameState.Created} = Repo.insert!(build(:game))
  end

  test "game in progress states" do
    assert Game.in_progress?(build(:game, state: GameState.Created))
    assert Game.in_progress?(build(:game, state: GameState.Running))

    refute Game.in_progress?(build(:game, state: GameState.Finished))
    refute Game.in_progress?(build(:game, state: GameState.Aborted))
  end
end
