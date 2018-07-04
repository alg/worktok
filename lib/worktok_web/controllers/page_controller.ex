defmodule WorktokWeb.PageController do
  use WorktokWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
