defmodule Alternis.Engines.MatchEngine.WordleImpl do
  @moduledoc """
    Implements Wordle logic for matching a guess to the secret word
  """

  alias Alternis.Dictionary
  alias Alternis.GameSettings
  alias Alternis.Guess
  alias Alternis.Repo
  alias Alternis.Word

  @spec secret(GameSettings.t()) :: String.t() | nil
  def secret(settings) do
    import Ecto.Query

    Repo.one(
      from w in Word,
        join: d in Dictionary,
        where:
          d.language == ^settings.language and
            fragment("LENGTH(lemma) > ?", 4) and fragment("LENGTH(lemma) < ?", 9),
        select: w.lemma,
        order_by: fragment("RANDOM()"),
        limit: 1
    )
  end

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

  defp to_positions(list) do
    list
    |> Stream.with_index(1)
    |> Stream.reject(&match?({nil, _index}, &1))
    |> Stream.map(fn {_value, index} -> index end)
    |> Enum.to_list()
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

  @spec exact?(Guess.t()) :: boolean
  def exact?(guess = %Guess{}) do
    String.length(guess.word) == length(guess.bulls)
  end
end
