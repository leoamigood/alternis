defmodule Alternis.Match do
  @moduledoc false

  defstruct [:word, :secret, :bulls, :cows, :exact?]

  @type t :: %__MODULE__{}

  def new(word, secret, bulls, cows) do
    %__MODULE__{
      word: word,
      secret: secret,
      bulls: bulls,
      cows: cows,
      exact?: length(bulls) == String.length(secret)
    }
  end
end
