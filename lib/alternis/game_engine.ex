defmodule Alternis.Engines.GameEngine do
  @moduledoc "Behaviour for game actions and life cycle"

  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.GameSettings
  alias Alternis.Guess

  @implementation Application.compile_env!(:alternis, :game_engine)
  def impl, do: @implementation

  @callback create(GameSettings.t()) :: {:ok, Game.id()}
  @callback guess(Game.id(), String.t()) :: {:ok, Guess.id()} | {:error, map}
  @callback get(Game.id()) :: Game.t() | nil
  @callback abort(Game.id()) :: :ok | {:error, map}
  @callback games(list(GameState.t())) :: list(Game.t())
end
