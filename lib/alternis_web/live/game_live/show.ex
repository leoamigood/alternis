defmodule AlternisWeb.GameLive.Show do
  use AlternisWeb, :live_view

  alias Alternis.Landing

  @topic "game"

  @impl true
  def mount(_params, _session, socket) do
    AlternisWeb.Endpoint.subscribe(@topic)
    {:ok, socket}
  end

  @impl true
  def handle_info(%{topic: @topic, payload: game_id}, socket) do
    game = Landing.get_game!(game_id)
    {:noreply, assign(socket, :game, game)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    case Landing.get_game!(id) do
      nil ->
        raise AlternisWeb.GameLive.GameNotFoundError

      game ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:game, game)}
    end
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:guess), do: "Enter Guess"
end
