defmodule AlternisWeb.GameLive.Show do
  use AlternisWeb, :live_view

  alias Alternis.Landing

  @impl true
  def mount(%{"id" => game_id}, _session, socket = %{assigns: %{current_user: user}}) do
    case Landing.get_game!(game_id) do
      nil ->
        raise AlternisWeb.GameLive.GameNotFoundError

      game ->
        AlternisWeb.Endpoint.subscribe(game_id)
        Phoenix.Tracker.track(AlternisWeb.PlayersTracker, self(), game_id, game_id, %{user: user})

        {:ok,
         socket
         |> assign(:game, game)
         |> assign(:players, [])
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

  def handle_info({action, game_id, %{user: _email}}, socket) when action in [:join, :leave] do
    {:noreply, socket |> assign(:players, online_players(game_id))}
  end

  @impl true
  def handle_params(_assigns, _session, socket) do
    {:noreply, socket}
  end

  defp online_players(game_id) do
    Phoenix.Tracker.get_by_key(AlternisWeb.PlayersTracker, game_id, game_id)
    |> Enum.map(fn {_pid, %{user: user}} -> user.email end)
    |> Enum.uniq()
  end
end
