defmodule WorktokWeb.DashboardController do
  use WorktokWeb, :user_controller

  def index(conn, params, current_user) do
    projects =
      Worktok.Registry.list_active_user_projects(current_user)

    recent_work =
      Worktok.Billing.recent_work(current_user)
      |> Enum.group_by(&(&1.worked_on))
      |> Enum.sort(fn {k1, _v}, {k2, _v2} -> k1 >= k2 end)

    new_work =
      Worktok.Billing.new_work(current_user, params)

    render(conn, "index.html", projects: projects, recent_work: recent_work, new_work: new_work)
  end

  def add_work(conn, params = %{"work" => work_params}, current_user) do
    case Worktok.Billing.create_work(current_user, work_params) do
      {:ok, work} ->
        conn
        |> put_flash(:info, "Work registered successfully.")
        |> redirect(to: dashboard_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Please review your work")
        |> index(params, current_user)
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
