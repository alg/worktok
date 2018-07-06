defmodule WorktokWeb.ProjectControllerTest do
  use WorktokWeb.ConnCase

  alias Worktok.Registry

  @create_attrs %{active: true, name: "some name", prefix: "some prefix", rate: "120.5"}
  @update_attrs %{active: false, name: "some updated name", prefix: "some updated prefix", rate: "456.7"}
  @invalid_attrs %{active: nil, name: nil, prefix: nil, rate: nil}

  def fixture(:project) do
    {:ok, project} = Registry.create_project(@create_attrs)
    project
  end

  describe "index" do
    @tag login_as: "Max"
    test "lists all projects", %{conn: conn} do
      conn = get conn, project_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Projects"
    end
  end

  describe "new project" do
    @tag login_as: "Max"
    test "renders form", %{conn: conn} do
      conn = get conn, project_path(conn, :new)
      assert html_response(conn, 200) =~ "New Project"
    end
  end

  describe "create project" do
    @tag login_as: "Max"
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      client = insert_client(user)
      conn = post conn, project_path(conn, :create), project: Enum.into(%{client_id: client.id}, @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == project_path(conn, :show, id)
    end

    @tag login_as: "Max"
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, project_path(conn, :create), project: @invalid_attrs
      assert html_response(conn, 200) =~ "New Project"
    end
  end

  describe "edit project" do
    setup [:create_project]

    @tag login_as: "Max"
    test "renders form for editing chosen project", %{conn: conn, project: project} do
      conn = get conn, project_path(conn, :edit, project)
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "update project" do
    setup [:create_project]

    @tag login_as: "Max"
    test "redirects when data is valid", %{conn: conn, project: project} do
      conn = put conn, project_path(conn, :update, project), project: @update_attrs
      assert redirected_to(conn) == project_path(conn, :show, project)
    end

    @tag login_as: "Max"
    test "renders errors when data is invalid", %{conn: conn, project: project} do
      conn = put conn, project_path(conn, :update, project), project: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Project"
    end
  end

  describe "delete project" do
    setup [:create_project]

    @tag login_as: "Max"
    test "deletes chosen project", %{conn: conn, project: project} do
      conn = delete conn, project_path(conn, :delete, project)
      assert redirected_to(conn) == project_path(conn, :index)
      assert_raise Ecto.NoResultsError, fn ->
        Worktok.Registry.get_project!(project.id)
      end
    end
  end

  defp create_project(%{user: user}) do
    client = insert_client(user)
    project = insert_project(client)
    {:ok, project: project, client: client}
  end
end
