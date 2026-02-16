defmodule CloseTheLoop.Feedback.Report do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Feedback,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshEvents.Events]

  alias CloseTheLoop.Feedback.Report.Changes

  postgres do
    table "reports"
    repo CloseTheLoop.Repo
  end

  events do
    event_log(CloseTheLoop.Events.Event)
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]

    create :create do
      primary? true

      accept [
        :body,
        :normalized_body,
        :source,
        :reporter_name,
        :reporter_email,
        :reporter_phone,
        :consent,
        :location_id,
        :issue_id
      ]

      change Changes.NormalizeBody
      change Changes.NormalizeReporterPhone
      change Changes.ResolveIssueAndLocation

      validate match(:reporter_email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/) do
        message "Email address looks invalid"
        where present(:reporter_email)
      end
    end

    create :create_manual do
      accept [
        :body,
        :normalized_body,
        :reporter_name,
        :reporter_email,
        :reporter_phone,
        :consent,
        :location_id,
        :issue_id
      ]

      change set_attribute(:source, :manual)
      change Changes.NormalizeBody
      change Changes.NormalizeReporterPhone
      change Changes.ResolveIssueAndLocation

      validate match(:reporter_email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/) do
        message "Email address looks invalid"
        where present(:reporter_email)
      end
    end

    update :edit_details do
      accept [:body, :reporter_name, :reporter_email, :reporter_phone, :consent]

      require_atomic? false

      change Changes.NormalizeBody
      change Changes.NormalizeReporterPhone

      validate match(:reporter_email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/) do
        message "Email address looks invalid"
        where present(:reporter_email)
      end
    end

    update :reassign_issue do
      argument :issue_id, :uuid do
        allow_nil? false
      end

      # We must keep report.location_id consistent with the issue it belongs to.
      # This requires loading the issue, so this action cannot be fully atomic.
      require_atomic? false

      change CloseTheLoop.Feedback.Report.Changes.ReassignIssueAndLocation
    end
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_primary_key :id

    attribute :body, :string do
      allow_nil? false
      constraints min_length: 1, trim?: true
      public? true
    end

    attribute :normalized_body, :string do
      allow_nil? false
      public? false
    end

    attribute :source, :atom do
      allow_nil? false
      constraints one_of: [:qr, :sms, :manual]
      public? true
    end

    attribute :reporter_phone, :string do
      allow_nil? true
      public? false
    end

    attribute :reporter_name, :string do
      allow_nil? true
      public? false
    end

    attribute :reporter_email, :string do
      allow_nil? true
      public? false
    end

    attribute :consent, :boolean do
      allow_nil? false
      default false
      public? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :location, CloseTheLoop.Feedback.Location do
      allow_nil? false
      public? true
    end

    belongs_to :issue, CloseTheLoop.Feedback.Issue do
      # We always set this during the action (see ResolveIssueAndLocation),
      # but AshPhoenix form validation happens before submit, so we must not
      # require it at validate-time.
      allow_nil? true
      public? true
    end
  end
end
