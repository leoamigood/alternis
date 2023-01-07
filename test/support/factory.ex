defmodule Alternis.Factory do
  @moduledoc false

  alias Alternis.Game.GameState
  alias Alternis.Repo

  # Factories

  def build(:game) do
    %Alternis.Game{secret: "secret", state: GameState.Created}
  end

  def build(:guess) do
    %Alternis.Guess{word: "guess"}
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
