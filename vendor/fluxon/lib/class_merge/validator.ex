defmodule Fluxon.ClassMerge.Validator do
  @moduledoc false

  def any?(_), do: true

  def arbitrary?(v), do: Regex.match?(~r/^\[(?:([a-z-]+):)?(.+)\]$/i, v)

  def arbitrary_length?(v) do
    case extract_arbitrary_value(v) do
      {:ok, value} ->
        String.starts_with?(value, "length:") ||
          Regex.match?(
            ~r/^(\d+\.?\d*|\.\d+)(%|px|r?em|[sdl]?v([hwib]|min|max)|pt|pc|in|cm|mm|cap|ch|ex|r?lh|cq(w|h|i|b|min|max))$|\b(calc|min|max|clamp)\([^)]+\)|^0$/,
            value
          )

      :error ->
        false
    end
  end

  def arbitrary_color?(v) do
    case extract_arbitrary_value(v) do
      {:ok, value} ->
        String.starts_with?(value, "color:") || Regex.match?(~r/(#[0-9a-fA-F]{3,8}|rgba?\([^)]+\)|hsl\([^)]+\))/, value)

      :error ->
        false
    end
  end

  def arbitrary_position?(v) do
    case extract_arbitrary_value(v) do
      {:ok, value} -> String.starts_with?(value, "position:")
      :error -> false
    end
  end

  def arbitrary_image?(v) do
    case extract_arbitrary_value(v) do
      {:ok, value} ->
        Regex.match?(
          ~r/^(url|image|image-set|cross-fade|element|(repeating-)?(linear|radial|conic)-gradient)\(.+\)$/,
          value
        )

      :error ->
        false
    end
  end

  def arbitrary_size?(v) do
    case extract_arbitrary_value(v) do
      {:ok, value} ->
        # Accept percentage: prefix values
        # Accept length: prefix values
        # Accept size-related patterns but exclude color patterns
        String.starts_with?(value, "percentage:") ||
          String.starts_with?(value, "length:") ||
          (Regex.match?(
             ~r/^(\d+(%|px|r?em|[sdl]?v([hwib]|min|max)|pt|pc|in|cm|mm|cap|ch|ex|r?lh|cq(w|h|i|b|min|max))(_\d+(%|px|r?em|[sdl]?v([hwib]|min|max)|pt|pc|in|cm|mm|cap|ch|ex|r?lh|cq(w|h|i|b|min|max)))*|auto|cover|contain)$/,
             value
           ) &&
             !arbitrary_color?("[#{value}]"))

      :error ->
        false
    end
  end

  def arbitrary_text_color?(value) do
    arbitrary_color?(value) and not arbitrary_length?(value)
  end

  def integer?(value), do: match_parse?(&Integer.parse/1, value)
  def float?(value), do: match_parse?(&Float.parse/1, normalize_float(value))
  def ratio?(value), do: Regex.match?(~r/^\d+\/\d+$/, value)
  def number?(value), do: integer?(value) || float?(value)
  def tshirt_size?(value), do: Regex.match?(~r/^(\d+)?(xs|sm|md|lg|xl)$/, value)

  # Private helpers
  defp extract_arbitrary_value(value) do
    case Regex.run(~r/^\[(?:([a-z-]+):)?(.+)\]$/i, value) do
      [_, "", extracted] -> {:ok, extracted}
      [_, label, extracted] -> {:ok, "#{label}:#{extracted}"}
      _ -> :error
    end
  end

  defp match_parse?(parse_fn, value) do
    case parse_fn.(value) do
      {_value, ""} -> true
      _ -> false
    end
  end

  defp normalize_float(value) do
    if Regex.match?(~r/^\.\d+$/, value), do: "0" <> value, else: value
  end
end
