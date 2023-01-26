defmodule Alternis.Engines.GameEngine.ImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.Game.GameState.Aborted
  alias Alternis.Game.GameState.Created
  alias Alternis.Game.GameState.Finished
  alias Alternis.Guess
  alias Alternis.Match
  alias Alternis.Repo

  import Alternis.Factory

  import Hammox
  setup :verify_on_exit!

  describe "create/1 with engine generated secret" do
    setup do
      expect(DictionaryEngine.impl(), :secret, fn _secret -> "secret" end)
      {:ok, settings: build(:game_settings, secret: nil)}
    end

    test "creates game using generated secret", %{settings: settings} do
      assert {:ok, uuid} = GameEngine.Impl.create(settings)
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)
    end
  end

  describe "create/1 with engine failing to generate a secret" do
    setup do
      expect(DictionaryEngine.impl(), :secret, fn _secret -> nil end)
      {:ok, settings: build(:game_settings, secret: nil)}
    end

    test "fails creating game", %{settings: settings} do
      assert {:error, %{reason: :secret_not_found}} = GameEngine.Impl.create(settings)
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
      expect(MatchEngine.impl(), :match, fn "secret", "secret" ->
        %Match{word: "secret", bulls: [6], cows: [], exact?: true}
      end)

      {:ok, game: insert(:game, secret: "secret")}
    end

    test "invokes matching with normalized lower case word", %{game: %{id: game_id}} do
      GameEngine.Impl.guess(game_id, "Secret")
    end
  end

  describe "guess/2 placing a guess during game in progress" do
    setup do
      Mock.allow_to_call_impl(MatchEngine, :match, 2, WordleImpl)
      {:ok, game: insert(:game, secret: "secret", state: Created)}
    end

    test "creates a guess for game", %{game: %Game{id: game_id}} do
      assert {:ok, %Guess{id: uuid}} = GameEngine.Impl.guess(game_id, "dialog")
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)

      assert 1 == Repo.aggregate(Guess, :count, :id)
    end

    test "changes game state to running on non exact guess", %{game: %Game{id: game_id}} do
      assert {:ok, _} = GameEngine.Impl.guess(game_id, "dialog")
      assert %Game{state: GameState.Running} = Repo.get(Game, game_id)
    end

    test "changes game state to finished on exact guess", %{game: %Game{id: game_id}} do
      assert {:ok, _} = GameEngine.Impl.guess(game_id, "secret")
      assert %Game{state: Finished} = Repo.get(Game, game_id)
    end
  end

  describe "guess/2 placing a guess after game has finished" do
    setup do
      {:ok, game: insert(:game, state: Finished)}
    end

    test "fails with error without creating a guess", %{game: %Game{id: game_id}} do
      errors = GameEngine.Impl.guess(game_id, "secret")

      assert {:error, %{reason: :unpermitted_action, action: :guess}} = errors
      assert 0 == Repo.aggregate(Guess, :count, :id)
    end
  end

  describe "guess/2 placing a guess after game was aborted" do
    setup do
      {:ok, game: insert(:game, state: Aborted)}
    end

    test "fails with error without creating a guess", %{game: %Game{id: game_id}} do
      errors = GameEngine.Impl.guess(game_id, "secret")

      assert {:error, %{reason: :unpermitted_action, action: :guess}} = errors
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
             GameEngine.Impl.abort(Ecto.ShortUUID.generate())
  end

  describe "abort/1 when game is in progress" do
    setup do
      {:ok, game: insert(:game, state: Created)}
    end

    test "changes state to aborted", %{game: %Game{id: game_id}} do
      assert :ok == GameEngine.Impl.abort(game_id)
      assert %Game{state: Aborted} = Repo.get(Game, game_id)
    end
  end

  describe "abort/1 when game is not in progress" do
    setup do
      {:ok, game: insert(:game, state: Finished)}
    end

    test "fails with errors and does not change game state", %{game: %Game{id: game_id}} do
      assert {:error, %{reason: :unpermitted_action, action: :abort}} =
               GameEngine.Impl.abort(game_id)

      assert %Game{state: Finished} = Repo.get(Game, game_id)
    end
  end

  describe "games/1" do
    setup do
      insert(:game, state: Created)
      insert(:game, state: Finished)
      insert(:game, state: Aborted)

      :ok
    end

    test "finds games in specified state only" do
      assert [%Game{state: Finished} | [%Game{state: Aborted}]] =
               GameEngine.Impl.games([Finished, Aborted])
    end
  end
end
