defmodule CloseTheLoop.DevSeeds do
  @moduledoc """
  Dev seeding helpers.

  Best practice with Ash is to seed via Ash actions (and pass `tenant:` for
  tenant-scoped resources) instead of inserting directly via `Repo`.
  """

  import Ash.Expr

  require Ash.Query

  alias CloseTheLoop.Accounts.User
  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.{Issue, IssueCategory, IssueComment, IssueUpdate, Location, Report}
  alias CloseTheLoop.Tenants.Organization

  @default_tenant_schema "org_demo"
  @default_org_name "Demo Organization"
  @dev_user_email "asdf@asdf.com"
  @dev_user_password "asdfasdf"

  @doc """
  Seeds a demo organization (public schema) and demo tenant data.

  Options:
  - `:tenant_schema` - the Postgres schema name (default: #{inspect(@default_tenant_schema)})
  - `:organization_name` - display name (default: #{inspect(@default_org_name)})
  """
  @spec run(keyword()) :: Organization.t()
  def run(opts \\ []) do
    tenant_schema =
      Keyword.get(opts, :tenant_schema) ||
        System.get_env("SEED_TENANT_SCHEMA", @default_tenant_schema)

    org_name =
      Keyword.get(opts, :organization_name) ||
        System.get_env("SEED_ORG_NAME", @default_org_name)

    org = ensure_organization!(tenant_schema, org_name)

    seed_tenant!(org.tenant_schema)

    org
  end

  defp ensure_organization!(tenant_schema, org_name) when is_binary(tenant_schema) do
    case get_organization_by_schema(tenant_schema) do
      {:ok, %Organization{} = org} ->
        # Keep name in sync with the seed defaults without creating duplicates.
        if org.name == org_name do
          org
        else
          Ash.update!(org, %{name: org_name}, action: :update)
        end

      {:ok, nil} ->
        Ash.create!(Organization, %{
          name: org_name,
          tenant_schema: tenant_schema,
          ai_business_context:
            "A demo environment for staff to triage and close the loop on facility feedback.",
          ai_categorization_instructions:
            "Prefer specific categories. When unsure, use `other` and add a short note to internal context."
        })

      {:error, error} ->
        raise "Failed to look up organization for seed: #{inspect(error)}"
    end
  end

  defp get_organization_by_schema(tenant_schema) do
    Organization
    |> Ash.Query.filter(tenant_schema == ^tenant_schema)
    |> Ash.read_one()
  end

  @doc """
  Ensures a dev user exists, confirmed and attached to the given organization as owner.

  Returns `%{email: email, password: password}` for printing login instructions.
  Override with `DEV_USER_EMAIL` and `DEV_USER_PASSWORD` env vars.
  """
  @spec ensure_dev_user!(Organization.t()) :: %{email: String.t(), password: String.t()}
  def ensure_dev_user!(org) do
    email = System.get_env("DEV_USER_EMAIL", @dev_user_email)
    password = System.get_env("DEV_USER_PASSWORD", @dev_user_password)
    now = DateTime.utc_now()

    user =
      case User
           |> Ash.Query.for_read(:get_by_email, %{email: email})
           |> Ash.read_one(authorize?: false) do
        {:ok, %User{} = existing} ->
          existing
          |> Ash.update!(%{confirmed_at: now}, action: :set_confirmed_at, authorize?: false)
          |> then(
            &Ash.update!(&1, %{organization_id: org.id, role: :owner},
              action: :set_organization,
              authorize?: false
            )
          )
          |> then(
            &Ash.update!(&1, %{name: "Demo Owner"}, action: :update_profile, authorize?: false)
          )

        {:ok, nil} ->
          User
          |> Ash.create!(%{email: email, password: password, password_confirmation: password},
            action: :register_with_password,
            authorize?: false
          )
          |> then(
            &Ash.update!(&1, %{confirmed_at: now}, action: :set_confirmed_at, authorize?: false)
          )
          |> then(
            &Ash.update!(&1, %{organization_id: org.id, role: :owner},
              action: :set_organization,
              authorize?: false
            )
          )
          |> then(
            &Ash.update!(&1, %{name: "Demo Owner"}, action: :update_profile, authorize?: false)
          )

        {:error, error} ->
          raise "Failed to ensure dev user: #{inspect(error)}"
      end

    %{email: user.email, password: password}
  end

  defp seed_tenant!(tenant) when is_binary(tenant) do
    :ok = Feedback.Categories.ensure_defaults(tenant)
    :ok = seed_issue_category_guidance!(tenant)

    locations = seed_locations!(tenant)
    seed_inbox_examples!(tenant, locations)

    :ok
  end

  defp seed_locations!(tenant) do
    facility = ensure_location!(tenant, "Demo Facility", nil)
    locker_rooms = ensure_location!(tenant, "Locker Rooms", facility)
    mens = ensure_location!(tenant, "Mens Locker Room", locker_rooms)
    womens = ensure_location!(tenant, "Womens Locker Room", locker_rooms)
    pool = ensure_location!(tenant, "Pool", facility)
    front_desk = ensure_location!(tenant, "Front Desk", facility)

    %{
      facility: facility,
      locker_rooms: locker_rooms,
      mens: mens,
      womens: womens,
      pool: pool,
      front_desk: front_desk
    }
  end

  defp ensure_location!(tenant, name, nil) do
    full_path = name

    case Location |> Ash.Query.filter(full_path == ^full_path) |> Ash.read_one(tenant: tenant) do
      {:ok, %Location{} = location} ->
        location

      {:ok, nil} ->
        Ash.create!(Location, %{name: name, full_path: full_path}, tenant: tenant)

      {:error, error} ->
        raise "Failed to seed location #{inspect(full_path)}: #{inspect(error)}"
    end
  end

  defp ensure_location!(tenant, name, %Location{} = parent) do
    parent_full_path = parent.full_path || parent.name
    full_path = parent_full_path <> " / " <> name

    case Location |> Ash.Query.filter(full_path == ^full_path) |> Ash.read_one(tenant: tenant) do
      {:ok, %Location{} = location} ->
        location

      {:ok, nil} ->
        Ash.create!(
          Location,
          %{name: name, full_path: full_path, parent_id: parent.id},
          tenant: tenant
        )

      {:error, error} ->
        raise "Failed to seed location #{inspect(full_path)}: #{inspect(error)}"
    end
  end

  defp seed_issue_category_guidance!(tenant) do
    # Defaults are created by `Feedback.Categories.ensure_defaults/1`.
    # Here we add a little guidance so the settings UI looks realistic in dev.
    guidance = %{
      "plumbing" => %{
        description: "Water, drains, toilets, showers, sinks, leaks.",
        ai_include_keywords:
          "leak, dripping, clogged, toilet, shower, sink, faucet, water pressure",
        ai_exclude_keywords: "light, bulb, outlet, power"
      },
      "electrical" => %{
        description: "Lighting, outlets, breakers, power issues.",
        ai_include_keywords: "light, bulb, outlet, power, breaker, flicker",
        ai_exclude_keywords: "leak, clogged"
      },
      "cleaning" => %{
        description: "Trash, spills, odors, bathroom cleanliness.",
        ai_include_keywords: "trash, spill, smell, dirty, sticky, mop",
        ai_exclude_keywords: nil
      }
    }

    Enum.each(guidance, fn {key, attrs} ->
      cat =
        IssueCategory
        |> Ash.Query.filter(key == ^key)
        |> Ash.read_one!(tenant: tenant)

      if cat do
        _ = Ash.update(cat, attrs, action: :update, tenant: tenant)
      end
    end)

    :ok
  end

  defp seed_inbox_examples!(tenant, locations) do
    issue1 =
      ensure_issue!(
        tenant,
        locations.mens,
        "Cold water in the men's showers",
        %{status: :new, category: "plumbing"}
      )

    _report1 =
      ensure_report!(
        tenant,
        issue1,
        locations.mens,
        "Cold water in the men's showers. Started this morning around 7am.",
        %{source: :qr, reporter_phone: "+15555550123", consent: true}
      )

    _ = ensure_issue_update!(tenant, issue1, "Thanks - we are on it.")

    issue2 =
      ensure_issue!(
        tenant,
        locations.pool,
        "Broken overhead light by the pool entrance",
        %{status: :in_progress, category: "electrical"}
      )

    _report2 =
      ensure_report!(
        tenant,
        issue2,
        locations.pool,
        "The overhead light by the pool entrance has been out for two days.",
        %{source: :sms, reporter_phone: "+15555550124", consent: false}
      )

    issue3 =
      ensure_issue!(
        tenant,
        locations.front_desk,
        "Trash overflowing near the front desk",
        %{status: :acknowledged, category: "cleaning"}
      )

    _report3 =
      ensure_report!(
        tenant,
        issue3,
        locations.front_desk,
        "Trash can overflowing near the front desk and smells bad.",
        %{source: :qr}
      )

    _ =
      ensure_issue_comment!(
        tenant,
        issue3,
        "Noted - asked the cleaning crew to prioritize this today.",
        %{author_email: "demo_owner@example.com"}
      )

    :ok
  end

  defp ensure_issue!(tenant, %Location{} = location, description, extra_attrs)
       when is_binary(description) and is_map(extra_attrs) do
    normalized = normalize_text(description)

    query =
      Issue
      |> Ash.Query.filter(
        expr(
          location_id == ^location.id and normalized_description == ^normalized and
            is_nil(duplicate_of_issue_id)
        )
      )
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(1)

    case Ash.read_one(query, tenant: tenant) do
      {:ok, %Issue{} = issue} ->
        issue

      {:ok, nil} ->
        attrs =
          %{
            location_id: location.id,
            title: build_title(description),
            description: description,
            normalized_description: normalized
          }
          |> Map.merge(extra_attrs)

        Ash.create!(Issue, attrs, tenant: tenant)

      {:error, error} ->
        raise "Failed to seed issue: #{inspect(error)}"
    end
  end

  defp ensure_report!(tenant, %Issue{} = issue, %Location{} = location, body, extra_attrs)
       when is_binary(body) and is_map(extra_attrs) do
    normalized = normalize_text(body)

    query =
      Report
      |> Ash.Query.filter(expr(issue_id == ^issue.id and normalized_body == ^normalized))
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(1)

    case Ash.read_one(query, tenant: tenant) do
      {:ok, %Report{} = report} ->
        report

      {:ok, nil} ->
        attrs =
          %{
            location_id: location.id,
            issue_id: issue.id,
            body: body,
            normalized_body: normalized
          }
          |> Map.merge(extra_attrs)
          |> Map.put_new(:source, :qr)
          |> Map.put_new(:consent, false)

        Ash.create!(Report, attrs, tenant: tenant)

      {:error, error} ->
        raise "Failed to seed report: #{inspect(error)}"
    end
  end

  defp ensure_issue_update!(tenant, %Issue{} = issue, message) when is_binary(message) do
    query =
      IssueUpdate
      |> Ash.Query.filter(expr(issue_id == ^issue.id and message == ^message))
      |> Ash.Query.limit(1)

    case Ash.read_one(query, tenant: tenant) do
      {:ok, %IssueUpdate{} = update} ->
        update

      {:ok, nil} ->
        Ash.create!(
          IssueUpdate,
          %{issue_id: issue.id, message: message, sent_at: DateTime.utc_now()},
          tenant: tenant
        )

      {:error, error} ->
        raise "Failed to seed issue update: #{inspect(error)}"
    end
  end

  defp ensure_issue_comment!(tenant, %Issue{} = issue, body, extra_attrs)
       when is_binary(body) and is_map(extra_attrs) do
    query =
      IssueComment
      |> Ash.Query.filter(expr(issue_id == ^issue.id and body == ^body))
      |> Ash.Query.limit(1)

    case Ash.read_one(query, tenant: tenant) do
      {:ok, %IssueComment{} = comment} ->
        comment

      {:ok, nil} ->
        attrs =
          %{issue_id: issue.id, body: body}
          |> Map.merge(extra_attrs)

        Ash.create!(IssueComment, attrs, tenant: tenant)

      {:error, error} ->
        raise "Failed to seed issue comment: #{inspect(error)}"
    end
  end

  defp build_title(body) do
    body
    |> String.trim()
    |> String.slice(0, 80)
    |> case do
      "" -> "New report"
      title -> title
    end
  end

  defp normalize_text(text) when is_binary(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, " ")
    |> String.trim()
  end
end
