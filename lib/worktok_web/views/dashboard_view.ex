defmodule WorktokWeb.DashboardView do
  use WorktokWeb, :view

  def day_label(date) do
    today = Date.utc_today()
    cond do
      date == today ->
        "Today"

      date == Date.add(today, -1) ->
        "Yesterday"

      date > Date.add(today, -7) ->
        Timex.format!(date, "%A", :strftime)

      true ->
        Timex.format!(date, "%B %d", :strftime)
    end
  end

end
