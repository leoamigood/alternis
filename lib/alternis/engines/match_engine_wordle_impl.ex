defmodule Alternis.Engines.MatchEngine.WordleImpl do
  @moduledoc """
    Implements Wordle logic for matching a guess to the secret word
  """

  alias Alternis.Engines.MatchEngine

  @spec match(String.t(), String.t()) :: {:ok, MatchEngine.bulls_and_cows()} | {:error, map}
  def match(guess, secret) do
    case validate(guess, secret) do
      :ok -> {:ok, do_match(by_letter(guess), by_letter(secret))}
      {:error, errors} -> {:error, errors}
    end
  end

  defp validate(guess, secret) do
    case String.length(guess) == String.length(secret) do
      true -> :ok
      false -> {:error, %{length_match_error: guess}}
    end
  end

  defp do_match(guess, secret) when is_list(guess) and is_list(secret) do
    bulls = bulls(guess, secret)
    cows = cows(exclude(guess, bulls), exclude(secret, bulls))

    {bulls, cows}
  end

  defp bulls(guess, secret) do
    Enum.zip_with(guess, secret, fn g, s -> if g == s, do: g, else: nil end)
  end

  defp cows(guess, secret) do
    Enum.reduce(guess, [], fn letter, matched ->
      if Enum.member?(secret -- matched, letter), do: [letter | matched], else: [nil | matched]
    end)
    |> Enum.reverse()
  end

  defp exclude(letters, extra) do
    Enum.zip_with(letters, extra, fn l, e -> if l == e, do: nil, else: l end)
  end

  defp by_letter(word) do
    String.split(word, "", trim: true)
  end
end
