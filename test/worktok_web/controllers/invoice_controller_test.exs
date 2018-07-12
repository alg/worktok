defmodule WorktokWeb.InvoiceControllerTest do
  use WorktokWeb.ConnCase

  describe "index" do
    @tag login_as: "Max"
    test "lists all invoices", %{conn: conn} do
      conn = get conn, invoice_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Invoices"
    end
  end

  describe "show" do
    setup [:create_invoice]

    @tag login_as: "Max"
    test "shows invoice details", %{conn: conn, invoice: invoice} do
      conn = get conn, invoice_path(conn, :show, invoice)
      assert html_response(conn, 200) =~ "Show Invoice"
    end
  end

  describe "delete invoice" do
    setup [:create_invoice]

    @tag login_as: "Max"
    test "deletes chosen invoice", %{conn: conn, user: user, invoice: invoice} do
      conn = delete conn, invoice_path(conn, :delete, invoice)
      assert redirected_to(conn) == invoice_path(conn, :index)
      assert_raise Ecto.NoResultsError, fn ->
        Worktok.Billing.get_user_invoice!(user, invoice.id)
      end
    end
  end

  defp create_invoice(%{user: user}) do
    client = client_fixture(user)
    project = project_fixture(client)
    invoice = invoice_fixture(user, project)

    {:ok, invoice: invoice}
  end
end
