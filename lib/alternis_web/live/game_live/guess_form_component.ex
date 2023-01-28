defmodule AlternisWeb.GameLive.GuessFormComponent do
  use AlternisWeb, :live_component

  import AlternisWeb.Endpoint

  alias Alternis.Guess
  alias Alternis.Landing

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
        broadcast!(game.id, "guess_placed", %{guess: guess})
        put_flash(socket, :info, "Guess posted successfully")

      {:ok, guess = %{exact?: true}} ->
        broadcast!(game.id, "guess_placed", %{guess: guess})
        broadcast_from!(self(), game.id, "game_ended", %{return_to: socket.assigns.return_to})
        put_flash(socket, :warn, "Congratulations! You guessed the secret word!")

      {:error, %{game: %{in_progress?: false}}} ->
        put_flash(socket, :error, "Game has ended!")
    end
  end
end
