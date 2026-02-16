defmodule CloseTheLoopWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use CloseTheLoopWeb, :verified_routes

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

  def on_mount(:live_org_required, _params, _session, socket) do
    cond do
      !socket.assigns[:current_user] ->
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}

      socket.assigns.current_user.organization_id ->
        user = socket.assigns.current_user

        case Tenants.get_organization_by_id(user.organization_id) do
          {:ok, org} ->
            tenant = org && Map.get(org, :tenant_schema)

            {:cont,
             socket
             |> assign(:current_org, org)
             |> assign(:current_tenant, tenant)
             |> assign(:current_scope, %{actor: user, tenant: tenant})}

          {:error, _err} ->
            # Best-effort: allow LiveView to handle empty/error states.
            {:cont,
             socket
             |> assign(:current_org, nil)
             |> assign(:current_tenant, nil)
             |> assign(:current_scope, %{actor: user, tenant: nil})}
        end

      true ->
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/app/onboarding")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      # If a signed-in user lands on an auth page (sign-in/register/reset),
      # send them into the app instead of bouncing back to marketing.
      to =
        if socket.assigns.current_user.organization_id do
          ~p"/app"
        else
          ~p"/app/onboarding"
        end

      {:halt, Phoenix.LiveView.redirect(socket, to: to)}
    else
      {:cont, socket |> assign(:current_user, nil) |> assign(:current_scope, nil)}
    end
  end
end
