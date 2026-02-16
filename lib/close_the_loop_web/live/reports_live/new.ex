defmodule CloseTheLoopWeb.ReportsLive.New do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Feedback.{Issue, Location, Report}
  alias CloseTheLoop.Feedback.Intake
  alias CloseTheLoop.Feedback.Text
  alias CloseTheLoop.Messaging.Phone

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:locations, [])
      |> assign(:location_options, [])
      |> assign(:selected_location_id, nil)
      |> assign(:selected_location_label, nil)
      |> assign(:issue_options, [])
      |> assign(:error, nil)
      |> assign(
        :manual_form,
        to_form(
          %{
            "location_id" => "",
            "issue_id" => "",
            "body" => "",
            "reporter_name" => "",
            "reporter_email" => "",
            "reporter_phone" => "",
            "consent" => "false"
          },
          as: :manual
        )
      )

    tenant = socket.assigns.current_tenant

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         {:ok, locations} <- list_locations(tenant) do
      location_id = params["location_id"]
      selected = find_location(locations, location_id)

      socket =
        socket
        |> assign(:locations, locations)
        |> assign(:location_options, build_location_options(locations))
        |> assign(:selected_location_id, selected && selected.id)
        |> assign(:selected_location_label, selected && (selected.full_path || selected.name))
        |> assign(
          :manual_form,
          to_form(
            %{
              "location_id" => (selected && selected.id) || "",
              "issue_id" => "",
              "body" => "",
              "reporter_name" => "",
              "reporter_email" => "",
              "reporter_phone" => "",
              "consent" => "false"
            },
            as: :manual
          )
        )

      socket =
        case selected do
          %Location{} = loc ->
            assign(socket, :issue_options, build_issue_options(list_issues(tenant, loc.id)))

          _ ->
            socket
        end

      {:ok, socket}
    else
      _ ->
        {:ok,
         put_flash(socket, :error, "Failed to load form")
         |> push_navigate(to: ~p"/app/#{socket.assigns.current_org.id}/reports")}
    end
  end

  defp list_locations(tenant) do
    FeedbackDomain.list_locations(
      tenant: tenant,
      query: [sort: [full_path: :asc, name: :asc], limit: 500]
    )
  end

  defp build_location_options(locations) do
    Enum.map(locations, fn loc ->
      label = loc.full_path || loc.name
      {label, loc.id}
    end)
  end

  defp find_location(_locations, nil), do: nil
  defp find_location(_locations, ""), do: nil

  defp find_location(locations, id) do
    Enum.find(locations, fn loc -> to_string(loc.id) == to_string(id) end)
  end

  defp list_issues(tenant, location_id) do
    case FeedbackDomain.list_non_duplicate_issues(
           tenant: tenant,
           query: [
             filter: [location_id: location_id],
             sort: [inserted_at: :desc],
             limit: 200
           ]
         ) do
      {:ok, issues} -> issues
      _ -> []
    end
  end

  defp build_issue_options([]), do: []

  defp build_issue_options(issues) do
    Enum.map(issues, fn issue ->
      {"#{issue.title} (#{issue.status})", issue.id}
    end)
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
            <h1 class="text-2xl font-semibold">New report</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              Enter a report you received in person or over the phone. We’ll attach it to the right issue.
            </p>
          </div>

          <.button navigate={~p"/app/#{@current_org.id}/reports"} variant="ghost">Back</.button>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <.form
            for={@manual_form}
            id="manual-report-form"
            phx-change="change"
            phx-submit="create"
            class="space-y-5"
          >
            <div class="grid gap-4 lg:grid-cols-2">
              <%= if @selected_location_id do %>
                <div class="lg:col-span-2">
                  <div class="text-xs font-medium text-foreground-soft">Location</div>
                  <div class="mt-1 text-sm font-medium">
                    {@selected_location_label}
                  </div>
                  <input
                    type="hidden"
                    name={@manual_form[:location_id].name}
                    value={@selected_location_id}
                  />
                </div>
              <% else %>
                <div class="lg:col-span-2">
                  <.select
                    id="manual-location"
                    field={@manual_form[:location_id]}
                    label="Location"
                    options={@location_options}
                    searchable
                    placeholder="Select a location"
                  />
                </div>
              <% end %>

              <div class="lg:col-span-2">
                <.textarea
                  id="manual-body"
                  field={@manual_form[:body]}
                  label="What happened?"
                  rows={6}
                  placeholder="Customer said the men's showers are cold again."
                  required
                />
              </div>

              <div class="lg:col-span-2">
                <.separator text="Assign (optional)" class="my-2" />
                <p class="text-sm text-foreground-soft">
                  Leave this blank to auto-group into an existing open issue (or create a new one).
                </p>

                <div class="mt-3">
                  <.select
                    id={"manual-issue-#{@selected_location_id || "none"}"}
                    field={@manual_form[:issue_id]}
                    label="Attach to existing issue"
                    options={@issue_options}
                    searchable={@selected_location_id != nil}
                    disabled={@selected_location_id == nil}
                    placeholder={
                      if(@selected_location_id == nil,
                        do: "Select a location first",
                        else: "Auto (recommended)"
                      )
                    }
                  />
                  <div :if={@selected_location_id == nil} class="mt-1 text-xs text-foreground-soft">
                    Select a location to see existing issues.
                  </div>
                  <div
                    :if={@selected_location_id != nil and @issue_options == []}
                    class="mt-1 text-xs text-foreground-soft"
                  >
                    No existing issues found for this location yet (auto-assign will create or group as needed).
                  </div>
                </div>
              </div>

              <div class="lg:col-span-2">
                <.separator text="Reporter (optional)" class="my-2" />
              </div>

              <.input
                id="manual-reporter-name"
                field={@manual_form[:reporter_name]}
                type="text"
                label="Name"
                placeholder="Jane Doe"
              />

              <.input
                id="manual-reporter-email"
                field={@manual_form[:reporter_email]}
                type="email"
                label="Email"
                placeholder="jane@example.com"
                autocomplete="email"
              />

              <.input
                id="manual-reporter-phone"
                field={@manual_form[:reporter_phone]}
                type="text"
                label="Phone"
                placeholder="+15555555555"
                autocomplete="tel"
              />

              <div class="lg:col-span-2">
                <.checkbox
                  id="manual-consent"
                  field={@manual_form[:consent]}
                  label="Reporter consented to receive SMS updates."
                  description="Requires a phone number."
                />
              </div>
            </div>

            <%= if @error do %>
              <.alert color="danger" hide_close>{@error}</.alert>
            <% end %>

            <div class="flex justify-end">
              <.button type="submit" variant="solid" color="primary" phx-disable-with="Saving...">
                Add report
              </.button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("change", %{"manual" => params}, socket) when is_map(params) do
    tenant = socket.assigns.current_tenant

    location_id = params |> Map.get("location_id", "") |> to_string() |> String.trim()
    selected = find_location(socket.assigns.locations, location_id)

    socket =
      socket
      |> assign(:manual_form, to_form(params, as: :manual))
      |> assign(:error, nil)

    socket =
      if selected do
        socket
        |> assign(:selected_location_id, selected.id)
        |> assign(:selected_location_label, selected.full_path || selected.name)
        |> assign(:issue_options, build_issue_options(list_issues(tenant, selected.id)))
      else
        socket
        |> assign(:selected_location_id, nil)
        |> assign(:selected_location_label, nil)
        |> assign(:issue_options, [])
      end

    {:noreply, socket}
  end

  def handle_event("create", %{"manual" => params}, socket) do
    tenant = socket.assigns.current_tenant
    user = socket.assigns.current_user

    location_id = params |> Map.get("location_id", "") |> to_string() |> String.trim()
    issue_id = params |> Map.get("issue_id", "") |> to_string() |> String.trim()
    body = params |> Map.get("body", "") |> to_string() |> String.trim()

    reporter_name = params |> Map.get("reporter_name", "") |> to_string() |> String.trim()
    reporter_email = params |> Map.get("reporter_email", "") |> to_string() |> String.trim()
    reporter_phone_raw = params |> Map.get("reporter_phone", "") |> to_string() |> String.trim()
    consent = Map.get(params, "consent", "false") in ["true", "on", true]

    socket = assign(socket, :manual_form, to_form(params, as: :manual))

    with true <- location_id != "" || {:error, "Location is required"},
         true <- body != "" || {:error, "Report text is required"},
         :ok <- validate_email(blank_to_nil(reporter_email)),
         {:ok, reporter_phone} <- Phone.normalize_e164(reporter_phone_raw),
         true <-
           not (consent and is_nil(reporter_phone)) || {:error, "Consent requires a phone number"},
         {:ok, %{issue: issue}} <-
           create_manual_report(
             tenant,
             user,
             location_id,
             issue_id,
             %{
               body: body,
               reporter_name: blank_to_nil(reporter_name),
               reporter_email: blank_to_nil(reporter_email),
               reporter_phone: reporter_phone_raw,
               consent: consent
             }
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "Report added.")
       |> push_navigate(to: ~p"/app/#{socket.assigns.current_org.id}/issues/#{issue.id}")}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, assign(socket, :error, msg)}

      {:error, err} ->
        {:noreply, assign(socket, :error, Exception.message(err))}

      other ->
        {:noreply, assign(socket, :error, "Failed to add report: #{inspect(other)}")}
    end
  end

  defp create_manual_report(tenant, _actor, location_id, "", attrs) do
    Intake.submit_report(tenant, location_id, Map.put(attrs, :source, :manual))
  end

  defp create_manual_report(tenant, actor, location_id, issue_id, attrs) do
    with {:ok, %Issue{} = issue} <- FeedbackDomain.get_issue_by_id(issue_id, tenant: tenant),
         true <-
           to_string(issue.location_id) == to_string(location_id) ||
             {:error, "Selected issue does not match the location"},
         normalized_body <- Text.normalize_for_dedupe(Map.get(attrs, :body)),
         {:ok, normalized_phone} <- Phone.normalize_e164(Map.get(attrs, :reporter_phone)),
         {:ok, %Report{} = report} <-
           FeedbackDomain.create_report(
             %{
               location_id: location_id,
               issue_id: issue.id,
               body: Map.get(attrs, :body),
               normalized_body: normalized_body,
               source: :manual,
               reporter_name: Map.get(attrs, :reporter_name),
               reporter_email: Map.get(attrs, :reporter_email),
               reporter_phone: normalized_phone,
               consent: Map.get(attrs, :consent) and not is_nil(normalized_phone)
             },
             tenant: tenant,
             actor: actor
           ) do
      {:ok, %{issue: issue, report: report}}
    end
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(val), do: val

  defp validate_email(nil), do: :ok

  defp validate_email(email) when is_binary(email) do
    if Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email) do
      :ok
    else
      {:error, "Email address looks invalid"}
    end
  end
end
