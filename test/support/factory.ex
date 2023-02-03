defmodule Alternis.Factory do
  use ExMachina.Ecto, repo: Alternis.Repo

  @moduledoc false

  alias Alternis.AccountsFixtures
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
    %Game{
      user: AccountsFixtures.user_fixture(),
      secret: "secret",
      state: Created,
      in_progress?: true,
      language: English
    }
  end

  def guess_factory do
    %Guess{
      user: AccountsFixtures.user_fixture(),
      word: "guess"
    }
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
