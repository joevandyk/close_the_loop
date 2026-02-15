defmodule CloseTheLoop.Messaging.Phone do
  @moduledoc """
  Basic phone normalization/validation for SMS.

  We store phone numbers in E.164 format (e.g. `+14254207179`).

  UX rule:
  - If the user enters a 10-digit NANP number (US/Canada), we assume `+1`.
  - Otherwise, require an explicit country code (e.g. `+44...`).
  """

  @type normalized :: String.t() | nil

  @spec normalize_e164(String.t() | nil) :: {:ok, normalized} | {:error, String.t()}
  def normalize_e164(nil), do: {:ok, nil}

  def normalize_e164(phone) when is_binary(phone) do
    phone = String.trim(phone)

    if phone == "" do
      {:ok, nil}
    else
      normalized =
        phone
        # Keep this intentionally conservative: strip common separators only.
        |> String.replace(~r/[\s\-\(\)\.]+/u, "")

      case normalized do
        "+" <> digits ->
          if digits =~ ~r/^\d{10,15}$/ do
            {:ok, "+" <> digits}
          else
            {:error, error_message()}
          end

        # International dialing prefix (common outside US)
        "00" <> digits ->
          if digits =~ ~r/^\d{10,15}$/ do
            {:ok, "+" <> digits}
          else
            {:error, error_message()}
          end

        # US international dialing prefix
        "011" <> digits ->
          if digits =~ ~r/^\d{10,15}$/ do
            {:ok, "+" <> digits}
          else
            {:error, error_message()}
          end

        digits ->
          cond do
            # US/Canada (NANP) without country code
            digits =~ ~r/^\d{10}$/ ->
              {:ok, "+1" <> digits}

            # US/Canada with leading 1
            digits =~ ~r/^1\d{10}$/ ->
              {:ok, "+1" <> String.slice(digits, 1, 10)}

            true ->
              {:error, error_message()}
          end
      end
    end
  end

  defp error_message do
    "Enter a valid phone number. For international numbers, start with + and country code."
  end
end
