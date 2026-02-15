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

      accept [
        :key,
        :label,
        :active,
        :description,
        :ai_guidance,
        :ai_include_keywords,
        :ai_exclude_keywords,
        :ai_examples
      ]
    end

    update :update do
      primary? true

      accept [
        :label,
        :active,
        :description,
        :ai_guidance,
        :ai_include_keywords,
        :ai_exclude_keywords,
        :ai_examples
      ]
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

    # Optional longer description shown in settings and used by AI.
    attribute :description, :string do
      allow_nil? true
      public? true
    end

    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end

    # Additional context that helps the AI choose the right category.
    #
    # These are all optional, but can materially improve classification quality:
    # - include/exclude keywords to disambiguate similar categories
    # - examples of real reports that should (or should not) map here
    attribute :ai_guidance, :string do
      allow_nil? true
      public? true
    end

    attribute :ai_include_keywords, :string do
      allow_nil? true
      public? true
    end

    attribute :ai_exclude_keywords, :string do
      allow_nil? true
      public? true
    end

    attribute :ai_examples, :string do
      allow_nil? true
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_key, [:key]
  end
end
