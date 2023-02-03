defmodule AlternisWeb.GameLive.Index do
  use AlternisWeb, :live_view

  alias Alternis.GameSettings
  alias Alternis.Landing

  @topic "players"

  def topic, do: @topic

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

  defp apply_action(socket = %{assigns: %{current_user: user}}, :new, _params) do
    socket
    |> assign(:button, "Auto Generate")
    |> assign(:user, user)
    |> assign(:game_settings, %GameSettings{})
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp list_games do
    Landing.list_games()
  end
end
