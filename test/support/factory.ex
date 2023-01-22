defmodule Alternis.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Alternis.Repo

  alias Alternis.Dictionary
  alias Alternis.Game
  alias Alternis.Game.GameLanguage.English
  alias Alternis.Game.GameState.Created
  alias Alternis.GameSettings
  alias Alternis.Guess
  alias Alternis.Word

  def game_settings_factory do
    %GameSettings{secret: "secret", language: English}
  end

  def game_factory do
    %Game{secret: "secret", state: Created, in_progress?: true, language: English}
  end

  def guess_factory do
    %Guess{word: "guess"}
  end

  def dictionary_factory do
    %Dictionary{name: "Webster", language: English}
  end

  def word_factory do
    %Word{
      frequency: :rand.uniform() * 1000.0,
      r: :rand.uniform(100),
      d: :rand.uniform(100),
      doc: :rand.uniform(100)
    }
  end
end
