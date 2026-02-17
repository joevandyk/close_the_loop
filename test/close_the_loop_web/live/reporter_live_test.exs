defmodule CloseTheLoopWeb.ReporterLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CloseTheLoop.Feedback.Location
  alias CloseTheLoop.Feedback.Report

  test "reporter can submit a QR report", %{conn: conn} do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, view, _html} = live(conn, ~p"/r/#{tenant}/#{location.id}")

    body = "Cold shower #{System.unique_integer([:positive])}"

    view
    |> form("#reporter-intake-form", report: %{body: body})
    |> render_submit()

    assert render(view) =~ "Got it"

    {:ok, reports} = Ash.read(Report, tenant: tenant)
    report = Enum.find(reports, fn r -> r.body == body end)

    assert report
    assert report.location_id == location.id
    assert report.source == :qr
  end

  test "reporter can submit a manual report via URL variant", %{conn: conn} do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, view, _html} = live(conn, ~p"/r/#{tenant}/#{location.id}/manual")

    body = "Manual report #{System.unique_integer([:positive])}"

    view
    |> form("#reporter-intake-form", report: %{body: body})
    |> render_submit()

    assert render(view) =~ "Got it"

    {:ok, reports} = Ash.read(Report, tenant: tenant)
    report = Enum.find(reports, fn r -> r.body == body end)

    assert report
    assert report.location_id == location.id
    assert report.source == :manual
  end
end
