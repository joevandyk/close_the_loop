defmodule CloseTheLoopWeb.SettingsLive.Team do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Accounts.OrganizationInvitation

  @impl true
  def mount(_params, _session, socket) do
    org = socket.assigns.current_org
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:invite_error, nil)
      |> assign(:pending_error, nil)
      |> assign(:members_error, nil)

    if socket.assigns.current_role != :owner do
      {:ok,
       socket
       |> put_flash(:error, "Only organization owners can invite teammates.")
       |> push_navigate(to: ~p"/app/#{org.id}/settings")}
    else
      pending_invites = list_pending_invites(org.id, user)
      members = list_members(org.id, user)

      {:ok,
       socket
       |> assign(:invite_form, invite_form(org.id, user))
       |> assign(:pending_invites, pending_invites)
       |> assign(:memberships, members)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_user={@current_user}
      current_scope={@current_scope}
      org={@current_org}
    >
      <div class="max-w-4xl mx-auto space-y-8">
        <div class="flex items-start justify-between gap-4">
          <div>
            <h1 class="text-2xl font-semibold">Team</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              Invite teammates to join this organization.
            </p>
          </div>

          <.button navigate={~p"/app/#{@current_org.id}/settings"} variant="ghost">Back</.button>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Invite someone</h2>
          <p class="mt-2 text-sm text-foreground-soft">
            We'll email them a secure link to accept the invitation.
          </p>

          <.form
            for={@invite_form}
            id="org-invite-form"
            phx-change="validate_invite"
            phx-submit="send_invite"
            class="mt-4 space-y-4"
          >
            <.input
              field={@invite_form[:email]}
              type="email"
              label="Email"
              placeholder="teammate@example.com"
              autocomplete="email"
              required
            />

            <.select
              field={@invite_form[:role]}
              label="Role"
              options={[{"Staff", "staff"}, {"Owner", "owner"}]}
              help_text="Owners can manage settings and invite others."
            />

            <input type="hidden" name={@invite_form[:organization_id].name} value={@current_org.id} />

            <.alert :if={@invite_error} color="danger" hide_close>
              {@invite_error}
            </.alert>

            <.button
              type="submit"
              variant="solid"
              color="primary"
              class="w-full"
              phx-disable-with="Sending..."
            >
              Send invite
            </.button>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-sm font-semibold">Pending invitations</h2>
              <p class="mt-2 text-sm text-foreground-soft">
                Invites expire after 7 days.
              </p>
            </div>
          </div>

          <.alert :if={@pending_error} color="danger" hide_close class="mt-4">
            {@pending_error}
          </.alert>

          <div :if={@pending_invites == []} class="mt-4 text-sm text-foreground-soft">
            No pending invitations.
          </div>

          <.table :if={@pending_invites != []} class="mt-4">
            <.table_head>
              <:col>Email</:col>
              <:col>Role</:col>
              <:col>Expires</:col>
              <:col></:col>
            </.table_head>
            <.table_body>
              <.table_row :for={invite <- @pending_invites} id={"invite-#{invite.id}"}>
                <:cell>{to_string(invite.email)}</:cell>
                <:cell>{invite.role}</:cell>
                <:cell>{expires_label(invite)}</:cell>
                <:cell class="text-right">
                  <.button
                    variant="ghost"
                    color="danger"
                    size="sm"
                    phx-click="revoke_invite"
                    phx-value-id={invite.id}
                  >
                    Revoke
                  </.button>
                </:cell>
              </.table_row>
            </.table_body>
          </.table>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Members</h2>
          <p class="mt-2 text-sm text-foreground-soft">
            Everyone who can access this organization.
          </p>

          <.alert :if={@members_error} color="danger" hide_close class="mt-4">
            {@members_error}
          </.alert>

          <div :if={@memberships == []} class="mt-4 text-sm text-foreground-soft">
            No members found.
          </div>

          <.table :if={@memberships != []} class="mt-4">
            <.table_head>
              <:col>Name</:col>
              <:col>Email</:col>
              <:col>Role</:col>
            </.table_head>
            <.table_body>
              <.table_row :for={m <- @memberships} id={"member-#{m.id}"}>
                <:cell>{m.user && (m.user.name || "—")}</:cell>
                <:cell>{m.user && to_string(m.user.email)}</:cell>
                <:cell>{m.role}</:cell>
              </.table_row>
            </.table_body>
          </.table>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate_invite", %{"invite" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.invite_form, params)
    {:noreply, socket |> assign(:invite_form, form) |> assign(:invite_error, nil)}
  end

  def handle_event("send_invite", %{"invite" => params}, socket) when is_map(params) do
    user = socket.assigns.current_user
    org = socket.assigns.current_org

    case AshPhoenix.Form.submit(socket.assigns.invite_form, params: params) do
      {:ok, %OrganizationInvitation{}} ->
        pending_invites = list_pending_invites(org.id, user)

        {:noreply,
         socket
         |> put_flash(:info, "Invitation sent.")
         |> assign(:invite_form, invite_form(org.id, user))
         |> assign(:pending_invites, pending_invites)
         |> assign(:invite_error, nil)}

      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, assign(socket, :invite_form, form)}

      {:error, err} ->
        {:noreply, assign(socket, :invite_error, error_message(err))}
    end
  end

  def handle_event("revoke_invite", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    org = socket.assigns.current_org

    invite =
      Enum.find(socket.assigns.pending_invites, fn invite ->
        to_string(invite.id) == to_string(id)
      end)

    case invite do
      %OrganizationInvitation{} = invite ->
        case Accounts.revoke_organization_invitation(invite, %{}, actor: user) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Invitation revoked.")
             |> assign(:pending_invites, list_pending_invites(org.id, user))}

          {:error, err} ->
            {:noreply, assign(socket, :pending_error, error_message(err))}
        end

      _ ->
        {:noreply, socket}
    end
  end

  defp invite_form(org_id, user) do
    AshPhoenix.Form.for_create(OrganizationInvitation, :invite,
      as: "invite",
      id: "invite",
      actor: user,
      params: %{"organization_id" => org_id, "email" => "", "role" => "staff"}
    )
    |> to_form()
  end

  defp list_pending_invites(org_id, user) do
    case Accounts.list_pending_organization_invitations(%{organization_id: org_id},
           actor: user,
           authorize?: false
         ) do
      {:ok, invites} when is_list(invites) ->
        invites

      {:error, _err} ->
        []
    end
  end

  defp list_members(org_id, user) do
    case Accounts.list_user_organizations(
           query: [filter: [organization_id: org_id], sort: [inserted_at: :asc], limit: 250],
           load: [user: [:name, :email]],
           actor: user,
           authorize?: false
         ) do
      {:ok, memberships} when is_list(memberships) ->
        memberships

      {:error, _err} ->
        []
    end
  end

  defp expires_label(%OrganizationInvitation{expires_at: %DateTime{} = expires_at}) do
    DateTime.to_date(expires_at) |> Date.to_iso8601()
  end

  defp expires_label(_), do: "—"

  defp error_message(%Ash.Error.Forbidden{errors: [%{message: message} | _]})
       when is_binary(message),
       do: message

  defp error_message(%Ash.Error.Invalid{errors: [%{message: message} | _]})
       when is_binary(message),
       do: message

  defp error_message(err) when Kernel.is_exception(err), do: Exception.message(err)
  defp error_message(_), do: "Something went wrong. Please try again."
end
