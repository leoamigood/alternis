defmodule AlternisWeb.GameLive.GameNotFoundError do
  defexception message: "game not found", plug_status: 404
end
