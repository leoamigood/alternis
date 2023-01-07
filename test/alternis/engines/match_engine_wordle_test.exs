defmodule Alternis.Engines.MatchEngine.WordleImplTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engines.MatchEngine

  describe "match/2" do
    test "raises exception when words length is not the same" do
      assert_raise RuntimeError, fn -> MatchEngine.WordleImpl.match("sun", "secret") end
      assert_raise RuntimeError, fn -> MatchEngine.WordleImpl.match("typewriter", "secret") end
    end

    test "no matching guess to secret word" do
      assert {[], []} = MatchEngine.WordleImpl.match("dialog", "secret")
    end

    test "multiple bulls matching only" do
      assert {[1, 2], []} = MatchEngine.WordleImpl.match("season", "secret")
    end

    test "multiple cows matching only" do
      assert {[], [1, 6]} = MatchEngine.WordleImpl.match("tumble", "secret")
      assert {[], [1, 4]} = MatchEngine.WordleImpl.match("ransom", "secret")
      assert {[], [1, 2, 3, 4, 6]} = MatchEngine.WordleImpl.match("creeps", "secret")
    end

    test "multiple bulls and multiple cows matching" do
      assert {[2, 5], [1, 6]} = MatchEngine.WordleImpl.match("temper", "secret")
      assert {[5], [1]} = MatchEngine.WordleImpl.match("eleven", "secret")
      assert {[5], [1, 3, 6]} = MatchEngine.WordleImpl.match("clever", "secret")
      assert {[1], [2, 3, 4, 5]} = MatchEngine.WordleImpl.match("steers", "secret")
    end

    test "precise guess to secret word matching" do
      assert {[1, 2, 3, 4, 5, 6], []} = MatchEngine.WordleImpl.match("secret", "secret")
    end
  end
end
