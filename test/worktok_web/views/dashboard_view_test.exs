defmodule WorktokWeb.DashboardViewTest do
  use WorktokWeb.ConnCase, async: true

  alias WorktokWeb.DashboardView
  alias Timex, as: T
  alias Timex.Duration, as: D

  test "day_label/1" do
    assert "Today" == DashboardView.day_label(days_ago(0))
    assert "Yesterday" == DashboardView.day_label(days_ago(1))

    for d <- 2..6 do
      t = days_ago(d)
      assert weekday(t) == DashboardView.day_label(t)
    end

    t = days_ago(7)
    assert month_date(t) == DashboardView.day_label(t)
  end

  defp days_ago(d) do
    T.subtract(T.today(), D.from_days(d))
  end

  defp weekday(t) do
    T.format!(t, "%A", :strftime)
  end

  defp month_date(t) do
    T.format!(t, "%B %d", :strftime)
  end
end
