defmodule CloseTheLoop.Mailer do
  use Swoosh.Mailer, otp_app: :close_the_loop

  def default_from do
    name =
      (System.get_env("CTL_MAIL_FROM_NAME") || "")
      |> String.trim()
      |> case do
        "" -> "CloseTheLoop"
        val -> val
      end

    email =
      (System.get_env("CTL_MAIL_FROM_EMAIL") || "")
      |> String.trim()
      |> case do
        "" -> "noreply@close-the-loop.local"
        val -> val
      end

    {name, email}
  end
end
