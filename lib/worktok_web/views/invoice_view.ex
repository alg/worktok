defmodule WorktokWeb.InvoiceView do
  use WorktokWeb, :view

  alias Worktok.Accounts.{User,Profile,BillingAddress}
  alias Worktok.Billing.Invoice

  def billing_address(%User{profile: nil}), do: ""
  def billing_address(%User{profile: %Profile{billing_address: nil}}), do: ""
  def billing_address(%User{profile: %Profile{billing_address: ba = %BillingAddress{}}}) do
    [ strong(ba.name),
      ba.street,
      [ba.zip, ba.city] |> join(", "),
      [ba.state, ba.country] |> join(", "),
      ba.email,
      ba.phone
    ] |> join("<br/>")
  end

  def invoice_row_class(%Invoice{paid_on: nil}), do: ""
  def invoice_row_class(%Invoice{}), do: "table-success"

  defp strong(nil), do: nil
  defp strong(v), do: "<strong>#{v}</strong>"

  defp join(list, sep) do
    list
    |> Enum.reject(fn x -> x == nil or x == "" end)
    |> Enum.join(sep)
  end

end
