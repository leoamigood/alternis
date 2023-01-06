defmodule Alternis.Engines.MatchEngine do
  @moduledoc """
    Logic for matching a guess to the secret word
  """

  alias Alternis.Game

  @implementation Application.compile_env!(:alternis, :match_engine)
  def impl, do: @implementation

  @type bulls_and_cows :: {list, list}
  @callback secret(Game.t()) :: {:ok, String.t()} | {:error, map}
  @callback match(String.t(), String.t()) :: {:ok, bulls_and_cows} | {:error, map}
end
