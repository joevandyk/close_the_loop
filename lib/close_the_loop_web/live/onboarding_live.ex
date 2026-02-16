defmodule CloseTheLoopWeb.OnboardingLive do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_user_required}

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    case Accounts.list_user_organizations(
           query: [filter: [user_id: user.id], limit: 1],
           authorize?: false
         ) do
      {:ok, [_ | _]} ->
        {:ok, push_navigate(socket, to: ~p"/app")}

      {:ok, []} ->
        {:ok,
         socket
         |> assign(:form, to_form(%{"org_name" => ""}, as: :onboarding))
         |> assign(:error, nil)}

      _ ->
        {:ok, push_navigate(socket, to: ~p"/app")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} current_scope={@current_scope}>
      <div class="max-w-lg mx-auto">
        <h1 class="text-2xl font-semibold">Set up your business</h1>
        <p class="text-foreground-soft mt-2">
          Create your organization to start receiving reports.
        </p>

        <.form for={@form} id="onboarding-form" phx-submit="save" class="mt-6 space-y-4">
          <.input
            field={@form[:org_name]}
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

          <.button type="submit" variant="solid" color="primary" class="w-full">
            Create organization
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("save", %{"onboarding" => %{"org_name" => name}}, socket) do
    user = socket.assigns.current_user
    name = String.trim(name || "")
    socket = assign(socket, :form, to_form(%{"org_name" => name}, as: :onboarding))

    with true <- name != "" || {:error, "Organization name is required"},
         {:ok, %Organization{} = org} <-
           CloseTheLoop.Tenants.create_organization(%{name: name}, actor: user),
         {:ok, _membership} <-
           Accounts.create_user_organization(
             %{user_id: user.id, organization_id: org.id, role: :owner},
             actor: user
           ) do
      # Seed default categories for this business (best-effort).
      _ = Categories.ensure_defaults(org.tenant_schema)

      socket =
        socket
        |> put_flash(:info, "Organization created. Next: add your first location.")
        |> push_navigate(to: ~p"/app/#{org.id}/onboarding")

      {:noreply, socket}
    else
      {:error, err} ->
        message =
          if Kernel.is_exception(err) do
            Exception.message(err)
          else
            inspect(err)
          end

        {:noreply, assign(socket, :error, message)}

      other ->
        {:noreply, assign(socket, :error, "Failed to onboard: #{inspect(other)}")}
    end
  end
end
