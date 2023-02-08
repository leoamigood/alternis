defmodule AlternisWeb.GameLive.GameListComponent do
  use Phoenix.Component
  use AlternisWeb, :verified_routes

  attr :games, :list, default: []

  def render(assigns) do
    ~H"""
    <table>
      <%= unless @games == [] do %>
        <thead>
          <tr>
            <th>Language</th>
            <th>Secret</th>

            <th></th>
          </tr>
        </thead>
      <% end %>
      <tbody id="games">
        <%= for game <- @games do %>
          <tr id={"game-#{game.id}"}>
            <td><%= Recase.to_pascal(game.language.value) %></td>
            <td><%= String.pad_leading("", String.length(game.secret), "*") %></td>

            <td>
              <span><%= live_redirect("Play", to: ~p"/games/#{game}") %></span>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
