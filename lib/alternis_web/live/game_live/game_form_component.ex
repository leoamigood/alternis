defmodule AlternisWeb.GameLive.GameFormComponent do
  use AlternisWeb, :live_component

  import AlternisWeb.Endpoint

  alias Alternis.GameSettings
  alias Alternis.Landing
  alias AlternisWeb.GameLive

  @impl true
  def update(assigns = %{game_settings: settings}, socket) do
    changeset = GameSettings.changeset(settings)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"game_settings" => params},
        socket = %{assigns: %{game_settings: settings}}
      ) do
    changeset =
      settings
      |> GameSettings.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset) |> assign(:button, button_title(params))}
  end

  def handle_event("save", %{"game_settings" => game_settings_params}, socket) do
    create_game(socket, socket.assigns.action, game_settings_params)
  end

  defp create_game(socket, :new, game_settings_params) do
    case Landing.create_game(game_settings_params) do
      {:ok, _game_id} ->
        broadcast_from!(self(), GameLive.Index.topic(), "save_game", [])

        {:noreply,
         socket
         |> put_flash(:info, "Game created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset |> Map.put(:action, :validate))}
    end
  end

  defp button_title(%{"secret" => ""}), do: "Auto Generate"
  defp button_title(_), do: "Start"
end
