defmodule Alternis.GameTest do
  use Alternis.DataCase, async: true

  alias Alternis.Game
  alias Alternis.Game.GameState

  import Alternis.Factory

  test "creates game with game state created" do
    assert %Game{secret: "secret", state: GameState.Created} = Repo.insert!(build(:game))
  end
end
