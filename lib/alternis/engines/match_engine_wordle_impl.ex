defmodule Alternis.Engines.MatchEngine.WordleImpl do
  @moduledoc """
    Implements Wordle logic for matching a guess to the secret word
  """

  alias Alternis.Match

  @spec match(String.t(), String.t()) :: Match.t() | {:error, map}
  def match(word, secret) do
    case validate(word, secret) do
      :ok ->
        {bulls, cows} = do_match(word |> by_letter, secret |> by_letter)
        Match.new(word, secret, bulls, cows)

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp validate(word, secret) do
    case String.length(word) == String.length(secret) do
      true -> :ok
      false -> {:error, %{reason: :length_mismatch, word: word, secret: secret}}
    end
  end

  defp do_match(word, secret) when is_list(word) and is_list(secret) do
    bulls = bulls(word, secret)
    cows = cows(word |> exclude(bulls), secret |> exclude(bulls))

    {bulls |> to_positions, cows |> to_positions}
  end

  defp bulls(word, secret) do
    Enum.zip_with(word, secret, fn g, s -> if g == s, do: g, else: nil end)
  end

  defp cows(word, secret) do
    Enum.reduce(word, [], fn letter, matched ->
      if Enum.member?(secret -- matched, letter), do: [letter | matched], else: [nil | matched]
    end)
    |> Enum.reverse()
  end

  defp to_positions(list) do
    list
    |> Stream.with_index(1)
    |> Stream.reject(&match?({nil, _index}, &1))
    |> Stream.map(fn {_value, index} -> index end)
    |> Enum.to_list()
  end

  defp exclude(letters, extra) do
    Enum.zip_with(letters, extra, fn l, e -> if l == e, do: nil, else: l end)
  end

  defp by_letter(word) do
    String.split(word, "", trim: true)
  end
end
