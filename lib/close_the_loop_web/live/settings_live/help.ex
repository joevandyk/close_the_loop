defmodule CloseTheLoopWeb.SettingsLive.Help do
  @moduledoc """
  Help page in the Admin area: explains how customers use the site,
  how main features work, and defines key terms (Locations, Issues, Reports, etc.).
  """
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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
      <div class="max-w-4xl mx-auto space-y-10">
        <div>
          <h1 class="text-2xl font-semibold">Help</h1>
          <p class="mt-2 text-sm text-foreground-soft">
            How customers use the site and how the main features work.
          </p>
        </div>

        <section class="space-y-4">
          <h2 class="text-lg font-semibold">How customers use the site</h2>
          <p class="text-sm text-foreground-soft leading-relaxed">
            Your customers (reporters) submit issues by scanning a QR code at each location:
          </p>
          <ul class="list-disc list-inside space-y-2 text-sm text-foreground-soft">
            <li>
              <strong>QR code</strong>
              — At each location you add a printable poster with a QR code. When someone scans it, they open a mobile-friendly form with the location already set. They describe the issue, optionally add their phone number, and submit.
            </li>
          </ul>
          <p class="text-sm text-foreground-soft leading-relaxed">
            If a reporter opts in (e.g. by checking “Notify me”), they can receive updates (email/SMS) when you acknowledge or resolve the issue. This “closes the loop” between report and resolution.
          </p>
        </section>

        <section class="space-y-4">
          <h2 class="text-lg font-semibold">Main features</h2>

          <div class="rounded-xl border border-base bg-base p-4 space-y-2">
            <h3 class="font-medium">Dashboard</h3>
            <p class="text-sm text-foreground-soft">
              A quick overview: counts of open issues and reports, recent activity (new reports, comments, status updates), and shortcuts to the Issues list and creating a new report.
            </p>
          </div>

          <div class="rounded-xl border border-base bg-base p-4 space-y-2">
            <h3 class="font-medium">Issues (inbox)</h3>
            <p class="text-sm text-foreground-soft">
              This is your triage inbox. Each <strong>Issue</strong>
              groups one or more <strong>Reports</strong>
              about the same problem (e.g. “shower is cold” at a given location). You can filter by status (e.g. open, in progress, fixed), search, and assign categories. From an issue you can add internal notes, change status, move it to another location or issue, and send an update to all opted-in reporters.
            </p>
          </div>

          <div class="rounded-xl border border-base bg-base p-4 space-y-2">
            <h3 class="font-medium">Reports</h3>
            <p class="text-sm text-foreground-soft">
              Every submission from a customer is a <strong>Report</strong>. Reports appear in the Reports list (chronological) and are grouped into Issues. You can open a report to see full details, who reported it, and whether they opted in for updates. You can also create reports manually (e.g. from a phone call) via “New report”.
            </p>
          </div>

          <div class="rounded-xl border border-base bg-base p-4 space-y-2">
            <h3 class="font-medium">Locations</h3>
            <p class="text-sm text-foreground-soft">
              <strong>Locations</strong>
              are the physical places where issues can occur (e.g. “Locker room A”, “Main pool”). Each location can have a QR code poster; reports submitted via that QR are tied to that location. You manage locations under Admin → Locations and can print or download QR posters from there.
            </p>
          </div>

          <div class="rounded-xl border border-base bg-base p-4 space-y-2">
            <h3 class="font-medium">Issue categories</h3>
            <p class="text-sm text-foreground-soft">
              <strong>Issue categories</strong>
              (e.g. “Plumbing”, “Safety”) help you classify and filter issues. You configure them under Admin → Issues configuration. Categories can be used for triage and for optional auto-classification of incoming reports.
            </p>
          </div>

          <div class="rounded-xl border border-base bg-base p-4 space-y-2">
            <h3 class="font-medium">Organization and account</h3>
            <p class="text-sm text-foreground-soft">
              Under Admin you can set your <strong>organization</strong>
              name, public display name, and the tagline/footer shown on the reporter form.
              <strong>Account</strong>
              is your own profile, email, and password. <strong>Issues configuration</strong>
              covers categories and triage-related settings. <strong>Inbox</strong>
              settings (if applicable) control how the issues inbox behaves.
            </p>
          </div>
        </section>

        <section class="space-y-4">
          <h2 class="text-lg font-semibold">Key terms</h2>
          <dl class="space-y-3 text-sm">
            <div class="rounded-lg border border-base bg-base p-3">
              <dt class="font-medium text-foreground">Location</dt>
              <dd class="mt-1 text-foreground-soft">
                A physical place (room, area, asset) where issues can be reported. Each location can have its own QR code and optional hierarchy (e.g. building → room).
              </dd>
            </div>
            <div class="rounded-lg border border-base bg-base p-3">
              <dt class="font-medium text-foreground">Report</dt>
              <dd class="mt-1 text-foreground-soft">
                A single submission from a customer via the QR form, containing a description, optional contact info, and the location (if known).
              </dd>
            </div>
            <div class="rounded-lg border border-base bg-base p-3">
              <dt class="font-medium text-foreground">Issue</dt>
              <dd class="mt-1 text-foreground-soft">
                A group of one or more reports that represent the same problem (e.g. “cold shower in Locker room A”). Issues have status (open, in progress, fixed, etc.) and can be assigned a category and location.
              </dd>
            </div>
            <div class="rounded-lg border border-base bg-base p-3">
              <dt class="font-medium text-foreground">Reporter</dt>
              <dd class="mt-1 text-foreground-soft">
                The person who submitted a report. If they opted in, they can receive updates (email/SMS) when the issue is acknowledged or resolved.
              </dd>
            </div>
            <div class="rounded-lg border border-base bg-base p-3">
              <dt class="font-medium text-foreground">Issue category</dt>
              <dd class="mt-1 text-foreground-soft">
                A label you define (e.g. “Plumbing”, “HVAC”) to classify issues for triage and filtering.
              </dd>
            </div>
          </dl>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
