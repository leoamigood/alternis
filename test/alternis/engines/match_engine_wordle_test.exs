defmodule Alternis.Engines.MatchEngine.WordleImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.MatchEngine.WordleImpl
  alias Alternis.Match

  describe "match/2" do
    test "returns errors when guess and secret lengths do not match" do
      assert {:error, %{reason: :length_mismatch}} = WordleImpl.match("sun", "secret")
      assert {:error, %{reason: :length_mismatch}} = WordleImpl.match("typewriter", "secret")
    end

    test "no matching guess to secret word" do
      assert %{bulls: [], cows: [], exact?: false} = WordleImpl.match("dialog", "secret")
    end

    test "multiple bulls matching only" do
      assert %{bulls: [1, 2], cows: [], exact?: false} = WordleImpl.match("season", "secret")
    end

    test "multiple cows matching only" do
      assert %Match{bulls: [], cows: [1, 6]} = WordleImpl.match("tumble", "secret")
      assert %Match{bulls: [], cows: [1, 4]} = WordleImpl.match("ransom", "secret")
      assert %Match{bulls: [], cows: [1, 2, 3, 4, 6]} = WordleImpl.match("creeps", "secret")
    end

    test "multiple bulls and multiple cows matching" do
      assert %Match{bulls: [2, 5], cows: [1, 6]} = WordleImpl.match("temper", "secret")
      assert %Match{bulls: [5], cows: [1]} = WordleImpl.match("eleven", "secret")
      assert %Match{bulls: [5], cows: [1, 3, 6]} = WordleImpl.match("clever", "secret")
      assert %Match{bulls: [1], cows: [2, 3, 4, 5]} = WordleImpl.match("steers", "secret")
    end

    test "precise guess to secret word matching" do
      assert %Match{bulls: [1, 2, 3, 4, 5, 6], cows: []} = WordleImpl.match("secret", "secret")
    end
  end
end
