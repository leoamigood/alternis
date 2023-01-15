defmodule AlternisWeb.GameLive.Show do
  use AlternisWeb, :live_view

  alias Alternis.Landing
  alias Alternis.Guess

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:game, Landing.get_game!(id))}
  end

  defp apply_action(socket, :guess, _params) do
    socket
    |> assign(:page_title, "Guess")
    |> assign(:guess, %Guess{})
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:guess), do: "Show Guess"
end