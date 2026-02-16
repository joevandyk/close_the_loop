defmodule CloseTheLoop.Accounts do
  use Ash.Domain,
    otp_app: :close_the_loop

  resources do
    resource CloseTheLoop.Accounts.Token

    resource CloseTheLoop.Accounts.User do
      define :get_user_by_id, action: :read, get_by: [:id]
      define :get_user_by_email, action: :get_by_email

      define :update_user_profile, action: :update_profile
      define :change_user_email, action: :change_email
      define :change_user_password, action: :change_password
      define :set_user_organization, action: :set_organization
    end
  end
end
