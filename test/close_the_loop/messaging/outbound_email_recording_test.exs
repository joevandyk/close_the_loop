defmodule CloseTheLoop.Messaging.OutboundEmailRecordingTest do
  use CloseTheLoop.DataCase, async: true

  import Ash.Expr
  require Ash.Query

  alias CloseTheLoop.Accounts.User.Senders.SendMagicLinkEmail
  alias CloseTheLoop.Messaging.OutboundDelivery
  alias CloseTheLoop.TestHelpers

  test "records an outbound delivery when sending a magic link email" do
    email = TestHelpers.unique_email("magic-link")

    _ = SendMagicLinkEmail.send(email, "token-123", %{})

    query =
      OutboundDelivery
      |> Ash.Query.filter(expr(channel == :email and template == "magic_link" and to == ^email))

    {:ok, deliveries} = Ash.read(query, authorize?: false)
    assert [delivery] = deliveries

    assert delivery.subject == "Your login link"
    assert delivery.status == :sent
  end
end
