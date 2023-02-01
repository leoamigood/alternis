defmodule Alternis.ExpiredGamesWorkerTest do
  use Alternis.DataCase, async: true
  use Oban.Testing, repo: Alternis.Repo

  import Alternis.Factory
  import Hammox
  setup :verify_on_exit!

  alias Alternis.Game
  alias Alternis.Game.GameState.{Aborted, Created, Expired, Finished, Running}
  alias AlternisWeb.GameLive.Index

  test "returns total amount of expired games" do
    insert(:game, state: Created, expires_at: ago(60, :second))
    insert(:game, state: Running, expires_at: ago(1, :day))

    assert {:ok, 2} = perform_job(Alternis.ExpiredGamesWorker, %{})
  end

  test "updates games to expire status" do
    %Game{id: created} = insert(:game, state: Created, expires_at: ago(60, :second))
    %Game{id: running} = insert(:game, state: Running, expires_at: ago(1, :day))

    perform_job(Alternis.ExpiredGamesWorker, %{})

    assert %Game{state: Expired, expires_at: nil} = Repo.get!(Game, created)
    assert %Game{state: Expired, expires_at: nil} = Repo.get!(Game, running)
  end

  describe "with games list subscription" do
    setup do
      AlternisWeb.Endpoint.subscribe(Index.topic())
      on_exit(fn -> AlternisWeb.Endpoint.unsubscribe(Index.topic()) end)

      {:ok, %{topic: Index.topic()}}
    end

    test "succeeds to notify game players" do
      insert(:game, state: Created, expires_at: ago(60, :second))

      perform_job(Alternis.ExpiredGamesWorker, %{})

      assert_receive %{topic: "players"}
    end
  end

  describe "with particular games subscriptions" do
    setup do
      %Game{id: created} = insert(:game, state: Created, expires_at: ago(60, :second))
      %Game{id: running} = insert(:game, state: Running, expires_at: ago(1, :day))

      AlternisWeb.Endpoint.subscribe(created)
      AlternisWeb.Endpoint.subscribe(running)

      on_exit(fn ->
        AlternisWeb.Endpoint.unsubscribe(created)
        AlternisWeb.Endpoint.unsubscribe(running)
      end)

      {:ok, %{games: [created, running]}}
    end

    test "succeeds to notify game players", %{games: [created, running]} do
      perform_job(Alternis.ExpiredGamesWorker, %{})

      assert_receive %{topic: ^created, event: "game_ended"}
      assert_receive %{topic: ^running, event: "game_ended"}
    end
  end

  test "does not expire any fresh games" do
    insert(:game, state: Created, expires_at: ahead(60, :second))
    insert(:game, state: Running, expires_at: ahead(1, :day))

    assert {:ok, 0} = perform_job(Alternis.ExpiredGamesWorker, %{})
  end

  test "does not expire any finished or aborted games" do
    insert(:game, state: Finished, expires_at: ago(60, :second))
    insert(:game, state: Aborted, expires_at: ago(1, :day))

    assert {:ok, 0} = perform_job(Alternis.ExpiredGamesWorker, %{})
  end

  defp ahead(amount, unit) do
    DateTime.utc_now() |> DateTime.add(amount, unit)
  end

  defp ago(amount, unit) do
    DateTime.utc_now() |> DateTime.add(-amount, unit)
  end
end
