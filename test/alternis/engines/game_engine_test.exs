defmodule Alternis.Engines.GameEngine.ImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game.GameState

  import Alternis.Factory

  import Hammox
  setup :verify_on_exit!

  describe "create/1 with engine generated secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> {:ok, "secret"} end)
      {:ok, game: build(:game, secret: nil)}
    end

    test "creates a game using generated secret", %{game: game} do
      assert {:ok, _uuid} = GameEngine.Impl.create(game)
    end
  end

  describe "create/1 with engine failing to generate secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> {:error, %{}} end)
      {:ok, game: build(:game, secret: nil)}
    end

    test "fails to create a game", %{game: game} do
      assert {:error, _} = GameEngine.Impl.create(game)
    end
  end

  describe "create/1 with user provided secret" do
    setup do
      {:ok, game: build(:game, secret: "secret")}
    end

    test "creates a game with user provided secret", %{game: game} do
      assert {:ok, _uuid} = GameEngine.Impl.create(game)
    end
  end

  describe "guess/1 placing a guess during running game" do
    setup do
      expect(MatchEngine.impl(), :match, fn _word, _secret -> {:ok, {[], []}} end)
      {:ok, game: build(:game, secret: "secret", state: GameState.Running)}
    end

    test "succeeds", %{game: game} do
      assert :ok = GameEngine.Impl.guess(game, "secret")
    end
  end

  describe "guess/1 placing a guess after game has finished" do
    setup do
      {:ok, game: build(:game, state: GameState.Finished)}
    end

    test "fails with error", %{game: game} do
      assert {:error, %{reason: :not_allowed}} = GameEngine.Impl.guess(game, "secret")
    end
  end

  describe "guess/1 placing a guess after game was aborted" do
    setup do
      {:ok, game: build(:game, state: GameState.Aborted)}
    end

    test "fails with error", %{game: game} do
      assert {:error, %{reason: :not_allowed}} = GameEngine.Impl.guess(game, "secret")
    end
  end

  describe "get/1" do
    setup do
      {:ok, game: insert!(:game, state: GameState.Running)}
    end

    test "succeeds", %{game: game} do
      assert game == GameEngine.Impl.get(game.id)
    end
  end
end
