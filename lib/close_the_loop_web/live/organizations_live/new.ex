defmodule CloseTheLoopWeb.OrganizationsLive.New do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_user_required}

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:form, org_form(user))
     |> assign(:error, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} current_scope={@current_scope}>
      <div class="max-w-lg mx-auto space-y-6">
        <div>
          <h1 class="text-2xl font-semibold">New organization</h1>
          <p class="mt-2 text-sm text-foreground-soft">
            Create a new organization and switch into it.
          </p>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <.form
            for={@form}
            id="new-org-form"
            phx-change="validate"
            phx-submit="save"
            class="space-y-4"
          >
            <.input
              field={@form[:name]}
              type="text"
              label="Organization name"
              placeholder="Acme Gym"
              required
            />

            <%= if @error do %>
              <.alert color="danger" hide_close>
                {@error}
              </.alert>
            <% end %>

            <div class="flex items-center justify-end gap-2">
              <.button navigate={~p"/app"} variant="ghost">Cancel</.button>
              <.button type="submit" variant="solid" color="primary" phx-disable-with="Creating...">
                Create organization
              </.button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"org" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, socket |> assign(:form, form) |> assign(:error, nil)}
  end

  def handle_event("save", %{"org" => params}, socket) when is_map(params) do
    user = socket.assigns.current_user

    with {:ok, %Organization{} = org} <-
           AshPhoenix.Form.submit(socket.assigns.form, params: params),
         {:ok, _membership} <-
           Accounts.create_user_organization(
             %{user_id: user.id, organization_id: org.id, role: :owner},
             actor: user
           ) do
      _ = Categories.ensure_defaults(org.tenant_schema)

      {:noreply,
       socket
       |> put_flash(:info, "Organization created.")
       |> push_navigate(to: ~p"/app/#{org.id}/onboarding")}
    else
      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, assign(socket, :form, form)}

      {:error, err} ->
        message =
          if Kernel.is_exception(err) do
            Exception.message(err)
          else
            inspect(err)
          end

        {:noreply, assign(socket, :error, message)}

      other ->
        {:noreply, assign(socket, :error, "Failed to create organization: #{inspect(other)}")}
    end
  end

  defp org_form(user) do
    AshPhoenix.Form.for_create(Organization, :create,
      as: "org",
      id: "org",
      actor: user,
      params: %{"name" => ""}
    )
    |> to_form()
  end
end
