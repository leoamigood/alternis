defmodule Alternis.Engines.MatchEngine do
  @moduledoc """
    Logic for matching a guess to the secret word
  """

  alias Alternis.Game

  @implementation Application.compile_env!(:alternis, :match_engine)
  def impl, do: @implementation

  @callback secret(Game.t()) :: {:ok, String.t()} | {:error, map}
  @callback match(String.t(), String.t()) :: {:ok, {list, list}} | {:error, map}
end
