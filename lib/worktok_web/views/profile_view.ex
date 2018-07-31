defmodule WorktokWeb.ProfileView do
  use WorktokWeb, :view

  def join_non_blank(list, separator) do
    list
    |> Enum.reject(fn x -> x == nil or x == "" end)
    |> Enum.join(separator)
  end
end
