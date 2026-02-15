defmodule CloseTheLoop.Feedback.IssueCategory do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Feedback,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "issue_categories"
    repo CloseTheLoop.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:key, :label, :active]
    end

    update :update do
      accept [:label, :active]
    end
  end

  policies do
    # MVP: allow access; tighten later with roles/org membership.
    policy always() do
      authorize_if always()
    end
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_primary_key :id

    # Stable identifier used by the AI prompt + stored on Issue.category.
    attribute :key, :string do
      allow_nil? false
      public? true
      constraints match: ~r/^[a-z0-9_]+$/
    end

    # Human-friendly label shown in the UI.
    attribute :label, :string do
      allow_nil? false
      public? true
    end

    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_key, [:key]
  end
end
