defmodule AlternisWeb.GameLive.PlayersComponent do
  use Phoenix.Component

  attr :players, :list, default: []

  def render(assigns) do
    ~H"""
    <div>
      <%= for player <- @players do %>
        <li>
          <%= player.username %>
        </li>
      <% end %>
    </div>
    """
  end
end
