defmodule AlternisWeb.GameLive.Show do
  use AlternisWeb, :live_view

  alias Alternis.Landing

  @impl true
  def mount(%{"id" => game_id}, _session, socket) do
    AlternisWeb.Endpoint.subscribe(game_id)
    {:ok, socket}
  end

  @impl true
  def handle_info(%{event: "guess_placed"}, socket) do
    game = Landing.get_game!(socket.assigns.game.id)
    {:noreply, assign(socket, :game, game)}
  end

  def handle_info(%{event: "game_ended", payload: %{return_to: return_to}}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Game has ended!")
     |> push_redirect(to: return_to)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    case Landing.get_game!(id) do
      nil ->
        raise AlternisWeb.GameLive.GameNotFoundError

      game ->
        {:noreply,
         socket
         |> assign(:game, game)}
    end
  end
end
