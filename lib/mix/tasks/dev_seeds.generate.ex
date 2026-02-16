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
      "location_specs",
      "issue_category_guidance",
      "inbox_entries"
    ],
    "additionalProperties" => false,
    "properties" => %{
      "organization_name" => %{"type" => "string"},
      "ai_business_context" => %{"type" => "string"},
      "ai_categorization_instructions" => %{"type" => ["string", "null"]},
      "location_specs" => %{
        "type" => "array",
        "items" => %{
          "type" => "object",
          "required" => ["name", "parent_path"],
          "additionalProperties" => false,
          "properties" => %{
            "name" => %{"type" => "string"},
            "parent_path" => %{"type" => ["string", "null"]}
          }
        }
      },
      "issue_category_guidance" => %{
        # A list feels more natural than an object with fixed keys.
        # (The "key" field still matches the issue.category enum.)
        "type" => "array",
        "items" => %{
          "type" => "object",
          "required" => ["key", "description", "ai_include_keywords", "ai_exclude_keywords"],
          "additionalProperties" => false,
          "properties" => %{
            "key" => %{
              "type" => "string",
              "enum" => [
                "plumbing",
                "electrical",
                "cleaning",
                "equipment",
                "suggestion",
                "other"
              ]
            },
            "description" => %{"type" => ["string", "null"]},
            "ai_include_keywords" => %{"type" => ["string", "null"]},
            "ai_exclude_keywords" => %{"type" => ["string", "null"]}
          }
        }
      },
      "inbox_entries" => %{
        "type" => "array",
        "items" => %{
          "type" => "object",
          "required" => ["location_full_path", "issue", "reports", "updates", "comments"],
          "additionalProperties" => false,
          "properties" => %{
            "location_full_path" => %{"type" => "string"},
            "issue" => %{
              "type" => "object",
              "required" => ["description", "status", "category", "days_ago"],
              "additionalProperties" => false,
              "properties" => %{
                "description" => %{"type" => "string"},
                "status" => %{
                  "type" => "string",
                  "enum" => ["new", "acknowledged", "in_progress", "fixed"]
                },
                "category" => %{
                  "type" => "string",
                  "enum" => [
                    "plumbing",
                    "electrical",
                    "cleaning",
                    "equipment",
                    "suggestion",
                    "other"
                  ]
                },
                "days_ago" => %{"type" => "integer", "minimum" => 1, "maximum" => 90}
              }
            },
            "reports" => %{
              "type" => "array",
              "minItems" => 1,
              "items" => %{
                "type" => "object",
                "required" => ["body", "source", "days_ago"],
                "additionalProperties" => false,
                "properties" => %{
                  "body" => %{"type" => "string"},
                  "source" => %{"type" => "string", "enum" => ["qr", "sms", "manual"]},
                  "days_ago" => %{"type" => "integer", "minimum" => 1, "maximum" => 90}
                }
              }
            },
            "updates" => %{
              "type" => "array",
              "items" => %{
                "type" => "object",
                "required" => ["message", "days_ago"],
                "additionalProperties" => false,
                "properties" => %{
                  "message" => %{"type" => "string"},
                  "days_ago" => %{"type" => "integer", "minimum" => 1, "maximum" => 90}
                }
              }
            },
            "comments" => %{
              "type" => "array",
              "items" => %{
                "type" => "object",
                "required" => ["body", "author_email", "days_ago"],
                "additionalProperties" => false,
                "properties" => %{
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
    openai = OpenaiEx.new(api_key) |> OpenaiEx.with_receive_timeout(60_000)

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
      case openai
           |> OpenaiEx.Chat.Completions.create(
             OpenaiEx.Chat.Completions.new(base_opts ++ [max_tokens: 8192])
           ) do
        {:error, %OpenaiEx.Error{code: "unsupported_parameter", param: "max_tokens"}} ->
          openai
          |> OpenaiEx.Chat.Completions.create(
            OpenaiEx.Chat.Completions.new(base_opts ++ [max_completion_tokens: 8192])
          )

        other ->
          other
      end

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
      case config["location_specs"] || [] do
        [] ->
          "Suggest 5–10 locations appropriate for this business."

        specs ->
          paths =
            specs
            |> Enum.map(fn s ->
              parent_path = s["parent_path"]
              name = s["name"]
              if parent_path, do: "#{parent_path} / #{name}", else: name
            end)

          "Use only these location_full_path values (or build from them): " <>
            Enum.join(paths, ", ")
      end

    """
    You are a seed-data generator for a facility feedback app. Generate realistic location specs and inbox entries (issues with reports, updates, comments) for the given business.

    Rules:
    - organization_name, ai_business_context, ai_categorization_instructions: set from the business name and context in the user message.
    - location_specs: #{locations_hint}
    - issue_category_guidance: include plumbing, electrical, and cleaning with short description and ai_include_keywords / ai_exclude_keywords (null ok).
    - inbox_entries: 1–3 months of feedback; use days_ago between 1 and 90; variety of statuses (new, acknowledged, in_progress, fixed) and categories.
    - Each issue must have at least one report. Some issues have updates and/or comments.
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
      {:ok, %{"location_specs" => _ls, "inbox_entries" => _es} = decoded} ->
        if blank?(decoded["organization_name"]) or blank?(decoded["ai_business_context"]) do
          {:error, "model output missing organization_name or ai_business_context"}
        else
          {:ok, decoded}
        end

      {:ok, _} ->
        {:error, "missing location_specs or inbox_entries"}

      {:error, _} = err ->
        err
    end
  end

  defp blank?(nil), do: true
  defp blank?(s) when is_binary(s), do: String.trim(s) == ""
  defp blank?(_), do: false
end
