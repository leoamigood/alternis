defmodule Alternis.Engines.GameEngine do
  @moduledoc "Logic for game life cycle"

  alias Alternis.Game
  alias Alternis.Guess

  @implementation Application.compile_env!(:alternis, :game_engine)
  def impl, do: @implementation

  @callback create(Game.t()) :: {:ok, Game.t()} | {:error, map}
  @callback guess(Game.t(), String.t()) :: {:ok, Guess.t()} | {:error, map}
  @callback get(Game.t(), Ecto.ShortUUID) :: Game.t() | nil
end
