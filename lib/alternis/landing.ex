defmodule Alternis.Landing do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Alternis.Engines.GameEngine
  alias Alternis.Game
  alias Alternis.Game.GameState.Created
  alias Alternis.Game.GameState.Running
  alias Alternis.GameSettings
  alias Alternis.Guess
  alias Alternis.Repo

  def list_games do
    GameEngine.impl().games([Created, Running])
  end

  def get_game!(id) do
    GameEngine.impl().get(id) |> Repo.preload(guesses: from(g in Guess, order_by: g.inserted_at))
  end

  def create_game(game_params) do
    %GameSettings{expires_at: datetime_in(1, :hour)}
    |> GameSettings.changeset(game_params)
    |> Ecto.Changeset.apply_changes()
    |> GameEngine.impl().create()
  end

  defp datetime_in(period, unit) do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.add(period, unit)
  end

  def guess(game, guess_params) do
    GameEngine.impl().guess(game.id, Map.get(guess_params, "word"))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(game = %Game{}, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end
end
