defmodule Alternis.Engines.GameEngine.Impl do
  @moduledoc """
    Implements logic for game life cycle
  """

  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Repo

  @spec create(Game.t()) :: {:ok, Game.t()} | {:error, map}
  def create(game = %Game{secret: nil}) do
    game
    |> add_secret()
    |> Game.changeset()
    |> Repo.insert()
  end

  @spec guess(Game.t(), String.t()) :: {:ok, {list, list}} | {:error, map}
  def guess(game, word) do
    MatchEngine.impl().match(word, game.secret)
  end

  defp add_secret(game) do
    case MatchEngine.impl().secret(game) do
      {:ok, secret} -> %{game | secret: secret}
    end
  end
end
