defmodule WorktokWeb.ProjectController do
  use WorktokWeb, :user_controller

  alias Worktok.Registry
  alias Worktok.Registry.Project

  def index(conn, _params, current_user) do
    projects = Registry.list_projects()
    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params, current_user) do
    changeset = Registry.change_project(current_user, %Project{})
    clients = Registry.list_active_user_clients(current_user)
    render(conn, "new.html", changeset: changeset, clients: clients)
  end

  def create(conn, %{"project" => project_params}, current_user) do
    case Registry.create_project(current_user, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        clients = Registry.list_active_user_clients(current_user)
        render(conn, "new.html", changeset: changeset, clients: clients)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    project = Registry.get_user_project!(current_user, id)
    render(conn, "show.html", project: project)
  end

  def edit(conn, %{"id" => id}, current_user) do
    project = Registry.get_user_project!(current_user, id)
    clients = Registry.list_active_user_clients(current_user)
    changeset = Registry.change_project(current_user, project)
    render(conn, "edit.html", project: project, changeset: changeset, clients: clients)
  end

  def update(conn, %{"id" => id, "project" => project_params}, current_user) do
    project = Registry.get_user_project!(current_user, id)

    case Registry.update_project(project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: project_path(conn, :show, project))

      {:error, %Ecto.Changeset{} = changeset} ->
        clients = Registry.list_active_user_clients(current_user)
        render(conn, "edit.html", project: project, changeset: changeset, clients: clients)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    project = Registry.get_project!(id)
    {:ok, _project} = Registry.delete_project(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: project_path(conn, :index))
  end
end
