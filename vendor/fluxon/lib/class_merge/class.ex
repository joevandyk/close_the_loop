defmodule Fluxon.ClassMerge.Class do
  @moduledoc false

  alias Fluxon.ClassMerge.Config

  defstruct [:modifier, :important, :base, :negative, :variants, :raw, :group, :overrides, :key]

  def parse(class) do
    {variants, base, _modifier} = extract_variants(class)
    {important, base_without_important} = extract_important(base)
    {negative, final_base} = extract_negative(base_without_important)
    group = group(final_base)

    %__MODULE__{
      important: important,
      negative: negative,
      variants: variants,
      raw: class,
      base: final_base,
      group: group,
      overrides: overrides(group),
      key: conflict_key(important, group, variants, class)
    }
  end

  defp conflict_key(_, nil, variants, class) do
    case Regex.run(~r/\[([^\]:]+)(?::|\])/, class) do
      [_, arbitrary_property] ->
        (variants ++ ["var", String.trim_leading(arbitrary_property, "-")]) |> Enum.join(":")

      _ ->
        nil
    end
  end

  defp conflict_key(false, group, variants, _) do
    (Enum.sort(variants) ++ [group]) |> Enum.join(":")
  end

  defp conflict_key(true, group, variants, _) do
    "!" <> ((Enum.sort(variants) ++ [group]) |> Enum.join(":"))
  end

  defp extract_variants(class) do
    # Split by colon to separate variants and base class
    parts = Regex.split(~r/:(?![^[]*\])/, class)
    {variants, [last_part]} = Enum.split(parts, -1)

    # Extract modifier from the last part
    case Regex.split(~r{/(?![^[]*\])}, last_part, parts: 2) do
      [base_class, modifier] -> {variants, base_class, modifier}
      [base_class] -> {variants, base_class, nil}
    end
  end

  defp extract_important(base) do
    if String.starts_with?(base, "!") do
      {true, String.slice(base, 1..-1//1)}
    else
      {false, base}
    end
  end

  defp extract_negative(base) do
    if String.starts_with?(base, "-") do
      {true, String.slice(base, 1..-1//1)}
    else
      {false, base}
    end
  end

  def group(base_class) do
    class_groups = Config.class_groups()

    Enum.find_value(class_groups, fn {group, values} ->
      if match_group?(base_class, values), do: group
    end)
  end

  defp match_group?(base_class, values) when is_list(values) do
    Enum.any?(values, &match_value?(base_class, &1))
  end

  defp match_value?(base_class, value) when is_binary(value) do
    base_class == value
  end

  defp match_value?(base_class, {prefix, sub_values}) when is_binary(prefix) do
    if String.starts_with?(base_class, "#{prefix}-") do
      remaining = String.replace_prefix(base_class, "#{prefix}-", "")
      match_sub_values?(remaining, sub_values)
    else
      false
    end
  end

  defp match_value?(base_class, value) when is_function(value, 1) do
    value.(base_class)
  end

  defp match_sub_values?(remaining, sub_values) when is_list(sub_values) do
    Enum.any?(sub_values, fn
      sub_value when is_binary(sub_value) -> remaining == sub_value
      sub_value when is_function(sub_value, 1) -> sub_value.(remaining)
      {nested_prefix, nested_values} -> match_value?(remaining, {nested_prefix, nested_values})
    end)
  end

  defp overrides(group) do
    Config.group_overrides()
    |> Enum.find_value(fn {g, override} -> if g == group, do: override end)
  end
end
