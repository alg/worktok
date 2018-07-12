defmodule WorktokWeb.DashboardController do
  use WorktokWeb, :user_controller

  def index(conn, _, current_user) do
    projects =
      Worktok.Registry.list_user_projects(current_user)
      |> Worktok.Repo.preload(:client)

    render(conn, "index.html", projects: projects)
  end

  def add_work(conn, _, current_user) do
    IO.puts "---------------- add_work"
    IO.inspect dashboard_path(conn, :index)
    
    conn
    |> put_flash(:info, "Project created successfully.")
    |> redirect(to: dashboard_path(conn, :index))
  end

end
