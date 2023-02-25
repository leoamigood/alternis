defmodule AlternisWeb.GameLive.SecretComponent do
  use Phoenix.Component

  attr :game, :map, required: true

  def secret(assigns) do
    ~H"""
    <div style={unless @game.in_progress?, do: "color:red"}>
      <strong>Secret:</strong>
      <%= if @game.in_progress? do %>
        <%= String.pad_leading("", String.length(@game.secret), "*") %>
      <% else %>
        <%= @game.secret %>
      <% end %>
    </div>
    """
  end
end
