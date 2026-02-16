defmodule CloseTheLoop.Workers.SendIssueUpdateSmsWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 10

  import Ash.Expr

  alias CloseTheLoop.Feedback.{IssueUpdate, Report}
  alias CloseTheLoop.Messaging.OutboundSms

  require Ash.Query

  @impl true
  def perform(%Oban.Job{} = job) do
    tenant = job.args["tenant"]
    issue_id = job.args["issue_id"]
    issue_update_id = job.args["issue_update_id"]
    message = job.args["message"]

    recipients = list_recipients(tenant, issue_id)

    Enum.each(recipients, fn phone ->
      _ = OutboundSms.queue_issue_update(tenant, issue_update_id, phone, message)
    end)

    :ok
  end

  defp list_recipients(tenant, issue_id) do
    query =
      Report
      |> Ash.Query.filter(
        expr(issue_id == ^issue_id and consent == true and not is_nil(reporter_phone))
      )
      |> Ash.Query.load([])

    case Ash.read(query, tenant: tenant) do
      {:ok, reports} ->
        reports
        |> Enum.map(& &1.reporter_phone)
        |> Enum.uniq()

      _ ->
        []
    end
  end

  # Convenience helper used by LiveView
  def enqueue(%IssueUpdate{} = update, tenant) when is_binary(tenant) do
    new(%{
      "tenant" => tenant,
      "issue_id" => update.issue_id,
      "issue_update_id" => update.id,
      "message" => update.message
    })
    |> Oban.insert()
  end
end
