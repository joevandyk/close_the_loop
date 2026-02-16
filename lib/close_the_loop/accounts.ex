defmodule CloseTheLoop.Accounts do
  use Ash.Domain,
    otp_app: :close_the_loop,
    extensions: [AshPhoenix]

  resources do
    resource CloseTheLoop.Accounts.Token

    resource CloseTheLoop.Accounts.User do
      define :get_user_by_id, action: :read, get_by: [:id]
      define :get_user_by_email, action: :get_by_email
      define :list_users, action: :read

      define :update_user_profile, action: :update_profile
      define :change_user_email, action: :change_email
      define :change_user_password, action: :change_password
    end

    resource CloseTheLoop.Accounts.UserOrganization do
      define :get_user_organization_by_id, action: :read, get_by: [:id]

      define :get_user_organization_by_user_org,
        action: :read,
        get_by: [:user_id, :organization_id]

      define :list_user_organizations, action: :read
      define :create_user_organization, action: :create
      define :update_user_organization, action: :update
      define :destroy_user_organization, action: :destroy
    end

    resource CloseTheLoop.Accounts.OrganizationInvitation do
      define :get_organization_invitation_by_token, action: :by_token, args: [:token]
      define :list_pending_organization_invitations, action: :pending_for_org

      define :invite_user_to_organization, action: :invite
      define :accept_organization_invitation, action: :accept
      define :revoke_organization_invitation, action: :revoke
    end
  end
end
