defmodule CloseTheLoop.Accounts.OrganizationInvitation do
  use Ash.Resource,
    otp_app: :close_the_loop,
    domain: CloseTheLoop.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  import Ash.Expr

  alias CloseTheLoop.Accounts.OrganizationInvitation.Changes
  alias CloseTheLoop.Accounts.OrganizationInvitation.Validations
  alias CloseTheLoop.Accounts.User
  alias CloseTheLoop.Tenants.Organization

  postgres do
    table "organization_invitations"
    repo CloseTheLoop.Repo
  end

  actions do
    defaults [:read]

    read :by_token do
      get_by [:token]
    end

    read :pending_for_org do
      argument :organization_id, :uuid, allow_nil?: false

      filter expr(
               organization_id == ^arg(:organization_id) and
                 is_nil(accepted_at) and
                 is_nil(revoked_at)
             )

      prepare build(sort: [inserted_at: :desc])
    end

    create :invite do
      primary? true

      accept [:organization_id, :email, :role]

      validate {Validations.InviterIsOwner, []}

      change Changes.GenerateToken
      change relate_actor(:invited_by_user)
      change Changes.SendInvitationEmail
    end

    update :revoke do
      require_atomic? false
      accept []

      validate {Validations.InviterIsOwner, []}

      change Changes.SetRevokedAtNow
    end

    update :accept do
      require_atomic? false
      accept []

      validate {Validations.InviteeCanAccept, []}

      change Changes.AcceptInvitation
    end
  end

  policies do
    # MVP: allow access; action-level validations enforce permissions.
    policy always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      constraints trim?: true
    end

    attribute :token, :string do
      allow_nil? false
      sensitive? true
      constraints trim?: true
    end

    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:owner, :staff]
      default :staff
    end

    attribute :expires_at, :utc_datetime_usec do
      allow_nil? false
      default &__MODULE__.default_expires_at/0
    end

    attribute :accepted_at, :utc_datetime_usec
    attribute :revoked_at, :utc_datetime_usec

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :organization, Organization do
      allow_nil? false
      public? false
    end

    belongs_to :invited_by_user, User do
      allow_nil? false
      public? false
    end
  end

  identities do
    identity :unique_token, [:token]
  end

  def default_expires_at do
    # Default to 7 days from now.
    DateTime.utc_now() |> DateTime.add(7 * 24 * 60 * 60, :second)
  end
end
