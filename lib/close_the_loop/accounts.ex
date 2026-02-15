defmodule CloseTheLoop.Accounts do
  use Ash.Domain,
    otp_app: :close_the_loop

  resources do
    resource CloseTheLoop.Accounts.Token
    resource CloseTheLoop.Accounts.User
  end
end
