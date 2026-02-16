defmodule CloseTheLoop.Events do
  use Ash.Domain,
    otp_app: :close_the_loop

  resources do
    resource CloseTheLoop.Events.Event do
      define :list_events, action: :read
    end
  end
end
