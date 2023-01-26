defmodule AlternisWeb.GameLive.GuessFormComponent do
  use AlternisWeb, :live_component

  import AlternisWeb.Endpoint

  alias Alternis.GameSettings
  alias Alternis.Guess
  alias Alternis.Landing

  @impl true
  def update(assigns = %{game: game}, socket) do
    changeset =
      Guess.validate_word(game)
      |> GameSettings.validate_in_dictionary(:word)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"guess" => guess_params}, socket) do
    changeset =
      socket.assigns.game
      |> Guess.validate_word(guess_params)
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
        broadcast_from!(self(), guess.game_id, "guess_placed", %{})
        put_flash(socket, :info, "Guess posted successfully")

      {:ok, guess = %{exact?: true}} ->
        broadcast_from!(self(), guess.game_id, "guess_placed", %{})

        broadcast_from!(self(), guess.game_id, "game_ended", %{
          return_to: socket.assigns.return_to
        })

        put_flash(socket, :warn, "Congratulations! You guessed the secret word")

      {:error, %{game: %{in_progress?: false}}} ->
        put_flash(socket, :error, "Game has ended!")
    end
  end
end
