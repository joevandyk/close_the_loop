defmodule CloseTheLoop.Messaging.OutboundEmail do
  @moduledoc false

  alias CloseTheLoop.Mailer
  alias CloseTheLoop.Messaging.OutboundDelivery

  @spec deliver!(Swoosh.Email.t(), keyword()) :: any()
  def deliver!(%Swoosh.Email{} = email, opts \\ []) when is_list(opts) do
    template = Keyword.get(opts, :template)
    tenant = Keyword.get(opts, :tenant)
    related_resource = Keyword.get(opts, :related_resource)
    related_id = Keyword.get(opts, :related_id)

    {to_value, from_value} = {format_addresses(email.to), format_addresses(email.from)}

    body =
      cond do
        is_binary(email.html_body) and String.trim(email.html_body) != "" ->
          email.html_body

        is_binary(email.text_body) and String.trim(email.text_body) != "" ->
          email.text_body

        true ->
          "(no body)"
      end

    delivery =
      Ash.create!(
        OutboundDelivery,
        %{
          channel: :email,
          status: :queued,
          provider: "swoosh",
          to: to_value,
          from: blank_to_nil(from_value),
          subject: blank_to_nil(email.subject),
          body: body,
          tenant: tenant,
          template: template,
          related_resource: related_resource,
          related_id: related_id
        },
        authorize?: false
      )

    try do
      result = Mailer.deliver!(email)

      _ =
        Ash.update!(
          delivery,
          %{
            status: :sent,
            provider_response: normalize_provider_response(result)
          },
          authorize?: false
        )

      result
    rescue
      exception ->
        _ =
          Ash.update!(
            delivery,
            %{
              status: :failed,
              error: Exception.message(exception),
              provider_response: %{"exception" => Exception.message(exception)}
            },
            authorize?: false
          )

        reraise exception, __STACKTRACE__
    catch
      kind, value ->
        _ =
          Ash.update!(
            delivery,
            %{
              status: :failed,
              error: "#{kind}: #{inspect(value)}",
              provider_response: %{"error" => inspect({kind, value})}
            },
            authorize?: false
          )

        :erlang.raise(kind, value, __STACKTRACE__)
    end
  end

  defp format_addresses(nil), do: ""
  defp format_addresses([]), do: ""

  defp format_addresses({name, address}) when is_binary(address) do
    if is_binary(name) and String.trim(name) != "" do
      "#{String.trim(name)} <#{address}>"
    else
      address
    end
  end

  defp format_addresses(address) when is_binary(address), do: address

  defp format_addresses(addresses) when is_list(addresses) do
    addresses
    |> Enum.map(fn
      {name, address} when is_binary(address) ->
        if is_binary(name) and String.trim(name) != "" do
          "#{String.trim(name)} <#{address}>"
        else
          address
        end

      address when is_binary(address) ->
        address

      other ->
        inspect(other)
    end)
    |> Enum.join(", ")
  end

  defp normalize_provider_response(%_{} = struct),
    do: struct |> Map.from_struct() |> normalize_provider_response()

  defp normalize_provider_response(%{} = map), do: map
  defp normalize_provider_response(other), do: %{"raw" => inspect(other)}

  defp blank_to_nil(nil), do: nil

  defp blank_to_nil(value) when is_binary(value) do
    value = String.trim(value)
    if value == "", do: nil, else: value
  end
end
