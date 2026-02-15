defmodule CloseTheLoopWeb.OnboardingLive do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_user_required}

  alias CloseTheLoop.Accounts.User
  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Feedback.Location
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    if user.organization_id do
      {:ok, push_navigate(socket, to: ~p"/app/issues")}
    else
      {:ok,
       socket
       |> assign(:org_name, "")
       |> assign(:error, nil)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto">
      <h1 class="text-2xl font-semibold">Set up your business</h1>
      <p class="text-base-content/70 mt-2">
        Create your organization to start receiving reports.
      </p>

      <.form for={%{}} as={:onboarding} phx-submit="save" class="mt-6 space-y-4">
        <div class="form-control">
          <label class="label" for="org_name">
            <span class="label-text">Organization name</span>
          </label>
          <input
            id="org_name"
            name="org_name"
            type="text"
            value={@org_name}
            class="input input-bordered w-full"
            placeholder="Acme Gym"
            required
          />
        </div>

        <%= if @error do %>
          <div class="alert alert-error">
            <span>{@error}</span>
          </div>
        <% end %>

        <button type="submit" class="btn btn-primary w-full">
          Create organization
        </button>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("save", %{"org_name" => name}, socket) do
    user = socket.assigns.current_user
    name = String.trim(name || "")

    with true <- name != "" || {:error, "Organization name is required"},
         {:ok, %Organization{} = org} <- Ash.create(Organization, %{name: name}),
         {:ok, %Location{} = _location} <-
           Ash.create(Location, %{name: "General", full_path: "General"},
             tenant: org.tenant_schema
           ),
         {:ok, %User{} = updated_user} <-
           Ash.update(user, %{organization_id: org.id, role: :owner},
             action: :set_organization,
             actor: user
           ) do
      # Seed default categories for this business (best-effort).
      _ = Categories.ensure_defaults(org.tenant_schema)

      socket =
        socket
        |> assign(:current_user, updated_user)
        |> put_flash(:info, "Organization created. Your first location is ready.")
        |> push_navigate(to: ~p"/app/issues")

      # The reporter link is deterministic; we show it once on the issues page (later).
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
