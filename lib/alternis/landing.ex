defmodule Alternis.Landing do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Engines.GameEngine
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

  def guess(game, %{"word" => word}) do
    GameEngine.impl().guess(game.id, word)
  end

  def create_game(game_settings = %{"secret" => ""}) do
    %GameSettings{}
    |> GameSettings.changeset(game_settings)
    |> Ecto.Changeset.apply_changes()
    |> with_expiration()
    |> GameEngine.impl().create()
  end

  def create_game(game_params) do
    case validate_settings(game_params) do
      changeset = %Ecto.Changeset{valid?: true} ->
        changeset
        |> Ecto.Changeset.apply_changes()
        |> with_expiration()
        |> with_language()
        |> GameEngine.impl().create()

      changeset ->
        {:error, changeset}
    end
  end

  defp validate_settings(game_params) do
    %GameSettings{}
    |> GameSettings.changeset(game_params)
    |> GameSettings.validate_in_dictionary(:secret)
  end

  defp with_expiration(settings = %GameSettings{}) do
    %{settings | expires_at: datetime_in(1, :hour)}
  end

  defp with_language(settings = %GameSettings{secret: secret, language: language}) do
    %{settings | language: language_of(secret, language)}
  end

  defp language_of(secret, language) do
    case DictionaryEngine.impl().find_word(secret, language) do
      nil -> nil
      word -> word.language
    end
  end

  defp datetime_in(period, unit) do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.add(period, unit)
  end
end
