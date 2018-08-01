defmodule WorktokWeb.InvoiceViewTest do
  use WorktokWeb.ConnCase, async: true

  alias WorktokWeb.InvoiceView
  alias Worktok.Accounts.{User,Profile,BillingAddress}
  alias Worktok.Billing.Invoice

  describe "billing_address/1" do
    test "when no progile" do
      assert InvoiceView.billing_address(%User{profile: nil}) == ""
    end

    test "when no billing address" do
      assert InvoiceView.billing_address(%User{profile: %Profile{billing_address: nil}}) == ""
    end

    test "with full billing address" do
      ba = %BillingAddress{
        name: "John Smith",
        street: "1 Main Str",
        zip: "3505",
        city: "Exampleville",
        state: "Stateus",
        country: "Countrius",
        email: "john@smith.com",
        phone: "89991234567"
      }
      assert InvoiceView.billing_address(%User{profile: %Profile{billing_address: ba}}) ==
        "<strong>" <> ba.name <> "</strong><br/>" <>
        ba.street <> "<br/>" <>
        ba.zip <> ", " <> ba.city <> "<br/>" <>
        ba.state <> ", " <> ba.country <> "<br/>" <>
        ba.email <> "<br/>" <>
        ba.phone
    end

    test "with empty billing address" do
      assert InvoiceView.billing_address(%User{profile: %Profile{billing_address: %BillingAddress{}}}) == ""
    end
  end


  describe "invoice_row_class/1" do
    test "unpaid invoice" do
      assert InvoiceView.invoice_row_class(%Invoice{paid_on: nil}) == ""
    end

    test "paid invoice" do
      assert InvoiceView.invoice_row_class(%Invoice{paid_on: Timex.now()}) == "table-success"
    end
  end
end
