defmodule CloseTheLoop.Accounts.UserOrganization do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "user_organizations"
    repo CloseTheLoop.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:user_id, :organization_id, :role]
    end

    update :update do
      primary? true
      accept [:role]
    end
  end

  policies do
    # MVP: allow access; tighten later with roles/org membership.
    policy always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:owner, :staff]
      default :staff
      public? false
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, CloseTheLoop.Accounts.User do
      allow_nil? false
      public? false
    end

    belongs_to :organization, CloseTheLoop.Tenants.Organization do
      allow_nil? false
      public? false
    end
  end

  identities do
    identity :unique_user_org, [:user_id, :organization_id]
  end
end
