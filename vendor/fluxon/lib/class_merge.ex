defmodule Fluxon.ClassMerge do
  @moduledoc false

  alias Fluxon.ClassMerge.Class

  def merge(classes) when is_list(classes) do
    classes
    |> List.flatten()
    |> Enum.join(" ")
    |> merge()
  end

  def merge(classes) when is_binary(classes) do
    class_list = String.split(classes)

    class_list
    |> Enum.map(&Class.parse/1)
    |> merge_classes()
    |> reconstruct_class_string(class_list)
  end

  defp merge_classes(classified_classes) do
    classified_classes
    |> remove_leftmost_conflicts()
    |> merge_by_key()
    |> apply_overrides()
  end

  defp remove_leftmost_conflicts(classes) do
    classes
    |> Enum.reverse()
    |> Enum.reduce([], fn
      %{key: nil} = class, acc -> [class | acc]
      %{key: key} = class, acc -> if Enum.any?(acc, &(&1.key == key)), do: acc, else: [class | acc]
    end)
  end

  defp merge_by_key(classes) do
    Enum.reduce(classes, [], fn class, acc ->
      case Enum.find_index(acc, &(&1.key == class.key and not is_nil(&1.key))) do
        nil -> acc ++ [class]
        index -> List.update_at(acc, index, &resolve_conflicts([class, &1]))
      end
    end)
  end

  defp apply_overrides(classes) do
    Enum.reduce(classes, [], fn class, acc ->
      cond do
        is_nil(class.key) ->
          acc ++ [class]

        class.overrides ->
          filtered_acc = Enum.reject(acc, &should_override?(&1, class))
          filtered_acc ++ [class]

        Enum.any?(acc, &duplicate?(&1, class)) ->
          acc

        true ->
          acc ++ [class]
      end
    end)
  end

  defp should_override?(existing, new) do
    existing.group in new.overrides and existing.variants == new.variants
  end

  defp duplicate?(existing, new) do
    existing.key == new.key and existing.important == new.important
  end

  defp resolve_conflicts([new_class, existing_class]) do
    cond do
      new_class.important and not existing_class.important -> new_class
      not new_class.important and existing_class.important -> existing_class
      true -> new_class
    end
  end

  defp reconstruct_class_string(merged_classes, classes) do
    merged_class_set = MapSet.new(merged_classes, & &1.raw)

    classes
    |> Enum.uniq()
    |> Enum.filter(&MapSet.member?(merged_class_set, &1))
    |> Enum.join(" ")
  end
end
