defmodule Alternis.Engines.GameEngine do
  @moduledoc "Logic for game life cycle"

  alias Alternis.Game

  @implementation Application.compile_env!(:alternis, :game_engine)
  def impl, do: @implementation

  @type uuid :: Ecto.ShortUUID.uuid()
  @callback create(Game.t()) :: {:ok, uuid} | {:error, map}
  @callback guess(Game.t(), String.t()) :: :ok | {:error, map}
end
