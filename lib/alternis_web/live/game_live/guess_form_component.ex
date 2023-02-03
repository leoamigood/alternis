defmodule AlternisWeb.GameLive.GuessFormComponent do
  use AlternisWeb, :live_component

  import AlternisWeb.Endpoint

  alias Alternis.Guess
  alias Alternis.Landing
  alias AlternisWeb.GameLive.Show

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
  def handle_event("place", %{"guess" => %{"word" => word}}, socket) do
    case Landing.guess(socket.assigns.player, socket.assigns.game, word) do
      {:ok, guess = %{exact?: false}} ->
        notify_guess_placed(guess)

        {:noreply,
         socket
         |> put_flash(:info, "Guess posted successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:ok, guess = %{exact?: true}} ->
        notify_guess_placed(guess)
        notify_game_ended(socket.assigns.game)

        {:noreply,
         socket
         |> put_flash(:warn, "Congratulations! You guessed the secret word!")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %{game: %{in_progress?: false}}} ->
        notify_game_ended(socket.assigns.game)
        {:noreply, socket}
    end
  end

  defp notify_guess_placed(guess) do
    broadcast!(guess.game_id, Show.guess_placed_event(), %{topic: guess.game_id, guess: guess})
  end

  defp notify_game_ended(game) do
    broadcast_from!(self(), game.id, Show.game_ended_event(), %{topic: game.id})
  end
end
