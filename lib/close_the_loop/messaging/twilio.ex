defmodule CloseTheLoop.Messaging.Twilio do
  @moduledoc false

  require Logger

  def send_sms(to, body) when is_binary(to) and is_binary(body) do
    from = System.get_env("TWILIO_PHONE_NUMBER") || ""
    sid = System.get_env("TWILIO_ACCOUNT_SID") || ""
    token = System.get_env("TWILIO_AUTH_TOKEN") || ""

    if from == "" or sid == "" or token == "" do
      Logger.info("SMS (dev noop) to=#{to} body=#{inspect(body)}")
      {:ok, :noop}
    else
      # ExTwilio reads credentials from config :ex_twilio (system tuples),
      # but we still treat missing env vars as a noop for local dev.
      ExTwilio.Message.create(to: to, from: from, body: body)
    end
  end
end
