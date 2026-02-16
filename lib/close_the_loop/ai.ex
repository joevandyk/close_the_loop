defmodule CloseTheLoop.AI do
  @moduledoc """
  Small wrapper around OpenAI for classification/dedupe helpers.
  """

  alias OpenaiEx.Chat
  alias OpenaiEx.ChatMessage

  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Tenants.Organization

  require Ash.Query

  defp create_chat_completion(openai, opts, limit) do
    # We standardize on max_completion_tokens (newer OpenAI models).
    req = Chat.Completions.new(opts ++ [max_completion_tokens: limit])
    openai |> Chat.Completions.create(req)
  end

  @spec categorize_issue(String.t(), binary()) :: {:ok, String.t()} | {:error, term()}
  def categorize_issue(text, tenant) when is_binary(text) and is_binary(tenant) do
    case System.get_env("OPENAI_API_KEY") do
      nil ->
        {:error, :missing_openai_api_key}

      "" ->
        {:error, :missing_openai_api_key}

      api_key ->
        allowed = Categories.active_keys(tenant)
        categories = Categories.active_for_ai(tenant)
        org = get_org_by_tenant(tenant)
        model = System.get_env("OPENAI_MODEL", "gpt-5-mini")
        openai = OpenaiEx.new(api_key) |> OpenaiEx.with_receive_timeout(45_000)

        prompt = build_categorize_prompt(allowed, categories, org)

        opts = [
          model: model,
          messages: [
            ChatMessage.system(prompt),
            ChatMessage.user(text)
          ],
          temperature: 0
        ]

        case create_chat_completion(openai, opts, 10) do
          {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
            category =
              content
              |> to_string()
              |> String.trim()
              |> String.downcase()

            normalize_category(category, allowed)

          {:error, err} ->
            {:error, err}

          other ->
            {:error, {:unexpected_openai_response, other}}
        end
    end
  end

  @spec match_duplicate_issue(String.t(), list(map())) ::
          {:ok, String.t() | nil} | {:error, term()}
  def match_duplicate_issue(new_issue_text, candidates)
      when is_binary(new_issue_text) and is_list(candidates) do
    case System.get_env("OPENAI_API_KEY") do
      nil ->
        {:error, :missing_openai_api_key}

      "" ->
        {:error, :missing_openai_api_key}

      api_key ->
        model = System.get_env("OPENAI_MODEL", "gpt-5-mini")
        openai = OpenaiEx.new(api_key) |> OpenaiEx.with_receive_timeout(45_000)

        prompt = """
        You are deduplicating facility issues.

        Given a NEW issue and a list of EXISTING open issues in the same organization, decide if the new issue
        is reporting the same underlying problem as one of the existing issues.

        Issues may refer to different locations. Use any provided location context as a hint, but do not require
        the locations to match if it is clearly the same underlying problem.

        Return ONLY:
        - the matching issue id (a UUID) if it is clearly the same issue, OR
        - "none" if it is not a duplicate.

        Be strict: only match when you're confident.
        """

        user = """
        NEW ISSUE:
        #{new_issue_text}

        EXISTING ISSUES (choose at most one id):
        #{encode_candidates(candidates)}
        """

        opts = [
          model: model,
          messages: [
            ChatMessage.system(prompt),
            ChatMessage.user(user)
          ],
          temperature: 0
        ]

        case create_chat_completion(openai, opts, 20) do
          {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
            answer =
              content
              |> to_string()
              |> String.trim()
              |> String.downcase()

            normalize_duplicate_answer(answer, candidates)

          {:error, err} ->
            {:error, err}

          other ->
            {:error, {:unexpected_openai_response, other}}
        end
    end
  end

  @spec resolve_report_issue(String.t(), binary(), String.t(), list(map())) ::
          {:ok,
           {:match, String.t()} | {:new_issue, %{title: String.t(), category: String.t() | nil}}}
          | {:error, term()}
  def resolve_report_issue(report_text, tenant, location_context, candidates)
      when is_binary(report_text) and is_binary(tenant) and is_binary(location_context) and
             is_list(candidates) do
    case System.get_env("OPENAI_API_KEY") do
      nil ->
        {:error, :missing_openai_api_key}

      "" ->
        {:error, :missing_openai_api_key}

      api_key ->
        model = System.get_env("OPENAI_MODEL", "gpt-5-mini")
        openai = OpenaiEx.new(api_key) |> OpenaiEx.with_receive_timeout(45_000)

        allowed_categories = Categories.active_keys(tenant)
        categories = Categories.active_for_ai(tenant)
        org = get_org_by_tenant(tenant)

        {category_rules, category_reference} =
          build_category_rules_and_reference(allowed_categories, categories, org)

        system_prompt =
          """
          You triage a NEW customer report about a facility issue.

          Your job is to either:
          1) match it to one EXISTING open issue (if it is clearly the same underlying problem), OR
          2) create a NEW issue proposal (title + category) if it is not a duplicate.

          Return ONLY a JSON object, with no extra keys, no markdown, and no surrounding text.

          If it matches an existing issue, return:
          {"action":"match","issue_id":"<uuid>"}

          If it does not match any existing issue, return:
          {"action":"new","title":"<title>","category":<category>}

          Matching rules:
          - Choose at most one existing issue id.
          - Be strict: only match when you're confident it's the same underlying issue.
          - Location is a hint, but do not require locations to match if it is clearly the same problem.

          Title rules:
          - 4-12 words
          - concise, specific, actionable (avoid filler like "issue" or "problem" when possible)
          - no trailing period
          - do not include a location name unless it's essential

          #{category_rules}

          #{category_reference}
          """
          |> String.trim()

        location_block =
          if String.trim(location_context) == "" do
            ""
          else
            "REPORT LOCATION:\n#{String.trim(location_context)}\n\n"
          end

        user_prompt =
          """
          #{location_block}REPORT TEXT:
          #{String.trim(report_text)}

          EXISTING ISSUES (choose at most one id):
          #{encode_candidates(candidates)}
          """
          |> String.trim()

        opts = [
          model: model,
          messages: [
            ChatMessage.system(system_prompt),
            ChatMessage.user(user_prompt)
          ],
          temperature: 0,
          response_format: %{type: "json_object"}
        ]

        case create_chat_completion(openai, opts, 250) do
          {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
            decode_resolution_json(content, candidates, allowed_categories)

          {:error, err} ->
            {:error, err}

          other ->
            {:error, {:unexpected_openai_response, other}}
        end
    end
  end

  defp encode_candidates(candidates) do
    candidates
    |> Enum.map(fn c ->
      id = Map.get(c, :id) || Map.get(c, "id")
      location = Map.get(c, :location) || Map.get(c, "location")
      title = Map.get(c, :title) || Map.get(c, "title")
      description = Map.get(c, :description) || Map.get(c, "description")

      location_line =
        if is_binary(location) and String.trim(location) != "" do
          # Include trailing indentation so the following "title" line stays aligned.
          "location: #{String.trim(location)}\n        "
        else
          ""
        end

      """
      - id: #{id}
        #{location_line}title: #{title}
        description: #{description}
      """
    end)
    |> Enum.join("\n")
  end

  defp normalize_duplicate_answer("none", _candidates), do: {:ok, nil}

  defp normalize_duplicate_answer(answer, candidates) when is_binary(answer) do
    allowed_ids =
      candidates
      |> Enum.map(&(Map.get(&1, :id) || Map.get(&1, "id")))
      |> MapSet.new()

    # Models sometimes return "id: <uuid>" or "<uuid>." etc.
    candidate =
      answer
      |> String.replace("id:", "")
      |> String.trim()
      |> String.trim_trailing(".")

    if MapSet.member?(allowed_ids, candidate) do
      {:ok, candidate}
    else
      {:ok, nil}
    end
  end

  defp decode_resolution_json(content, candidates, allowed_categories) do
    with {:ok, decoded} <- Jason.decode(to_string(content)),
         action when is_binary(action) <- Map.get(decoded, "action") do
      case String.downcase(String.trim(action)) do
        "match" ->
          issue_id = decoded |> Map.get("issue_id") |> to_string() |> String.trim()

          allowed_ids =
            candidates
            |> Enum.map(&(Map.get(&1, :id) || Map.get(&1, "id")))
            |> MapSet.new()

          if MapSet.member?(allowed_ids, issue_id) do
            {:ok, {:match, issue_id}}
          else
            {:error, {:invalid_match_id, issue_id}}
          end

        "new" ->
          title =
            decoded
            |> Map.get("title")
            |> to_string()
            |> String.trim()
            |> String.replace(~r/\s+/u, " ")

          if title == "" do
            {:error, {:invalid_issue_title, decoded}}
          else
            category =
              normalize_resolution_category(Map.get(decoded, "category"), allowed_categories)

            {:ok, {:new_issue, %{title: title, category: category}}}
          end

        other ->
          {:error, {:invalid_action, other}}
      end
    else
      {:error, err} ->
        {:error, err}

      _ ->
        {:error, {:invalid_openai_json, content}}
    end
  end

  defp normalize_resolution_category(nil, _allowed_categories), do: nil

  defp normalize_resolution_category(category, allowed_categories)
       when is_list(allowed_categories) do
    category =
      category
      |> to_string()
      |> String.trim()
      |> String.downcase()
      |> String.trim_trailing(".")

    cond do
      allowed_categories == [] ->
        nil

      category in allowed_categories ->
        category

      "other" in allowed_categories ->
        "other"

      allowed_categories != [] ->
        List.first(allowed_categories)

      true ->
        nil
    end
  end

  defp normalize_category(category, allowed) when is_binary(category) and is_list(allowed) do
    # Model sometimes returns "plumbing." or "plumbing\n" despite the instruction.
    candidate =
      category
      |> String.split(~r/\s+/, parts: 2, trim: true)
      |> List.first()
      |> to_string()
      |> String.trim_trailing(".")

    if candidate in allowed do
      {:ok, candidate}
    else
      {:error, {:invalid_category, category}}
    end
  end

  defp get_org_by_tenant(tenant) when is_binary(tenant) do
    query =
      Organization
      |> Ash.Query.filter(tenant_schema == ^tenant)
      |> Ash.Query.limit(1)

    case Ash.read_one(query) do
      {:ok, %Organization{} = org} -> org
      _ -> nil
    end
  end

  defp build_category_rules_and_reference(allowed, categories, org)
       when is_list(allowed) and is_list(categories) do
    if allowed == [] do
      {
        "Category rules:\n- Set category to null.",
        ""
      }
    else
      fallback =
        cond do
          "other" in allowed -> "other"
          allowed != [] -> List.first(allowed)
          true -> "other"
        end

      org_bits =
        case org do
          %Organization{} ->
            [
              org.ai_business_context && String.trim(org.ai_business_context) != "" &&
                "Business context:\n#{String.trim(org.ai_business_context)}",
              org.ai_categorization_instructions &&
                String.trim(org.ai_categorization_instructions) != "" &&
                "Categorization rules:\n#{String.trim(org.ai_categorization_instructions)}"
            ]
            |> Enum.filter(& &1)
            |> Enum.join("\n\n")

          _ ->
            ""
        end

      categories_block =
        categories
        |> Enum.map(fn c ->
          bits = [
            c.description && String.trim(c.description) != "" &&
              "Description: #{String.trim(c.description)}",
            c.ai_guidance && String.trim(c.ai_guidance) != "" &&
              "AI guidance: #{String.trim(c.ai_guidance)}",
            c.ai_include_keywords && String.trim(c.ai_include_keywords) != "" &&
              "Include keywords:\n#{String.trim(c.ai_include_keywords)}",
            c.ai_exclude_keywords && String.trim(c.ai_exclude_keywords) != "" &&
              "Exclude keywords:\n#{String.trim(c.ai_exclude_keywords)}",
            c.ai_examples && String.trim(c.ai_examples) != "" &&
              "Examples:\n#{String.trim(c.ai_examples)}"
          ]

          body =
            bits
            |> Enum.filter(& &1)
            |> Enum.join("\n")

          header = "- #{c.key}: #{c.label}"

          if body == "" do
            header
          else
            header <> "\n" <> body
          end
        end)
        |> Enum.join("\n\n")

      reference =
        """
        Category reference:
        - category must be one of: #{Enum.join(allowed, ", ")}
        - if unsure, choose \"#{fallback}\"

        #{org_bits}

        Categories:
        #{categories_block}
        """
        |> String.trim()

      rules =
        """
        Category rules:
        - category must be a string key from the allowed list (not the label).
        - output the key in lowercase.
        - if unsure, choose \"#{fallback}\".
        """
        |> String.trim()

      {rules, reference}
    end
  end

  defp build_categorize_prompt(allowed, categories, org)
       when is_list(allowed) and is_list(categories) do
    fallback =
      cond do
        "other" in allowed -> "other"
        allowed != [] -> List.first(allowed)
        true -> "other"
      end

    org_bits =
      case org do
        %Organization{} ->
          [
            org.ai_business_context && String.trim(org.ai_business_context) != "" &&
              "Business context:\n#{String.trim(org.ai_business_context)}",
            org.ai_categorization_instructions &&
              String.trim(org.ai_categorization_instructions) != "" &&
              "Categorization rules:\n#{String.trim(org.ai_categorization_instructions)}"
          ]
          |> Enum.filter(& &1)
          |> Enum.join("\n\n")

        _ ->
          ""
      end

    categories_block =
      categories
      |> Enum.map(fn c ->
        bits = [
          c.description && String.trim(c.description) != "" &&
            "Description: #{String.trim(c.description)}",
          c.ai_guidance && String.trim(c.ai_guidance) != "" &&
            "AI guidance: #{String.trim(c.ai_guidance)}",
          c.ai_include_keywords && String.trim(c.ai_include_keywords) != "" &&
            "Include keywords:\n#{String.trim(c.ai_include_keywords)}",
          c.ai_exclude_keywords && String.trim(c.ai_exclude_keywords) != "" &&
            "Exclude keywords:\n#{String.trim(c.ai_exclude_keywords)}",
          c.ai_examples && String.trim(c.ai_examples) != "" &&
            "Examples:\n#{String.trim(c.ai_examples)}"
        ]

        body =
          bits
          |> Enum.filter(& &1)
          |> Enum.join("\n")

        header = "- #{c.key}: #{c.label}"

        if body == "" do
          header
        else
          header <> "\n" <> body
        end
      end)
      |> Enum.join("\n\n")

    """
    You categorize customer-reported facility issues for a business.

    Return ONLY one category key from this list:
    #{Enum.join(allowed, ", ")}

    Rules:
    - Output exactly one key, nothing else (no punctuation, no explanation).
    - If you're unsure, choose "#{fallback}".
    - Use the category definitions and keywords to disambiguate similar categories.

    #{org_bits}

    Categories:
    #{categories_block}
    """
    |> String.trim()
  end
end
