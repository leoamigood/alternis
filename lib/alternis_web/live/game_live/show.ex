defmodule AlternisWeb.GameLive.Show do
  use AlternisWeb, :live_view

  import AlternisWeb.GameLive.GameComponent

  alias Alternis.Landing
  alias Alternis.Game.GameState.{Expired, Finished}
  alias Alternis.Guess

  @game_ended_event "game_ended"
  @guess_placed_event "guess_placed"

  def game_ended_event, do: @game_ended_event
  def guess_placed_event, do: @guess_placed_event

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
         |> assign(:update, "append")
         |> assign(:current_user, user)
         |> assign(:players, online_players(game.id))
         |> assign(:guesses, game.guesses), temporary_assigns: [guesses: []]}
    end
  end

  @impl true
  def handle_info(%{event: @guess_placed_event, payload: %{guess: guess}}, socket) do
    {:noreply,
     socket
     |> assign(:update, "append")
     |> assign(:guesses, [guess])}
  end

  def handle_info(%{event: @game_ended_event}, socket) do
    {:noreply, socket |> push_redirect(to: ~p"/games/#{socket.assigns.game}")}
  end

  def handle_info({action, game_id, %{user: _email}}, socket) when action in [:join, :leave] do
    {:noreply, socket |> assign(:players, online_players(game_id))}
  end

  @impl true
  def handle_event("order_top", %{"game_id" => game_id}, socket) do
    case Landing.get_game!(game_id) do
      nil ->
        raise AlternisWeb.GameLive.GameNotFoundError

      game ->
        sorted = Enum.sort(game.guesses, &(Guess.priority(&1) > Guess.priority(&2)))

        {:noreply,
         socket
         |> assign(:update, "replace")
         |> assign(:guesses, sorted)}
    end
  end

  @impl true
  def handle_params(_params, _session, socket = %{assigns: %{game: game}}) do
    case game.state do
      Finished ->
        {:noreply, socket |> put_flash(:error, "Game has ended!")}

      Expired ->
        {:noreply, socket |> put_flash(:error, "Game has expired!")}

      _ ->
        {:noreply, socket}
    end
  end

  defp online_players(game_id) do
    Phoenix.Tracker.get_by_key(AlternisWeb.PlayersTracker, game_id, game_id)
    |> Enum.map(fn {_pid, %{user: user}} -> user end)
    |> Enum.uniq()
  end
end
