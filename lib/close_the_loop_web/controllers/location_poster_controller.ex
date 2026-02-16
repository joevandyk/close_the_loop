defmodule CloseTheLoopWeb.LocationPosterController do
  use CloseTheLoopWeb, :controller

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Feedback.Location
  alias CloseTheLoop.Tenants.Organization
  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Tenants, as: TenantsDomain

  def show(conn, %{"org_id" => org_id, "id" => id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_flash(:error, "Please sign in to view this page.")
        |> redirect(to: ~p"/sign-in")

      user ->
        with {:ok, %Organization{} = org} <- TenantsDomain.get_organization_by_id(org_id),
             {:ok, _membership} <-
               Accounts.get_user_organization_by_user_org(user.id, org.id, authorize?: false),
             tenant when is_binary(tenant) <- org.tenant_schema,
             {:ok, %Location{} = location} <-
               FeedbackDomain.get_location_by_id(id, tenant: tenant) do
          poster = build_poster(org, tenant, location)

          conn
          |> assign(:page_title, "Printable poster - #{poster.location_name}")
          |> render(:show, poster: poster, org_id: org.id)
        else
          _ ->
            conn
            |> put_flash(:error, "You don't have access to that organization.")
            |> redirect(to: ~p"/app")
        end
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
