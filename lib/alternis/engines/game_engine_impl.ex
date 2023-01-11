defmodule Alternis.Engines.GameEngine.Impl do
  @moduledoc """
    Implements logic for game actions
  """

  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.GameSettings
  alias Alternis.Guess
  alias Alternis.Repo

  @spec create(GameSettings.t()) :: Game.t()
  def create(settings = %GameSettings{secret: nil}) do
    settings |> inject_secret() |> create
  end

  def create(settings = %GameSettings{}) do
    settings
    |> Game.setup()
    |> Game.changeset()
    |> Repo.insert()
  end

  defp inject_secret(settings = %GameSettings{}) do
    %{settings | secret: MatchEngine.impl().secret(settings)}
  end

  @spec guess(Game.t(), String.t()) :: {:ok, Guess.t()} | {:error, map}
  def guess(game, word) do
    case validate(game) do
      :ok ->
        match(game, word)
        |> build_guess
        |> associate(game)
        |> Repo.insert()

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp validate(game) do
    case in_progress?(game) do
      true -> :ok
      false -> {:error, %{reason: :action_in_state_error, game: game}}
    end
  end

  defp in_progress?(game) do
    Enum.member?([GameState.Created, GameState.Running], game.state)
  end

  defp match(game, guess) do
    {guess, MatchEngine.impl().match(guess, game.secret)}
  end

  defp build_guess({word, {bulls, cows}}) do
    %Guess{word: word, bulls: bulls, cows: cows}
  end

  defp associate(guess, game) do
    %Guess{guess | game: game}
  end

  @spec get(Game.t(), Ecto.ShortUUID) :: Game.t() | nil
  def get(%Game{}, id) do
    Repo.get(Game, id) |> Repo.preload(:guesses)
  end

  @spec update_state(GameState.t(), Game.t()) :: {:ok, Game.t()} | {:error, map}
  def update_state(state, game) do
    case validate(game) do
      :ok ->
        game
        |> Game.changeset(%{state: state})
        |> Repo.update()

      {:error, errors} ->
        {:error, errors}
    end
  end
end
