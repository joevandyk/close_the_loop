defmodule CloseTheLoop.TestHelpers do
  @moduledoc false

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Accounts.User
  alias CloseTheLoop.Repo

  def unique_email(prefix \\ "user") do
    "#{prefix}-#{System.unique_integer([:positive])}@example.com"
  end

  def insert_org!(tenant \\ "public", name \\ "Test Org") do
    org_id = Ash.UUID.generate()
    org_id_bin = Ecto.UUID.dump!(org_id)
    now = DateTime.utc_now()

    {1, _} =
      Repo.insert_all("organizations", [
        %{
          id: org_id_bin,
          name: name,
          tenant_schema: tenant,
          inserted_at: now,
          updated_at: now
        }
      ])

    %{id: org_id, tenant_schema: tenant, name: name}
  end

  def register_user!(email, password \\ "password1234") do
    {:ok, user} =
      Ash.create(
        User,
        %{
          email: email,
          password: password,
          password_confirmation: password
        },
        action: :register_with_password,
        context: %{private: %{ash_authentication?: true}}
      )

    user
  end

  def create_membership!(user, org_id, role \\ :owner) do
    {:ok, membership} =
      Accounts.create_user_organization(
        %{user_id: user.id, organization_id: org_id, role: role},
        actor: user
      )

    membership
  end
end
