defmodule WorktokWeb.UserController do
  use WorktokWeb, :controller

  alias Worktok.Accounts
  alias Worktok.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> WorktokWeb.Auth.login(user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: dashboard_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
