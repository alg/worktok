defmodule WorktokWeb.ClientControllerTest do
  use WorktokWeb.ConnCase

  @create_attrs %{active: true, email: "some email", name: "some name", prefix: "some prefix", rate: "120.5"}
  @update_attrs %{active: false, email: "some updated email", name: "some updated name", prefix: "some updated prefix", rate: "456.7"}
  @invalid_attrs %{active: nil, email: nil, name: nil, prefix: nil, rate: nil}

  describe "index" do
    @tag login_as: "Max"
    test "lists all clients", %{conn: conn} do
      conn = get conn, client_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Clients"
    end
  end

  describe "show" do
    @tag login_as: "Max"
    test "showing client", %{conn: conn, user: user} do
      client = client_fixture(user)
      conn = get conn, client_path(conn, :show, client)
      assert html_response(conn, 200) =~ "Show Client"
    end
  end

  describe "new client" do
    @tag login_as: "Max"
    test "renders form", %{conn: conn} do
      conn = get conn, client_path(conn, :new)
      assert html_response(conn, 200) =~ "New Client"
    end
  end

  describe "create client" do
    @tag login_as: "Max"
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, client_path(conn, :create), client: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == client_path(conn, :show, id)
    end

    @tag login_as: "Max"
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, client_path(conn, :create), client: @invalid_attrs
      assert html_response(conn, 200) =~ "New Client"
    end
  end

  describe "edit client" do
    @tag login_as: "Max"
    test "renders form for editing chosen client", %{conn: conn, user: user} do
      client = client_fixture(user)
      conn = get conn, client_path(conn, :edit, client)
      assert html_response(conn, 200) =~ "Edit Client"
    end
  end

  describe "update client" do
    @tag login_as: "Max"
    test "redirects when data is valid", %{conn: conn, user: user} do
      client = client_fixture(user)
      conn = put conn, client_path(conn, :update, client), client: @update_attrs
      assert redirected_to(conn) == client_path(conn, :show, client)
    end

    @tag login_as: "Max"
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      client = client_fixture(user)
      conn = put conn, client_path(conn, :update, client), client: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Client"
    end
  end

  describe "delete client" do
    @tag login_as: "Max"
    test "deletes chosen client", %{conn: conn, user: user} do
      client = client_fixture(user)
      conn = delete conn, client_path(conn, :delete, client)
      assert redirected_to(conn) == client_path(conn, :index)
      assert_raise Ecto.NoResultsError, fn ->
        Worktok.Registry.get_user_client!(user, client.id)
      end
    end

    @tag login_as: "Max"
    test "can't complete", %{conn: conn, user: user} do
      client = client_fixture(user)
      project_fixture(client)
      conn = delete conn, client_path(conn, :delete, client)
      assert redirected_to(conn) == client_path(conn, :index)
      assert get_flash(conn, :error) =~ ~r/Could not delete client/
    end
  end

end
