defmodule Worktok.AccountsTest do
  use Worktok.DataCase

  alias Worktok.Accounts

  describe "users" do
    alias Worktok.Accounts.User

    @update_attrs %{name: "Mark Smith"}
    @invalid_attrs %{name: nil}


    test "list_users/0 returns all users" do
      %User{id: id} = user_fixture()
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user(user.id).id == user.id
    end

    test "get_user_by_email/1 returns the user with given id" do
      user = user_fixture() |> Worktok.Repo.preload(:credential)
      assert Accounts.get_user_by_email(user.credential.email).id == user.id
    end

    test "authenticate_by_email_and_pass returns the user if valid" do
      user = user_fixture() |> Worktok.Repo.preload(:credential)
      {:ok, auth_user} = Accounts.authenticate_by_email_and_pass(user.credential.email, "supersecret")
      assert auth_user.id == user.id
    end

    test "authenticate_by_email_and_pass when not authorized" do
      user = user_fixture() |> Worktok.Repo.preload(:credential)
      assert {:error, :unauthorized} = Accounts.authenticate_by_email_and_pass(user.credential.email, "wrong-password")
    end

    test "authenticate_by_email_and_pass when no user" do
      assert {:error, :unauthorized} = Accounts.authenticate_by_email_and_pass("unknown@email.com", "supersecret")
    end

    test "create_user/1 with valid data creates a user" do
      user = user_fixture()
      assert user.name == "John Doe"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.name == "Mark Smith"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
