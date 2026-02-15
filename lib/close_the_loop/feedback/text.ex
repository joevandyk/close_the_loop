defmodule CloseTheLoop.Feedback.Text do
  @moduledoc false

  @doc """
  Normalizes free-form text for deterministic comparisons/dedupe.

  Keep this stable: changes affect issue dedupe behavior.
  """
  @spec normalize_for_dedupe(String.t() | nil) :: String.t()
  def normalize_for_dedupe(nil), do: ""

  def normalize_for_dedupe(text) when is_binary(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, " ")
    |> String.trim()
  end
end
