defmodule Alternis.Engines.MatchEngine do
  @moduledoc """
    Logic for matching a guess to the secret word
  """

  alias Alternis.Match

  @implementation Application.compile_env!(:alternis, :match_engine)
  def impl, do: @implementation

  @callback match(String.t(), String.t()) :: Match.t() | {:error, map}
end
