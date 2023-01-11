defmodule Alternis.Engines.GameEngine.ImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.Guess

  import Alternis.Factory

  import Hammox
  setup :verify_on_exit!

  describe "create/1 with engine generated secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> "secret" end)
      {:ok, settings: build(:game_settings, secret: nil)}
    end

    test "creates a game using generated secret", %{settings: settings} do
      assert {:ok, %Game{id: uuid}} = GameEngine.Impl.create(settings)
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)
    end
  end

  describe "create/1 with engine failing to generate secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> raise "failed to generate secret" end)
      {:ok, settings: build(:game_settings, secret: nil)}
    end

    test "fails to create a game", %{settings: settings} do
      assert_raise RuntimeError, fn -> GameEngine.Impl.create(settings) end
    end
  end

  describe "create/1 with user provided secret" do
    setup do
      {:ok, settings: build(:game_settings, secret: "secret")}
    end

    test "creates a game with user provided secret", %{settings: settings} do
      assert {:ok, %Game{id: uuid}} = GameEngine.Impl.create(settings)
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)
    end
  end

  describe "guess/1 placing a guess during running game" do
    setup do
      expect(MatchEngine.impl(), :match, fn _word, _secret -> {[], []} end)
      {:ok, game: insert(:game, secret: "secret", state: GameState.Running)}
    end

    test "creates guess for game and returns guess id", %{game: game = %Game{id: game_id}} do
      assert {:ok, %Guess{id: uuid}} = GameEngine.Impl.guess(game, "secret")
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)

      assert %Guess{id: ^uuid, game_id: ^game_id} = Alternis.Repo.get(Guess, uuid)
    end
  end

  describe "guess/1 placing a guess after game has finished" do
    setup do
      {:ok, game: insert(:game, state: GameState.Finished)}
    end

    test "fails with error without creating guess", %{game: game} do
      assert {:error, %{reason: :action_in_state_error}} = GameEngine.Impl.guess(game, "secret")

      assert 0 == Alternis.Repo.aggregate(Guess, :count, :id)
    end
  end

  describe "guess/1 placing a guess after game was aborted" do
    setup do
      {:ok, game: build(:game, state: GameState.Aborted)}
    end

    test "fails with error without creating guess", %{game: game} do
      assert {:error, %{reason: :action_in_state_error}} = GameEngine.Impl.guess(game, "secret")

      assert 0 == Alternis.Repo.aggregate(Guess, :count, :id)
    end
  end

  describe "get/1" do
    setup do
      {:ok, game: insert(:game, guesses: [])}
    end

    test "succeeds without guesses", %{game: game} do
      assert game == GameEngine.Impl.get(%Game{}, game.id)
    end

    test "succeeds with guesses", %{game: game} do
      insert_list(3, :guess, %{game: game})

      loaded = GameEngine.Impl.get(%Game{}, game.id)

      assert game.id == loaded.id
      assert 3 = length(loaded.guesses)
    end

    test "not found" do
      assert nil == GameEngine.Impl.get(%Game{}, Ecto.ShortUUID.generate())
    end
  end
end
