defmodule WorktokWeb.Errors do

  # Returns the list of full-text messages concatenating the names of fields
  # and error messages taken from the changeset errors.
  #
  # Field names are translated using Gettext's "schema" domain. The key is
  # formed from the name of the data structure (MyApp.MyContext.MyModel,
  # for example: MyApp.Accounts.User) and the name of the field the error
  # is related too (for `email` it becomes `MyApp.Accounts.User.email`
  def full_messages(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&full_message/3)
    |> Enum.flat_map(&elem(&1, 1))
  end

  defp full_message(%Ecto.Changeset{} = changeset, key, error) do
    module_name = inspect(changeset.data.__struct__)
    key_path = "#{module_name}.#{key}"
    key_name = case Gettext.dgettext(WorktokWeb.Gettext, "schema", key_path) do
      ^key_path -> key
      n -> n
    end

    "#{key_name} #{WorktokWeb.ErrorHelpers.translate_error(error)}"
  end
end
