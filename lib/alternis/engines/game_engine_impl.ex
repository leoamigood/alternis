defmodule Alternis.Engines.GameEngine.Impl do
  @moduledoc """
    Implements logic for game actions and life cycle
  """

  import Ecto.Query

  alias Alternis.Accounts.User
  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.{GameState, GameState.Created, GameState.Running}
  alias Alternis.GameSettings
  alias Alternis.Guess
  alias Alternis.Repo
  alias Alternis.Word

  @spec create(User.t(), GameSettings.t()) :: {:ok, Game.id()} | {:error, map}
  def create(user, settings = %GameSettings{secret: nil}) do
    case DictionaryEngine.impl().find_word(settings.language) do
      nil -> {:error, %{reason: :word_not_found, settings: settings}}
      %Word{lemma: word} -> create(user, %{settings | secret: word})
    end
  end

  def create(user, settings = %GameSettings{}) do
    %Game{id: id} =
      settings
      |> Game.configure()
      |> Game.changeset()
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Repo.insert!()

    {:ok, id}
  end

  @spec guess(User.t(), Game.id(), String.t()) :: {:ok, Guess.t()} | {:error, map}
  def guess(user, game_id, word) do
    case get(game_id) do
      nil ->
        not_found_error(Game, game_id)

      game ->
        case game.in_progress? do
          true -> do_guess(user, game, word |> String.downcase())
          false -> {:error, %{reason: :unpermitted_action, action: :guess, game: game}}
        end
    end
  end

  defp do_guess(user, game, word) do
    with match <- MatchEngine.impl().match(word, game.secret) do
      Repo.transaction(fn ->
        case match.exact? do
          true -> Game.update_state(game, GameState.Finished)
          false -> Game.update_state(game, GameState.Running)
        end

        game
        |> Ecto.build_assoc(:guesses)
        |> Guess.changeset(Map.from_struct(match))
        |> Ecto.Changeset.put_assoc(:user, user)
        |> Repo.insert!()
      end)
    end
  end

  @spec get(Game.id()) :: Game.t() | nil
  def get(game_id) do
    Repo.one(
      from g in Game,
        where: g.id == ^game_id,
        select_merge: %{in_progress?: g.state in [^Created, ^Running]}
    )
  end

  @spec abort(Game.id()) :: :ok | {:error, map}
  def abort(game_id) do
    case get(game_id) do
      nil ->
        not_found_error(Game, game_id)

      game ->
        case game.in_progress? do
          true -> Game.update_state(game, GameState.Aborted) |> elem(0)
          false -> {:error, %{reason: :unpermitted_action, action: :abort, game: game}}
        end
    end
  end

  defp not_found_error(schema, game_id) do
    {:error, %{reason: :not_found, schema: schema, id: game_id}}
  end

  @spec games(list(GameState.t())) :: list(Game.t())
  def games(states) do
    Repo.all(from g in Game, where: g.state in ^states, order_by: :inserted_at)
  end
end
