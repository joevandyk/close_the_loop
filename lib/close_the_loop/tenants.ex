defmodule CloseTheLoop.Tenants do
  use Ash.Domain,
    otp_app: :close_the_loop

  resources do
    resource CloseTheLoop.Tenants.Organization
  end

  @doc """
  Generate a safe Postgres schema name for schema-based multitenancy.

  We avoid hyphens (UUIDs) because unquoted schema names can't contain them.
  """
  def generate_tenant_schema do
    "org_" <> (Ash.UUID.generate() |> String.replace("-", ""))
  end
end
