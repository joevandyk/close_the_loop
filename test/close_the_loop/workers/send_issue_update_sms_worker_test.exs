defmodule CloseTheLoop.Workers.SendIssueUpdateSmsWorkerTest do
  use CloseTheLoop.DataCase, async: true

  import Ash.Expr
  require Ash.Query

  alias CloseTheLoop.Feedback.{Issue, IssueUpdate, Location, Report}
  alias CloseTheLoop.Messaging.OutboundDelivery
  alias CloseTheLoop.Workers.SendIssueUpdateSmsWorker
  alias CloseTheLoop.Workers.SendOutboundDeliveryWorker

  test "records noop delivery per unique recipient when twilio env is missing" do
    tenant = "public"

    twilio_keys = ["TWILIO_PHONE_NUMBER", "TWILIO_ACCOUNT_SID", "TWILIO_AUTH_TOKEN"]
    previous = Map.new(twilio_keys, fn k -> {k, System.get_env(k)} end)

    Enum.each(twilio_keys, &System.delete_env/1)

    on_exit(fn ->
      Enum.each(previous, fn {k, v} ->
        if is_binary(v), do: System.put_env(k, v), else: System.delete_env(k)
      end)
    end)

    {:ok, location} =
      Ash.create(Location, %{name: "Gym", full_path: "Gym"}, tenant: tenant, authorize?: false)

    {:ok, issue} =
      Ash.create(
        Issue,
        %{
          title: "Broken shower",
          description: "Water is cold",
          normalized_description: "water is cold",
          location_id: location.id
        },
        tenant: tenant,
        authorize?: false
      )

    # Two reports share the same phone number; we should send (and record) only once per recipient.
    {:ok, _r1} =
      Ash.create(
        Report,
        %{
          body: "Report 1",
          source: :sms,
          reporter_phone: "+15555550100",
          consent: true,
          location_id: location.id,
          issue_id: issue.id
        },
        tenant: tenant,
        authorize?: false
      )

    {:ok, _r2} =
      Ash.create(
        Report,
        %{
          body: "Report 2",
          source: :sms,
          reporter_phone: "+15555550100",
          consent: true,
          location_id: location.id,
          issue_id: issue.id
        },
        tenant: tenant,
        authorize?: false
      )

    {:ok, _r3} =
      Ash.create(
        Report,
        %{
          body: "Report 3",
          source: :sms,
          reporter_phone: "+15555550200",
          consent: true,
          location_id: location.id,
          issue_id: issue.id
        },
        tenant: tenant,
        authorize?: false
      )

    {:ok, issue_update} =
      Ash.create(
        IssueUpdate,
        %{issue_id: issue.id, message: "We are working on it"},
        tenant: tenant,
        authorize?: false
      )

    job = %Oban.Job{
      args: %{
        "tenant" => tenant,
        "issue_id" => issue.id,
        "issue_update_id" => issue_update.id,
        "message" => issue_update.message
      }
    }

    assert :ok = SendIssueUpdateSmsWorker.perform(job)

    query =
      OutboundDelivery
      |> Ash.Query.filter(expr(channel == :sms and template == "issue_update"))

    {:ok, deliveries} = Ash.read(query, authorize?: false)

    assert Enum.sort(Enum.map(deliveries, & &1.to)) ==
             Enum.sort(["+15555550100", "+15555550200"])

    assert Enum.all?(deliveries, &(&1.status == :queued))

    Enum.each(deliveries, fn delivery ->
      assert :ok =
               SendOutboundDeliveryWorker.perform(%Oban.Job{
                 args: %{"delivery_id" => delivery.id}
               })
    end)

    {:ok, deliveries_after} = Ash.read(query, authorize?: false)
    assert Enum.all?(deliveries_after, &(&1.status == :noop))
  end
end
