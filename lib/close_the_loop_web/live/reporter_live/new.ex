defmodule CloseTheLoopWeb.ReporterLive.New do
  use CloseTheLoopWeb, :live_view

  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Tenants
  alias CloseTheLoop.Tenants.Organization
  alias CloseTheLoop.Feedback.Location
  @impl true
  def mount(%{"tenant" => tenant, "location_id" => location_id}, _session, socket) do
    socket =
      socket
      |> assign_new(:current_user, fn -> nil end)
      |> assign(:current_scope, %{actor: nil, tenant: tenant})
      |> assign(:tenant, tenant)
      |> assign(:location_id, location_id)
      |> assign(:org, get_org_by_tenant(tenant))
      |> assign(
        :report_form,
        report_form(tenant, location_id)
      )
      |> assign(:submitted, false)
      |> assign(:error, nil)

    case FeedbackDomain.get_location_by_id(location_id, tenant: tenant) do
      {:ok, %Location{} = location} ->
        {:ok, assign(socket, :location, location)}

      {:ok, nil} ->
        {:ok, assign(socket, :location, nil) |> assign(:error, "Unknown location")}

      {:error, err} ->
        {:ok, assign(socket, :location, nil) |> assign(:error, Exception.message(err))}
    end
  end

  defp get_org_by_tenant(tenant) when is_binary(tenant) do
    case Tenants.get_organization_by_tenant_schema(tenant) do
      {:ok, %Organization{} = org} -> org
      _ -> nil
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      variant={:reporter}
      flash={@flash}
      current_user={@current_user}
      current_scope={@current_scope}
      org={@org}
      location={@location}
    >
      <div class="space-y-5">
        <h2 class="text-2xl font-semibold tracking-tight">Report an issue</h2>

        <div class="rounded-2xl border border-base bg-base p-5 shadow-base">
          <%= if @submitted do %>
            <div class="space-y-4">
              <.alert color="success" hide_close>
                Got it. We'll update you.
              </.alert>

              <p class="text-sm text-foreground-soft">
                If you opted into text updates, we will send status changes to your phone.
              </p>

              <.button href={~p"/r/#{@tenant}/#{@location_id}"} variant="outline">
                Report another issue
              </.button>
            </div>
          <% else %>
            <.form
              for={@report_form}
              id="reporter-intake-form"
              phx-change="validate"
              phx-submit="submit"
              class="space-y-4"
            >
              <.textarea
                field={@report_form[:body]}
                label="What's wrong?"
                rows={4}
                placeholder="Cold water in the men's showers"
                required
              />

              <div class="space-y-2">
                <.input
                  field={@report_form[:reporter_name]}
                  type="text"
                  label="Your name"
                  sublabel="Optional"
                  autocomplete="name"
                />

                <.input
                  field={@report_form[:reporter_email]}
                  type="email"
                  label="Email"
                  sublabel="Optional"
                  autocomplete="email"
                  inputmode="email"
                  help_text="Only used if the business needs to follow up."
                />

                <.input
                  field={@report_form[:reporter_phone]}
                  type="tel"
                  label="Phone number"
                  sublabel="Optional"
                  placeholder="+15555550100"
                  inputmode="tel"
                  autocomplete="tel"
                  help_text="For international numbers, start with + and country code."
                />

                <.checkbox
                  field={@report_form[:consent]}
                  label="I agree to receive text updates about this issue."
                />
              </div>

              <%= if @error do %>
                <.alert color="danger" hide_close>
                  {@error}
                </.alert>
              <% end %>

              <.button
                type="submit"
                variant="solid"
                color="primary"
                class="w-full"
                phx-disable-with="Submitting..."
              >
                Submit
              </.button>
            </.form>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"report" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.report_form, params)
    {:noreply, socket |> assign(:report_form, form) |> assign(:error, nil)}
  end

  def handle_event("submit", %{"report" => params}, socket) when is_map(params) do
    socket =
      assign(socket, :report_form, AshPhoenix.Form.validate(socket.assigns.report_form, params))

    case AshPhoenix.Form.submit(socket.assigns.report_form, params: params) do
      {:ok, _report} ->
        {:noreply, assign(socket, :submitted, true)}

      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, socket |> assign(:report_form, form) |> assign(:error, nil)}

      {:error, err} ->
        {:noreply, assign(socket, :error, "Failed to submit report: #{inspect(err)}")}
    end
  end

  defp report_form(tenant, location_id) do
    AshPhoenix.Form.for_create(CloseTheLoop.Feedback.Report, :create,
      as: "report",
      id: "report",
      tenant: tenant,
      params: %{
        "body" => "",
        "reporter_name" => "",
        "reporter_email" => "",
        "reporter_phone" => "",
        "consent" => "false"
      },
      prepare_source: fn changeset ->
        changeset
        |> Ash.Changeset.change_attribute(:location_id, location_id)
        |> Ash.Changeset.change_attribute(:source, :qr)
      end,
      post_process_errors: fn _form, _path, {field, message, vars} ->
        # `issue_id` is resolved server-side during report creation. We still want
        # field-level validation UX for other fields.
        if field in [:issue, :issue_id] do
          nil
        else
          {field, message, vars}
        end
      end
    )
    |> to_form()
  end
end
