defmodule CloseTheLoop.DevSeeds do
  @moduledoc """
  Dev seeding for empty databases only (e.g. `mix ecto.reset`).

  Creates organizations, tenant data, and dev users via Ash actions. No
  idempotency checks—assumes DB is empty.
  """

  import Ecto.Query

  require Ash.Query

  alias CloseTheLoop.Accounts.User
  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.{Issue, IssueCategory, IssueComment, IssueUpdate, Location, Report}
  alias CloseTheLoop.Repo
  alias CloseTheLoop.Tenants.Organization

  @dev_user_password "asdfasdf"

  @doc """
  Returns configs for all orgs: loops over each generated JSON org file in
  priv/repo/seed_fixtures (excluding orgs_config.json), loads and parses each.
  """
  def sample_org_configs do
    dir = seed_fixtures_dir()

    if File.exists?(dir) do
      dir
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".json"))
      |> Enum.reject(&(&1 == "orgs_config.json"))
      |> Enum.sort()
      |> Enum.map(fn filename -> Path.rootname(filename, ".json") end)
      |> Enum.map(&load_fixture/1)
      |> Enum.reject(&is_nil/1)
    else
      []
    end
  end

  defp seed_fixtures_dir do
    project_priv = Path.join(File.cwd!(), "priv/repo/seed_fixtures")
    code_priv = Path.join(:code.priv_dir(:close_the_loop), "repo/seed_fixtures")
    if File.exists?(project_priv), do: project_priv, else: code_priv
  end

  defp load_fixture(tenant_schema) when is_binary(tenant_schema) do
    path = Path.join(seed_fixtures_dir(), "#{tenant_schema}.json")

    if File.exists?(path) do
      path
      |> File.read!()
      |> Jason.decode!()
      |> parse_fixture(tenant_schema)
    else
      nil
    end
  end

  defp parse_fixture(
         %{"location_specs" => loc_specs, "inbox_entries" => entries} = json,
         tenant_schema
       )
       when is_list(loc_specs) and is_list(entries) do
    if blank?(json["organization_name"]) or blank?(json["ai_business_context"]) do
      nil
    else
      now = DateTime.utc_now()

      location_specs =
        Enum.map(loc_specs, fn s ->
          %{
            name: s["name"],
            parent_path: s["parent_path"]
          }
        end)

      inbox_entries =
        Enum.map(entries, fn entry ->
          parse_inbox_entry(entry, now)
        end)

      issue_category_guidance =
        parse_issue_category_guidance(Map.get(json, "issue_category_guidance"))

      %{
        tenant_schema: tenant_schema,
        organization_name: json["organization_name"],
        ai_business_context: json["ai_business_context"],
        ai_categorization_instructions: json["ai_categorization_instructions"],
        location_specs: location_specs,
        inbox_entries: inbox_entries,
        issue_category_guidance: issue_category_guidance
      }
    end
  end

  defp parse_fixture(_, _), do: nil

  defp blank?(nil), do: true
  defp blank?(s) when is_binary(s), do: String.trim(s) == ""
  defp blank?(_), do: false

  defp parse_issue_category_guidance(nil), do: %{}

  defp parse_issue_category_guidance(guidance) when is_map(guidance) do
    Enum.reduce(guidance, %{}, fn {key, val}, acc ->
      if is_map(val) do
        Map.put(acc, key, %{
          description: val["description"],
          ai_include_keywords: val["ai_include_keywords"],
          ai_exclude_keywords: val["ai_exclude_keywords"]
        })
      else
        acc
      end
    end)
  end

  # New fixture format: list of objects with a "key" field.
  defp parse_issue_category_guidance(guidance) when is_list(guidance) do
    Enum.reduce(guidance, %{}, fn item, acc ->
      if is_map(item) and is_binary(item["key"]) do
        Map.put(acc, item["key"], %{
          description: item["description"],
          ai_include_keywords: item["ai_include_keywords"],
          ai_exclude_keywords: item["ai_exclude_keywords"]
        })
      else
        acc
      end
    end)
  end

  defp parse_inbox_entry(entry, now) do
    issue = entry["issue"] || %{}
    days_ago = issue["days_ago"]
    inserted_at = if days_ago, do: DateTime.add(now, -days_ago, :day), else: nil

    issue_map = %{
      description: issue["description"],
      status: string_to_status(issue["status"]),
      category: issue["category"],
      inserted_at: inserted_at
    }

    reports = Enum.map(entry["reports"] || [], fn r -> parse_report(r, now) end)
    updates = Enum.map(entry["updates"] || [], fn u -> parse_update(u, now) end)
    comments = Enum.map(entry["comments"] || [], fn c -> parse_comment(c, now) end)

    %{
      location_full_path: entry["location_full_path"],
      issue: issue_map,
      reports: reports,
      updates: updates,
      comments: comments
    }
  end

  defp string_to_status(nil), do: :new
  defp string_to_status("new"), do: :new
  defp string_to_status("acknowledged"), do: :acknowledged
  defp string_to_status("in_progress"), do: :in_progress
  defp string_to_status("fixed"), do: :fixed
  defp string_to_status(_), do: :new

  defp string_to_source(nil), do: :qr
  defp string_to_source("qr"), do: :qr
  defp string_to_source("sms"), do: :sms
  defp string_to_source("manual"), do: :manual
  defp string_to_source(_), do: :qr

  defp parse_report(r, now) do
    days_ago = r["days_ago"]
    inserted_at = if days_ago, do: DateTime.add(now, -days_ago, :day), else: nil

    %{
      body: r["body"],
      source: string_to_source(r["source"]),
      consent: Map.get(r, "consent", false),
      reporter_phone: r["reporter_phone"],
      inserted_at: inserted_at
    }
  end

  defp parse_update(u, now) when is_map(u) do
    days_ago = u["days_ago"]
    inserted_at = if days_ago, do: DateTime.add(now, -days_ago, :day), else: nil
    %{message: u["message"], inserted_at: inserted_at}
  end

  defp parse_comment(c, now) when is_map(c) do
    days_ago = c["days_ago"]
    inserted_at = if days_ago, do: DateTime.add(now, -days_ago, :day), else: nil
    %{body: c["body"], author_email: c["author_email"], inserted_at: inserted_at}
  end

  @doc """
  Seeds all sample organizations and returns the list of orgs.
  Call `ensure_dev_users_for_orgs!(orgs)` after to create one dev user per org.
  """
  @spec run_all_sample_orgs!() :: [Organization.t()]
  def run_all_sample_orgs! do
    for config <- sample_org_configs() do
      org = create_organization!(config)
      seed_tenant!(org.tenant_schema, config)
      org
    end
  end

  defp create_organization!(config) do
    Ash.create!(Organization, %{
      name: config.organization_name,
      tenant_schema: config.tenant_schema,
      ai_business_context: config.ai_business_context,
      ai_categorization_instructions: config.ai_categorization_instructions
    })
  end

  defp backdate_record!(tenant_schema, table, id, opts) when is_binary(tenant_schema) do
    set =
      []
      |> maybe_set(:inserted_at, opts[:inserted_at])
      |> maybe_set(:updated_at, opts[:updated_at])

    if set != [] do
      # Postgrex expects binary (16 bytes) for uuid in raw queries; Ash uses string UUIDs.
      id_param = Ecto.UUID.dump!(id)

      from(t in table, where: t.id == ^id_param)
      |> Repo.update_all([set: set], prefix: tenant_schema)
    end

    :ok
  end

  defp maybe_set(acc, _key, nil), do: acc
  defp maybe_set(acc, key, value), do: [{key, value} | acc]

  @dev_user_per_org %{
    "org_demo" => %{email: "asdf@asdf.com", name: "Demo Owner"},
    "org_24hr_fitness" => %{email: "24hr@asdf.com", name: "24hr Owner"},
    "org_the_spot" => %{email: "thespot@asdf.com", name: "The Spot Owner"},
    "org_laundromat" => %{email: "sudzy@asdf.com", name: "Sudzy Owner"},
    "org_grocery" => %{email: "freshmart@asdf.com", name: "Fresh Mart Owner"}
  }

  @doc """
  Creates one dev user per organization. Returns list of %{org_name, tenant_schema, email, password}.
  """
  @spec ensure_dev_users_for_orgs!([Organization.t()]) :: [
          %{
            org_name: String.t(),
            tenant_schema: String.t(),
            email: String.t(),
            password: String.t()
          }
        ]
  def ensure_dev_users_for_orgs!(orgs) do
    password = System.get_env("DEV_USER_PASSWORD", @dev_user_password)
    now = DateTime.utc_now()

    Enum.map(orgs, fn org ->
      config =
        Map.get(@dev_user_per_org, org.tenant_schema) ||
          %{email: "dev_#{org.tenant_schema}@asdf.com", name: "#{org.name} Owner"}

      user =
        User
        |> Ash.create!(
          %{email: config.email, password: password, password_confirmation: password},
          action: :register_with_password,
          authorize?: false
        )
        |> Ash.update!(%{confirmed_at: now}, action: :set_confirmed_at, authorize?: false)
        |> Ash.update!(%{organization_id: org.id, role: :owner},
          action: :set_organization,
          authorize?: false
        )
        |> Ash.update!(%{name: config.name}, action: :update_profile, authorize?: false)

      %{
        org_name: org.name,
        tenant_schema: org.tenant_schema,
        email: user.email,
        password: password
      }
    end)
  end

  defp seed_tenant!(tenant, config) when is_binary(tenant) and is_map(config) do
    :ok = Feedback.Categories.ensure_defaults(tenant)
    :ok = seed_issue_category_guidance!(tenant, Map.get(config, :issue_category_guidance, %{}))

    locations_by_path = seed_locations!(tenant, config.location_specs)
    seed_inbox_examples!(tenant, locations_by_path, config.inbox_entries)

    :ok
  end

  defp seed_locations!(tenant, location_specs) do
    Enum.reduce(location_specs, %{}, fn spec, acc ->
      full_path = if spec.parent_path, do: spec.parent_path <> " / " <> spec.name, else: spec.name
      parent_id = if spec.parent_path, do: Map.get(acc, spec.parent_path).id, else: nil
      attrs = %{name: spec.name, full_path: full_path} |> maybe_put(:parent_id, parent_id)
      location = Ash.create!(Location, attrs, tenant: tenant)
      Map.put(acc, full_path, location)
    end)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp seed_issue_category_guidance!(tenant, guidance) when is_map(guidance) do
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

  defp seed_inbox_examples!(tenant, locations_by_path, inbox_entries) do
    for entry <- inbox_entries do
      location = Map.fetch!(locations_by_path, entry.location_full_path)
      issue_attrs = entry.issue
      issue = create_issue!(tenant, location, issue_attrs)

      if issue_attrs[:inserted_at],
        do:
          backdate_record!(tenant, "issues", issue.id,
            inserted_at: issue_attrs.inserted_at,
            updated_at: issue_attrs.inserted_at
          )

      for r <- entry.reports do
        report = create_report!(tenant, issue, location, r)

        if r[:inserted_at],
          do: backdate_record!(tenant, "reports", report.id, inserted_at: r.inserted_at)
      end

      for u <- entry.updates do
        update = create_issue_update!(tenant, issue, u)

        if inserted_at = u[:inserted_at] do
          backdate_record!(tenant, "issue_updates", update.id, inserted_at: inserted_at)
        end
      end

      for c <- entry.comments do
        comment = create_issue_comment!(tenant, issue, c)

        if inserted_at = c[:inserted_at] do
          backdate_record!(tenant, "issue_comments", comment.id, inserted_at: inserted_at)
        end
      end
    end

    :ok
  end

  defp create_issue!(tenant, location, attrs) do
    desc = attrs.description

    Ash.create!(
      Issue,
      %{
        location_id: location.id,
        title: build_title(desc),
        description: desc,
        normalized_description: normalize_text(desc),
        status: attrs.status,
        category: attrs.category
      },
      tenant: tenant
    )
  end

  defp create_report!(tenant, issue, location, attrs) do
    body = attrs.body

    Ash.create!(
      Report,
      %{
        location_id: location.id,
        issue_id: issue.id,
        body: body,
        normalized_body: normalize_text(body),
        source: Map.get(attrs, :source, :qr),
        consent: Map.get(attrs, :consent, false),
        reporter_phone: attrs[:reporter_phone]
      },
      tenant: tenant
    )
  end

  defp create_issue_update!(tenant, issue, attrs) when is_map(attrs) do
    message = Map.fetch!(attrs, :message)

    Ash.create!(
      IssueUpdate,
      %{issue_id: issue.id, message: message, sent_at: DateTime.utc_now()},
      tenant: tenant
    )
  end

  defp create_issue_comment!(tenant, issue, attrs) when is_map(attrs) do
    body = Map.fetch!(attrs, :body)

    attrs =
      %{issue_id: issue.id, body: body}
      |> maybe_put(:author_email, attrs[:author_email])

    Ash.create!(IssueComment, attrs, tenant: tenant)
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
