defmodule CloseTheLoop.Feedback.Issue do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Feedback,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "issues"
    repo CloseTheLoop.Repo
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true

      accept [
        :title,
        :description,
        :normalized_description,
        :status,
        :category,
        :location_id
      ]
    end

    update :set_status do
      argument :status, :atom do
        allow_nil? false
        constraints one_of: [:new, :acknowledged, :in_progress, :fixed]
      end

      change set_attribute(:status, arg(:status))
    end

    update :mark_duplicate do
      argument :duplicate_of_issue_id, :uuid do
        allow_nil? false
      end

      change set_attribute(:duplicate_of_issue_id, arg(:duplicate_of_issue_id))
    end

    update :edit_details do
      accept [:title, :description]
      require_atomic? false

      change fn changeset, _ctx ->
        desc = Ash.Changeset.get_attribute(changeset, :description)

        Ash.Changeset.change_attribute(
          changeset,
          :normalized_description,
          CloseTheLoop.Feedback.Text.normalize_for_dedupe(desc)
        )
      end
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

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      allow_nil? false
      public? true
    end

    attribute :normalized_description, :string do
      allow_nil? false
      public? false
    end

    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:new, :acknowledged, :in_progress, :fixed]
      default :new
      public? true
    end

    attribute :internal_notes, :string do
      allow_nil? true
      public? false
    end

    attribute :category, :string do
      allow_nil? true
      public? true
    end

    attribute :duplicate_of_issue_id, :uuid do
      allow_nil? true
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

    has_many :reports, CloseTheLoop.Feedback.Report do
      destination_attribute :issue_id
      public? true
    end

    has_many :updates, CloseTheLoop.Feedback.IssueUpdate do
      destination_attribute :issue_id
      public? true
    end

    has_many :comments, CloseTheLoop.Feedback.IssueComment do
      destination_attribute :issue_id
      public? false
    end

    belongs_to :duplicate_of, __MODULE__ do
      source_attribute :duplicate_of_issue_id
      allow_nil? true
      public? false
    end
  end

  aggregates do
    count :reporter_count, :reports do
      public? true
    end
  end
end
