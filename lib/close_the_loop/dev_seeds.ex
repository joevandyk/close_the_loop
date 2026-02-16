defmodule CloseTheLoop.DevSeeds do
  @moduledoc """
  Dev seeding for empty databases only (e.g. `mix ecto.reset`).

  Creates organizations, tenant data, and dev users via Ash actions. No
  idempotency checks—assumes DB is empty.
  """

  import Ecto.Query

  alias CloseTheLoop.Accounts.User
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
         %{
           "issue_categories" => issue_categories,
           "locations" => locations,
           "issues" => issues
         } = json,
         tenant_schema
       )
       when is_list(issue_categories) and is_list(locations) and is_list(issues) do
    now = DateTime.utc_now()

    %{
      tenant_schema: tenant_schema,
      organization_name: Map.fetch!(json, "organization_name"),
      ai_business_context: Map.fetch!(json, "ai_business_context"),
      ai_categorization_instructions: Map.fetch!(json, "ai_categorization_instructions"),
      issue_categories: Enum.map(issue_categories, &parse_issue_category!/1),
      locations: Enum.map(locations, &parse_location!/1),
      issues: Enum.map(issues, fn issue -> parse_issue!(issue, now) end)
    }
  end

  defp parse_issue_category!(category) when is_map(category) do
    %{
      key: Map.fetch!(category, "key"),
      label: Map.fetch!(category, "label"),
      description: Map.fetch!(category, "description"),
      ai_include_keywords: Map.fetch!(category, "ai_include_keywords"),
      ai_exclude_keywords: Map.fetch!(category, "ai_exclude_keywords"),
      active: Map.fetch!(category, "active")
    }
  end

  defp parse_location!(location) when is_map(location) do
    %{
      key: Map.fetch!(location, "key"),
      name: Map.fetch!(location, "name"),
      full_path: Map.fetch!(location, "full_path")
    }
  end

  defp parse_issue!(issue, now) when is_map(issue) do
    days_ago = Map.fetch!(issue, "days_ago")
    inserted_at = DateTime.add(now, -days_ago, :day)

    %{
      key: Map.fetch!(issue, "key"),
      location_key: Map.fetch!(issue, "location_key"),
      description: Map.fetch!(issue, "description"),
      status: string_to_status!(Map.fetch!(issue, "status")),
      category: Map.fetch!(issue, "category_key"),
      inserted_at: inserted_at,
      reports: Enum.map(Map.fetch!(issue, "reports"), fn r -> parse_report!(r, now) end),
      updates: Enum.map(Map.fetch!(issue, "updates"), fn u -> parse_update!(u, now) end),
      comments: Enum.map(Map.fetch!(issue, "comments"), fn c -> parse_comment!(c, now) end)
    }
  end

  defp string_to_status!("new"), do: :new
  defp string_to_status!("acknowledged"), do: :acknowledged
  defp string_to_status!("in_progress"), do: :in_progress
  defp string_to_status!("fixed"), do: :fixed

  defp string_to_source!("qr"), do: :qr
  defp string_to_source!("sms"), do: :sms
  defp string_to_source!("manual"), do: :manual

  defp parse_report!(report, now) when is_map(report) do
    days_ago = Map.fetch!(report, "days_ago")
    inserted_at = DateTime.add(now, -days_ago, :day)

    %{
      key: Map.fetch!(report, "key"),
      body: Map.fetch!(report, "body"),
      source: string_to_source!(Map.fetch!(report, "source")),
      consent: Map.fetch!(report, "consent"),
      reporter_phone: Map.fetch!(report, "reporter_phone"),
      inserted_at: inserted_at
    }
  end

  defp parse_update!(update, now) when is_map(update) do
    days_ago = Map.fetch!(update, "days_ago")
    inserted_at = DateTime.add(now, -days_ago, :day)

    %{
      key: Map.fetch!(update, "key"),
      message: Map.fetch!(update, "message"),
      inserted_at: inserted_at
    }
  end

  defp parse_comment!(comment, now) when is_map(comment) do
    days_ago = Map.fetch!(comment, "days_ago")
    inserted_at = DateTime.add(now, -days_ago, :day)

    %{
      key: Map.fetch!(comment, "key"),
      body: Map.fetch!(comment, "body"),
      author_email: Map.fetch!(comment, "author_email"),
      inserted_at: inserted_at
    }
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
    seed_issue_categories!(tenant, config.issue_categories)
    locations_by_key = seed_locations_from_keyed_list!(tenant, config.locations)
    seed_issues!(tenant, locations_by_key, config.issues)

    :ok
  end

  defp seed_issue_categories!(tenant, issue_categories) when is_list(issue_categories) do
    Enum.each(issue_categories, fn attrs ->
      Ash.create!(IssueCategory, attrs, tenant: tenant)
    end)

    :ok
  end

  defp seed_locations_from_keyed_list!(tenant, locations) when is_list(locations) do
    keyed_by_full_path = Map.new(locations, &{&1.full_path, &1})

    all_paths =
      locations
      |> Enum.flat_map(&location_prefixes(&1.full_path))
      |> Enum.uniq()
      |> Enum.sort_by(fn path -> path |> String.split(" / ", trim: true) |> length() end)

    {by_key, _by_full_path} =
      Enum.reduce(all_paths, {%{}, %{}}, fn full_path, {by_key, by_full_path} ->
        parts = String.split(full_path, " / ", trim: true)

        parent_full_path =
          case parts do
            [_] -> nil
            _ -> parts |> Enum.drop(-1) |> Enum.join(" / ")
          end

        parent_id =
          if parent_full_path do
            Map.fetch!(by_full_path, parent_full_path).id
          else
            nil
          end

        name =
          case Map.get(keyed_by_full_path, full_path) do
            nil -> List.last(parts)
            loc -> loc.name
          end

        attrs =
          %{name: name, full_path: full_path}
          |> maybe_put(:parent_id, parent_id)

        created = Ash.create!(Location, attrs, tenant: tenant)
        by_full_path = Map.put(by_full_path, full_path, created)

        by_key =
          case Map.get(keyed_by_full_path, full_path) do
            nil -> by_key
            loc -> Map.put(by_key, loc.key, created)
          end

        {by_key, by_full_path}
      end)

    by_key
  end

  defp location_prefixes(full_path) when is_binary(full_path) do
    parts = String.split(full_path, " / ", trim: true)

    {prefixes, _} =
      Enum.reduce(parts, {[], ""}, fn part, {acc, prev} ->
        current = if prev == "", do: part, else: prev <> " / " <> part
        {[current | acc], current}
      end)

    Enum.reverse(prefixes)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp seed_issues!(tenant, locations_by_key, issues) do
    for issue_entry <- issues do
      location = Map.fetch!(locations_by_key, issue_entry.location_key)
      issue = create_issue!(tenant, location, issue_entry)

      backdate_record!(tenant, "issues", issue.id,
        inserted_at: issue_entry.inserted_at,
        updated_at: issue_entry.inserted_at
      )

      for r <- issue_entry.reports do
        report = create_report!(tenant, issue, location, r)

        backdate_record!(tenant, "reports", report.id, inserted_at: r.inserted_at)
      end

      for u <- issue_entry.updates do
        update = create_issue_update!(tenant, issue, u)

        backdate_record!(tenant, "issue_updates", update.id, inserted_at: u.inserted_at)
      end

      for c <- issue_entry.comments do
        comment = create_issue_comment!(tenant, issue, c)

        backdate_record!(tenant, "issue_comments", comment.id, inserted_at: c.inserted_at)
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
        source: Map.fetch!(attrs, :source),
        consent: Map.fetch!(attrs, :consent),
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
