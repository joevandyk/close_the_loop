defmodule CloseTheLoopWeb.OnboardingLive.GettingStarted do
  use CloseTheLoopWeb, :live_view

  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Feedback.Location
  alias CloseTheLoopWeb.OnboardingProgress

  @impl true
  def mount(_params, _session, socket) do
    tenant = socket.assigns.current_tenant
    org = socket.assigns.current_org
    user = socket.assigns.current_user

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         {:ok, locations} <- list_locations(tenant) do
      locations = decorate_locations(locations, tenant, org.id)
      progress = socket.assigns[:onboarding_progress] || OnboardingProgress.load(tenant)

      {:ok,
       socket
       |> assign(:locations, locations)
       |> assign(:primary_location, List.first(locations))
       |> assign(:progress, progress)
       |> assign(:location_form, new_location_form(tenant, user))
       |> assign(:error, nil)}
    else
      _ ->
        {:ok, put_flash(socket, :error, "Failed to load getting started")}
    end
  end

  defp list_locations(tenant) do
    FeedbackDomain.list_locations(tenant: tenant, query: [sort: [inserted_at: :asc]])
  end

  defp decorate_locations(locations, tenant, org_id) do
    locations
    |> Enum.map(fn loc ->
      reporter_link = CloseTheLoopWeb.Endpoint.url() <> ~p"/r/#{tenant}/#{loc.id}/manual"
      poster_href = ~p"/app/#{org_id}/settings/locations/#{loc.id}/poster"

      %{
        id: loc.id,
        name: loc.name,
        full_path: loc.full_path,
        display_name: loc.full_path || loc.name,
        reporter_link: reporter_link,
        poster_href: poster_href
      }
    end)
    |> Enum.sort_by(& &1.display_name)
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
        <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <h1 class="text-2xl font-semibold">Getting started</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              You're 1 minute away from receiving your first report.
            </p>
          </div>

          <div class="flex items-center gap-2 shrink-0">
            <.button navigate={~p"/app/#{@current_org.id}"} variant="outline">
              Back to dashboard
            </.button>
            <.button navigate={~p"/app/#{@current_org.id}/issues"} variant="solid" color="primary">
              Open issues
            </.button>
          </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-2">
          <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-5">
            <div>
              <h2 class="text-sm font-semibold">Checklist</h2>
              <p class="mt-1 text-sm text-foreground-soft">
                Follow these in order. You can skip and come back anytime.
              </p>
            </div>

            <div class="space-y-4">
              <div class="flex items-start gap-3">
                <.icon
                  name={
                    if @progress.has_any_locations?,
                      do: "hero-check-circle",
                      else: "hero-circle-stack"
                  }
                  class={[
                    "size-5 mt-0.5 shrink-0",
                    @progress.has_any_locations? && "text-primary",
                    !@progress.has_any_locations? && "text-foreground-soft"
                  ]}
                />
                <div class="min-w-0 flex-1">
                  <div class="text-sm font-medium">Create your first location</div>
                  <p class="mt-1 text-sm text-foreground-soft">
                    Locations are used for posters and for organizing incoming reports.
                  </p>
                  <div class="mt-3">
                    <.form
                      for={@location_form}
                      id="getting-started-location-form"
                      phx-change="validate_location"
                      phx-submit="create_location"
                      class="space-y-3"
                    >
                      <div class="grid gap-3 sm:grid-cols-2">
                        <.input
                          id="getting-started-location-name"
                          field={@location_form[:name]}
                          type="text"
                          label="Location name"
                          placeholder="Downtown"
                          required
                        />
                        <.input
                          id="getting-started-location-full-path"
                          field={@location_form[:full_path]}
                          type="text"
                          label="Full path (optional)"
                          placeholder="Building A / Floor 2"
                        />
                      </div>

                      <.alert :if={@error} color="danger" hide_close>{@error}</.alert>

                      <div class="flex flex-wrap items-center gap-2">
                        <.button
                          type="submit"
                          variant="solid"
                          color="primary"
                          phx-disable-with="Creating..."
                        >
                          Create location
                        </.button>
                        <.button
                          navigate={~p"/app/#{@current_org.id}/settings/locations"}
                          variant="outline"
                        >
                          Manage locations
                        </.button>
                      </div>
                    </.form>
                  </div>
                </div>
              </div>

              <div class="flex items-start gap-3">
                <.icon
                  name="hero-printer"
                  class={[
                    "size-5 mt-0.5 shrink-0",
                    @progress.has_any_locations? && "text-foreground",
                    !@progress.has_any_locations? && "text-foreground-soft"
                  ]}
                />
                <div class="min-w-0 flex-1">
                  <div class="text-sm font-medium">Print your first QR poster</div>
                  <p class="mt-1 text-sm text-foreground-soft">
                    Print it and tape it up. That's how reports start coming in.
                  </p>
                  <div class="mt-3">
                    <.button
                      :if={@primary_location}
                      href={@primary_location.poster_href}
                      target="_blank"
                      rel="noreferrer"
                      variant="outline"
                    >
                      <.icon name="hero-printer" class="size-4" /> Open poster (PDF)
                    </.button>
                    <p :if={!@primary_location} class="text-sm text-foreground-soft">
                      Create a location to unlock poster printing.
                    </p>
                  </div>
                </div>
              </div>

              <div class="flex items-start gap-3">
                <.icon
                  name={
                    if @progress.has_any_reports?,
                      do: "hero-check-circle",
                      else: "hero-arrow-top-right-on-square"
                  }
                  class={[
                    "size-5 mt-0.5 shrink-0",
                    @progress.has_any_reports? && "text-primary",
                    !@progress.has_any_reports? && "text-foreground-soft"
                  ]}
                />
                <div class="min-w-0 flex-1">
                  <div class="text-sm font-medium">Submit a test report</div>
                  <p class="mt-1 text-sm text-foreground-soft">
                    Use the public reporter link to validate the full loop end-to-end.
                  </p>
                  <div class="mt-3 flex flex-wrap items-center gap-2">
                    <.button
                      :if={@primary_location}
                      href={@primary_location.reporter_link}
                      target="_blank"
                      rel="noreferrer"
                      variant="outline"
                    >
                      <.icon name="hero-arrow-top-right-on-square" class="size-4" />
                      Open reporter link
                    </.button>
                    <.button navigate={~p"/app/#{@current_org.id}/issues"} variant="outline">
                      View issues
                    </.button>
                    <p :if={!@primary_location} class="text-sm text-foreground-soft">
                      Create a location first.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="space-y-6">
            <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4">
              <h2 class="text-sm font-semibold">Quick links</h2>
              <div class="flex flex-wrap items-center gap-2">
                <.button
                  navigate={~p"/app/#{@current_org.id}/settings/organization"}
                  variant="outline"
                >
                  Organization branding
                </.button>
                <.button
                  navigate={~p"/app/#{@current_org.id}/settings/issue-categories"}
                  variant="outline"
                >
                  Issue categories
                </.button>
              </div>
            </div>

            <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4">
              <div class="flex items-center justify-between gap-4">
                <h2 class="text-sm font-semibold">Your locations</h2>
                <span class="text-xs text-foreground-soft">
                  {length(@locations)} total
                </span>
              </div>

              <div :if={@locations == []} class="text-sm text-foreground-soft">
                No locations yet.
              </div>

              <.navlist
                :if={@locations != []}
                class="space-y-3 rounded-none border-0 p-0 [&>*]:block"
              >
                <div
                  :for={loc <- @locations}
                  id={"getting-started-location-#{loc.id}"}
                  class="rounded-2xl border border-base bg-base p-5 shadow-base grid grid-cols-[1fr_auto] items-center gap-4"
                >
                  <div class="min-w-0">
                    <div
                      class="text-sm font-semibold text-foreground line-clamp-2"
                      title={loc.display_name}
                    >
                      {loc.display_name}
                    </div>
                  </div>
                  <div class="flex items-center justify-end gap-2 flex-nowrap">
                    <.button
                      href={loc.reporter_link}
                      target="_blank"
                      rel="noreferrer"
                      variant="outline"
                      size="sm"
                    >
                      <.icon name="hero-arrow-top-right-on-square" class="size-4" /> Reporter
                    </.button>
                    <.button
                      href={loc.poster_href}
                      target="_blank"
                      rel="noreferrer"
                      variant="outline"
                      size="sm"
                    >
                      <.icon name="hero-printer" class="size-4" /> Poster
                    </.button>
                  </div>
                </div>
              </.navlist>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate_location", %{"location" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.location_form, params)
    {:noreply, socket |> assign(:location_form, form) |> assign(:error, nil)}
  end

  @impl true
  def handle_event("create_location", %{"location" => params}, socket) when is_map(params) do
    tenant = socket.assigns.current_tenant
    org = socket.assigns.current_org
    user = socket.assigns.current_user

    params = normalize_location_params(params)

    case AshPhoenix.Form.submit(socket.assigns.location_form, params: params) do
      {:ok, %Location{}} ->
        {:ok, locations} = list_locations(tenant)
        locations = decorate_locations(locations, tenant, org.id)
        progress = OnboardingProgress.load(tenant)

        {:noreply,
         socket
         |> put_flash(:info, "Location created.")
         |> assign(:locations, locations)
         |> assign(:primary_location, List.first(locations))
         |> assign(:progress, progress)
         |> assign(:onboarding_progress, progress)
         |> assign(:location_form, new_location_form(tenant, user))
         |> assign(:error, nil)}

      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, assign(socket, :location_form, form)}

      {:error, err} ->
        {:noreply, assign(socket, :error, Exception.message(err))}
    end
  end

  defp normalize_location_params(params) when is_map(params) do
    name = params |> Map.get("name", "") |> to_string() |> String.trim()

    full_path =
      params
      |> Map.get("full_path", "")
      |> to_string()
      |> String.trim()

    params
    |> Map.put("name", name)
    |> Map.put("full_path", if(full_path == "", do: nil, else: full_path))
  end

  defp new_location_form(tenant, user) do
    AshPhoenix.Form.for_create(Location, :create,
      as: "location",
      id: "getting_started_location",
      tenant: tenant,
      actor: user,
      params: %{"name" => "", "full_path" => ""}
    )
    |> to_form()
  end
end
