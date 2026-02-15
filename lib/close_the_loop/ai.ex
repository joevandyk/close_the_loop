defmodule CloseTheLoop.AI do
  @moduledoc """
  Small wrapper around OpenAI for classification/dedupe helpers.
  """

  alias OpenaiEx.Chat
  alias OpenaiEx.ChatMessage

  alias CloseTheLoop.Feedback.Categories

  @spec categorize_issue(String.t(), binary()) :: {:ok, String.t()} | {:error, term()}
  def categorize_issue(text, tenant) when is_binary(text) and is_binary(tenant) do
    case System.get_env("OPENAI_API_KEY") do
      nil ->
        {:error, :missing_openai_api_key}

      "" ->
        {:error, :missing_openai_api_key}

      api_key ->
        allowed = Categories.active_keys(tenant)
        model = System.get_env("OPENAI_MODEL", "gpt-5.2")
        openai = OpenaiEx.new(api_key) |> OpenaiEx.with_receive_timeout(45_000)

        prompt = """
        You categorize customer-reported facility issues for a business.
        Return ONLY one category key from: #{Enum.join(allowed, ", ")}.
        """

        req =
          Chat.Completions.new(
            model: model,
            messages: [
              ChatMessage.system(prompt),
              ChatMessage.user(text)
            ],
            max_tokens: 10,
            temperature: 0
          )

        case openai |> Chat.Completions.create(req) do
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

  # Backwards-compatible wrapper for callers that don't have tenant context.
  @spec categorize_issue(String.t()) :: {:ok, String.t()} | {:error, term()}
  def categorize_issue(text) when is_binary(text) do
    categorize_issue(text, "public")
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
        model = System.get_env("OPENAI_MODEL", "gpt-5.2")
        openai = OpenaiEx.new(api_key) |> OpenaiEx.with_receive_timeout(45_000)

        prompt = """
        You are deduplicating facility issues.

        Given a NEW issue and a list of EXISTING open issues at the same location, decide if the new issue
        is reporting the same underlying problem as one of the existing issues.

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

        req =
          Chat.Completions.new(
            model: model,
            messages: [
              ChatMessage.system(prompt),
              ChatMessage.user(user)
            ],
            max_tokens: 20,
            temperature: 0
          )

        case openai |> Chat.Completions.create(req) do
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

  defp encode_candidates(candidates) do
    candidates
    |> Enum.map(fn c ->
      id = Map.get(c, :id) || Map.get(c, "id")
      title = Map.get(c, :title) || Map.get(c, "title")
      description = Map.get(c, :description) || Map.get(c, "description")

      """
      - id: #{id}
        title: #{title}
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
end
