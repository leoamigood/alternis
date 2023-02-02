defmodule AlternisWeb.GameLive.GuessFormComponent do
  use AlternisWeb, :live_component

  import AlternisWeb.Endpoint

  alias Alternis.Guess
  alias Alternis.Landing
  alias alias AlternisWeb.GameLive.Show

  @impl true
  def update(_assigns, socket = %{assigns: %{changeset: _changeset}}) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    changeset = Guess.changeset(%Guess{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"guess" => guess_params}, socket = %{assigns: %{game: game}}) do
    changeset =
      guess_params
      |> Guess.validate_word()
      |> Guess.validate_word_length(String.length(game.secret))
      |> Guess.validate_word_in_dictionary(game.language)
      |> Map.put(:action, :guess)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("place", %{"guess" => guess_params}, socket = %{assigns: %{game: game}}) do
    {:noreply,
     socket
     |> guess(socket.assigns.action, guess_params, game)
     |> push_patch(to: socket.assigns.return_to)}
  end

  defp guess(socket, :guess, _guess_params = %{"word" => word}, game) do
    case Landing.guess(game, word) do
      {:ok, guess = %{exact?: false}} ->
        notify_guess_placed(guess)
        put_flash(socket, :info, "Guess posted successfully")

      {:ok, guess = %{exact?: true}} ->
        notify_guess_placed(guess)
        notify_game_ended(game)
        put_flash(socket, :warn, "Congratulations! You guessed the secret word!")

      {:error, %{game: %{in_progress?: false}}} ->
        notify_game_ended(game)
    end
  end

  defp notify_guess_placed(guess) do
    broadcast!(guess.game_id, Show.guess_placed_event(), %{topic: guess.game_id, guess: guess})
  end

  defp notify_game_ended(game) do
    broadcast!(game.id, Show.game_ended_event(), %{topic: game.id})
  end
end
