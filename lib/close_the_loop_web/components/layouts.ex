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
