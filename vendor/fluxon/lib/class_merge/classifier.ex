defmodule Fluxon.ClassMerge.Classifier do
  @moduledoc false

  alias Fluxon.ClassMerge.{Config}

  def classify(classes) do
    class_groups = Config.class_groups()
    Enum.map(classes, &classify_class(&1, class_groups))
  end

  defp classify_class(class, class_groups) do
    {group, subgroup} = determine_group(class, class_groups)
    Map.merge(class, %{group: group, subgroup: subgroup})
  end

  defp determine_group(%{base: base, variants: variants}, class_groups) do
    full_class = (variants ++ [base]) |> Enum.join(":")

    Enum.find_value(class_groups, {:other, :other}, fn {group, definition} ->
      if matches_definition?(full_class, definition) do
        {String.to_atom(group), determine_subgroup(full_class, definition)}
      end
    end)
  end

  defp matches_definition?(class, definition) when is_list(definition) do
    Enum.any?(definition, &match_value?(class, &1))
  end

  defp matches_definition?(class, definition) when is_map(definition) do
    Enum.any?(definition, fn {prefix, values} ->
      String.starts_with?(class, prefix) and
        matches_definition?(String.replace_prefix(class, prefix, ""), values)
    end)
  end

  defp match_value?(class, value) when is_binary(value), do: class == value
  defp match_value?(class, validator) when is_function(validator), do: validator.(class)

  defp determine_subgroup(class, definition) when is_map(definition) do
    {prefix, _} = Enum.find(definition, fn {prefix, _} -> String.starts_with?(class, prefix) end)
    String.to_atom(prefix)
  end

  defp determine_subgroup(_class, _definition), do: :default
end
