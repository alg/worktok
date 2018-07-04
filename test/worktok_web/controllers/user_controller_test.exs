defmodule WorktokWeb.UserControllerTest do
  use WorktokWeb.ConnCase

  alias Worktok.Accounts

  @create_attrs %{email: "some email", name: "some name", password_hash: "some password_hash"}
  @invalid_attrs %{email: nil, name: nil, password_hash: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs

      assert redirected_to(conn) == page_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end
  end

end
