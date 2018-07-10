defmodule Worktok.Registry do
  @moduledoc """
  The Registry context.
  """

  import Ecto.Query, warn: false

  alias Worktok.Repo
  alias Worktok.Accounts
  alias Worktok.Registry.Client
  alias Worktok.Registry.Project

  @doc """
  Returns the list of clients of a user.
  """
  def list_user_clients(%Accounts.User{} = user) do
    Client
    |> Accounts.user_scope_query(user)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single client of a user.
  """
  def get_user_client!(%Accounts.User{} = user, id) do
    from(c in Client, where: c.id == ^id)
    |> Accounts.user_scope_query(user)
    |> Repo.one!()
    |> Repo.preload(:user)
  end

  @doc """
  Creates a client.
  """
  def create_client(%Accounts.User{} = user, attrs \\ %{}) do
    %Client{}
    |> Client.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  @doc """
  Updates a client.
  """
  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Client.
  """
  def delete_client(%Client{} = client) do
    Repo.delete(Client.delete_changeset(client))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client changes.
  """
  def change_client(%Accounts.User{} = user, %Client{} = client) do
    client
    |> Client.changeset(%{})
    |> put_user(user)
  end

  defp put_user(changeset, user) do
    Ecto.Changeset.put_assoc(changeset, :user, user)
  end

  @doc """
  Returns the list of user projects.
  """
  def list_user_projects(%Accounts.User{} = user) do
    Project
    |> Accounts.user_scope_query(user)
    |> Repo.all()
    |> Repo.preload([:user, :client])
  end

  @doc """
  Gets a single project.
  """
  def get_user_project!(%Accounts.User{} = user, id) do
    from(p in Project, where: p.id == ^id)
    |> Accounts.user_scope_query(user)
    |> Repo.one!()
    |> Repo.preload([:user, :client])
  end

   @doc """
  Creates a project.
  """
  def create_project(%Accounts.User{} = user, attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  @doc """
  Updates a project.
  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Project.
  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.
  """
  def change_project(%Accounts.User{} = user, %Project{} = project) do
    project
    |> Project.changeset(%{})
    |> put_user(user)
  end

  defp active(query) do
    from(q in query, where: q.active == true)
  end

end
