defmodule AlternisWeb.GameLive.GuessFormComponent do
  use AlternisWeb, :live_component

  alias Alternis.GameSettings
  alias Alternis.Guess
  alias Alternis.Landing
  alias AlternisWeb.Endpoint

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
    guess(socket, socket.assigns.action, guess_params)
  end

  defp guess(socket, :guess, guess_params) do
    case Landing.guess(socket.assigns.game, guess_params) do
      {:ok, guess = %{exact?: false}} ->
        Endpoint.broadcast!(guess.game_id, "guess_placed", %{})

        {:noreply,
         socket
         |> put_flash(:info, "Guess posted successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:ok, guess = %{exact?: true}} ->
        Endpoint.broadcast!(guess.game_id, "guess_placed", %{})
        Endpoint.broadcast!(guess.game_id, "game_ended", %{return_to: socket.assigns.return_to})

        {:noreply,
         socket
         |> put_flash(:warn, "Congratulations! You guessed the secret word")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %{game: %{in_progress?: false}}} ->
        {:noreply,
         socket
         |> put_flash(:error, "Game has ended!")
         |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end
