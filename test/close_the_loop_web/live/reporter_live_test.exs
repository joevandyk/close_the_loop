defmodule CloseTheLoopWeb.ReporterLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CloseTheLoop.Feedback.Location

  test "reporter can submit a QR report", %{conn: conn} do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, view, _html} = live(conn, ~p"/r/#{tenant}/#{location.id}")

    view
    |> form("#reporter-intake-form", report: %{body: "Cold shower"})
    |> render_submit()

    assert render(view) =~ "Got it"
  end
end
