defmodule CloseTheLoop.Feedback.IssueUpdateInput.Changes.PerformUpdates do
  @moduledoc false

  use Ash.Resource.Change

  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.Issue

  @impl true
  def change(changeset, _opts, context) do
    tenant = context.tenant || changeset.tenant
    actor = context.actor

    Ash.Changeset.after_action(changeset, fn changeset, result ->
      issue = changeset.context[:issue]
      status = Ash.Changeset.get_argument(changeset, :status)
      comment_body = Ash.Changeset.get_argument(changeset, :comment_body)

      with %Issue{} <- issue || {:error, :missing_issue},
           :ok <- maybe_set_status(issue, status, tenant, actor),
           :ok <- maybe_add_comment(issue, comment_body, tenant, actor) do
        {:ok, result}
      else
        {:error, :missing_issue} -> {:error, "Missing issue context"}
        {:error, err} -> {:error, err}
      end
    end)
  end

  defp maybe_set_status(_issue, nil, _tenant, _actor), do: :ok

  defp maybe_set_status(%Issue{} = issue, status, tenant, actor) when is_atom(status) do
    with true <- status != issue.status || {:ok, :no_change},
         {:ok, _updated_issue} <-
           Feedback.set_issue_status(issue, %{status: status},
             tenant: tenant,
             actor: actor,
             context: %{
               ash_events_metadata: %{
                 "changes" => %{
                   "status" => %{
                     "from" => to_string(issue.status),
                     "to" => to_string(status)
                   }
                 }
               }
             }
           ) do
      :ok
    else
      {:ok, :no_change} -> :ok
      {:error, err} -> {:error, err}
    end
  end

  defp maybe_add_comment(_issue, nil, _tenant, _actor), do: :ok

  defp maybe_add_comment(%Issue{} = issue, body, tenant, actor) when is_binary(body) do
    attrs = %{
      issue_id: issue.id,
      body: body,
      author_user_id: actor && Map.get(actor, :id),
      author_email: actor && to_string(Map.get(actor, :email))
    }

    case Feedback.create_issue_comment(attrs, tenant: tenant, actor: actor) do
      {:ok, _comment} -> :ok
      {:error, err} -> {:error, err}
    end
  end
end
