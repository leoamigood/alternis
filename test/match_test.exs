defmodule Alternis.MatchTest do
  use Alternis.DataCase, async: true

  alias Alternis.Match

  test "creates full non exact match" do
    assert %Match{word: "dialog", secret: "secret"} = Match.new("dialog", "secret", [], [])
    assert %Match{bulls: [], cows: [], exact?: false} = Match.new("dialog", "secret", [], [])
  end

  test "creates partial non exact match" do
    assert %Match{word: "eleven", secret: "secret"} = Match.new("eleven", "secret", [5], [1])
    assert %Match{bulls: [5], cows: [1], exact?: false} = Match.new("eleven", "secret", [5], [1])
  end

  test "creates full exact match" do
    assert %Match{word: "secret", secret: "secret"} =
             Match.new("secret", "secret", [1, 2, 3, 4, 5, 6], [])

    assert %Match{bulls: [1, 2, 3, 4, 5, 6], cows: [], exact?: true} =
             Match.new("secret", "secret", [1, 2, 3, 4, 5, 6], [])
  end
end
