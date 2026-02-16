defmodule CloseTheLoopWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use CloseTheLoopWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Top-level LiveView wrapper. All LiveView templates in this repo should begin
  with `<Layouts.app flash={@flash} ...>` and render their content inside.
  """
  attr :variant, :atom, values: [:app, :reporter], default: :app
  attr :flash, :map, required: true
  attr :current_user, :any, default: nil
  attr :current_scope, :any, required: true
  attr :org, :any, default: nil
  attr :location, :any, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    current_view =
      assigns[:live_module] ||
        (assigns[:socket] && Map.get(assigns.socket, :view))

    current_view = if is_atom(current_view), do: Atom.to_string(current_view), else: ""
    assigns = assign(assigns, :current_view, current_view)

    ~H"""
    <%= case @variant do %>
      <% :reporter -> %>
        <div class="min-h-screen bg-base text-foreground" style={org_brand_style(assigns[:org])}>
          <.flash_group flash={@flash} />

          <header class="border-b border-base bg-base/90 backdrop-blur">
            <div class="mx-auto max-w-3xl px-6 py-6">
              <div class="flex flex-col gap-1">
                <h1 class="text-lg font-semibold tracking-tight">
                  {org_public_name(assigns[:org])}
                </h1>
                <p :if={tagline = org_tagline(assigns[:org])} class="text-sm text-foreground-soft">
                  {tagline}
                </p>
                <p :if={location = assigns[:location]} class="text-sm text-foreground-soft">
                  Location:
                  <span class="font-medium text-foreground">
                    {location.full_path || location.name}
                  </span>
                </p>
              </div>
            </div>
          </header>

          <main class="mx-auto max-w-3xl px-6 py-10">
            <div class="mx-auto max-w-xl">
              {render_slot(@inner_block)}
            </div>
          </main>

          <footer class="mx-auto max-w-3xl px-6 pb-10 text-sm text-foreground-soft">
            <div class="flex flex-wrap items-center justify-between gap-3 border-t border-base pt-6">
              <div class="flex flex-col gap-1">
                <span class="text-xs">Powered by CloseTheLoop</span>
                <span :if={note = org_footer_note(assigns[:org])} class="text-xs">
                  {note}
                </span>
              </div>

              <div class="flex items-center gap-4 text-xs">
                <a href={~p"/privacy"} class="hover:text-foreground transition">Privacy</a>
                <a href={~p"/terms"} class="hover:text-foreground transition">Terms</a>
              </div>
            </div>
          </footer>
        </div>
      <% _ -> %>
        <div class="min-h-screen bg-accent text-foreground">
          <.flash_group flash={@flash} />

          <%!-- Mobile navigation drawer --%>
          <.sheet id="app-nav-sheet" placement="left" class="w-80 h-full p-0">
            <div class="flex h-full flex-col bg-overlay">
              <div class="border-b border-base px-5 py-4">
                <a href={~p"/"} class="flex items-center gap-2">
                  <span class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-zinc-900 text-white text-sm font-semibold">
                    CTL
                  </span>
                  <span class="text-sm font-semibold tracking-tight">CloseTheLoop</span>
                </a>
              </div>

              <div class="flex-1 overflow-y-auto px-5 py-4">
                <.app_nav current_view={@current_view} />
              </div>

              <div class="border-t border-base px-5 py-4">
                <div class="flex items-center justify-between gap-3">
                  <div class="min-w-0">
                    <p class="truncate text-sm font-medium text-foreground">
                      {if assigns[:current_user], do: @current_user.email, else: "Signed out"}
                    </p>
                  </div>

                  <%= if assigns[:current_user] do %>
                    <.button href={~p"/sign-out"} variant="ghost" size="sm">Sign out</.button>
                  <% else %>
                    <.button href={~p"/sign-in"} variant="ghost" size="sm">Sign in</.button>
                  <% end %>
                </div>
              </div>
            </div>
          </.sheet>

          <div class="flex min-h-screen min-w-0">
            <%!-- Desktop sidebar --%>
            <aside class="hidden md:sticky md:top-0 md:flex md:h-screen md:w-64 md:shrink-0 md:flex-col md:border-r md:border-base md:bg-base/90 md:backdrop-blur">
              <div class="px-6 py-5">
                <a href={~p"/"} class="flex items-center gap-2">
                  <span class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-zinc-900 text-white text-sm font-semibold">
                    CTL
                  </span>
                  <span class="text-sm font-semibold tracking-tight">CloseTheLoop</span>
                </a>
              </div>

              <div class="flex-1 overflow-y-auto px-6 pb-6">
                <.app_nav current_view={@current_view} />
              </div>

              <div class="border-t border-base px-6 py-4">
                <div class="flex items-center justify-between gap-3">
                  <div class="min-w-0">
                    <p
                      :if={assigns[:current_user]}
                      class="truncate text-sm font-medium text-foreground"
                    >
                      {@current_user.email}
                    </p>
                    <p :if={!assigns[:current_user]} class="text-sm text-foreground-soft">
                      Signed out
                    </p>
                  </div>

                  <%= if assigns[:current_user] do %>
                    <.button href={~p"/sign-out"} variant="ghost" size="sm">Sign out</.button>
                  <% else %>
                    <.button href={~p"/sign-in"} variant="ghost" size="sm">Sign in</.button>
                  <% end %>
                </div>
              </div>
            </aside>

            <div class="min-w-0 flex-1 flex flex-col">
              <%!-- Mobile topbar --%>
              <header class="sticky top-0 z-40 border-b border-base bg-base/90 backdrop-blur md:hidden">
                <div class="flex items-center gap-3 px-4 py-3">
                  <.button
                    type="button"
                    variant="ghost"
                    size="sm"
                    aria-label="Open navigation"
                    phx-click={Fluxon.open_dialog("app-nav-sheet")}
                  >
                    <.icon name="hero-bars-3" />
                  </.button>

                  <a href={~p"/"} class="flex items-center gap-2">
                    <span class="inline-flex h-8 w-8 items-center justify-center rounded-xl bg-zinc-900 text-white text-xs font-semibold">
                      CTL
                    </span>
                    <span class="text-sm font-semibold tracking-tight">CloseTheLoop</span>
                  </a>

                  <div class="flex-1" />

                  <%= if assigns[:current_user] do %>
                    <.button href={~p"/sign-out"} variant="ghost" size="sm">Sign out</.button>
                  <% else %>
                    <.button href={~p"/sign-in"} variant="ghost" size="sm">Sign in</.button>
                  <% end %>
                </div>
              </header>

              <main class="flex-1 px-6 py-10">
                <div class="mx-auto w-full max-w-6xl">
                  {render_slot(@inner_block)}
                </div>
              </main>
            </div>
          </div>
        </div>
    <% end %>
    """
  end

  attr :flash, :map, default: %{}
  attr :current_user, :any, default: nil
  slot :inner_block, required: true

  def marketing_layout(assigns) do
    signed_in? = !!assigns[:current_user]
    org_id = assigns[:current_user] && Map.get(assigns[:current_user], :organization_id)

    primary_href =
      cond do
        !signed_in? -> ~p"/register"
        org_id -> ~p"/app"
        true -> ~p"/app/onboarding"
      end

    primary_label =
      if signed_in? do
        "Open dashboard"
      else
        "Get started"
      end

    secondary_href = ~p"/sign-in"
    secondary_label = "Sign in"

    assigns =
      assigns
      |> assign(:primary_href, primary_href)
      |> assign(:primary_label, primary_label)
      |> assign(:secondary_href, secondary_href)
      |> assign(:secondary_label, secondary_label)
      |> assign(:signed_in?, signed_in?)

    ~H"""
    <.flash_group flash={@flash} />

    <div class="min-h-screen bg-base text-foreground">
      <div class="absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-80">
        <div class="relative left-[calc(50%-11rem)] aspect-[1155/678] w-[36.125rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-indigo-400 to-rose-400 opacity-20 sm:left-[calc(50%-30rem)] sm:w-[72.1875rem]">
        </div>
      </div>

      <header class="mx-auto max-w-6xl px-6 pt-8">
        <nav class="flex items-center justify-between">
          <a href={~p"/"} class="flex items-center gap-2">
            <span class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-zinc-900 text-white text-sm font-semibold">
              CTL
            </span>
            <span class="text-sm font-semibold tracking-tight">CloseTheLoop</span>
          </a>

          <div class="hidden items-center gap-6 text-sm font-medium text-zinc-600 sm:flex">
            <a href={~p"/how-it-works"} class="hover:text-zinc-900 transition">How it works</a>
            <a href={~p"/pricing"} class="hover:text-zinc-900 transition">Pricing</a>
          </div>

          <div class="flex items-center gap-2">
            <%= if !@signed_in? do %>
              <.button href={@secondary_href} variant="ghost" size="sm">
                {@secondary_label}
              </.button>
            <% end %>
            <.button href={@primary_href} variant="solid" color="primary" size="sm">
              {@primary_label}
            </.button>
          </div>
        </nav>
      </header>

      <main>
        {render_slot(@inner_block)}
      </main>

      <footer class="mx-auto max-w-6xl px-6 pb-10 text-sm text-zinc-500">
        <div class="flex flex-wrap items-center justify-between gap-3 border-t border-zinc-200 pt-6">
          <span>CloseTheLoop</span>
          <div class="flex items-center gap-4">
            <a href={~p"/privacy"} class="hover:text-zinc-700 transition">Privacy</a>
            <a href={~p"/terms"} class="hover:text-zinc-700 transition">Terms</a>
          </div>
        </div>
      </footer>
    </div>
    """
  end

  # For public reporter pages, we allow per-org color customization by overriding
  # Fluxon's CSS variables (see vendor/fluxon/priv/static/theme.css).
  def org_brand_style(org) do
    primary = normalize_hex_color(org && Map.get(org, :brand_primary_color))
    primary_fg = normalize_hex_color(org && Map.get(org, :brand_primary_foreground_color))

    style_bits =
      [
        primary && "--primary: #{primary};",
        primary_fg && "--foreground-primary: #{primary_fg};"
      ]
      |> Enum.filter(& &1)

    if style_bits == [], do: nil, else: Enum.join(style_bits, " ")
  end

  def org_public_name(org) do
    candidate =
      org &&
        (Map.get(org, :public_display_name) || Map.get(org, :name))

    case candidate do
      name when is_binary(name) ->
        trimmed = String.trim(name)
        if trimmed != "", do: trimmed, else: "Report an issue"

      _ ->
        "Report an issue"
    end
  end

  def org_tagline(org) do
    tagline = org && Map.get(org, :reporter_tagline)

    case tagline do
      t when is_binary(t) ->
        trimmed = String.trim(t)
        if trimmed != "", do: trimmed, else: nil

      _ ->
        nil
    end
  end

  def org_footer_note(org) do
    note = org && Map.get(org, :reporter_footer_note)

    case note do
      n when is_binary(n) ->
        trimmed = String.trim(n)
        if trimmed != "", do: trimmed, else: nil

      _ ->
        nil
    end
  end

  defp normalize_hex_color(nil), do: nil

  defp normalize_hex_color(color) do
    color = color |> to_string() |> String.trim()

    if String.match?(color, ~r/^#[0-9a-fA-F]{6}$/) do
      String.upcase(color)
    else
      nil
    end
  end

  @doc """
  Fluxon-based navigation used across the authenticated app shell.

  We pass `current_view` as a string to avoid compile-time deps on LiveView modules
  (which can introduce cyclic compilation).
  """
  attr :current_view, :string, default: ""

  def app_nav(assigns) do
    dashboard_active = String.contains?(assigns.current_view, ".DashboardLive.")
    inbox_active = String.contains?(assigns.current_view, ".IssuesLive.")
    reports_active = String.contains?(assigns.current_view, ".ReportsLive.")
    locations_active = String.contains?(assigns.current_view, ".LocationsLive.")

    org_settings_active = String.contains?(assigns.current_view, ".SettingsLive.Organization")
    account_settings_active = String.contains?(assigns.current_view, ".SettingsLive.Account")

    inbox_settings_active =
      String.contains?(assigns.current_view, ".SettingsLive.Inbox") or
        String.contains?(assigns.current_view, ".IssueCategoriesLive.")

    onboarding_active = String.contains?(assigns.current_view, ".OnboardingLive.")

    assigns =
      assigns
      |> assign(:dashboard_active, dashboard_active)
      |> assign(:inbox_active, inbox_active)
      |> assign(:reports_active, reports_active)
      |> assign(:locations_active, locations_active)
      |> assign(:org_settings_active, org_settings_active)
      |> assign(:account_settings_active, account_settings_active)
      |> assign(:inbox_settings_active, inbox_settings_active)
      |> assign(:onboarding_active, onboarding_active)

    ~H"""
    <.navlist heading="Main">
      <.navlink navigate={~p"/app"} active={@dashboard_active}>
        <.icon name="hero-squares-2x2" class="size-5" /> Dashboard
      </.navlink>
      <.navlink navigate={~p"/app/issues"} active={@inbox_active}>
        <.icon name="hero-inbox" class="size-5" /> Inbox
      </.navlink>
      <.navlink navigate={~p"/app/reports"} active={@reports_active}>
        <.icon name="hero-document-text" class="size-5" /> Reports
      </.navlink>
    </.navlist>

    <.navlist heading="Admin">
      <.navlink navigate={~p"/app/settings/organization"} active={@org_settings_active}>
        <.icon name="hero-building-office-2" class="size-5" /> Organization
      </.navlink>
      <.navlink navigate={~p"/app/settings/account"} active={@account_settings_active}>
        <.icon name="hero-user-circle" class="size-5" /> Account
      </.navlink>
      <.navlink navigate={~p"/app/settings/inbox"} active={@inbox_settings_active}>
        <.icon name="hero-adjustments-horizontal" class="size-5" /> Inbox configuration
      </.navlink>
      <.navlink navigate={~p"/app/settings/locations"} active={@locations_active}>
        <.icon name="hero-map-pin" class="size-5" /> Locations
      </.navlink>
      <.navlink href={~p"/app/oban"}>
        <.icon name="hero-queue-list" class="size-5" /> Jobs
      </.navlink>
      <.navlink :if={@onboarding_active} navigate={~p"/app/onboarding"} active>
        <.icon name="hero-sparkles" class="size-5" /> Onboarding
      </.navlink>
    </.navlist>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        data-auto-dismiss="false"
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        data-auto-dismiss="false"
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="relative flex flex-row items-center rounded-full border border-base bg-accent p-0.5">
      <div class="absolute h-[calc(100%-0.25rem)] w-1/3 rounded-full border border-base bg-base shadow-base left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="relative flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="relative flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="relative flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
