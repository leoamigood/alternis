defmodule Alternis.Engines.GameEngine do
  @moduledoc "Logic for game actions"

  alias Alternis.Game
  alias Alternis.Game.GameState
  alias Alternis.GameSettings
  alias Alternis.Guess

  @implementation Application.compile_env!(:alternis, :game_engine)
  def impl, do: @implementation

  @callback create(GameSettings.t()) :: {:ok, Game.t()} | {:error, map}
  @callback guess(Game.t(), String.t()) :: {:ok, Guess.t()} | {:error, map}
  @callback get(Game.t(), Ecto.ShortUUID) :: Game.t() | nil
  @callback update_state(GameState.t(), Game.t()) :: {:ok, Game.t()} | {:error, map}
end
