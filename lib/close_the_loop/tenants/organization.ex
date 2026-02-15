defmodule CloseTheLoop.Tenants.Organization do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Tenants,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "organizations"
    repo CloseTheLoop.Repo

    manage_tenant do
      # This creates/renames Postgres schemas and runs tenant migrations.
      template [:tenant_schema]
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:name, :tenant_schema]
    end

    update :update do
      accept [:name]
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

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :tenant_schema, :string do
      allow_nil? false
      public? true
      default &CloseTheLoop.Tenants.generate_tenant_schema/0
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_tenant_schema, [:tenant_schema]
  end
end
