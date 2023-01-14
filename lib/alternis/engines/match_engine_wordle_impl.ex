defmodule Alternis.Engines.MatchEngine.WordleImpl do
  @moduledoc """
    Implements Wordle logic for matching a guess to the secret word
  """

  alias Alternis.Guess

  @spec match(String.t(), String.t()) :: {list, list}
  def match(guess, secret) do
    validate!(guess, secret)
    do_match(by_letter(guess), by_letter(secret))
  end

  defp validate!(guess, secret) do
    case String.length(guess) == String.length(secret) do
      true ->
        :ok

      false ->
        raise RuntimeError,
              "unable to match guess '#{guess}' to secret word '#{secret}' - length mismatch"
    end
  end

  defp do_match(guess, secret) when is_list(guess) and is_list(secret) do
    bulls = bulls(guess, secret)
    cows = cows(guess |> exclude(bulls), secret |> exclude(bulls))

    {bulls |> to_positions, cows |> to_positions}
  end

  defp bulls(guess, secret) do
    Enum.zip_with(guess, secret, fn g, s -> if g == s, do: g, else: nil end)
  end

  # tail recursion, for example: [nil, "a", nil, nil, "b"] into [2, 5]
  defp to_positions(list, index \\ 1)
  defp to_positions([nil | tail], index), do: to_positions(tail, index + 1)
  defp to_positions([_ | tail], index), do: [index | to_positions(tail, index + 1)]
  defp to_positions([], _), do: []

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

  @spec exact?(Guess.t()) :: boolean
  def exact?(guess = %Guess{}) do
    String.length(guess.word) == length(guess.bulls)
  end
end
