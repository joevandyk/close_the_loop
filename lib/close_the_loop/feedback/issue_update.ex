defmodule CloseTheLoop.Feedback.IssueUpdate do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Feedback,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshEvents.Events]

  postgres do
    table "issue_updates"
    repo CloseTheLoop.Repo
  end

  events do
    event_log(CloseTheLoop.Events.Event)
    only_actions([:create])
    create_timestamp :inserted_at
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:message, :sent_at, :issue_id]
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

    attribute :message, :string do
      allow_nil? false
      public? true
    end

    attribute :sent_at, :utc_datetime_usec do
      allow_nil? true
      public? true
    end

    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :issue, CloseTheLoop.Feedback.Issue do
      allow_nil? false
      public? true
    end
  end
end
