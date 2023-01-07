defmodule Alternis.Engines.GameEngine.Impl do
  @moduledoc """
    Implements logic for game life cycle
  """

  alias Alternis.Engines.MatchEngine
  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.Guess
  alias Alternis.Repo

  @spec create(Game.t()) :: Game.t()
  def create(game = %Game{secret: nil}) do
    game |> inject_secret() |> create
  end

  def create(game) do
    Game.changeset(game) |> Repo.insert()
  end

  defp inject_secret(game) do
    %{game | secret: MatchEngine.impl().secret(game)}
  end

  @spec guess(Game.t(), String.t()) :: {:ok, Guess.t()} | {:error, map}
  def guess(game, word) do
    case validate(game) do
      :ok ->
        match(game, word)
        |> build_guess
        |> associate(game)
        |> persist

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp validate(game) do
    case in_progress(game) do
      true -> :ok
      false -> {:error, %{reason: :action_in_state_error, action: :guess, state: game.state}}
    end
  end

  defp in_progress(game) do
    Enum.member?([GameState.Created, GameState.Running], game.state)
  end

  defp build_guess({word, {bulls, cows}}) do
    %Guess{word: word, bulls: bulls, cows: cows}
  end

  defp associate(guess, game) do
    %Guess{guess | game: game}
  end

  defp persist(guess) do
    Guess.changeset(guess) |> Repo.insert()
  end

  defp match(game, guess) do
    {guess, MatchEngine.impl().match(guess, game.secret)}
  end

  @spec get(Game.t(), Ecto.ShortUUID) :: Game.t() | nil
  def get(%Game{}, id) do
    Repo.get(Game, id)
  end
end
