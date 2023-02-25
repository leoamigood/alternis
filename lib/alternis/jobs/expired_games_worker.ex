defmodule Alternis.ExpiredGamesWorker do
  use Oban.Worker,
    queue: :default,
    tags: ["cleanup"],
    unique: [fields: [:worker]]

  @moduledoc false

  import Ecto.Query

  alias Alternis.Events
  alias Alternis.Game
  alias Alternis.Game.GameState.{Created, Expired, Running}
  alias Alternis.PubSub
  alias Alternis.Repo
  alias Alternis.Topics

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.info("Expire stale games...")
    {total, games} = expire()
    Logger.info("Expired #{total} games.")

    notify_players(games)
    refresh_running_games()

    {:ok, total}
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)

  defp expire(cutoff \\ DateTime.utc_now()) do
    from(g in Game,
      select: g,
      where:
        g.state in [^Created, ^Running] and
          g.expires_at < ^cutoff
    )
    |> Repo.update_all(set: [state: Expired, expires_at: nil])
  end

  defp notify_players(games) do
    games
    |> Enum.each(fn game ->
      Phoenix.PubSub.broadcast(PubSub, game.id, %{
        topic: game.id,
        event: Events.game_ended_event()
      })
    end)
  end

  defp refresh_running_games do
    Phoenix.PubSub.broadcast(PubSub, Topics.players(), %{topic: Topics.players()})
  end
end
