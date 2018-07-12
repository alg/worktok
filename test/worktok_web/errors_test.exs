defmodule WorktokWeb.ErrorsTest do
  use Worktok.DataCase

  alias Worktok.Registry.Client

  test "without errors" do
    ch = Client.delete_changeset(%Client{})
    assert WorktokWeb.Errors.full_messages(ch) == []
  end

  test "with errors" do
    ch =
      Client.delete_changeset(%Client{})
      |> Ecto.Changeset.add_error(:projects, "still exist")

    assert WorktokWeb.Errors.full_messages(ch) == ["Projects still exist"]
  end

  test "with errors with no translation for key" do
    ch =
      Client.delete_changeset(%Client{})
      |> Ecto.Changeset.add_error(:magic, "still exist")

    assert WorktokWeb.Errors.full_messages(ch) == ["magic still exist"]
  end
end
