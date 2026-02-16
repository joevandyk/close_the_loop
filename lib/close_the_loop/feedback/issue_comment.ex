defmodule CloseTheLoop.Feedback.IssueComment do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Feedback,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshEvents.Events]

  postgres do
    table "issue_comments"
    repo CloseTheLoop.Repo
  end

  events do
    event_log(CloseTheLoop.Events.Event)
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :issue_id,
        :body,
        :author_user_id,
        :author_email
      ]
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
      public? false
    end

    # Users live in the public schema; store identifiers without FK constraints.
    attribute :author_user_id, :uuid do
      allow_nil? true
      public? false
    end

    attribute :author_email, :string do
      allow_nil? true
      public? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :issue, CloseTheLoop.Feedback.Issue do
      allow_nil? false
      public? false
    end
  end
end
