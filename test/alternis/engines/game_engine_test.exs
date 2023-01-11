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

    test "creates game using generated secret", %{settings: settings} do
      game = GameEngine.Impl.create(settings)

      assert {:ok, %Game{id: uuid}} = game
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
      {:ok, settings: build(:game_settings, secret: "secret")}
    end

    test "creates a game with provided secret", %{settings: settings} do
      game = GameEngine.Impl.create(settings)

      assert {:ok, %Game{id: uuid}} = game
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)
    end
  end

  describe "guess/1 placing a guess during running game" do
    setup do
      expect(MatchEngine.impl(), :match, fn _word, _secret -> {[], []} end)

      {:ok, game: insert(:game, state: GameState.Created)}
    end

    test "creates a guess for game and returns guess id", %{game: game = %Game{id: game_id}} do
      guess = GameEngine.Impl.guess(game, "guess")

      assert {:ok, %Guess{id: uuid}} = guess
      assert {:ok, _} = Ecto.ShortUUID.dump(uuid)

      assert %Guess{id: ^uuid, game_id: ^game_id} = Alternis.Repo.get(Guess, uuid)
    end
  end

  describe "guess/1 placing a guess after game has finished" do
    setup do
      {:ok, game: insert(:game, state: GameState.Finished)}
    end

    test "fails with error without creating a guess", %{game: game} do
      guess = GameEngine.Impl.guess(game, "secret")

      assert {:error, %{reason: :action_in_state_error, game: ^game}} = guess
      assert 0 == Alternis.Repo.aggregate(Guess, :count, :id)
    end
  end

  describe "guess/1 placing a guess after game was aborted" do
    setup do
      {:ok, game: build(:game, state: GameState.Aborted)}
    end

    test "fails with error without creating a guess", %{game: game} do
      guess = GameEngine.Impl.guess(game, "secret")

      assert {:error, %{reason: :action_in_state_error, game: ^game}} = guess
      assert 0 == Alternis.Repo.aggregate(Guess, :count, :id)
    end
  end

  describe "get/1" do
    setup do
      {:ok, game: insert(:game, guesses: [])}
    end

    test "succeeds for a game without guesses", %{game: game} do
      assert game == GameEngine.Impl.get(%Game{}, game.id)
    end

    test "succeeds for a game with guesses", %{game: game} do
      insert_list(3, :guess, %{game: game})

      loaded = GameEngine.Impl.get(%Game{}, game.id)

      assert game.id == loaded.id
      assert 3 = length(loaded.guesses)
    end

    test "returns nil when a game not found" do
      assert nil == GameEngine.Impl.get(%Game{}, Ecto.ShortUUID.generate())
    end
  end

  describe "update_state/1 with game in progress" do
    setup do
      {:ok, game: insert(:game, state: GameState.Created)}
    end

    test "updates game state to finished", %{game: game = %Game{id: uuid}} do
      GameEngine.Impl.update_state(GameState.Finished, game)

      assert %Game{state: GameState.Finished} = GameEngine.Impl.get(%Game{}, uuid)
    end
  end

  describe "update_state/1 with game not in progress" do
    setup do
      {:ok, game: insert(:game, state: GameState.Aborted)}
    end

    test "fails to update game state with error", %{game: game} do
      {:error, error} = GameEngine.Impl.update_state(GameState.Running, game)

      assert %{reason: :action_in_state_error, game: ^game} = error
    end
  end
end
