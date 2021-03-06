defmodule WorktokWeb.ClientController do
  use WorktokWeb, :user_controller

  alias Worktok.Registry
  alias Worktok.Registry.Client

  def index(conn, _params, current_user) do
    clients = Registry.list_user_clients(current_user)
    render(conn, "index.html", clients: clients)
  end

  def new(conn, _params, current_user) do
    changeset = Registry.change_client(current_user, %Client{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"client" => client_params}, current_user) do
    case Registry.create_client(current_user, client_params) do
      {:ok, client} ->
        conn
        |> put_flash(:info, "Client created successfully.")
        |> redirect(to: client_path(conn, :show, client))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    client = Registry.get_user_client!(current_user, id)
    render(conn, "show.html", client: client)
  end

  def edit(conn, %{"id" => id}, current_user) do
    client = Registry.get_user_client!(current_user, id)
    changeset = Registry.change_client(current_user, client)
    render(conn, "edit.html", client: client, changeset: changeset)
  end

  def update(conn, %{"id" => id, "client" => client_params}, current_user) do
    client = Registry.get_user_client!(current_user, id)

    case Registry.update_client(client, client_params) do
      {:ok, client} ->
        conn
        |> put_flash(:info, "Client updated successfully.")
        |> redirect(to: client_path(conn, :show, client))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", client: client, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    client = Registry.get_user_client!(current_user, id)

    case Registry.delete_client(client) do
      {:ok, _client} ->
        conn
        |> put_flash(:info, "Client deleted successfully.")
        |> redirect(to: client_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        msg =
          WorktokWeb.Errors.full_messages(changeset)
          |> Enum.join(" ")

        conn
        |> put_flash(:error, "Could not delete client: #{msg}")
        |> redirect(to: client_path(conn, :index))
    end
  end
end
