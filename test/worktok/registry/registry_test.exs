defmodule Worktok.RegistryTest do
  use Worktok.DataCase

  alias Worktok.Accounts
  alias Worktok.Registry

  describe "clients" do
    alias Worktok.Registry.Client

    @update_attrs %{active: false, email: "some updated email", name: "some updated name", prefix: "some updated prefix", rate: "456.7"}
    @invalid_attrs %{active: nil, email: nil, name: nil, prefix: nil, rate: nil}

    test "list_clients/0 returns all clients" do
      user = insert_user()
      %Registry.Client{id: id} = insert_client(user)
      assert [%Registry.Client{id: ^id}] = Registry.list_clients()
    end

    test "get_client!/1 returns the client with given id" do
      user = insert_user()
      %Registry.Client{id: id} = insert_client(user)
      assert %Registry.Client{id: ^id} = Registry.get_client!(id)
    end

    test "create_client/1 with valid data creates a client" do
      user = insert_user()
      client = insert_client(user)
      assert client.active == true
      assert client.email == "client@email.com"
      assert client.name == "Some Client"
      assert client.prefix == "SC"
      assert client.rate == Decimal.new("100.25")
    end

    test "create_client/1 with invalid data returns error changeset" do
      user = insert_user()
      assert {:error, %Ecto.Changeset{}} = Registry.create_client(user, @invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      user = insert_user()
      client = insert_client(user)
      assert {:ok, client} = Registry.update_client(client, @update_attrs)
      assert %Client{} = client
      assert client.active == false
      assert client.email == "some updated email"
      assert client.name == "some updated name"
      assert client.prefix == "some updated prefix"
      assert client.rate == Decimal.new("456.7")
    end

    test "update_client/2 with invalid data returns error changeset" do
      user = insert_user()
      client = insert_client(user)
      assert {:error, %Ecto.Changeset{}} = Registry.update_client(client, @invalid_attrs)
    end

    test "delete_client/1 deletes the client" do
      user = insert_user()
      client = insert_client(user)
      assert {:ok, %Client{}} = Registry.delete_client(client)
      assert_raise Ecto.NoResultsError, fn -> Registry.get_client!(client.id) end
    end

    test "change_client/1 returns a client changeset" do
      user = insert_user()
      client = insert_client(user)
      assert %Ecto.Changeset{} = Registry.change_client(user, client)
    end
  end

  describe "projects" do
    alias Worktok.Registry.Project

    @update_attrs %{active: false, name: "Some updated name", prefix: "SP2", rate: "456.7"}
    @invalid_attrs %{active: nil, name: nil, prefix: nil, rate: nil}

    defp project_fixture do
      user = insert_user()
      client = insert_client(user)
      project = insert_project(client)
      project
    end

    test "list_projects/0 returns all projects" do
      %Project{id: id} = project_fixture()
      assert [%Registry.Project{id: ^id}] = Registry.list_projects()
    end

    test "list_user_projects/1 returns all user projects" do
      %Project{id: id, user: owner} = project_fixture()
      assert [%Registry.Project{id: ^id}] = Registry.list_user_projects(owner)

      foo = insert_user(name: "Foo")
      assert [] = Registry.list_user_projects(foo)
    end

    test "get_project!/1 returns the project with given id" do
      %Project{id: id} = project_fixture()
      assert %Project{id: ^id} = Registry.get_project!(id)
    end

    test "get_user_project!/2 returns the project with given id" do
      %Project{id: id, user: owner} = project_fixture()
      assert %Project{id: ^id} = Registry.get_user_project!(owner, id)

      foo = insert_user(name: "Foo")
      assert_raise Ecto.NoResultsError, fn ->
        Registry.get_user_project!(foo, id)
      end
    end

    test "create_project/1 with valid data creates a project" do
      %Accounts.User{id: user_id} = user = insert_user()
      %Registry.Client{id: client_id} = client = insert_client(user)
      project = insert_project(client)
      project = Repo.preload(project, [:user, :client])

      assert project.active == true
      assert project.name == "Some Project"
      assert project.prefix == "SP"
      assert project.rate == Decimal.new("50.25")
      assert %Accounts.User{id: ^user_id} = project.user
      assert %Registry.Client{id: ^client_id} = project.client
    end

    test "create_project/1 with invalid data returns error changeset" do
      user = insert_user()
      assert {:error, %Ecto.Changeset{}} = Registry.create_project(user, @invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      assert {:ok, project} = Registry.update_project(project, @update_attrs)
      assert %Project{} = project
      assert project.active == false
      assert project.name == "Some updated name"
      assert project.prefix == "SP2"
      assert project.rate == Decimal.new("456.7")
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Registry.update_project(project, @invalid_attrs)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Registry.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Registry.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Registry.change_project(project.user, project)
    end
  end
end
