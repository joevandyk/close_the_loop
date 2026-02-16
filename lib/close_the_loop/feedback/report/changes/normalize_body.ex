defmodule CloseTheLoop.Feedback.Report.Changes.NormalizeBody do
  @moduledoc false

  use Ash.Resource.Change

  alias CloseTheLoop.Feedback.Text

  @impl true
  def change(changeset, _opts, _context) do
    body = Ash.Changeset.get_attribute(changeset, :body)
    normalized = Text.normalize_for_dedupe(body)
    Ash.Changeset.change_attribute(changeset, :normalized_body, normalized)
  end
end
