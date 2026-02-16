defmodule CloseTheLoop.Workers.SendOutboundDeliveryWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 10

  import Ash.Expr
  require Ash.Query

  alias CloseTheLoop.Messaging.OutboundDelivery
  alias CloseTheLoop.Messaging.Twilio

  @impl true
  def perform(%Oban.Job{args: %{"delivery_id" => delivery_id}}) do
    case get_delivery(delivery_id) do
      nil ->
        # Nothing to do (deleted, bad id, etc). Treat as success so Oban doesn't retry forever.
        :ok

      %OutboundDelivery{channel: :sms} = delivery ->
        send_sms_delivery(delivery)

      %OutboundDelivery{} ->
        # Only SMS is handled async today.
        :ok
    end
  end

  defp send_sms_delivery(%OutboundDelivery{} = delivery) do
    # Idempotency: do not re-send if we've already finalized.
    if delivery.status in [:sent, :noop] do
      :ok
    else
      result =
        try do
          Twilio.send_sms(to_string(delivery.to), to_string(delivery.body))
        rescue
          exception -> {:error, exception}
        catch
          kind, value -> {:error, {kind, value}}
        end

      case result do
        {:ok, :noop} ->
          _ =
            Ash.update!(
              delivery,
              %{
                status: :noop,
                provider_response: %{"noop" => true, "reason" => "missing_twilio_env"}
              },
              authorize?: false
            )

          :ok

        {:ok, response} ->
          _ =
            Ash.update!(
              delivery,
              %{
                status: :sent,
                provider_id: response_sid(response),
                provider_response: normalize_provider_response(response)
              },
              authorize?: false
            )

          :ok

        {:error, error} ->
          _ =
            Ash.update!(
              delivery,
              %{
                status: :failed,
                error: normalize_error(error),
                provider_response: %{"error" => inspect(error)}
              },
              authorize?: false
            )

          {:error, error}
      end
    end
  end

  defp get_delivery(delivery_id) do
    query =
      OutboundDelivery
      |> Ash.Query.filter(expr(id == ^delivery_id))

    case Ash.read_one(query, authorize?: false) do
      {:ok, delivery} -> delivery
      _ -> nil
    end
  end

  defp response_sid(%{sid: sid}) when is_binary(sid), do: sid
  defp response_sid(%{"sid" => sid}) when is_binary(sid), do: sid
  defp response_sid(_), do: nil

  defp normalize_provider_response(%_{} = struct),
    do: struct |> Map.from_struct() |> normalize_provider_response()

  defp normalize_provider_response(%{} = map), do: map
  defp normalize_provider_response(other), do: %{"raw" => inspect(other)}

  defp normalize_error(%{__exception__: true} = exception), do: Exception.message(exception)
  defp normalize_error({kind, value}), do: "#{kind}: #{inspect(value)}"
  defp normalize_error(other), do: inspect(other)
end
