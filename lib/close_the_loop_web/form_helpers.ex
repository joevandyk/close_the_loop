defmodule CloseTheLoopWeb.FormHelpers do
  @moduledoc false

  @doc """
  Trim string values in a params map.

  Options:
  - `:only` - list of keys to trim (keys can be strings or atoms)
  - `:except` - list of keys to *not* trim (keys can be strings or atoms)
  """
  @spec trim_params(map(), keyword()) :: map()
  def trim_params(params, opts \\ []) when is_map(params) do
    only = opts[:only]
    except = MapSet.new(opts[:except] || [])

    Map.new(params, fn {k, v} ->
      should_trim? =
        cond do
          is_list(only) -> k in only
          true -> is_binary(v) and not MapSet.member?(except, k)
        end

      v = if should_trim? and is_binary(v), do: String.trim(v), else: v
      {k, v}
    end)
  end

  @doc """
  Convert empty strings to nil for the given keys.

  Call after `trim_params/2` if you want to treat cleared inputs as nil.
  """
  @spec blank_to_nil(map(), list()) :: map()
  def blank_to_nil(params, keys) when is_map(params) and is_list(keys) do
    Enum.reduce(keys, params, fn key, acc ->
      case Map.get(acc, key) do
        "" -> Map.put(acc, key, nil)
        _ -> acc
      end
    end)
  end
end
