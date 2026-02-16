defmodule CloseTheLoopWeb.TimeHelpers do
  @moduledoc """
  Small, shared time formatting helpers for templates.

  We keep this as a dedicated module so `CloseTheLoopWeb` can import it for
  LiveViews/components without repeating helper functions across modules.
  """

  @doc """
  Convert common date/time structs (and strings) to ISO8601.

  Returns `nil` for `nil` so HEEx can omit the attribute entirely.
  """
  def iso8601(nil), do: nil
  def iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  def iso8601(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  def iso8601(%Date{} = d), do: Date.to_iso8601(d)
  def iso8601(dt) when is_binary(dt), do: dt
  def iso8601(dt), do: to_string(dt)
end
