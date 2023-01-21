defmodule AlternisWeb.GameLive.GuessComponent do
  use AlternisWeb, :live_component

  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Guess
  alias Alternis.Landing

  @impl true
  def update(assigns, socket) do
    changeset =
      Guess.change_secret()
      |> DictionaryEngine.impl().validate_word(:word)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"guess" => guess_params}, socket) do
    changeset =
      socket.assigns.game.secret
      |> Guess.change_secret(guess_params)
      |> DictionaryEngine.impl().validate_word(:word)
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
      {:ok, guess} ->
        notify_game_players(socket.assigns.game)

        {:noreply,
         socket
         |> flash_message(guess)
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, errors} ->
        {:noreply, assign(socket, errors: errors)}
    end
  end

  defp flash_message(socket, guess) do
    case guess.exact? do
      true -> put_flash(socket, :warn, "Congratulations! You guessed the secret word")
      false -> put_flash(socket, :info, "Guess posted successfully")
    end
  end

  defp notify_game_players(game) do
    AlternisWeb.Endpoint.broadcast!(game.id, "guess_placed", %{topic: game.id})
  end
end
