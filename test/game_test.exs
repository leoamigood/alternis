defmodule Alternis.GameTest do
  use Alternis.DataCase, async: true

  alias Alternis.Game
  alias Alternis.Game.GameState

  setup do
    {:ok, game: %Game{secret: "secret"}}
  end

  test "creates game with game state created", %{game: game} do
    assert %Game{secret: "secret", state: GameState.Created} = Repo.insert!(game)
  end
end
