defmodule Alternis.Engines.GameEngine do
  @moduledoc "Behaviour for game actions and life cycle"

  alias Alternis.Accounts.User
  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.GameSettings
  alias Alternis.Guess

  @implementation Application.compile_env!(:alternis, :game_engine)
  def impl, do: @implementation

  @callback create(User.t(), GameSettings.t()) :: {:ok, Game.id()} | {:error, map}
  @callback guess(User.t(), Game.id(), word :: String.t()) :: {:ok, Guess.t()} | {:error, map}
  @callback get(Game.id()) :: Game.t() | nil
  @callback abort(Game.id()) :: :ok | {:error, map}
  @callback games(list(GameState.t())) :: list(Game.t())
end
