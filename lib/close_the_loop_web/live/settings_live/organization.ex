defmodule CloseTheLoopWeb.SettingsLive.Organization do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    case Ash.get(Organization, user.organization_id) do
      {:ok, %Organization{} = org} ->
        {:ok,
         socket
         |> assign(:org, org)
         |> assign(:tenant, org.tenant_schema)
         |> assign(:error, nil)
         |> assign(:org_name, org.name)
         |> assign(:public_display_name, org.public_display_name || "")
         |> assign(:reporter_tagline, org.reporter_tagline || "")
         |> assign(:reporter_footer_note, org.reporter_footer_note || "")}

      _ ->
        {:ok, put_flash(socket, :error, "Failed to load organization settings")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
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
          for={%{}}
          as={:org}
          id="org-basics-form"
          phx-submit="save_basics"
          class="mt-4 space-y-4"
        >
          <.input id="org_name" name="name" type="text" label="Name" value={@org_name} required />

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
          for={%{}}
          as={:brand}
          id="org-branding-form"
          phx-submit="save_branding"
          class="mt-4 space-y-4"
        >
          <.input
            id="org_public_display_name"
            name="public_display_name"
            type="text"
            label="Public display name"
            value={@public_display_name}
            placeholder={@org_name}
            help_text="Shown to reporters. Leave blank to use your organization name."
          />

          <.input
            id="org_reporter_tagline"
            name="reporter_tagline"
            type="text"
            label="Tagline"
            value={@reporter_tagline}
            placeholder="e.g. Thanks for helping us keep the gym in top shape."
          />

          <.textarea
            id="org_reporter_footer_note"
            name="reporter_footer_note"
            label="Footer note"
            value={@reporter_footer_note}
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
    """
  end

  @impl true
  def handle_event("save_basics", %{"name" => name}, socket) do
    org = socket.assigns.org
    name = String.trim(name || "")

    with true <- name != "" || {:error, "Name is required"},
         {:ok, %Organization{} = org} <- Ash.update(org, %{name: name}) do
      {:noreply,
       socket
       |> put_flash(:info, "Organization updated.")
       |> assign(:org, org)
       |> assign(:org_name, org.name)
       |> assign(:error, nil)}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, assign(socket, :error, msg)}

      {:error, err} ->
        {:noreply, assign(socket, :error, Exception.message(err))}

      other ->
        {:noreply, assign(socket, :error, "Failed to save: #{inspect(other)}")}
    end
  end

  @impl true
  def handle_event("save_branding", params, socket) do
    org = socket.assigns.org

    public_display_name =
      params |> Map.get("public_display_name", "") |> to_string() |> String.trim()

    reporter_tagline = params |> Map.get("reporter_tagline", "") |> to_string() |> String.trim()

    reporter_footer_note =
      params
      |> Map.get("reporter_footer_note", "")
      |> to_string()
      |> String.trim()

    case Ash.update(org, %{
           public_display_name: blank_to_nil(public_display_name),
           reporter_tagline: blank_to_nil(reporter_tagline),
           reporter_footer_note: blank_to_nil(reporter_footer_note)
         }) do
      {:ok, %Organization{} = org} ->
        {:noreply,
         socket
         |> put_flash(:info, "Branding updated.")
         |> assign(:org, org)
         |> assign(:public_display_name, org.public_display_name || "")
         |> assign(:reporter_tagline, org.reporter_tagline || "")
         |> assign(:reporter_footer_note, org.reporter_footer_note || "")
         |> assign(:error, nil)}

      {:error, msg} when is_binary(msg) ->
        {:noreply, assign(socket, :error, msg)}

      {:error, err} ->
        {:noreply, assign(socket, :error, Exception.message(err))}
    end
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(str), do: str
end
