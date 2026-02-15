defmodule CloseTheLoop.Feedback.Location do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Feedback,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "locations"
    repo CloseTheLoop.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:name, :full_path, :parent_id]
    end

    update :update do
      accept [:name, :full_path, :parent_id]
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

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :full_path, :string do
      allow_nil? true
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent, __MODULE__ do
      allow_nil? true
      public? true
    end

    has_many :children, __MODULE__ do
      destination_attribute :parent_id
      public? true
    end

    has_many :issues, CloseTheLoop.Feedback.Issue do
      destination_attribute :location_id
      public? true
    end
  end
end
