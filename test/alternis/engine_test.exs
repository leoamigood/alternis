defmodule Alternis.EngineTest do
  use Alternis.DataCase, async: true

  alias Alternis.Engine

  describe "match engine" do
    test "no matching guess to secret word" do
      assert {:ok, {[nil, nil, nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil]}} =
               Engine.match("dialog", "secret")
    end

    test "multiple bulls matching only" do
      assert {:ok, {["s", "e", nil, nil, nil, nil], [nil, nil, nil, nil, nil, nil]}} =
               Engine.match("season", "secret")
    end

    test "multiple cows matching only" do
      assert {:ok, {[nil, nil, nil, nil, nil, nil], ["t", nil, nil, nil, nil, "e"]}} =
               Engine.match("tumble", "secret")

      assert {:ok, {[nil, nil, nil, nil, nil, nil], ["r", nil, nil, "s", nil, nil]}} =
               Engine.match("ransom", "secret")

      assert {:ok, {[nil, nil, nil, nil, nil, nil], ["c", "r", "e", "e", nil, "s"]}} =
               Engine.match("creeps", "secret")
    end

    test "multiple bulls and multiple cows matching" do
      assert {:ok, {[nil, "e", nil, nil, "e", nil], ["t", nil, nil, nil, nil, "r"]}} =
               Engine.match("temper", "secret")

      assert {:ok, {[nil, nil, nil, nil, "e", nil], ["e", nil, nil, nil, nil, nil]}} =
               Engine.match("eleven", "secret")

      assert {:ok, {[nil, nil, nil, nil, "e", nil], ["c", nil, "e", nil, nil, "r"]}} =
               Engine.match("clever", "secret")

      assert {:ok, {["s", nil, nil, nil, nil, nil], [nil, "t", "e", "e", "r", nil]}} =
               Engine.match("steers", "secret")
    end

    test "precise guess to secret word matching" do
      assert {:ok, {["s", "e", "c", "r", "e", "t"], [nil, nil, nil, nil, nil, nil]}} =
               Engine.match("secret", "secret")
    end
  end
end
