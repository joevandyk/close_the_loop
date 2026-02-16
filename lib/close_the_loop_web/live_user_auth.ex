defmodule CloseTheLoopWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use CloseTheLoopWeb, :verified_routes

  # This is used for nested liveviews to fetch the current user.
  # To use, place the following at the top of that liveview:
  # on_mount {CloseTheLoopWeb.LiveUserAuth, :current_user}
  def on_mount(:current_user, _params, session, socket) do
    {:cont, AshAuthentication.Phoenix.LiveSession.assign_new_resources(socket, session)}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_org_required, _params, _session, socket) do
    cond do
      !socket.assigns[:current_user] ->
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}

      socket.assigns.current_user.organization_id ->
        {:cont, socket}

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
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
