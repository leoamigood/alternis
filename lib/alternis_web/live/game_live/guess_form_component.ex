defmodule AlternisWeb.GameLive.GuessFormComponent do
  use AlternisWeb, :live_component

  alias Alternis.Guess
  alias Alternis.Landing

  @impl true
  def update(assigns = %{game: _game}, socket) do
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
  def handle_event("place", %{"guess" => guess_params}, socket) do
    {:noreply,
     socket
     |> guess(socket.assigns.action, guess_params)
     |> push_redirect(to: socket.assigns.return_to)}
  end

  defp guess(socket, :guess, guess_params) do
    case Landing.guess(socket.assigns.game, guess_params) do
      {:ok, guess = %{exact?: false}} ->
        notify!(guess.game_id, "guess_placed")
        put_flash(socket, :info, "Guess posted successfully")

      {:ok, guess = %{exact?: true}} ->
        notify!(guess.game_id, "guess_placed")
        notify!(guess.game_id, "game_ended", %{return_to: socket.assigns.return_to})
        put_flash(socket, :warn, "Congratulations! You guessed the secret word")

      {:error, %{game: %{in_progress?: false}}} ->
        put_flash(socket, :error, "Game has ended!")
    end
  end

  defp notify!(game_id, event, payload \\ %{}) do
    AlternisWeb.Endpoint.broadcast_from!(self(), game_id, event, payload)
  end
end
