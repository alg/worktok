defmodule WorktokWeb.PageController do
  use WorktokWeb, :controller

  plug :authenticate_user when action in [:secure]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def secure(conn, _params) do
    render conn, "secure.html"
  end

end
