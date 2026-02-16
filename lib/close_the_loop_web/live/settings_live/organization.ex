defmodule CloseTheLoopWeb.SettingsLive.Organization do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Tenants.Organization
  @impl true
  def mount(_params, _session, socket) do
    org = socket.assigns.current_org
    tenant = socket.assigns.current_tenant
    user = socket.assigns.current_user

    case org do
      %Organization{} = org ->
        org_form = org_form(org, user)
        brand_form = brand_form(org, user)

        {:ok,
         socket
         |> assign(:org, org)
         |> assign(:tenant, tenant)
         |> assign(:error, nil)
         |> assign(:org_form, org_form)
         |> assign(:brand_form, brand_form)}

      _ ->
        {:ok, put_flash(socket, :error, "Failed to load organization settings")}
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
            <h1 class="text-2xl font-semibold">Organization</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              Manage your organization details and reporter page branding.
            </p>
          </div>

          <.button navigate={~p"/app/settings"} variant="ghost">Back</.button>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Basics</h2>

          <.form
            for={@org_form}
            id="org-basics-form"
            phx-change="validate"
            phx-submit="save_basics"
            class="mt-4 space-y-4"
          >
            <.input id="org_name" field={@org_form[:name]} type="text" label="Name" required />

            <div class="text-xs text-foreground-soft">
              Tenant: <span class="font-mono">{@tenant}</span>
            </div>

            <%= if @error do %>
              <.alert color="danger" hide_close>{@error}</.alert>
            <% end %>

            <.button
              type="submit"
              variant="solid"
              color="primary"
              class="w-full"
              phx-disable-with="Saving..."
            >
              Save
            </.button>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Reporter page branding</h2>
          <p class="mt-2 text-sm text-foreground-soft">
            This affects the public page reporters see at <span class="font-mono">/r/&lt;tenant&gt;/&lt;location&gt;</span>.
          </p>

          <.form
            for={@brand_form}
            id="org-branding-form"
            phx-submit="save_branding"
            class="mt-4 space-y-4"
          >
            <.input
              id="org_public_display_name"
              field={@brand_form[:public_display_name]}
              type="text"
              label="Public display name"
              placeholder={@org.name}
              help_text="Shown to reporters. Leave blank to use your organization name."
            />

            <.input
              id="org_reporter_tagline"
              field={@brand_form[:reporter_tagline]}
              type="text"
              label="Tagline"
              placeholder="e.g. Thanks for helping us keep the gym in top shape."
            />

            <.textarea
              id="org_reporter_footer_note"
              field={@brand_form[:reporter_footer_note]}
              label="Footer note"
              rows={3}
              placeholder="Optional. For example: For emergencies, call the front desk."
            />

            <%= if @error do %>
              <.alert color="danger" hide_close>{@error}</.alert>
            <% end %>

            <.button
              type="submit"
              variant="solid"
              color="primary"
              class="w-full"
              phx-disable-with="Saving..."
            >
              Save branding
            </.button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"org" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.org_form, params)
    {:noreply, socket |> assign(:org_form, form) |> assign(:error, nil)}
  end

  def handle_event("save_basics", %{"org" => params}, socket) when is_map(params) do
    user = socket.assigns.current_user

    case AshPhoenix.Form.submit(socket.assigns.org_form, params: params) do
      {:ok, %Organization{} = org} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organization updated.")
         |> assign(:org, org)
         |> assign(:org_form, org_form(org, user))
         |> assign(:error, nil)}

      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, assign(socket, :org_form, form)}

      {:error, err} ->
        {:noreply, assign(socket, :error, Exception.message(err))}
    end
  end

  @impl true
  def handle_event("save_branding", %{"brand" => params}, socket) when is_map(params) do
    user = socket.assigns.current_user

    socket =
      assign(socket, :brand_form, AshPhoenix.Form.validate(socket.assigns.brand_form, params))

    case AshPhoenix.Form.submit(socket.assigns.brand_form, params: params) do
      {:ok, %Organization{} = org} ->
        {:noreply,
         socket
         |> put_flash(:info, "Branding updated.")
         |> assign(:org, org)
         |> assign(:brand_form, brand_form(org, user))
         |> assign(:error, nil)}

      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, socket |> assign(:brand_form, form) |> assign(:error, nil)}

      {:error, err} ->
        message =
          if Kernel.is_exception(err) do
            Exception.message(err)
          else
            inspect(err)
          end

        {:noreply, assign(socket, :error, message)}
    end
  end

  defp org_form(%Organization{} = org, user) do
    AshPhoenix.Form.for_update(org, :update,
      as: "org",
      id: "org",
      actor: user,
      params: %{"name" => org.name}
    )
    |> to_form()
  end

  defp brand_form(%Organization{} = org, user) do
    AshPhoenix.Form.for_update(org, :update,
      as: "brand",
      id: "brand",
      actor: user,
      params: %{
        "public_display_name" => org.public_display_name,
        "reporter_tagline" => org.reporter_tagline,
        "reporter_footer_note" => org.reporter_footer_note
      }
    )
    |> to_form()
  end
end
