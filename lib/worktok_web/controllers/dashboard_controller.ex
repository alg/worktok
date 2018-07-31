defmodule WorktokWeb.DashboardController do
  use WorktokWeb, :user_controller

  alias Worktok.Registry
  alias Worktok.Billing

  def index(conn, params, current_user) do
    projects =
      Registry.list_active_user_projects(current_user)

    recent_work =
      Billing.recent_work(current_user)
      |> Enum.group_by(&(&1.worked_on))
      |> Enum.sort(fn {k1, _v}, {k2, _v2} -> k1 >= k2 end)

    new_work =
      Billing.new_work(current_user, params)

    earnings =
      Billing.earnings(current_user)

    current_work =
      Billing.current_work(current_user)

    render(conn, "index.html", projects: projects, recent_work: recent_work, new_work: new_work, earnings: earnings, current_work: current_work)
  end

  def add_work(conn, params = %{"work" => work_params}, current_user) do
    case Billing.create_work(current_user, work_params) do
      {:ok, %Billing.Work{}} ->
        conn
        |> redirect(to: dashboard_path(conn, :index))

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Please review your work")
        |> index(params, current_user)
    end
  end

  def delete_work(conn, %{"id" => id}, current_user) do
    work = Billing.get_user_work!(current_user, id)
    {:ok, _work} = Billing.delete_work(work)

    conn
    |> put_flash(:info, "Work record deleted successfully.")
    |> redirect(to: dashboard_path(conn, :index))
  end

  def create_invoice(conn, %{"project_id" => project_id}, current_user) do
    project = Registry.get_user_project!(current_user, project_id)
    {:ok, invoice} = Billing.create_invoice_from_unpaid_work(project)

    conn
    |> put_flash(:info, "Invoice created")
    |> redirect(to: invoice_path(conn, :show, invoice.id))
  end

end
