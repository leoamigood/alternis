defmodule Alternis.Engines.MatchEngine do
  @moduledoc """
    Logic for matching a guess to the secret word
  """

  alias Alternis.Game.GameLanguage

  @implementation Application.compile_env!(:alternis, :match_engine)
  def impl, do: @implementation

  @callback secret(GameLanguage.t()) :: String.t() | nil
  @callback match(String.t(), String.t()) :: {list, list, boolean}
end
