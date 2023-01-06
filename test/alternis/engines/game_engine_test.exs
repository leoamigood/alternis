defmodule Alternis.Engines.GameEngine.ImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameStatus

  import Hammox
  setup :verify_on_exit!

  describe "create/1 with engine generated secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> {:ok, "secret"} end)
      {:ok, game: %Game{secret: nil}}
    end

    test "creates a game using generated secret", %{game: game} do
      assert {:ok, _uuid} = GameEngine.Impl.create(game)
    end
  end

  describe "create/1 with engine failing to generate secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> {:error, %{}} end)
      {:ok, game: %Game{secret: nil}}
    end

    test "fails to create a game", %{game: game} do
      assert {:error, _} = GameEngine.Impl.create(game)
    end
  end

  describe "create/1 with user provided secret" do
    setup do
      {:ok, game: %Game{secret: "secret"}}
    end

    test "creates a game with user provided secret", %{game: game} do
      assert {:ok, _uuid} = GameEngine.Impl.create(game)
    end
  end

  describe "guess/1" do
    setup do
      Mock.allow_to_call_impl(MatchEngine, :match, 2, WordleImpl)
      {:ok, game: %Game{secret: "secret", status: GameStatus.Running}}
    end

    test "placing non exact guess during a running game", %{game: game} do
      assert :ok = GameEngine.Impl.guess(game, "dialog")
    end
  end
end
