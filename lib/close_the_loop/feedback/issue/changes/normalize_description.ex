defmodule CloseTheLoop.Feedback.Issue.Changes.NormalizeDescription do
  @moduledoc false

  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    desc = Ash.Changeset.get_attribute(changeset, :description)
    normalized = CloseTheLoop.Feedback.Text.normalize_for_dedupe(desc)

    Ash.Changeset.change_attribute(changeset, :normalized_description, normalized)
  end
end
