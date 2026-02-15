defmodule CloseTheLoop.Feedback.Categories do
  @moduledoc """
  Per-tenant issue category configuration.

  Issue categories live inside each tenant schema.
  """

  alias CloseTheLoop.Feedback.IssueCategory

  @default_categories [
    %{key: "plumbing", label: "Plumbing"},
    %{key: "electrical", label: "Electrical"},
    %{key: "cleaning", label: "Cleaning"},
    %{key: "equipment", label: "Equipment"},
    %{key: "suggestion", label: "Suggestion"},
    %{key: "other", label: "Other"}
  ]

  @spec ensure_defaults(binary()) :: :ok
  def ensure_defaults(tenant) when is_binary(tenant) do
    existing =
      case list(tenant) do
        {:ok, cats} -> MapSet.new(Enum.map(cats, & &1.key))
        _ -> MapSet.new()
      end

    Enum.each(@default_categories, fn %{key: key} = attrs ->
      if not MapSet.member?(existing, key) do
        _ = Ash.create(IssueCategory, attrs, tenant: tenant)
      end
    end)

    :ok
  end

  @spec list(binary()) :: {:ok, list(IssueCategory.t())} | {:error, term()}
  def list(tenant) when is_binary(tenant) do
    Ash.read(IssueCategory, tenant: tenant)
  end

  @spec active_key_label_map(binary()) :: %{optional(String.t()) => String.t()}
  def active_key_label_map(tenant) when is_binary(tenant) do
    case Ash.read(IssueCategory, tenant: tenant) do
      {:ok, cats} ->
        cats
        |> Enum.filter(& &1.active)
        |> Map.new(&{&1.key, &1.label})

      _ ->
        # Used by UI rendering; falling back is fine.
        Map.new(@default_categories, &{&1.key, &1.label})
    end
  end

  @spec active_keys(binary()) :: list(String.t())
  def active_keys(tenant) when is_binary(tenant) do
    case Ash.read(IssueCategory, tenant: tenant) do
      {:ok, cats} ->
        keys =
          cats
          |> Enum.filter(& &1.active)
          |> Enum.map(& &1.key)

        if keys == [] do
          Enum.map(@default_categories, & &1.key)
        else
          keys
        end

      _ ->
        Enum.map(@default_categories, & &1.key)
    end
  end
end

