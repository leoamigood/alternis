defmodule AlternisWeb.GameLive.ShowTest do
  use AlternisWeb.ConnCase

  alias Alternis.Engines.{GameEngine, MatchEngine}
  alias Alternis.Game.GameState.Created

  import Phoenix.LiveViewTest
  import Alternis.Factory

  setup do
    {:ok, game: insert(:game, secret: "secret", state: Created)}
  end

  describe "with logged out user" do
    test "redirect not logged in user", %{conn: conn, game: game} do
      {:error, {:redirect, flash}} = live(conn, "/games/#{game.id}")
      assert %{flash: %{"error" => _}, to: "/users/log_in"} = flash
    end
  end

  describe "with logged in user" do
    setup :register_and_log_in_user

    setup do
      Mock.allow_to_call_impl(GameEngine, :games, 1, Impl, 2)
      Mock.allow_to_call_impl(GameEngine, :get, 1, Impl, 2)
      Mock.allow_to_call_impl(GameEngine, :guess, 3, Impl)
      Mock.allow_to_call_impl(MatchEngine, :match, 2, WordleImpl)

      :ok
    end

    test "listing existing guesses", %{conn: conn, game: game} do
      insert(:guess, game: game, word: "master", bulls: [5], cows: [4, 6])

      {:ok, view, html} = live(conn, "/games/#{game.id}")

      assert html =~ "Game History"
      assert render(view) =~ ~r/master.*bulls: 1, cows: 2/
    end

    test "places a guess", %{conn: conn, game: game} do
      {:ok, view, _html} = live(conn, "/games/#{game.id}")

      # shows modal popup
      assert view |> render_patch("/games/#{game.id}/guess") =~ "Your guess"
      assert_patched(view, "/games/#{game.id}/guess")

      # submits a guess word
      assert view
             |> form("#guess-form")
             |> render_submit(guess: %{word: "poster"})

      assert_patch(view, "/games/#{game.id}")

      # validates submitted guess placed
      assert render(view) =~ "poster"
    end

    test "back link takes to the games list", %{conn: conn, game: game} do
      {:ok, view, _} = live(conn, "/games/#{game.id}")

      {:ok, _, html} =
        view
        |> back_link()
        |> render_click()
        |> follow_redirect(conn, ~p"/games")

      assert html =~ "Running Games"
    end

    defp back_link(view) do
      element(view, "#Back")
    end
  end
end
