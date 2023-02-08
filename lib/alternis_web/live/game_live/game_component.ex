defmodule AlternisWeb.GameLive.GameComponent do
  use Phoenix.Component
  #  use AlternisWeb, :live_component

  attr :game, :map, required: true
  attr :guesses, :list, required: true

  def render(assigns) do
    ~H"""
    <div>
      <strong>Language:</strong> <%= Recase.to_pascal(@game.language.value) %>
      <li>
        <strong>Secret:</strong>
        <%= String.pad_leading("", String.length(@game.secret), "*") %>

        <ul id="game-guesses" phx-update="append">
          <%= for guess <- @guesses do %>
            <li id={guess.id} style={if guess.exact?, do: "color:green"}>
              <%= guess.user.username %>: <%= guess.word %> - bulls: <%= length(guess.bulls) %>, cows: <%= length(
                guess.cows
              ) %>
            </li>
          <% end %>
        </ul>
      </li>
    </div>
    """
  end
end
