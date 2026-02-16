defmodule CloseTheLoopWeb.OnboardingProgress do
  @moduledoc false

  alias CloseTheLoop.Feedback.{Location, Report}

  @spec load(binary()) :: %{
          locations_count: non_neg_integer(),
          reports_count: non_neg_integer(),
          has_any_locations?: boolean(),
          has_any_reports?: boolean(),
          complete?: boolean()
        }
  def load(tenant) when is_binary(tenant) do
    default = %{
      locations_count: 0,
      reports_count: 0,
      has_any_locations?: false,
      has_any_reports?: false,
      complete?: false
    }

    with {:ok, locations_count} <- Ash.count(Location, tenant: tenant),
         {:ok, reports_count} <- Ash.count(Report, tenant: tenant) do
      has_any_locations? = locations_count > 0
      has_any_reports? = reports_count > 0

      %{
        locations_count: locations_count,
        reports_count: reports_count,
        has_any_locations?: has_any_locations?,
        has_any_reports?: has_any_reports?,
        complete?: has_any_locations? and has_any_reports?
      }
    else
      _ -> default
    end
  end
end
