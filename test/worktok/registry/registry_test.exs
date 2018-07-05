defmodule Worktok.RegistryTest do
  use Worktok.DataCase

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
end
