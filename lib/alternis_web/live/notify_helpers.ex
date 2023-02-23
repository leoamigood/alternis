defmodule AlternisWeb.NotifyHelpers do
  @moduledoc false

  import AlternisWeb.Endpoint

  alias AlternisWeb.GameLive.Show

  def notify_guess_placed(guess) do
    broadcast!(guess.game_id, Show.guess_placed_event(), %{topic: guess.game_id, guess: guess})
  end

  def notify_game_ended(game) do
    broadcast_from!(self(), game.id, Show.game_ended_event(), %{topic: game.id})
  end
end
