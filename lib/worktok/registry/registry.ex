defmodule Worktok.Registry do
  @moduledoc """
  The Registry context.
  """

  import Ecto.Query, warn: false
  alias Worktok.Repo

  alias Worktok.Registry.Client
  alias Worktok.Accounts

  @doc """
  Returns the list of clients.
  """
  def list_clients() do
    Client
    |> Repo.all
    |> preload_user()
  end

  @doc """
  Returns the list of clients of a user.
  """
  def list_user_clients(%Accounts.User{} = user) do
    Client
    |> user_clients_query(user)
    |> Repo.all()
    |> preload_user()
  end

  @doc """
  Gets a single client.
  """
  def get_client!(id) do
    Client
    |> Repo.get!(id)
    |> preload_user()
  end

  @doc """
  Gets a single client of a user.
  """
  def get_user_client!(%Accounts.User{} = user, id) do
    from(c in Client, where: c.id == ^id)
    |> user_clients_query(user)
    |> Repo.one!()
    |> preload_user()
  end

  defp user_clients_query(query, %Accounts.User{id: user_id}) do
    from(c in query, where: c.user_id == ^user_id)
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
    Repo.delete(client)
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

  defp preload_user(query) do
    Repo.preload(query, :user)
  end
end
