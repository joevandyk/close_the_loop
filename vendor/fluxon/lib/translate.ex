defmodule Fluxon.Translate do
  @moduledoc false

  # Translates Phoenix validation errors and other messages.
  # - Uses configured translation function if available, otherwise processes placeholders directly
  # - For Phoenix errors {msg, opts}, replaces placeholders like %{count} with actual values
  # - Falls back to string conversion for any other input format
  def translate({msg, opts} = params) when is_binary(msg) do
    if translate_function = Application.get_env(:fluxon, :translate_function) do
      translate_function.(params)
    else
      # Process placeholders when no translation function is configured
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
      end)
    end
  end

  def translate(msg) do
    if translate_function = Application.get_env(:fluxon, :translate_function) do
      translate_function.(msg)
    else
      to_string(msg)
    end
  end
end
