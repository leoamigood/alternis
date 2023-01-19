defmodule Alternis.ExpiredGamesWorkerTest do
  use Alternis.DataCase, async: true
  use Oban.Testing, repo: Alternis.Repo

  import Alternis.Factory
  import Hammox
  setup :verify_on_exit!

  alias Alternis.Game
  alias Alternis.Game.GameState.Aborted
  alias Alternis.Game.GameState.Created
  alias Alternis.Game.GameState.Expired
  alias Alternis.Game.GameState.Finished
  alias Alternis.Game.GameState.Running

  test "succeeds to expire stale games in progress" do
    %Game{id: created} = insert(:game, state: Created, expires_at: ago(60, :second))
    %Game{id: running} = insert(:game, state: Running, expires_at: ago(1, :day))

    assert {:ok, 2} = perform_job(Alternis.ExpiredGamesWorker, %{})

    assert %Game{state: Expired, expires_at: nil} = Repo.get!(Game, created)
    assert %Game{state: Expired, expires_at: nil} = Repo.get!(Game, running)
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
