defmodule Alternis.Engines.GameEngine.Impl do
  @moduledoc """
    Implements logic for game life cycle
  """

  alias Alternis.Engines.GameEngine
  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.Repo

  @spec create(Game.t()) :: {:ok, GameEngine.uuid()} | {:error, map}
  def create(game = %Game{secret: nil}) do
    case inject_secret(game) do
      {:ok, game} -> create(game)
      {:error, errors} -> {:error, errors}
    end
  end

  def create(game) do
    game
    |> Game.changeset()
    |> Repo.insert!()

    {:ok, game.id}
  end

  defp inject_secret(game) do
    case MatchEngine.impl().secret(game) do
      {:ok, secret} -> {:ok, %{game | secret: secret}}
      {:error, errors} -> {:error, errors}
    end
  end

  @spec guess(Game.t(), String.t()) :: :ok | {:error, map}
  def guess(game, word) do
    case validate_action(game) do
      :ok -> match(game, word)
      {:error, errors} -> {:error, errors}
    end
  end

  defp validate_action(game) do
    case game.state do
      state when state in [GameState.Finished, GameState.Aborted] ->
        {:error, %{reason: :not_allowed, action: :guess, state: state}}

      _ ->
        :ok
    end
  end

  defp match(game, guess) do
    case MatchEngine.impl().match(guess, game.secret) do
      {:ok, _} -> :ok
      {:error, errors} -> {:error, errors}
    end
  end

  @spec get(GameEngine.uuid()) :: {:ok, Game.t()} | {:error, map}
  def get(uuid) do
    Repo.get(Game, uuid)
  end
end
