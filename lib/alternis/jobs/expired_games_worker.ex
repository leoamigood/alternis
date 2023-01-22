defmodule Alternis.ExpiredGamesWorker do
  use Oban.Worker,
    queue: :default,
    tags: ["cleanup"],
    unique: [fields: [:worker]]

  @moduledoc false

  import Ecto.Query

  alias Alternis.Game
  alias Alternis.Game.GameState.Created
  alias Alternis.Game.GameState.Expired
  alias Alternis.Game.GameState.Running
  alias Alternis.PubSub
  alias Alternis.Repo
  alias AlternisWeb.GameLive

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.info("Expire stale games...")
    {total, _} = expire()
    Logger.info("Expired #{total} games.")

    notify_all_players()

    {:ok, total}
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)

  defp expire(cutoff \\ DateTime.utc_now()) do
    from(g in Game,
      where:
        g.state in [^Created, ^Running] and
          g.expires_at < ^cutoff
    )
    |> Repo.update_all(set: [state: Expired, expires_at: nil])
  end

  defp notify_all_players do
    Phoenix.PubSub.broadcast(PubSub, GameLive.Index.topic(), %{topic: GameLive.Index.topic()})
  end
end
