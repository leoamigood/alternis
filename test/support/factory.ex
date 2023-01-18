defmodule Alternis.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Alternis.Repo

  alias Alternis.Game.GameState

  def game_settings_factory do
    %Alternis.GameSettings{secret: "secret"}
  end

  def game_factory do
    %Alternis.Game{secret: "secret", state: GameState.Created, in_progress?: true}
  end

  def guess_factory do
    %Alternis.Guess{word: "guess"}
  end
end
