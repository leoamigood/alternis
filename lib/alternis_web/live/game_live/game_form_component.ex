defmodule AlternisWeb.GameLive.GameFormComponent do
  use AlternisWeb, :live_component

  import AlternisWeb.Endpoint

  alias Alternis.GameSettings
  alias Alternis.Landing
  alias AlternisWeb.GameLive
  alias Phoenix.LiveView.JS

  @impl true
  def update(assigns = %{game_settings: settings}, socket) do
    changeset = GameSettings.changeset(settings)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def focus_on(js \\ %JS{}, id) when is_binary(id) do
    js |> JS.focus(to: id)
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

    {:noreply,
     socket
     |> assign(changeset: changeset)
     |> assign(:button, button_title(params))}
  end

  def handle_event("save", %{"game_settings" => game_settings_params}, socket) do
    case Landing.create_game(socket.assigns.player, game_settings_params) do
      {:ok, game_id} ->
        broadcast!(GameLive.Index.topic(), "save_game", [])

        {:noreply,
         socket
         |> put_flash(:info, "Game created successfully")
         |> push_redirect(to: ~p"/games/#{game_id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset |> Map.put(:action, :validate))}
    end
  end

  defp button_title(%{"secret" => ""}), do: "Auto Generate"
  defp button_title(_), do: "Start"
end
