defmodule CloseTheLoop.Accounts.User.Senders.SendPasswordResetEmail do
  @moduledoc """
  Sends a password reset email
  """

  use AshAuthentication.Sender
  use CloseTheLoopWeb, :verified_routes

  import Swoosh.Email

  alias CloseTheLoop.Mailer
  alias CloseTheLoop.Messaging.OutboundEmail

  @impl true
  def send(user, token, _) do
    email =
      new()
      |> from(Mailer.default_from())
      |> to(to_string(user.email))
      |> subject("Reset your password")
      |> html_body(body(token: token))

    OutboundEmail.deliver!(email,
      template: "password_reset",
      related_resource: "user",
      related_id: user.id
    )
  end

  defp body(params) do
    url = url(~p"/password-reset/#{params[:token]}")

    """
    <p>Click this link to reset your password:</p>
    <p><a href="#{url}">#{url}</a></p>
    """
  end
end
