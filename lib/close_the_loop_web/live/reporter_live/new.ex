defmodule CloseTheLoopWeb.ReporterLive.New do
  use CloseTheLoopWeb, :live_view

  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Tenants
  alias CloseTheLoop.Tenants.Organization
  alias CloseTheLoop.Feedback.Location

  @allowed_sources ~w(qr manual sms)a

  @impl true
  def mount(%{"tenant" => tenant, "location_id" => location_id} = params, _session, socket) do
    source = parse_source(Map.get(params, "source"))

    socket =
      socket
      |> assign_new(:current_user, fn -> nil end)
      |> assign(:current_scope, %{actor: nil, tenant: tenant})
      |> assign(:tenant, tenant)
      |> assign(:location_id, location_id)
      |> assign(:report_source, source)
      |> assign(:org, get_org_by_tenant(tenant))
      |> assign(
        :report_form,
        report_form(tenant, location_id, source)
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

              <.button
                href={reporter_path(@tenant, @location_id, @report_source)}
                variant="outline"
              >
                Report another issue
              </.button>
            </div>
          <% else %>
            <.form
              for={@report_form}
              id="reporter-intake-form"
              phx-hook=".RememberReporterInfo"
              phx-change="validate"
              phx-submit="submit"
              class="space-y-4"
              data-reporter-info-storage-key={"close_the_loop:reporter_info:v1:#{@tenant}"}
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
                  label="Email (optional)"
                  autocomplete="email"
                  inputmode="email"
                />

                <.input
                  field={@report_form[:reporter_phone]}
                  type="tel"
                  label="Phone number (optional)"
                  placeholder="+15555550100"
                  inputmode="tel"
                  autocomplete="tel"
                />

                <.checkbox
                  field={@report_form[:consent]}
                  label="Send me text updates about this issue."
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

            <script :type={Phoenix.LiveView.ColocatedHook} name=".RememberReporterInfo">
              export default {
                mounted() {
                  this.storageKey =
                    this.el.dataset.reporterInfoStorageKey ||
                      "close_the_loop:reporter_info:v1";

                  this.fields = {
                    name: this.el.querySelector('input[name="report[reporter_name]"]'),
                    email: this.el.querySelector('input[name="report[reporter_email]"]'),
                    phone: this.el.querySelector('input[name="report[reporter_phone]"]'),
                    consent: this.el.querySelector('input[type="checkbox"][name="report[consent]"]'),
                  };

                  this._listeners = [];

                  this.prefillFromStorage();
                  this.attachListeners();

                  // Capture any browser autofill that happens at load time.
                  setTimeout(() => this.persistToStorage(), 0);
                },

                destroyed() {
                  this.detachListeners();
                },

                attachListeners() {
                  const onInput = () => this.persistToStorage();
                  const onConsent = () => this.persistToStorage();

                  if (this.fields.name) this.addListener(this.fields.name, "input", onInput);
                  if (this.fields.email) this.addListener(this.fields.email, "input", onInput);
                  if (this.fields.phone) this.addListener(this.fields.phone, "input", onInput);
                  if (this.fields.consent) this.addListener(this.fields.consent, "change", onConsent);
                },

                detachListeners() {
                  for (const [el, event, handler] of this._listeners) {
                    el.removeEventListener(event, handler);
                  }
                  this._listeners = [];
                },

                addListener(el, event, handler) {
                  el.addEventListener(event, handler);
                  this._listeners.push([el, event, handler]);
                },

                safeGet() {
                  try {
                    const raw = window.localStorage.getItem(this.storageKey);
                    if (!raw) return null;

                    const parsed = JSON.parse(raw);
                    if (!parsed || typeof parsed !== "object") return null;

                    return {
                      reporter_name: this.safeString(parsed.reporter_name, 100),
                      reporter_email: this.safeString(parsed.reporter_email, 254),
                      reporter_phone: this.safeString(parsed.reporter_phone, 50),
                      consent: parsed.consent === true,
                    };
                  } catch (_err) {
                    return null;
                  }
                },

                safeSet(value) {
                  try {
                    window.localStorage.setItem(this.storageKey, JSON.stringify(value));
                  } catch (_err) {
                    // Ignore: storage might be disabled (private mode, quota, etc.)
                  }
                },

                safeRemove() {
                  try {
                    window.localStorage.removeItem(this.storageKey);
                  } catch (_err) {
                    // Ignore
                  }
                },

                safeString(value, maxLen) {
                  if (typeof value !== "string") return "";
                  return value.trim().slice(0, maxLen);
                },

                prefillFromStorage() {
                  const stored = this.safeGet();
                  if (!stored) return;

                  if (this.fields.name && !this.fields.name.value && stored.reporter_name) {
                    this.fields.name.value = stored.reporter_name;
                  }

                  if (this.fields.email && !this.fields.email.value && stored.reporter_email) {
                    this.fields.email.value = stored.reporter_email;
                  }

                  if (this.fields.phone && !this.fields.phone.value && stored.reporter_phone) {
                    this.fields.phone.value = stored.reporter_phone;
                  }

                  if (this.fields.consent && stored.consent === true) {
                    this.fields.consent.checked = true;
                  }
                },

                persistToStorage() {
                  const payload = {
                    reporter_name: this.safeString(this.fields.name && this.fields.name.value, 100),
                    reporter_email: this.safeString(this.fields.email && this.fields.email.value, 254),
                    reporter_phone: this.safeString(this.fields.phone && this.fields.phone.value, 50),
                    consent: !!(this.fields.consent && this.fields.consent.checked),
                    updated_at_ms: Date.now(),
                  };

                  const hasAny =
                    payload.reporter_name ||
                    payload.reporter_email ||
                    payload.reporter_phone ||
                    payload.consent;

                  if (!hasAny) {
                    this.safeRemove();
                    return;
                  }

                  this.safeSet(payload);
                },
              };
            </script>
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

  defp report_form(tenant, location_id, source) when source in @allowed_sources do
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
        |> Ash.Changeset.change_attribute(:source, source)
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

  # NOTE: user input -> only map to known atoms (never String.to_atom/1).
  defp parse_source(nil), do: :qr
  defp parse_source(""), do: :qr

  defp parse_source(source) when is_binary(source) do
    case source |> String.trim() |> String.downcase() do
      "qr" -> :qr
      "manual" -> :manual
      "sms" -> :sms
      _ -> :qr
    end
  end

  defp reporter_path(tenant, location_id, :qr), do: ~p"/r/#{tenant}/#{location_id}/qr"
  defp reporter_path(tenant, location_id, :manual), do: ~p"/r/#{tenant}/#{location_id}/manual"
  defp reporter_path(tenant, location_id, :sms), do: ~p"/r/#{tenant}/#{location_id}/sms"
end
