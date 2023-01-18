defmodule Alternis.Engines.GameEngine.ImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.Guess
  alias Alternis.Repo

  import Alternis.Factory

  import Hammox
  setup :verify_on_exit!

  describe "create/1 with engine generated secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> "secret" end)
      {:ok, settings: build(:game_settings, secret: nil)}
    end

    test "creates game using generated secret", %{settings: settings} do
      assert {:ok, uuid} = GameEngine.Impl.create(settings)
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)
    end
  end

  describe "create/1 with engine failing to generate a secret" do
    setup do
      expect(MatchEngine.impl(), :secret, fn _game -> raise "failed to generate secret" end)
      {:ok, settings: build(:game_settings, secret: nil)}
    end

    test "fails creating game", %{settings: settings} do
      assert_raise RuntimeError, fn -> GameEngine.Impl.create(settings) end
    end
  end

  describe "create/1 with a settings provided secret" do
    setup do
      {:ok, settings: build(:game_settings, secret: "Secret")}
    end

    test "creates a game with normalized lowe case secret", %{settings: settings} do
      assert {:ok, uuid} = GameEngine.Impl.create(settings)
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)

      assert %Game{secret: "secret"} = Repo.get(Game, uuid)
    end
  end

  test "guess/2 fails error when game not found" do
    assert {:error, %{reason: :not_found, schema: Game}} =
             GameEngine.Impl.guess(Ecto.ShortUUID.generate(), "secret")
  end

  describe "guess/2 placing a guess" do
    setup do
      expect(MatchEngine.impl(), :match, fn "secret", "secret" -> {[6], []} end)
      Mock.allow_to_call_impl(MatchEngine, :exact?, 1, WordleImpl)

      {:ok, game: insert(:game, secret: "secret")}
    end

    test "invokes matching with normalized lower case word", %{game: %{id: game_id}} do
      GameEngine.Impl.guess(game_id, "Secret")
    end
  end

  describe "guess/2 placing a guess during game in progress" do
    setup do
      Mock.allow_to_call_impl(MatchEngine, :match, 2, WordleImpl)
      Mock.allow_to_call_impl(MatchEngine, :exact?, 1, WordleImpl)

      {:ok, game: insert(:game, secret: "secret", state: GameState.Created)}
    end

    test "creates a guess for game and returns id", %{game: %Game{id: game_id}} do
      assert {:ok, uuid} = GameEngine.Impl.guess(game_id, "dialog")
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)

      assert 1 == Repo.aggregate(Guess, :count, :id)
    end

    test "changes game state to running on non exact guess", %{game: %Game{id: game_id}} do
      assert {:ok, _} = GameEngine.Impl.guess(game_id, "dialog")
      assert %Game{state: GameState.Running} = Repo.get(Game, game_id)
    end

    test "changes game state to finished on exact guess", %{game: %Game{id: game_id}} do
      assert {:ok, _} = GameEngine.Impl.guess(game_id, "secret")
      assert %Game{state: GameState.Finished} = Repo.get(Game, game_id)
    end
  end

  describe "guess/2 placing a guess after game has finished" do
    setup do
      {:ok, game: insert(:game, state: GameState.Finished)}
    end

    test "fails with error without creating a guess", %{game: %Game{id: game_id}} do
      errors = GameEngine.Impl.guess(game_id, "secret")

      assert {:error, %{reason: :action_in_state_error}} = errors
      assert 0 == Repo.aggregate(Guess, :count, :id)
    end
  end

  describe "guess/2 placing a guess after game was aborted" do
    setup do
      {:ok, game: insert(:game, state: GameState.Aborted)}
    end

    test "fails with error without creating a guess", %{game: %Game{id: game_id}} do
      errors = GameEngine.Impl.guess(game_id, "secret")

      assert {:error, %{reason: :action_in_state_error}} = errors
      assert 0 == Repo.aggregate(Guess, :count, :id)
    end
  end

  describe "get/1" do
    setup do
      {:ok, game: insert(:game)}
    end

    test "succeeds for a game without guesses", %{game: game} do
      assert game == GameEngine.Impl.get(game.id)
    end

    test "succeeds for a game with guesses", %{game: game} do
      insert_list(3, :guess, %{game: game})

      loaded = GameEngine.Impl.get(game.id) |> Repo.preload(:guesses)

      assert game.id == loaded.id
      assert 3 == length(loaded.guesses)
    end

    test "returns nil when a game not found" do
      assert nil == GameEngine.Impl.get(Ecto.ShortUUID.generate())
    end
  end

  test "abort/1 fails with error when game not found" do
    assert {:error, %{reason: :not_found, schema: Game}} =
             GameEngine.Impl.guess(Ecto.ShortUUID.generate(), "secret")
  end

  describe "abort/1 when game is in progress" do
    setup do
      {:ok, game: insert(:game, state: GameState.Created)}
    end

    test "changes state to aborted", %{game: %Game{id: game_id}} do
      assert :ok == GameEngine.Impl.abort(game_id)
      assert %Game{state: GameState.Aborted} = Repo.get(Game, game_id)
    end
  end

  describe "abort/1 when game is not in progress" do
    setup do
      {:ok, game: insert(:game, state: GameState.Finished)}
    end

    test "fails with errors and does not change game state", %{game: %Game{id: game_id}} do
      assert {:error, %{reason: :action_in_state_error}} = GameEngine.Impl.abort(game_id)
      assert %Game{state: GameState.Finished} = Repo.get(Game, game_id)
    end
  end
end
