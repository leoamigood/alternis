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
    GameEngine.impl().get(id)
    |> Repo.preload(guesses: from(g in Guess, order_by: g.inserted_at, preload: :user))
  end

  def guess(user, game, word) do
    GameEngine.impl().guess(user, game.id, word)
  end

  def create_game(user, settings = %{"secret" => ""}) do
    %GameSettings{}
    |> GameSettings.changeset(settings)
    |> Ecto.Changeset.apply_changes()
    |> with_expiration()
    |> then(fn settings ->
      GameEngine.impl().create(user, settings)
    end)
  end

  def create_game(user, settings) do
    case validate_settings(settings) do
      changeset = %Ecto.Changeset{valid?: true} ->
        changeset
        |> Ecto.Changeset.apply_changes()
        |> with_expiration()
        |> with_language()
        |> then(fn settings ->
          GameEngine.impl().create(user, settings)
        end)

      changeset ->
        {:error, changeset}
    end
  end

  defp validate_settings(settings) do
    %GameSettings{}
    |> GameSettings.changeset(settings)
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
