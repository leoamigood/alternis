defmodule Alternis.LandingTest do
  use Alternis.DataCase

  alias Alternis.Landing

  describe "games" do
    alias Alternis.Game

    import Alternis.LandingFixtures

    @invalid_attrs %{secret: nil}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Landing.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Landing.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{secret: "some secret"}

      assert {:ok, %Game{} = game} = Landing.create_game(valid_attrs)
      assert game.secret == "some secret"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Landing.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      update_attrs = %{secret: "some updated secret"}

      assert {:ok, %Game{} = game} = Landing.update_game(game, update_attrs)
      assert game.secret == "some updated secret"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Landing.update_game(game, @invalid_attrs)
      assert game == Landing.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Landing.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Landing.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Landing.change_game(game)
    end
  end
end
