defmodule AlternisWeb.GameLive.Index do
  use AlternisWeb, :live_view

  alias Alternis.Landing
  alias Alternis.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :games, list_games())}
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
