defmodule AlternisWeb.GameLive.GuessComponent do
  use AlternisWeb, :live_component

  alias Alternis.Landing

  @impl true
  def update(%{game: game} = assigns, socket) do
    changeset = Landing.change_game(game)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("place", %{"game" => guess_params}, socket) do
    guess(socket, socket.assigns.action, guess_params)
  end

  defp guess(socket, :guess, guess_params) do
    case Landing.guess(socket.assigns.game, guess_params) do
      {:ok, _guess} ->
        {:noreply,
         socket
         |> put_flash(:info, "Guess created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
