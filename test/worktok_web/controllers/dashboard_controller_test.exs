defmodule WorktokWeb.DashboardControllerTest do
  use WorktokWeb.ConnCase

  alias Worktok.Registry.Project
  alias Worktok.Billing
  alias Worktok.Billing.Work
  alias Worktok.Billing.Invoice

  describe "index" do
    @tag login_as: "Max"
    test "renders dashboard", %{conn: conn, user: user} do
      conn = get conn, dashboard_path(conn, :index)
      assert html_response(conn, 200) =~ "Earnings"
    end
  end

  describe "add_work" do
    @tag login_as: "Max"
    test "adds work", %{conn: conn, user: user} do
      client = client_fixture(user)
      %Project{id: project_id} = project_fixture(client)

      conn1 = post conn, dashboard_path(conn, :add_work), work: %{project_id: project_id, task: "Sample", hours: "1", total: "2", worked_on: "2018-07-24"}
      assert redirected_to(conn1) == dashboard_path(conn1, :index)

      conn2 = get conn, dashboard_path(conn, :index)
      assert html_response(conn2, 200) =~ "Sample"
    end

    @tag login_as: "Max"
    test "errors out", %{conn: conn} do
      conn = post conn, dashboard_path(conn, :add_work), work: %{task: "Sample", hours: "123", total: "456", worked_on: "2018-07-24"}
      resp = html_response(conn, 200)
      assert resp =~ "No work today yet"
      assert resp =~ "Sample"
      assert resp =~ "2018-07-24"
      assert resp =~ "123"
      assert resp =~ "456"
    end
  end

  describe "delete_work" do
    @tag login_as: "Max"
    test "should remove it", %{conn: conn, user: user} do
      work = work_fixture(user, %{})

      conn = delete conn, dashboard_path(conn, :delete_work, work.id)
      assert redirected_to(conn) == dashboard_path(conn, :index)

      assert [] = Billing.list_user_works(user)
    end
  end

  describe "create_invoice" do
    @tag login_as: "Max"
    test "should create invoice with current works", %{conn: conn, user: user} do
      %Work{project_id: project_id} = work_fixture(user, %{})

      conn = post conn, dashboard_path(conn, :create_invoice, project_id)
      [%Invoice{id: invoice_id}] = Billing.list_user_invoices(user)
      assert redirected_to(conn) == invoice_path(conn, :show, invoice_id)
    end
  end
end
