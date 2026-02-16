defmodule CloseTheLoop.Events.ChangeMetadata do
  @moduledoc """
  Helpers for attaching structured `ash_events_metadata` diffs to Ash actions.

  We store changes under:

      %{
        ash_events_metadata: %{
          "changes" => %{
            "field" => %{"from" => old, "to" => new}
          }
        }
      }

  This allows the ActivityFeed to render old/new values without inferring changes
  from event input keys (which can overstate changes when forms submit full payloads).
  """

  # We store string keys like "from"/"to", but Elixir typespecs don't allow
  # literal string keys in map types. Keep this loose.
  @type changes :: %{optional(String.t()) => %{optional(String.t()) => String.t() | nil}}

  @doc """
  Build a changes map for the given `fields` based on the current `record` and
  incoming `params`.

  Only fields present in `params` are considered. Fields with no effective change
  are omitted from the returned map.

  Options:
  - `:fields` (required) - list of atom field names to check
  - `:trim?` (default true) - trim strings before compare/store
  - `:empty_to_nil?` (default true) - treat empty strings as nil
  """
  @spec diff(struct(), map(), fields: [atom()], trim?: boolean(), empty_to_nil?: boolean()) ::
          changes()
  def diff(record, params, opts) when is_map(params) do
    fields = Keyword.fetch!(opts, :fields)
    trim? = Keyword.get(opts, :trim?, true)
    empty_to_nil? = Keyword.get(opts, :empty_to_nil?, true)

    Enum.reduce(fields, %{}, fn field, acc ->
      case fetch_param(params, field) do
        :missing ->
          acc

        {:ok, raw_to} ->
          raw_from = Map.get(record, field)

          from = normalize(raw_from, trim?: trim?, empty_to_nil?: empty_to_nil?)
          to = normalize(raw_to, trim?: trim?, empty_to_nil?: empty_to_nil?)

          if from == to do
            acc
          else
            Map.put(acc, Atom.to_string(field), %{"from" => from, "to" => to})
          end
      end
    end)
  end

  @doc """
  Wrap a `changes` map in a `context` map suitable for passing to Ash actions.
  """
  @spec context_for_changes(changes()) :: map()
  def context_for_changes(changes) when changes == %{}, do: %{}

  def context_for_changes(changes) when is_map(changes) do
    %{ash_events_metadata: %{"changes" => changes}}
  end

  @doc """
  Merge two context maps, deep-merging `:ash_events_metadata` and its `"changes"` map.
  """
  @spec merge_context(map(), map()) :: map()
  def merge_context(existing, additional) when is_map(existing) and is_map(additional) do
    Map.merge(existing, additional, fn
      :ash_events_metadata, meta1, meta2 ->
        merge_ash_events_metadata(meta1, meta2)

      _key, _v1, v2 ->
        v2
    end)
  end

  defp merge_ash_events_metadata(meta1, meta2) when is_map(meta1) and is_map(meta2) do
    Map.merge(meta1, meta2, fn
      "changes", c1, c2 when is_map(c1) and is_map(c2) ->
        Map.merge(c1, c2)

      _k, _v1, v2 ->
        v2
    end)
  end

  defp fetch_param(params, field) when is_atom(field) do
    key = Atom.to_string(field)

    cond do
      Map.has_key?(params, key) -> {:ok, Map.get(params, key)}
      Map.has_key?(params, field) -> {:ok, Map.get(params, field)}
      true -> :missing
    end
  end

  defp normalize(nil, _opts), do: nil

  defp normalize(%Ash.CiString{} = v, opts) do
    v |> to_string() |> normalize_string(opts)
  end

  defp normalize(v, opts) when is_binary(v) do
    v |> normalize_string(opts)
  end

  defp normalize(v, _opts) when is_atom(v), do: Atom.to_string(v)
  defp normalize(v, _opts) when is_boolean(v), do: to_string(v)
  defp normalize(v, _opts) when is_number(v), do: to_string(v)

  defp normalize(v, opts) do
    v |> to_string() |> normalize_string(opts)
  end

  defp normalize_string(str, opts) when is_binary(str) do
    str =
      if Keyword.get(opts, :trim?, true) do
        String.trim(str)
      else
        str
      end

    if Keyword.get(opts, :empty_to_nil?, true) and str == "" do
      nil
    else
      str
    end
  end
end
