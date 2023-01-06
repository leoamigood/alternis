defmodule Alternis.Engines.GameEngine.Impl do
  @moduledoc """
    Implements logic for game life cycle
  """

  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Repo

  @spec create(Game.t()) :: {:ok, Game.t()} | {:error, map}
  def create(game = %Game{secret: nil}) do
    case inject_secret(game) do
      {:ok, game} -> create(game)
      {:error, errors} -> {:error, errors}
    end
  end

  def create(game) do
    game
    |> Game.changeset()
    |> Repo.insert()
  end

  @spec guess(Game.t(), String.t()) :: {:ok, {list, list}} | {:error, map}
  def guess(game, word) do
    MatchEngine.impl().match(word, game.secret)
  end

  defp inject_secret(game) do
    case MatchEngine.impl().secret(game) do
      {:ok, secret} -> {:ok, %{game | secret: secret}}
      {:error, errors} -> {:error, errors}
    end
  end
end
