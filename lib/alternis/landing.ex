defmodule Alternis.Landing do
  @moduledoc """
  The Landing context.
  """

  import Ecto.Query, warn: false
  alias Alternis.Repo

  alias Alternis.Engines.GameEngine
  alias Alternis.Game
  alias Alternis.GameSettings
  alias Alternis.Guess

  def list_games do
    Repo.all(Game)
  end

  def get_game!(id), do: GameEngine.impl().get(id)

  def create_game(game_params) do
    %GameSettings{}
    |> GameSettings.changeset(game_params)
    |> Ecto.Changeset.apply_changes()
    |> GameEngine.impl().create()
  end

  def guess(game, guess_params) do
    GameEngine.impl().guess(game.id, Map.get(guess_params, "guess"))
    {:ok, %Guess{}}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end
end
