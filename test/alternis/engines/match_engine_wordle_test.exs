defmodule Alternis.Engines.MatchEngine.WordleImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.MatchEngine

  describe "match/2" do
    test "provides errors on match guess with different word length" do
      assert {:error, %{length_match_error: "sun"}} =
               MatchEngine.WordleImpl.match("sun", "secret")

      assert {:error, %{length_match_error: "typewriter"}} =
               MatchEngine.WordleImpl.match("typewriter", "secret")
    end

    test "no matching guess to secret word" do
      assert {:ok, {[nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil]}} =
               MatchEngine.WordleImpl.match("dialog", "secret")
    end

    test "multiple bulls matching only" do
      assert {:ok, {["s", "e", nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil]}} =
               MatchEngine.WordleImpl.match("season", "secret")
    end

    test "multiple cows matching only" do
      assert {:ok, {[nil, nil, nil, nil, nil, nil], ["t", nil, nil, nil, nil, "e"]}} =
               MatchEngine.WordleImpl.match("tumble", "secret")

      assert {:ok, {[nil, nil, nil, nil, nil, nil], ["r", nil, nil, "s", nil, nil]}} =
               MatchEngine.WordleImpl.match("ransom", "secret")

      assert {:ok, {[nil, nil, nil, nil, nil, nil], ["c", "r", "e", "e", nil, "s"]}} =
               MatchEngine.WordleImpl.match("creeps", "secret")
    end

    test "multiple bulls and multiple cows matching" do
      assert {:ok, {[nil, "e", nil, nil, "e", nil], ["t", nil, nil, nil, nil, "r"]}} =
               MatchEngine.WordleImpl.match("temper", "secret")

      assert {:ok, {[nil, nil, nil, nil, "e", nil], ["e", nil, nil, nil, nil, nil]}} =
               MatchEngine.WordleImpl.match("eleven", "secret")

      assert {:ok, {[nil, nil, nil, nil, "e", nil], ["c", nil, "e", nil, nil, "r"]}} =
               MatchEngine.WordleImpl.match("clever", "secret")

      assert {:ok, {["s", nil, nil, nil, nil, nil], [nil, "t", "e", "e", "r", nil]}} =
               MatchEngine.WordleImpl.match("steers", "secret")
    end

    test "precise guess to secret word matching" do
      assert {:ok, {["s", "e", "c", "r", "e", "t"], [nil, nil, nil, nil, nil, nil]}} =
               MatchEngine.WordleImpl.match("secret", "secret")
    end
  end
end
