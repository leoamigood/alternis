defmodule Alternis.LandingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Alternis.Landing` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        secret: "some secret"
      })
      |> Alternis.Landing.create_game()

    game
  end
end
