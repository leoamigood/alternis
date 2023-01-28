defmodule AlternisWeb.GameLive.Show do
  use AlternisWeb, :live_view

  alias Alternis.Landing

  @impl true
  def mount(%{"id" => game_id}, _session, socket) do
    AlternisWeb.Endpoint.subscribe(game_id)

    case Landing.get_game!(game_id) do
      nil ->
        raise AlternisWeb.GameLive.GameNotFoundError

      game ->
        {:ok,
         socket
         |> assign(:game, game)
         |> assign(:guesses, game.guesses), temporary_assigns: [guesses: []]}
    end
  end

  @impl true
  def handle_info(%{event: "guess_placed", payload: %{guess: guess}}, socket) do
    {:noreply, assign(socket, :guesses, [guess])}
  end

  def handle_info(%{event: "game_ended", payload: %{return_to: return_to}}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Game has ended!")
     |> push_redirect(to: return_to)}
  end

  @impl true
  def handle_params(_assigns, _session, socket) do
    {:noreply, socket}
  end
end
