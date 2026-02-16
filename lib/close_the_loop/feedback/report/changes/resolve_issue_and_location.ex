defmodule CloseTheLoop.Feedback.Report.Changes.ResolveIssueAndLocation do
  @moduledoc false

  use Ash.Resource.Change

  import Ash.Expr

  alias CloseTheLoop.Feedback.Issue
  alias CloseTheLoop.Workers.{CategorizeIssueWorker, DedupeIssueWorker}

  require Ash.Query

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
        resolve_or_create_issue(changeset, tenant, location_id, normalized_body)
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

  defp resolve_or_create_issue(changeset, tenant, location_id, normalized_body)
       when is_binary(tenant) and not is_nil(location_id) do
    query =
      Issue
      |> Ash.Query.filter(
        expr(
          location_id == ^location_id and status != :fixed and
            normalized_description == ^normalized_body and is_nil(duplicate_of_issue_id)
        )
      )
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(1)

    case Ash.read_one(query, tenant: tenant) do
      {:ok, %Issue{} = issue} ->
        changeset
        |> Ash.Changeset.force_change_attribute(:issue_id, issue.id)
        |> Ash.Changeset.force_change_attribute(:location_id, issue.location_id)

      {:ok, nil} ->
        create_new_issue(changeset, tenant, location_id, normalized_body)

      {:error, err} ->
        message = error_message(err)

        Ash.Changeset.add_error(changeset,
          field: :issue_id,
          message: "Failed to resolve issue: #{message}"
        )
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
    |> String.slice(0, 80)
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
