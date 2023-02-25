defmodule AlternisWeb.NotifyHelpers do
  @moduledoc false

  import AlternisWeb.Endpoint

  alias Alternis.Events
  alias Alternis.Topics

  def notify_game_created do
    broadcast!(Topics.players(), Events.game_created_event(), [])
  end

  def notify_guess_placed(guess) do
    broadcast!(guess.game_id, Events.guess_placed_event(), %{topic: guess.game_id, guess: guess})
  end

  def notify_game_ended(game) do
    broadcast_from!(self(), game.id, Events.game_ended_event(), %{topic: game.id})
    broadcast!(Topics.players(), Events.game_created_event(), [])
  end
end
