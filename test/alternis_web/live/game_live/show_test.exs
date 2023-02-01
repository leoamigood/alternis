defmodule AlternisWeb.GameLive.ShowTest do
  use AlternisWeb.ConnCase
  use Patch

  alias Alternis.Engines.GameEngine
  alias Alternis.Game.GameState.Created

  import Phoenix.LiveViewTest
  import Alternis.Factory

  setup do
    fake(GameEngine.Mock, GameEngine.Impl)
    {:ok, game: insert(:game, secret: "secret", state: Created)}
  end

  test "redirect not logged in user", %{conn: conn, game: game} do
    {:error, {:redirect, flash}} = live(conn, "/games/#{game.id}")
    assert %{flash: %{"error" => _}, to: "/users/log_in"} = flash
  end

  describe "with logged in user" do
    setup :register_and_log_in_user

    test "listing existing guesses", %{conn: conn, game: game} do
      insert(:guess, game: game, word: "master", bulls: [5], cows: [4, 6])

      {:ok, view, html} = live(conn, "/games/#{game.id}")

      assert html =~ "Game History"
      assert render(view) =~ ~r/master.*bulls: 1, cows: 2/
    end

    test "can return to games list", %{conn: conn, game: game} do
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
