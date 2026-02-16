defmodule CloseTheLoop.Tenants do
  use Ash.Domain,
    otp_app: :close_the_loop,
    extensions: [AshPhoenix]

  resources do
    resource CloseTheLoop.Tenants.Organization do
      define :get_organization_by_id, action: :read, get_by: [:id]
      define :get_organization_by_tenant_schema, action: :read, get_by: [:tenant_schema]

      define :create_organization, action: :create
      define :update_organization, action: :update
      define :destroy_organization, action: :destroy
    end
  end

  @doc """
  Generate a safe Postgres schema name for schema-based multitenancy.

  We avoid hyphens (UUIDs) because unquoted schema names can't contain them.
  """
  def generate_tenant_schema do
    "org_" <> (Ash.UUID.generate() |> String.replace("-", ""))
  end
end
