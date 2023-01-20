defmodule Alternis.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Alternis.Repo

  alias Alternis.Game
  alias Alternis.Game.GameLanguage.English
  alias Alternis.Game.GameState.Created
  alias Alternis.GameSettings
  alias Alternis.Guess

  def game_settings_factory do
    %GameSettings{secret: "secret", language: English}
  end

  def game_factory do
    %Game{secret: "secret", state: Created, in_progress?: true, language: English}
  end

  def guess_factory do
    %Guess{word: "guess"}
  end
end
