defmodule CloseTheLoopWeb.TwilioWebhookControllerTest do
  use CloseTheLoopWeb.ConnCase, async: true

  alias CloseTheLoop.Feedback.Location

  test "accepts inbound SMS webhook and returns TwiML", %{conn: conn} do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    conn =
      post(conn, ~p"/webhooks/twilio/sms?tenant=#{tenant}&location_id=#{location.id}", %{
        "Body" => "Water is cold",
        "From" => "+15555550100"
      })

    assert conn.status == 200
    assert response(conn, 200) =~ "<Response>"
    assert response(conn, 200) =~ "Got it"
  end
end
