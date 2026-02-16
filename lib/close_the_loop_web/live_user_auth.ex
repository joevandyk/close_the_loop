defmodule CloseTheLoopWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use CloseTheLoopWeb, :verified_routes

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Tenants

  # This is used for nested liveviews to fetch the current user.
  # To use, place the following at the top of that liveview:
  # on_mount {CloseTheLoopWeb.LiveUserAuth, :current_user}
  def on_mount(:current_user, _params, session, socket) do
    {:cont, AshAuthentication.Phoenix.LiveSession.assign_new_resources(socket, session)}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, assign(socket, :current_scope, %{actor: socket.assigns.current_user, tenant: nil})}
    else
      {:cont, socket |> assign(:current_user, nil) |> assign(:current_scope, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, assign(socket, :current_scope, %{actor: socket.assigns.current_user, tenant: nil})}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_org_required, params, _session, socket) do
    cond do
      !socket.assigns[:current_user] ->
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}

      true ->
        user = socket.assigns.current_user
        org_id = params["org_id"]

        with true <-
               (is_binary(org_id) and String.trim(org_id) != "") || {:error, :missing_org_id},
             {:ok, org} <- Tenants.get_organization_by_id(org_id),
             {:ok, membership} <-
               Accounts.get_user_organization_by_user_org(user.id, org.id, authorize?: false),
             tenant when is_binary(tenant) <- Map.get(org, :tenant_schema),
             true <- tenant != "" || {:error, :missing_tenant} do
          {:cont,
           socket
           |> assign(:current_org, org)
           |> assign(:current_role, membership.role)
           |> assign(:current_tenant, tenant)
           |> assign(:current_scope, %{actor: user, tenant: tenant})}
        else
          {:error, :missing_org_id} ->
            {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/app")}

          _ ->
            {:halt, Phoenix.LiveView.redirect(socket, to: default_post_login_path(user))}
        end
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      # If a signed-in user lands on an auth page (sign-in/register/reset),
      # send them into the app instead of bouncing back to marketing.
      {:halt,
       Phoenix.LiveView.redirect(socket,
         to: default_post_login_path(socket.assigns.current_user)
       )}
    else
      {:cont, socket |> assign(:current_user, nil) |> assign(:current_scope, nil)}
    end
  end

  defp default_post_login_path(user) do
    # Prefer a deterministic, non-tenant-dependent redirect:
    # - no org memberships => onboarding
    # - 1+ org memberships => org picker (or direct org URL if we want later)
    case Accounts.list_user_organizations(
           query: [filter: [user_id: user.id], sort: [inserted_at: :desc], limit: 2],
           authorize?: false
         ) do
      {:ok, []} -> ~p"/app/onboarding"
      {:ok, _} -> ~p"/app"
      _ -> ~p"/app/onboarding"
    end
  end
end
