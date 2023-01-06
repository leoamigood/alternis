defmodule Alternis.Engines.GameEngine do
  @moduledoc "Logic for game life cycle"

  alias Alternis.Game

  @implementation Application.compile_env!(:alternis, :game_engine)
  def impl, do: @implementation

  @callback guess(Game.t(), String.t()) :: {:ok, {list, list}}
end
