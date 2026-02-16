defmodule CloseTheLoop.Messaging.OutboundSms do
  @moduledoc false

  alias CloseTheLoop.Messaging.OutboundDelivery
  alias CloseTheLoop.Workers.SendOutboundDeliveryWorker

  @spec queue_issue_update(String.t() | nil, String.t() | nil, String.t(), String.t()) ::
          {:ok, OutboundDelivery.t()} | {:error, any()}
  def queue_issue_update(tenant, issue_update_id, to, body)
      when (is_binary(tenant) or is_nil(tenant)) and is_binary(to) and is_binary(body) do
    from = System.get_env("TWILIO_PHONE_NUMBER") |> blank_to_nil()

    delivery =
      Ash.create!(
        OutboundDelivery,
        %{
          channel: :sms,
          status: :queued,
          provider: "twilio",
          to: to,
          from: from,
          body: body,
          tenant: tenant,
          template: "issue_update",
          related_resource: "issue_update",
          related_id: issue_update_id
        },
        authorize?: false
      )

    case enqueue_delivery(delivery) do
      {:ok, _job} ->
        {:ok, delivery}

      {:error, err} ->
        _ =
          Ash.update!(
            delivery,
            %{
              status: :failed,
              error: "failed to enqueue delivery job: #{inspect(err)}",
              provider_response: %{"enqueue_error" => inspect(err)}
            },
            authorize?: false
          )

        {:error, err}
    end
  end

  # Backwards-compatible name; this now queues and returns the created delivery.
  def deliver_issue_update(tenant, issue_update_id, to, body),
    do: queue_issue_update(tenant, issue_update_id, to, body)

  defp enqueue_delivery(%OutboundDelivery{} = delivery) do
    SendOutboundDeliveryWorker.new(%{"delivery_id" => delivery.id})
    |> Oban.insert()
  end

  defp blank_to_nil(nil), do: nil

  defp blank_to_nil(value) when is_binary(value) do
    value = String.trim(value)
    if value == "", do: nil, else: value
  end
end
