defmodule CloseTheLoop.Accounts.OrganizationInvitation.Senders.SendInvitationEmail do
  @moduledoc """
  Sends an organization invitation email.
  """

  use AshAuthentication.Sender
  use CloseTheLoopWeb, :verified_routes

  import Swoosh.Email

  alias CloseTheLoop.Mailer
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def send(email, token, opts) when is_binary(token) do
    org = Keyword.fetch!(opts, :organization)
    inviter = Keyword.get(opts, :inviter)

    new()
    |> from(Mailer.default_from())
    |> to(to_string(email))
    |> subject("You've been invited to join #{org_subject(org)}")
    |> html_body(body(email: email, token: token, organization: org, inviter: inviter))
    |> Mailer.deliver!()
  end

  defp org_subject(%Organization{name: name}) when is_binary(name) and name != "", do: name
  defp org_subject(_), do: "an organization"

  defp inviter_name(inviter) do
    name = inviter && Map.get(inviter, :name)

    cond do
      is_binary(name) and String.trim(name) != "" ->
        String.trim(name)

      inviter && Map.get(inviter, :email) ->
        to_string(Map.get(inviter, :email))

      true ->
        "Someone"
    end
  end

  defp body(params) do
    accept_url = url(~p"/invites/#{params[:token]}")

    """
    <p>Hello, #{params[:email]}!</p>
    <p>#{inviter_name(params[:inviter])} invited you to join #{params[:organization].name}.</p>
    <p>To accept the invitation, open this link:</p>
    <p><a href="#{accept_url}">#{accept_url}</a></p>
    """
  end
end
