defmodule AlternisWeb.GameLive.IndexTest do
  use AlternisWeb.ConnCase
  use Patch

  alias Alternis.Engines.{DictionaryEngine, GameEngine}
  alias Alternis.Game.GameLanguage.English
  alias Alternis.Game.GameState.Created
  alias Alternis.Word

  import Phoenix.LiveViewTest
  import Alternis.Factory

  import Hammox
  setup :verify_on_exit!

  describe "with logged out user" do
    test "redirects to login form", %{conn: conn} do
      {:error, {:redirect, flash}} = live(conn, "/games/new")
      assert %{flash: %{"error" => _}, to: "/users/log_in"} = flash
    end
  end

  describe "with no running game" do
    setup do
      Mock.allow_to_call_impl(GameEngine, :games, 1, Impl, 2)
      :ok
    end

    test "user should not see any games", %{conn: conn} do
      {:ok, view, html} = live(conn, "/games")

      assert html =~ "Running Games"
      refute render(view) =~ "Play"
    end
  end

  describe "with some running game" do
    setup do
      insert_list(3, :game, secret: "secret", state: Created)
      Mock.allow_to_call_impl(GameEngine, :games, 1, Impl, 2)

      :ok
    end

    test "user can see games list on landing page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/games")

      assert html =~ "Running Games"
      assert render(view) =~ ~r/English.*Play/
    end
  end

  describe "with logged in user" do
    setup :register_and_log_in_user

    setup do
      Mock.allow_to_call_impl(GameEngine, :games, 1, Impl, 2)
      :ok
    end

    test "shows secret word form", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/games/new")

      assert html =~ "Enter Secret Word"
    end
  end

  describe "with mocked secret word" do
    setup :register_and_log_in_user

    setup do
      Mock.allow_to_call_impl(GameEngine, :games, 1, Impl, 2)
      Mock.allow_to_call_impl(GameEngine, :create, 2, Impl)
      Mock.allow_to_call_impl(GameEngine, :get, 1, Impl, 2)

      expect(DictionaryEngine.Mock, :find_word, 2, fn _word, _language ->
        %Word{lemma: "secret", language: English}
      end)

      :ok
    end

    test "creates new game", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/games/new")

      view
      |> form("#game-form",
        game_settings: %{
          secret: "secret",
          language: English.value()
        }
      )
      |> render_submit()
      |> follow_redirect(conn)

      assert_redirect(view)
    end
  end
end
