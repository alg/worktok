defmodule WorktokWeb.ProfileController do
  use WorktokWeb, :user_controller

  alias Worktok.Accounts.Profile

  def show(conn, _, current_user) do
    profile = Worktok.Accounts.get_profile!(current_user) |> Profile.changeset(%{})
    render(conn, "show.html", profile: profile)
  end

  def update(conn, %{"profile" => profile_params}, current_user) do
    case Worktok.Accounts.update_profile(current_user, profile_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Profile updated successfully")
        |> redirect(to: dashboard_path(conn, :index))

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Please review your profile. There was an error.")
        |> redirect(to: profile_path(conn, :show))
    end
  end
end
