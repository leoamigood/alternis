defmodule Alternis.Engines.GameEngine.Impl do
  @moduledoc """
    Implements logic for game actions and life cycle
  """

  import Ecto.Query

  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.{GameState, GameState.Created, GameState.Running}
  alias Alternis.GameSettings
  alias Alternis.Guess
  alias Alternis.Repo

  @spec create(GameSettings.t()) :: {:ok, Game.id()} | {:error, map}
  def create(settings = %GameSettings{secret: nil}) do
    case DictionaryEngine.impl().secret(settings.language) do
      nil -> {:error, %{reason: :secret_not_found, settings: settings}}
      secret -> create(%{settings | secret: secret})
    end
  end

  def create(settings = %GameSettings{}) do
    %Game{id: id} =
      settings
      |> Game.configure()
      |> Game.changeset()
      |> Repo.insert!()

    {:ok, id}
  end

  @spec guess(Game.id(), String.t()) :: {:ok, Guess.t()} | {:error, map}
  def guess(game_id, word) do
    case get(game_id) do
      nil ->
        not_found_error(Game, game_id)

      game ->
        case Game.validate_state(game) do
          :ok -> do_guess(game, word |> String.downcase())
          {:error, errors} -> {:error, errors}
        end
    end
  end

  defp do_guess(game, word) do
    with match <- MatchEngine.impl().match(word, game.secret) do
      Repo.transaction(fn ->
        case match.exact? do
          true -> Game.update_state(game, GameState.Finished)
          false -> Game.update_state(game, GameState.Running)
        end

        game
        |> Ecto.build_assoc(:guesses)
        |> Guess.changeset(Map.from_struct(match))
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
        case Game.validate_state(game) do
          :ok -> Game.update_state(game, GameState.Aborted) |> elem(0)
          {:error, errors} -> {:error, errors}
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
