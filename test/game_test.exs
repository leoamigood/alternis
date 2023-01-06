defmodule Alternis.GameTest do
  use Alternis.DataCase, async: true

  alias Alternis.Game
  alias Alternis.Game.GameStatus

  setup do
    {:ok, game: %Game{secret: "secret"}}
  end

  test "creates game with game status created", %{game: game} do
    assert %Game{secret: "secret", status: GameStatus.Created} = Repo.insert!(game)
  end
end
