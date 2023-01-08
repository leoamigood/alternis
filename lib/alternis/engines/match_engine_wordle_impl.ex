defmodule Alternis.Engines.MatchEngine.WordleImpl do
  @moduledoc """
    Implements Wordle logic for matching a guess to the secret word
  """

  @spec match(String.t(), String.t()) :: {:ok, {list, list}}
  def match(guess, secret) do
    {:ok, do_match(by_letter(guess), by_letter(secret))}
  end

  defp do_match(guess, secret) when is_list(guess) and is_list(secret) do
    bulls = bulls(guess, secret)
    cows = cows(guess |> exclude(bulls), secret |> exclude(bulls))

    {bulls, cows}
  end

  defp bulls(guess, secret) do
    guess |> Enum.zip_with(secret, fn g, s -> if g == s, do: g, else: nil end)
  end

  defp cows(guess, secret) do
    guess
    |> Enum.reduce([], fn g, acc ->
      if Enum.member?(secret -- acc, g), do: [g | acc], else: [nil | acc]
    end)
    |> Enum.reverse()
  end

  defp exclude(letters, extra) do
    letters |> Enum.zip_with(extra, fn l, m -> if l == m, do: nil, else: l end)
  end

  defp by_letter(word) do
    String.split(word, "", trim: true)
  end
end
