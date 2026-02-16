defmodule Mix.Tasks.DevSeeds.Generate do
  @shortdoc "Generate JSON seed fixtures via OpenAI for one org or all sample orgs"
  @moduledoc """
  Generates seed fixture JSON for sample organizations using OpenAI.

  Organization list and descriptions come from priv/repo/seed_fixtures/orgs_config.json.
  Loop over that config and generate one JSON fixture per org.

  Usage:
    mix dev_seeds.generate TENANT_SCHEMA   # e.g. org_24hr_fitness (must be in orgs_config.json)
    mix dev_seeds.generate --all          # generate for all orgs in orgs_config.json

  Requires OPENAI_API_KEY. Optional: OPENAI_MODEL (default gpt-5-mini).

  Writes to priv/repo/seed_fixtures/{tenant_schema}.json.
  """

  use Mix.Task

  # OpenAI structured outputs: request JSON that matches this schema so we don't
  # need to defensively strip markdown fences or parse free-form text.
  @seed_fixture_schema %{
    "type" => "object",
    "required" => [
      "organization_name",
      "ai_business_context",
      "ai_categorization_instructions",
      "issue_categories",
      "locations",
      "issues"
    ],
    "additionalProperties" => false,
    "properties" => %{
      "organization_name" => %{"type" => "string"},
      "ai_business_context" => %{"type" => "string"},
      "ai_categorization_instructions" => %{"type" => ["string", "null"]},
      "issue_categories" => %{
        "type" => "array",
        "items" => %{
          "type" => "object",
          "required" => [
            "key",
            "label",
            "description",
            "ai_include_keywords",
            "ai_exclude_keywords",
            "active"
          ],
          "additionalProperties" => false,
          "properties" => %{
            "key" => %{"type" => "string", "minLength" => 1},
            "label" => %{"type" => "string", "minLength" => 1},
            "description" => %{"type" => ["string", "null"]},
            "ai_include_keywords" => %{"type" => ["string", "null"]},
            "ai_exclude_keywords" => %{"type" => ["string", "null"]},
            "active" => %{"type" => "boolean"}
          }
        }
      },
      "locations" => %{
        "type" => "array",
        "items" => %{
          "type" => "object",
          "required" => ["key", "name", "full_path"],
          "additionalProperties" => false,
          "properties" => %{
            "key" => %{"type" => "string", "minLength" => 1},
            "name" => %{"type" => "string", "minLength" => 1},
            # Use " / " as the delimiter for hierarchy. Include parent nodes too.
            "full_path" => %{"type" => "string", "minLength" => 1}
          }
        }
      },
      "issues" => %{
        "type" => "array",
        "items" => %{
          "type" => "object",
          "required" => [
            "key",
            "location_key",
            "description",
            "status",
            "category_key",
            "days_ago",
            "reports",
            "updates",
            "comments"
          ],
          "additionalProperties" => false,
          "properties" => %{
            "key" => %{"type" => "string", "minLength" => 1},
            "location_key" => %{"type" => "string", "minLength" => 1},
            "description" => %{"type" => "string"},
            "status" => %{
              "type" => "string",
              "enum" => ["new", "acknowledged", "in_progress", "fixed"]
            },
            # Not an enum: different businesses can define different categories.
            # (But it must match one of issue_categories[].key)
            "category_key" => %{"type" => "string", "minLength" => 1},
            "days_ago" => %{"type" => "integer", "minimum" => 1, "maximum" => 90},
            "reports" => %{
              "type" => "array",
              "minItems" => 1,
              "maxItems" => 4,
              "items" => %{
                "type" => "object",
                "required" => ["key", "body", "source", "days_ago", "consent", "reporter_phone"],
                "additionalProperties" => false,
                "properties" => %{
                  "key" => %{"type" => "string", "minLength" => 1},
                  "body" => %{"type" => "string"},
                  "source" => %{"type" => "string", "enum" => ["qr", "sms", "manual"]},
                  "days_ago" => %{"type" => "integer", "minimum" => 1, "maximum" => 90},
                  "consent" => %{"type" => "boolean"},
                  "reporter_phone" => %{"type" => ["string", "null"]}
                }
              }
            },
            "updates" => %{
              "type" => "array",
              "items" => %{
                "type" => "object",
                "required" => ["key", "message", "days_ago"],
                "additionalProperties" => false,
                "properties" => %{
                  "key" => %{"type" => "string", "minLength" => 1},
                  "message" => %{"type" => "string"},
                  "days_ago" => %{"type" => "integer", "minimum" => 1, "maximum" => 90}
                }
              }
            },
            "comments" => %{
              "type" => "array",
              "items" => %{
                "type" => "object",
                "required" => ["key", "body", "author_email", "days_ago"],
                "additionalProperties" => false,
                "properties" => %{
                  "key" => %{"type" => "string", "minLength" => 1},
                  "body" => %{"type" => "string"},
                  "author_email" => %{"type" => ["string", "null"]},
                  "days_ago" => %{"type" => "integer", "minimum" => 1, "maximum" => 90}
                }
              }
            }
          }
        }
      }
    }
  }

  @impl Mix.Task
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:close_the_loop)

    {opts, args} = parse_args(args)

    orgs = read_orgs_config()

    if orgs == [] do
      Mix.shell().error(
        "No organizations in priv/repo/seed_fixtures/orgs_config.json. Add an \"organizations\" array with tenant_schema, organization_name, ai_business_context (and optional ai_categorization_instructions)."
      )

      exit(:normal)
    end

    orgs_by_tenant_schema = Map.new(orgs, &{&1["tenant_schema"], &1})

    tenant_schemas =
      if opts[:all] do
        Enum.map(orgs, & &1["tenant_schema"])
      else
        case args do
          [tenant_schema | _] when is_binary(tenant_schema) ->
            [tenant_schema]

          _ ->
            Mix.shell().error(
              "Usage: mix dev_seeds.generate TENANT_SCHEMA | mix dev_seeds.generate --all. TENANT_SCHEMA must exist in priv/repo/seed_fixtures/orgs_config.json."
            )

            exit(:normal)
        end
      end

    missing =
      tenant_schemas
      |> Enum.reject(&Map.has_key?(orgs_by_tenant_schema, &1))

    if missing != [] do
      Mix.shell().error(
        "Unknown tenant_schema(s): #{Enum.join(missing, ", ")}. Add them to priv/repo/seed_fixtures/orgs_config.json and try again."
      )

      exit(:normal)
    end

    api_key = fetch_api_key!()

    Mix.shell().info("Generating fixtures for: #{inspect(tenant_schemas)}")

    Enum.each(tenant_schemas, fn tenant_schema ->
      config =
        read_fixture_for_generator(tenant_schema) ||
          Map.fetch!(orgs_by_tenant_schema, tenant_schema)

      do_generate_one(tenant_schema, config, api_key)
    end)
  end

  defp parse_args(args) do
    {opts, rest, _} =
      OptionParser.parse(args, strict: [all: :boolean], aliases: [a: :all])

    {opts, rest}
  end

  defp seed_fixtures_dir do
    Path.join(File.cwd!(), "priv/repo/seed_fixtures")
  end

  defp orgs_config_path do
    Path.join(seed_fixtures_dir(), "orgs_config.json")
  end

  defp read_orgs_config do
    path = orgs_config_path()

    if not File.exists?(path) do
      []
    else
      path
      |> File.read!()
      |> Jason.decode!()
      |> then(fn
        %{"organizations" => orgs} when is_list(orgs) -> orgs
        _ -> []
      end)
      |> Enum.map(&org_entry_from_json/1)
      |> Enum.reject(&is_nil/1)
    end
  end

  # Keep org entries as decoded JSON (string keys). Validate required keys only.
  defp org_entry_from_json(
         %{
           "tenant_schema" => ts,
           "organization_name" => name,
           "ai_business_context" => ctx
         } = json
       )
       when is_binary(ts) and is_binary(name) and is_binary(ctx) do
    json
  end

  defp org_entry_from_json(_), do: nil

  defp read_fixture_for_generator(tenant_schema) do
    path = Path.join(seed_fixtures_dir(), "#{tenant_schema}.json")

    if File.exists?(path) do
      path |> File.read!() |> Jason.decode!()
    else
      nil
    end
  end

  defp fetch_api_key! do
    api_key = (System.get_env("OPENAI_API_KEY") || "") |> String.trim()

    if api_key == "" do
      Mix.shell().error("OPENAI_API_KEY is required. Set it and try again.")
      exit(:normal)
    end

    api_key
  end

  defp do_generate_one(tenant_schema, config, api_key) do
    model = System.get_env("OPENAI_MODEL", "gpt-5-mini")
    openai = OpenaiEx.new(api_key) |> OpenaiEx.with_receive_timeout(160_000)

    system = build_system(config)
    user = build_user(config)

    response_format = %{
      "type" => "json_schema",
      "json_schema" => %{
        "name" => "seed_fixture",
        "schema" => @seed_fixture_schema,
        "strict" => true
      }
    }

    base_opts = [
      model: model,
      messages: [
        OpenaiEx.ChatMessage.system(system),
        OpenaiEx.ChatMessage.user(user)
      ],
      temperature: 0.3,
      response_format: response_format
    ]

    result =
      openai
      |> OpenaiEx.Chat.Completions.create(
        OpenaiEx.Chat.Completions.new(base_opts ++ [max_completion_tokens: 8192])
      )

    case result do
      {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
        case parse_and_validate(content, tenant_schema) do
          {:ok, json} ->
            dir = seed_fixtures_dir()
            File.mkdir_p!(dir)
            path = Path.join(dir, "#{tenant_schema}.json")
            File.write!(path, Jason.encode!(json, pretty: true))
            Mix.shell().info("Wrote #{path}")

          {:error, reason} ->
            Mix.shell().error("Invalid JSON for #{tenant_schema}: #{inspect(reason)}")
        end

      {:error, err} ->
        Mix.shell().error("OpenAI error for #{tenant_schema}: #{inspect(err)}")
    end
  end

  defp build_system(config) do
    locations_hint =
      case config["locations"] || [] do
        [] ->
          "Suggest 8–20 location_full_path values appropriate for this business."

        specs ->
          full_paths = Enum.map(specs, & &1["full_path"])
          "Use only these location.full_path values: " <> Enum.join(full_paths, ", ")
      end

    """
    You are a seed-data generator for a facility feedback app. Generate realistic locations, issue categories, and issues (with reports, updates, comments) for the given business.

    Rules:
    - organization_name, ai_business_context, ai_categorization_instructions: set from the business name and context in the user message.
    - locations: return a list of {key, name, full_path}.
      - Use " / " in full_path for hierarchy, and include parent nodes.
      - Do NOT include the organization name as a path segment (no root like "The Spot").
        Example: "Bar / Bar Counter" (GOOD) vs "The Spot / Bar / Bar Counter" (BAD).
      #{locations_hint}
    - issue_categories: include all categories needed for this business (short snake_case keys + nice labels). Issues must reference issue_categories[].key via issue.category_key.
    - issues: 1–3 months of feedback; use days_ago between 1 and 90; variety of statuses (new, acknowledged, in_progress, fixed) and categories.
      Issues reference locations by issue.location_key (must match locations[].key).
    - Each issue must have at least one report; most issues should have 2–4 reports (distinct bodies).
      Some issues can have exactly 1 report, but seeing multiple reports is better.
    - Some issues have updates and/or comments.

    Example shape (abbreviated):
    {
      "locations": [
        {"key": "loc_bar", "name": "Bar", "full_path": "Bar"},
        {"key": "loc_bar_counter", "name": "Bar Counter", "full_path": "Bar / Bar Counter"}
      ],
      "issues": [
        {
          "key": "iss_001",
          "location_key": "loc_bar_counter",
          "description": "Bar counter is sticky and smells like old beer.",
          "status": "new",
          "category_key": "cleanliness_hygiene",
          "days_ago": 6,
          "reports": [
            {"key": "rep_001a", "body": "Counter is sticky near the register.", "source": "qr", "days_ago": 6, "consent": false, "reporter_phone": null},
            {"key": "rep_001b", "body": "Same spot smells sour and needs a deeper clean.", "source": "sms", "days_ago": 5, "consent": false, "reporter_phone": null}
          ],
          "updates": [],
          "comments": []
        }
      ]
    }
    """
  end

  defp build_user(config) do
    instructions = config["ai_categorization_instructions"]

    instructions_line =
      if blank?(instructions) do
        ""
      else
        "\nCategorization instructions: #{instructions}\n"
      end

    """
    Business: #{config["organization_name"]}
    Context: #{config["ai_business_context"]}#{instructions_line}

    Generate the JSON seed fixture for this organization.
    """
  end

  defp parse_and_validate(raw, _tenant_schema) do
    content =
      raw
      |> to_string()
      |> String.trim()

    case Jason.decode(content) do
      {:ok, %{"issue_categories" => _cats, "locations" => _locs, "issues" => _issues} = decoded} ->
        {:ok, decoded}

      {:ok, _} ->
        {:error, "missing issue_categories, locations, or issues"}

      {:error, _} = err ->
        err
    end
  end

  defp blank?(nil), do: true
  defp blank?(s) when is_binary(s), do: String.trim(s) == ""
  defp blank?(_), do: false
end
