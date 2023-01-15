defmodule Alternis.Engines.MatchEngine do
  @moduledoc """
    Logic for matching a guess to the secret word
  """

  alias Alternis.GameSettings
  alias Alternis.Guess

  @implementation Application.compile_env!(:alternis, :match_engine)
  def impl, do: @implementation

  @callback secret(GameSettings.t()) :: String.t()
  @callback match(String.t(), String.t()) :: {list, list}
  @callback exact?(Guess.t()) :: boolean
end
