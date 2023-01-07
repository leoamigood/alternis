defmodule Alternis.Engines.GameEngine.ImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameState

  import Alternis.Factory

  import Hammox
  setup :verify_on_exit!

  describe "create/1 with engine generated secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> "secret" end)
      {:ok, game: build(:game, secret: nil)}
    end

    test "creates a game using generated secret", %{game: game} do
      assert {:ok, %Game{id: uuid}} = GameEngine.Impl.create(game)
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)
    end
  end

  describe "create/1 with engine failing to generate secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> raise "failed to generate secret" end)
      {:ok, game: build(:game, secret: nil)}
    end

    test "fails to create a game", %{game: game} do
      assert_raise RuntimeError, fn -> GameEngine.Impl.create(game) end
    end
  end

  describe "create/1 with user provided secret" do
    setup do
      {:ok, game: build(:game, secret: "secret")}
    end

    test "creates a game with user provided secret", %{game: game} do
      assert {:ok, %Game{id: uuid}} = GameEngine.Impl.create(game)
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)
    end
  end

  describe "guess/1 placing a guess during running game" do
    setup do
      expect(MatchEngine.impl(), :match, fn _word, _secret -> {[], []} end)
      {:ok, game: build(:game, secret: "secret", state: GameState.Running)}
    end

    test "succeeds", %{game: game} do
      assert {:ok, %Guess{id: uuid}} = GameEngine.Impl.guess(game, "secret")
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)
    end
  end

  describe "guess/1 placing a guess after game has finished" do
    setup do
      {:ok, game: build(:game, state: GameState.Finished)}
    end

    test "fails with error", %{game: game} do
      assert {:error, %{reason: :action_in_state_error}} = GameEngine.Impl.guess(game, "secret")
    end
  end

  describe "guess/1 placing a guess after game was aborted" do
    setup do
      {:ok, game: build(:game, state: GameState.Aborted)}
    end

    test "fails with error", %{game: game} do
      assert {:error, %{reason: :action_in_state_error}} = GameEngine.Impl.guess(game, "secret")
    end
  end

  describe "get/1" do
    setup do
      {:ok, game: insert!(:game, state: GameState.Running)}
    end

    test "succeeds", %{game: game} do
      assert game == GameEngine.Impl.get(%Game{}, game.id)
    end

    test "not found" do
      assert nil == GameEngine.Impl.get(%Game{}, Ecto.ShortUUID.generate())
    end
  end
end
