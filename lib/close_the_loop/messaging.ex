defmodule CloseTheLoop.Messaging do
  use Ash.Domain,
    otp_app: :close_the_loop,
    extensions: [AshPhoenix]

  resources do
    resource CloseTheLoop.Messaging.OutboundDelivery do
      define :list_outbound_deliveries, action: :read
      define :create_outbound_delivery, action: :create
      define :update_outbound_delivery, action: :update
    end
  end
end
