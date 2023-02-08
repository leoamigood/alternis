defmodule AlternisWeb.GameLive.GameComponent do
  use Phoenix.Component

  attr :guesses, :list, required: true
  slot :header
  slot :footer

  def timeline(assigns) do
    ~H"""
    <div>
      <%= render_slot(@header) %>
      <ul id="game-guesses" phx-update="append">
        <%= for guess <- @guesses do %>
          <li id={guess.id} style={if guess.exact?, do: "color:green"}>
            <%= guess.user.username %>: <%= guess.word %> - bulls: <%= length(guess.bulls) %>, cows: <%= length(
              guess.cows
            ) %>
          </li>
        <% end %>
      </ul>
      <%= render_slot(@footer) %>
    </div>
    """
  end

  attr :players, :list, default: []
  slot :header

  def players(assigns) do
    ~H"""
    <div>
      <%= render_slot(@header) %>
      <%= for player <- @players do %>
        <li>
          <%= player.username %>
        </li>
      <% end %>
    </div>
    """
  end
end
