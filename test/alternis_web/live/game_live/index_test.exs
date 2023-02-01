defmodule AlternisWeb.GameLive.IndexTest do
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

  test "user can see games list on landing page", %{conn: conn} do
    {:ok, view, html} = live(conn, "/games")

    assert html =~ "Running Games"
    assert render(view) =~ ~r/English.*Play/
  end
end
