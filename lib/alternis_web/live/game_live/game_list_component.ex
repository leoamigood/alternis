defmodule AlternisWeb.GameLive.GameListComponent do
  use Phoenix.Component
  use AlternisWeb, :verified_routes

  attr :games, :list, default: []
  slot :header

  def board(assigns) do
    ~H"""
    <table>
      <%= unless @games == [] do %>
        <%= render_slot(@header) %>
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
