defmodule CloseTheLoopWeb.TwilioWebhookController do
  use CloseTheLoopWeb, :controller

  alias CloseTheLoop.Feedback, as: FeedbackDomain

  @doc """
  Inbound SMS webhook (Twilio).

  MVP convention: configure the webhook URL with query params:
    /webhooks/twilio/sms?tenant=org_...&location_id=...
  """
  def sms(conn, params) do
    tenant = params["tenant"] || conn.query_params["tenant"]
    location_id = params["location_id"] || conn.query_params["location_id"]
    body = params["Body"] || ""
    from = params["From"]

    with true <- (is_binary(tenant) and tenant != "") || {:error, "Missing tenant"},
         true <-
           (is_binary(location_id) and location_id != "") || {:error, "Missing location_id"},
         {:ok, _} <-
           FeedbackDomain.create_report(
             %{
               location_id: location_id,
               body: body,
               source: :sms,
               reporter_phone: from,
               consent: true
             },
             tenant: tenant,
             actor: nil
           ) do
      twiml_ok(conn)
    else
      _ ->
        twiml_error(conn)
    end
  end

  defp twiml_ok(conn) do
    twiml =
      ~s(<?xml version="1.0" encoding="UTF-8"?><Response><Message>Got it. We’ll update you.</Message></Response>)

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, twiml)
  end

  defp twiml_error(conn) do
    twiml =
      ~s(<?xml version="1.0" encoding="UTF-8"?><Response><Message>Sorry — we could not process that message.</Message></Response>)

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, twiml)
  end
end
