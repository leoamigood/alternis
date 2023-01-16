defmodule AlternisWeb.GameLive.GuessComponent do
  use AlternisWeb, :live_component

  alias Alternis.Guess
  alias Alternis.Landing

  @topic "game"

  @impl true
  def update(assigns, socket) do
    changeset = Guess.change_secret()

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
      {:ok, _guess_id} ->
        AlternisWeb.Endpoint.broadcast_from!(
          self(),
          @topic,
          "guess_placed",
          socket.assigns.game.id
        )

        {:noreply,
         socket
         |> put_flash(:info, "Guess posted successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, errors} ->
        {:noreply, assign(socket, errors: errors)}
    end
  end
end
