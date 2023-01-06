defmodule Alternis.Engines.GameEngine.ImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.GameEngine
  alias Alternis.Game
  alias Alternis.Game.GameStatus

  describe "create/1" do
    setup do
      {:ok, game: %Game{secret: nil}}
    end

    test "creating a game with engine selecting secret word", %{game: game} do
      assert {:ok, %Game{state: GameStatus.Created}} = GameEngine.impl().create(game)
    end
  end

  describe "guess/1" do
    setup do
      {:ok, game: %Game{secret: "secret", state: GameStatus.Running}}
    end

    test "placing a guess during a running game", %{game: game} do
      assert {:ok, _} = GameEngine.impl().guess(game, "guess")
    end
  end
end
