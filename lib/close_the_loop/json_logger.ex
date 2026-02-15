# lib/close_the_loop/json_logger.ex
# Structured JSON logging for Phoenix
defmodule CloseTheLoop.JSONLogger do
  @moduledoc """
  JSON log formatter for structured logging.
  Required fields: timestamp, level, msg, request_id, env, app
  """

  def format(level, message, timestamp, metadata) do
    %{
      timestamp: format_timestamp(timestamp),
      level: to_string(level),
      msg: to_string(message),
      request_id: Keyword.get(metadata, :request_id),
      env: Application.get_env(:close_the_loop, :app_env, "local"),
      app: "close-the-loop"
    }
    |> maybe_add_metadata(metadata)
    |> Jason.encode!()
    |> Kernel.<>("\n")
  rescue
    _ -> "#{inspect({level, message, metadata})}\n"
  end

  defp format_timestamp({date, {hours, minutes, seconds, _microseconds}}) do
    {date, {hours, minutes, seconds}}
    |> NaiveDateTime.from_erl!()
    |> NaiveDateTime.to_iso8601()
  end

  defp maybe_add_metadata(log, metadata) do
    metadata
    |> Keyword.drop([:request_id])
    |> Enum.reduce(log, fn {k, v}, acc ->
      Map.put(acc, k, inspect(v))
    end)
  end
end
