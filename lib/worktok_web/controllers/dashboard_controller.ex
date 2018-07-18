defmodule WorktokWeb.DashboardController do
  use WorktokWeb, :user_controller

  def index(conn, _, current_user) do
    projects =
      Worktok.Registry.list_user_projects(current_user)
      |> Worktok.Repo.preload(:client)

    works =
      Worktok.Billing.recent_work(current_user)

    render(conn, "index.html", projects: projects, recent_work: works)
  end

  def add_work(conn, %{"work" => work_params}, current_user) do
    case Worktok.Billing.create_work(current_user, work_params) do
      {:ok, work} ->
        conn
        |> put_flash(:info, "Work registered successfully.")
        |> redirect(to: dashboard_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Please review your work")
        |> index(%{}, current_user)
    end
  end

  def delete_work(conn, %{"id" => id}, current_user) do
    work = Worktok.Billing.get_user_work!(current_user, id)
    {:ok, _work} = Worktok.Billing.delete_work(work)

    conn
    |> put_flash(:info, "Work record deleted successfully.")
    |> redirect(to: dashboard_path(conn, :index))
  end
end
