defmodule CloseTheLoop.Feedback.Report do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Feedback,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshEvents.Events]

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
      allow_nil? false
      public? true
    end
  end
end
