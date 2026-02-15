defmodule CloseTheLoop.Messaging.Phone do
  @moduledoc """
  Basic phone normalization/validation for SMS.

  MVP rule: accept E.164 numbers only (e.g. +15555555555).
  We normalize common punctuation/spaces, but we do not guess country codes.
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
        |> String.replace(~r/[\s\-\(\)\.]+/u, "")

      case normalized do
        "+" <> digits ->
          if digits =~ ~r/^\d{10,15}$/ do
            {:ok, "+" <> digits}
          else
            {:error, error_message()}
          end

        _ ->
          {:error, error_message()}
      end
    end
  end

  defp error_message do
    "Enter a valid phone number with country code, like +15555555555."
  end
end
