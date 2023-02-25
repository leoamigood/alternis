defmodule Alternis.Events do
  @moduledoc false

  @game_created_event "game_created"
  @game_ended_event "game_ended"
  @guess_placed_event "guess_placed"

  def game_created_event, do: @game_created_event
  def game_ended_event, do: @game_ended_event
  def guess_placed_event, do: @guess_placed_event
end
