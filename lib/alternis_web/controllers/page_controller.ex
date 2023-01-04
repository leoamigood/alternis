defmodule AlternisWeb.PageController do
  use AlternisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
