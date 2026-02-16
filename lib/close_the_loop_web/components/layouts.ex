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
  Fluxon-based navigation used across the authenticated app shell.

  We pass `current_view` as a string to avoid compile-time deps on LiveView modules
  (which can introduce cyclic compilation).
  """
  attr :current_view, :string, default: ""

  def app_nav(assigns) do
    inbox_active = String.contains?(assigns.current_view, ".IssuesLive.")
    reports_active = String.contains?(assigns.current_view, ".ReportsLive.")
    locations_active = String.contains?(assigns.current_view, ".LocationsLive.")

    settings_active =
      String.contains?(assigns.current_view, ".SettingsLive.") or
        String.contains?(assigns.current_view, ".IssueCategoriesLive.")

    onboarding_active = String.contains?(assigns.current_view, ".OnboardingLive.")

    assigns =
      assigns
      |> assign(:inbox_active, inbox_active)
      |> assign(:reports_active, reports_active)
      |> assign(:locations_active, locations_active)
      |> assign(:settings_active, settings_active)
      |> assign(:onboarding_active, onboarding_active)

    ~H"""
    <.navlist heading="Main">
      <.navlink navigate={~p"/app/issues"} active={@inbox_active}>
        <.icon name="hero-inbox" class="size-5" /> Inbox
      </.navlink>
      <.navlink navigate={~p"/app/reports"} active={@reports_active}>
        <.icon name="hero-document-text" class="size-5" /> Reports
      </.navlink>
      <.navlink navigate={~p"/app/locations"} active={@locations_active}>
        <.icon name="hero-map-pin" class="size-5" /> Locations
      </.navlink>
    </.navlist>

    <.navlist heading="Admin">
      <.navlink navigate={~p"/app/settings"} active={@settings_active}>
        <.icon name="hero-cog-6-tooth" class="size-5" /> Settings
      </.navlink>
      <.navlink navigate={~p"/app/settings/issue-categories"} active={@settings_active}>
        <.icon name="hero-tag" class="size-5" /> Issue categories
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
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="sticky top-0 z-40 border-b border-base bg-base/90 backdrop-blur">
      <div class="mx-auto flex max-w-5xl items-center gap-4 px-4 py-3 sm:px-6 lg:px-8">
        <a href="/" class="flex items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold tracking-tight">CloseTheLoop</span>
        </a>

        <div class="flex-1" />

        <div class="hidden items-center gap-2 sm:flex">
          <.button variant="ghost" href="https://phoenixframework.org/">Website</.button>
          <.button variant="ghost" href="https://github.com/phoenixframework/phoenix">GitHub</.button>
          <.theme_toggle />
          <.button variant="solid" color="primary" href="https://hexdocs.pm/phoenix/overview.html">
            Get Started <span aria-hidden="true">&rarr;</span>
          </.button>
        </div>
      </div>
    </header>

    <main class="px-4 py-14 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-6">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
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
