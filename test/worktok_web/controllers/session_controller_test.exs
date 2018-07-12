defmodule WorktokWeb.SessionControllerTest do
  use WorktokWeb.ConnCase

  describe "new" do
    test "should render page", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end
  end

  describe "login" do
    setup %{conn: conn} do
      user = user_fixture()
      {:ok, conn: conn, user: user}
    end

    test "invalid login", %{conn: conn, user: user} do
      conn = post conn, session_path(conn, :new), session: %{email: user.credential.email, password: "invalid"}
      assert html_response(conn, 200) =~ "Invalid email/password combination"
    end

    test "valid login", %{conn: conn, user: user} do
      conn = post conn, session_path(conn, :new), session: %{email: user.credential.email, password: "supersecret"}
      assert get_flash(conn, :info) == "Welcome back!"
      assert redirected_to(conn) == page_path(conn, :index)
      assert conn.assigns.current_user != nil
    end
  end

  describe "logout" do
    @tag login_as: "max"
    test "successful", %{conn: conn} do
      conn = delete conn, session_path(conn, :delete)
      assert get_flash(conn, :info) == "Come back soon!"
      assert redirected_to(conn) == page_path(conn, :index)
      assert conn.cookies == %{}
    end
  end

end
