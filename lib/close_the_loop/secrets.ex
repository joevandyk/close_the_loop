defmodule CloseTheLoop.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        CloseTheLoop.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:close_the_loop, :token_signing_secret)
  end
end
