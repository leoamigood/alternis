defmodule AlternisWeb.GameLive.FormComponent do
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
  def handle_event("validate", %{"game" => game_params}, socket) do
    changeset =
      socket.assigns.game
      |> Landing.change_game(game_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"game" => game_params}, socket) do
    save_game(socket, socket.assigns.action, game_params)
  end

  defp save_game(socket, :new, game_params) do
    case Landing.create_game(game_params) do
      {:ok, _game} ->
        {:noreply,
         socket
         |> put_flash(:info, "Game created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
