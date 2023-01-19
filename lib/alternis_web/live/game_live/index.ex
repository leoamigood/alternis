defmodule AlternisWeb.GameLive.Index do
  use AlternisWeb, :live_view

  alias Alternis.Game
  alias Alternis.Landing

  @topic "players"

  @impl true
  def mount(_params, _session, socket) do
    AlternisWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :games, list_games())}
  end

  @impl true
  def handle_info(%{topic: @topic}, socket) do
    {:noreply, assign(socket, :games, Landing.list_games())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Game")
    |> assign(:game, %Game{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Games")
    |> assign(:game, nil)
  end

  defp list_games do
    Landing.list_games()
  end
end
