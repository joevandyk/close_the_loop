defmodule CloseTheLoop.Feedback.Report.Changes.ResolveIssueAndLocation do
  @moduledoc false

  use Ash.Resource.Change

  alias CloseTheLoop.Feedback.Issue
  alias CloseTheLoop.Workers.{CategorizeIssueWorker, DedupeIssueWorker}

  @impl true
  def change(changeset, _opts, context) do
    tenant = context.tenant || changeset.tenant

    issue_id = Ash.Changeset.get_attribute(changeset, :issue_id)
    location_id = Ash.Changeset.get_attribute(changeset, :location_id)
    normalized_body = Ash.Changeset.get_attribute(changeset, :normalized_body)

    cond do
      is_nil(tenant) ->
        # All report creates are tenant-scoped.
        Ash.Changeset.add_error(changeset, field: :location_id, message: "Missing tenant")

      not is_nil(issue_id) ->
        validate_and_force_issue_location(changeset, tenant, issue_id, location_id)

      is_nil(location_id) ->
        Ash.Changeset.add_error(changeset, field: :location_id, message: "Location is required")

      normalized_body in [nil, ""] ->
        # Don't query or create issues when the report body is empty/invalid.
        changeset

      true ->
        # Manual dedupe (exact body matching) causes surprising behavior when reporters
        # scan a QR code at one location to report an issue about another location.
        # Always create a new issue unless the caller explicitly picked an existing issue.
        #
        # Important: AshPhoenix forms call validate before submit. Changes run during
        # validation, so we must not create records directly in `change/3` or we'd
        # create duplicate issues. Instead, create the issue only right before the
        # action runs.
        Ash.Changeset.before_action(changeset, fn changeset ->
          tenant = changeset.tenant
          location_id = Ash.Changeset.get_attribute(changeset, :location_id)
          normalized_body = Ash.Changeset.get_attribute(changeset, :normalized_body)

          create_new_issue(changeset, tenant, location_id, normalized_body)
        end)
    end
  end

  defp validate_and_force_issue_location(changeset, tenant, issue_id, location_id) do
    case Ash.get(Issue, issue_id, tenant: tenant) do
      {:ok, %Issue{} = issue} ->
        if location_id && to_string(location_id) != to_string(issue.location_id) do
          Ash.Changeset.add_error(changeset,
            field: :issue_id,
            message: "Selected issue does not match the location"
          )
        else
          changeset
          |> Ash.Changeset.force_change_attribute(:issue_id, issue.id)
          |> Ash.Changeset.force_change_attribute(:location_id, issue.location_id)
        end

      _ ->
        Ash.Changeset.add_error(changeset, field: :issue_id, message: "Issue not found")
    end
  end

  defp create_new_issue(changeset, tenant, location_id, normalized_body) do
    body = Ash.Changeset.get_attribute(changeset, :body) || ""

    case Ash.create(
           Issue,
           %{
             location_id: location_id,
             title: build_title(body),
             description: body,
             normalized_description: normalized_body,
             status: :new
           },
           tenant: tenant
         ) do
      {:ok, %Issue{} = issue} ->
        # Best-effort async AI categorization + dedupe.
        _ = Oban.insert(CategorizeIssueWorker.new(%{tenant: tenant, issue_id: issue.id}))
        _ = Oban.insert(DedupeIssueWorker.new(%{tenant: tenant, issue_id: issue.id}))

        changeset
        |> Ash.Changeset.force_change_attribute(:issue_id, issue.id)
        |> Ash.Changeset.force_change_attribute(:location_id, issue.location_id)

      {:error, err} ->
        message = error_message(err)

        Ash.Changeset.add_error(changeset,
          field: :issue_id,
          message: "Failed to create issue: #{message}"
        )
    end
  end

  defp build_title(body) when is_binary(body) do
    body
    |> String.trim()
    # Keep the full title content; UI can clamp, but we shouldn't silently
    # truncate what we persist.
    |> String.replace(~r/\s+/u, " ")
    |> case do
      "" -> "New report"
      title -> title
    end
  end

  defp error_message(err) do
    if Kernel.is_exception(err) do
      Exception.message(err)
    else
      inspect(err)
    end
  end
end
