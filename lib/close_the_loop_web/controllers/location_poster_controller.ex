defmodule CloseTheLoopWeb.LocationPosterController do
  use CloseTheLoopWeb, :controller

  alias CloseTheLoop.Feedback.Location
  alias CloseTheLoop.Tenants.Organization
  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Tenants, as: TenantsDomain

  def show(conn, %{"id" => id}) do
    user = conn.assigns[:current_user]

    with %{organization_id: org_id} when not is_nil(org_id) <- user,
         {:ok, %Organization{} = org} <- TenantsDomain.get_organization_by_id(org_id),
         tenant when is_binary(tenant) <- org.tenant_schema,
         {:ok, %Location{} = location} <- FeedbackDomain.get_location_by_id(id, tenant: tenant) do
      poster = build_poster(org, tenant, location)

      conn
      |> assign(:page_title, "Printable poster - #{poster.location_name}")
      |> render(:show, poster: poster)
    else
      _ ->
        conn
        |> put_flash(:error, "Please sign in to view this page.")
        |> redirect(to: ~p"/sign-in")
    end
  end

  defp build_poster(org, tenant, location) do
    reporter_link = CloseTheLoopWeb.Endpoint.url() <> "/r/#{tenant}/#{location.id}"

    %{
      org_name: org.name,
      location_name: location.full_path || location.name,
      reporter_link: reporter_link,
      qr_svg_data_uri: CloseTheLoopWeb.QRCode.svg_data_uri(reporter_link)
    }
  end
end
