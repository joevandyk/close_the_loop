defmodule CloseTheLoop.Feedback.Report.Changes.NormalizeReporterPhone do
  @moduledoc false

  use Ash.Resource.Change

  alias CloseTheLoop.Messaging.Phone

  @impl true
  def change(changeset, _opts, _context) do
    phone = Ash.Changeset.get_attribute(changeset, :reporter_phone)

    case Phone.normalize_e164(phone) do
      {:ok, normalized} ->
        Ash.Changeset.change_attribute(changeset, :reporter_phone, normalized)

      {:error, message} when is_binary(message) ->
        Ash.Changeset.add_error(changeset, field: :reporter_phone, message: message)
    end
  end
end
