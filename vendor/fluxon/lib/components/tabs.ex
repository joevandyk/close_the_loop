defmodule Fluxon.Components.Tabs do
  @moduledoc """
  A tabs system for creating accessible, interactive tabbed interfaces.

  This component provides a solution for organizing content into tabbed sections across your
  application. It offers a structured set of components working together to create accessible and keyboard-navigable tabs.

  ## Components

  The tabs system consists of three main components working together in a specific hierarchy:

  - `tabs`: The main container providing structure and JavaScript functionality.
  - `tabs_list`: Navigation container holding the interactive tab buttons.
  - `tabs_panel`: Content panels associated with each tab, displayed one at a time.

  ```
  tabs
  ├── tabs_list
  │   └── tab slots (interactive buttons)
  └── tabs_panels
      └── panel content (one active at a time)
  ```

  ## Usage Examples

  ### Basic Tabs

  Create a simple tabbed interface with multiple static panels:

  ```heex
  <.tabs id="my-tabs">
    <.tabs_list active_tab="settings">
      <:tab name="profile">Profile</:tab>
      <:tab name="settings">Settings</:tab>
      <:tab name="notifications">Notifications</:tab>
    </.tabs_list>

    <.tabs_panel name="profile">
      Profile content here...
    </.tabs_panel>

    <.tabs_panel name="settings" active>
      Settings content here...
    </.tabs_panel>

    <.tabs_panel name="notifications">
      Notifications content here...
    </.tabs_panel>
  </.tabs>
  ```
  *Note: In static HTML or non-LiveView scenarios, manually setting `active_tab` on `tabs_list` and `active` on the
  corresponding `tabs_panel` works directly. For LiveView usage, see the "LiveView Integration" section.*

  ### Visual Variants

  The `tabs_list` component supports three distinct visual styles via the `variant` attribute:

  ```heex
  <!-- Default underlined style -->
  <.tabs_list variant="default">
    <:tab name="tab1">Default Tab</:tab>
  </.tabs_list>

  <!-- Segmented button-like style -->
  <.tabs_list variant="segmented">
    <:tab name="tab1">Segmented Tab</:tab>
  </.tabs_list>

  <!-- Ghost style with subtle backgrounds -->
  <.tabs_list variant="ghost">
    <:tab name="tab1">Ghost Tab</:tab>
  </.tabs_list>
  ```

  ### Size Variants

  The `tabs_list` component supports sizing that matches the button component for consistent alignment:

  ```heex
  <!-- Extra small size (28px height) - matches button size="xs" -->
  <.tabs_list size="xs">
    <:tab name="tab1">Extra Small Tab</:tab>
  </.tabs_list>

  <!-- Small size (32px height) - matches button size="sm" -->
  <.tabs_list size="sm">
    <:tab name="tab1">Small Tab</:tab>
  </.tabs_list>

  <!-- Medium size (36px height) - matches button size="md" (default) -->
  <.tabs_list size="md">
    <:tab name="tab1">Medium Tab</:tab>
  </.tabs_list>
  ```

  The size attribute controls the container height, padding, font size, and icon sizing to ensure visual consistency
  when tabs are used alongside buttons of the same size. Individual tab buttons automatically fill the full height
  of their container.

  ### Rich Tab Content

  Tabs can include icons, badges, or any other HEEx content:

  ```heex
  <.tabs_list>
    <:tab name="messages">
      <.icon name="hero-envelope" class="icon" />
      Messages
      <.badge class="ml-2">3</.badge>
    </:tab>

    <:tab name="settings">
      <.icon name="hero-cog-6-tooth" class="icon" />
      Settings
    </:tab>
  </.tabs_list>
  ```

  ### Dynamic Tabs

  Generate tabs dynamically from a collection using `for`:

  ```heex
  <!--
  Assuming @tabs_data = [%{id: "t1", title: "Tab One"}, %{id: "t2", title: "Tab Two"}]
  And @active_tab = "t1" (managed by LiveView, see below)
  -->

  <.tabs id="dynamic-tabs">
    <.tabs_list active_tab={@active_tab}>
      <:tab :for={tab_data <- @tabs_data} name={tab_data.id} phx-click={JS.push("set_tab", value: %{tab: tab_data.id})}>
        <%= tab_data.title %>
      </:tab>
    </.tabs_list>

    <.tabs_panel :for={tab_data <- @tabs_data} name={tab_data.id} active={@active_tab == tab_data.id}>
      Content for <%= tab_data.title %>...
    </.tabs_panel>
  </.tabs>
  ```

  ### Nested Tabs

  The component supports nesting for complex interfaces:

  ```heex
  <.tabs id="parent-tabs">
    <.tabs_list variant="segmented">
      <:tab name="profile">Profile</:tab>
      <:tab name="settings">Settings</:tab>
    </.tabs_list>

    <.tabs_panel name="profile">
      <.tabs id="profile-tabs">
        <.tabs_list variant="ghost">
          <:tab name="personal">Personal Info</:tab>
          <:tab name="preferences">Preferences</:tab>
        </.tabs_list>

        <.tabs_panel name="personal">
          Personal information content...
        </.tabs_panel>

        <.tabs_panel name="preferences">
          Preferences content...
        </.tabs_panel>
      </.tabs>
    </.tabs_panel>

    <.tabs_panel name="settings">
      Settings content...
    </.tabs_panel>
  </.tabs>
  ```

  ## LiveView Integration

  When using tabs within Phoenix LiveView, managing the active state requires synchronizing with the LiveView's assigns
  to prevent the active tab from resetting during patches.

  **1. Using Assigns and `handle_event`:**

  Manage the active tab in the LiveView's assigns and update it using `phx-click` events on the tabs.

  ```heex
  <.tabs id="lv-sync-tabs">
    <.tabs_list active_tab={@active_tab}>
      <:tab name="profile" phx-click={JS.push("set_active_tab", value: %{tab: "profile"})}>
        Profile
      </:tab>
      <:tab name="settings" phx-click={JS.push("set_active_tab", value: %{tab: "settings"})}>
        Settings
      </:tab>
    </.tabs_list>

    <.tabs_panel name="profile" active={@active_tab == "profile"}>
      Profile content...
    </.tabs_panel>
    <.tabs_panel name="settings" active={@active_tab == "settings"}>
      Settings content...
    </.tabs_panel>
  </.tabs>
  ```

  In your LiveView module:

  ```elixir
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :active_tab, "profile")} # Set initial tab
  end

  def handle_event("set_active_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end
  ```

  **2. Using URL Parameters and `push_patch`:**

  For state persistence across full page reloads or sharing links, store the active tab name in the URL parameters.

  ```heex
  <.tabs id="lv-url-tabs">
    <.tabs_list active_tab={@active_tab}>
      <:tab name="profile" phx-click={JS.push("set_tab", value: %{tab: "profile"})}>
        Profile
      </:tab>
      <:tab name="settings" phx-click={JS.push("set_tab", value: %{tab: "settings"})}>
        Settings
      </:tab>
    </.tabs_list>

    <.tabs_panel name="profile" active={@active_tab == "profile"}>...</.tabs_panel>
    <.tabs_panel name="settings" active={@active_tab == "settings"}>...</.tabs_panel>
  </.tabs>
  ```

  ```elixir
  def mount(_params, _session, socket) do
    # Initial tab state is set by handle_params based on URL
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    active_tab = params["tab"] || "profile" # Default if param missing
    {:noreply, assign(socket, :active_tab, active_tab)}
  end

  def handle_event("set_tab", %{"tab" => tab}, socket) do
    # Update URL, which triggers handle_params to update assigns
    current_path = URI.parse(socket.assigns.current_path).path
    {:noreply, push_patch(socket, to: current_path <> "?tab=\#{tab}")}
  end
  ```

  ## Accessibility/Keyboard Navigation

  This component suite automatically incorporates essential ARIA attributes (`role="tablist"`, `role="tab"`,
  `role="tabpanel"`, `aria-selected`, `aria-controls`, `aria-labelledby`) and manages focus according to best practices.

  ### Keyboard Support

  | Key         | Element Focus | Description                                                                 |
  |-------------|---------------|-----------------------------------------------------------------------------|
  | `Tab`       | Document      | Focuses the active tab button when tabbing into the tab list.               |
  | `→` / `↓`   | Tab button    | Moves focus to and **activates** the next tab, wrapping to first if at end.   |
  | `←` / `↑`   | Tab button    | Moves focus to and **activates** the previous tab, wrapping to last if at start. |
  | `Home`      | Tab button    | Moves focus to and **activates** the first tab in the list.                 |
  | `End`       | Tab button    | Moves focus to and **activates** the last tab in the list.                  |

  ### Focus Management Details
  - Only the *active* tab button is included in the page's default `Tab` sequence (`tabindex="0"`).
  - Non-active tab buttons have `tabindex="-1"` to be removed from the default sequence but remain focusable via arrow keys.
  - Activating a tab via keyboard immediately displays its associated panel and moves focus to the newly active tab button.
  - Focus remains within the active tab's panel content when navigating inside it until the user tabs out of the panel or uses tab list keyboard navigation.
  """

  use Fluxon.Component

  @styles %{
    "container" => [],
    "tablist" => ["flex"],
    "item" => [
      "cursor-pointer inline-flex items-center justify-center rounded-[calc(var(--radius-base)-2px)] font-medium",
      "[&>.icon]:shrink-0",
      "text-foreground-softer hover:text-foreground",
      "outline-hidden border border-transparent focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus"
    ],
    "panel" => [],
    "size" => %{
      "xs" => %{
        "tablist" => ["h-7"],
        "item" => [
          "h-full text-xs px-3 gap-x-1.5",
          "[&>.icon]:size-4 [&>.icon]:-mx-0.5 [&>.icon]:my-0.5"
        ]
      },
      "sm" => %{
        "tablist" => ["h-8"],
        "item" => [
          "h-full text-sm px-3.5 gap-x-1.5",
          "[&>.icon]:size-4.5 [&>.icon]:-mx-0.5 [&>.icon]:my-0.5"
        ]
      },
      "md" => %{
        "tablist" => ["h-9"],
        "item" => [
          "h-full text-sm px-4 gap-x-1.5",
          "[&>.icon]:size-5 [&>.icon]:-mx-0.5 [&>.icon]:my-0.5"
        ]
      }
    },
    "variant" => %{
      "segmented" => %{
        "tablist" => [
          "p-0.5 border border-base rounded-base",
          "bg-accent"
        ],
        "item" => [
          "flex-1 border border-transparent data-active:border-base",
          "data-active:text-foreground data-active:bg-base data-active:shadow-xs"
        ]
      },
      "default" => %{
        "tablist" => [
          "border-b border-base"
        ],
        "item" => [
          "relative",
          "after:content-[''] after:absolute after:-bottom-px after:left-1/2 after:-translate-x-1/2",
          "after:h-0.5 after:w-0 after:bg-primary after:rounded-base",
          "data-active:text-foreground data-active:after:w-full"
        ]
      },
      "ghost" => %{
        "tablist" => [
          "flex-row space-x-1"
        ],
        "item" => [
          "flex-1",
          "data-active:text-foreground data-active:bg-accent"
        ]
      }
    }
  }

  @doc """
  Renders a tabs container with support for dynamic content and keyboard navigation.

  This component serves as the foundation for building tabbed interfaces, providing proper
  structure, accessibility features, and JavaScript functionality. It works in conjunction
  with `tabs_list` and `tabs_panel` components to create tabbed interfaces.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :string,
    doc: """
    A unique identifier for the tabs container. If not provided, a unique ID will be generated.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to be applied to the tabs container. These are merged with
    the component's base styles.
    """

  attr :rest, :global,
    doc: """
    Allows passing additional HTML attributes (e.g., `data-*` attributes, custom ARIA roles/properties
    if needed beyond the defaults) directly to the main `div` container.
    """

  slot :inner_block,
    required: true,
    doc: """
    The primary content area for the tabs component. This slot typically houses one `<.tabs_list>`
    and one or more `<.tabs_panel>` components, defining the navigation and content areas.
    """

  def tabs(assigns) do
    assigns =
      assigns
      |> assign(:styles, @styles)
      |> assign_new(:id, fn -> gen_id() end)

    ~H"""
    <div id={@id} phx-hook="Fluxon.Tabs" class={merge([@styles["container"], @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a list of interactive tabs with support for different visual styles.

  This component provides the navigation interface for the tabs system, managing tab
  selection, keyboard navigation, and visual styling. It's designed to work within
  the `tabs` component.

  [INSERT LVATTRDOCS]

  ## Basic Usage

  ```heex
  <.tabs_list>
    <:tab name="tab1">First Tab</:tab>
    <:tab name="tab2">Second Tab</:tab>
  </.tabs_list>
  ```

  ## Visual Variants

  ```heex
  <.tabs_list variant="segmented">
    <:tab name="tab1">
      <.icon name="hero-home" class="icon" /> Home
    </:tab>
    <:tab name="tab2">
      <.icon name="hero-cog-6-tooth" class="icon" /> Settings
    </:tab>
  </.tabs_list>
  ```

  ## Size Variants

  ```heex
  <.tabs_list size="xs" variant="segmented">
    <:tab name="tab1">Extra Small Tab</:tab>
    <:tab name="tab2">XS Tab</:tab>
  </.tabs_list>

  <.tabs_list size="sm" variant="segmented">
    <:tab name="tab1">Small Tab</:tab>
    <:tab name="tab2">Small Tab</:tab>
  </.tabs_list>

  <.tabs_list size="md" variant="default">
    <:tab name="tab1">Medium Tab</:tab>
    <:tab name="tab2">Medium Tab</:tab>
  </.tabs_list>
  ```

  ## Custom Styling

  ```heex
  <.tabs_list class="gap-4">
    <:tab name="tab1" class="font-bold">
      Custom Tab
    </:tab>
  </.tabs_list>
  ```
  """
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to be applied to the tablist container. These are merged
    with the component's base styles and variant-specific styles.
    """

  attr :active_tab, :string,
    doc: """
    The `name` attribute of the tab that should be initially active. If not provided, the component
    defaults to activating the *first* tab defined within the `:tab` slot. In LiveView scenarios,
    this should typically be bound to an assign (e.g., `active_tab={@active_tab}`).
    """

  attr :variant, :string,
    default: "default",
    values: ~w(default segmented ghost),
    doc: """
    The visual style variant of the tabs. Available options:
    - `"default"`: Underlined style with bottom border indicator
    - `"segmented"`: Button-like style with background and shadow
    - `"ghost"`: Subtle style with background indicator
    """

  attr :size, :string,
    default: "md",
    values: ~w(xs sm md),
    doc: """
    The size of the tabs container. Controls the container height, padding, and font size to match button component sizes.
    Individual tab buttons will fill the full height of the container.
    Available options:
    - `"xs"`: Extra small container (28px height)
    - `"sm"`: Small container (32px height)
    - `"md"`: Medium container (36px height)
    """

  slot :tab,
    required: true,
    validate_attrs: false,
    doc: """
    Defines an individual interactive tab button within the list.
    - Requires a `name` attribute (string) which **must** correspond to the `name` of a `<.tabs_panel>`.
    - Any additional attributes (e.g., `class`, `phx-click`, `id`, `data-*`) are passed directly
      to the underlying `<button>` element. The content inside the `<:tab>` tag becomes the button's label.
    """

  slot :inner_block,
    required: true,
    doc: """
    The main content area within the `<.tabs_list>` component, typically containing only the `<:tab>` slots.
    """

  def tabs_list(assigns) do
    assigns =
      assigns
      |> assign(:styles, @styles)
      |> assign_new(:active_tab, fn ->
        List.first(assigns.tab)[:name]
      end)

    ~H"""
    <nav
      class={
        merge([
          @styles["tablist"],
          @styles["variant"][@variant]["tablist"],
          @styles["size"][@size]["tablist"],
          @class
        ])
      }
      data-part="tablist"
      role="tablist"
      aria-label="Tabs"
      aria-orientation="horizontal"
    >
      <button
        :for={tab <- @tab}
        aria-controls={"#{tab[:name]}-panel"}
        aria-selected={"#{@active_tab == tab[:name]}"}
        data-part="tab"
        data-panel={"#{tab[:name]}-panel"}
        role="tab"
        data-active={@active_tab == tab[:name]}
        tabindex={(@active_tab == tab[:name] && "0") || "-1"}
        class={
          merge([
            @styles["item"],
            @styles["variant"][@variant]["item"],
            @styles["size"][@size]["item"],
            tab[:class]
          ])
        }
        {assigns_to_attributes(tab, [:class, :active, :name])}
      >
        {render_slot(tab)}
      </button>
    </nav>
    """
  end

  @doc """
  Renders a tab panel that displays content when its corresponding tab is active.

  This component provides the content container for each tab, managing visibility
  and accessibility attributes. It's designed to work within the `tabs` component.

  [INSERT LVATTRDOCS]

  ## Basic Usage

  ```heex
  <.tabs_panel name="tab1" active>
    Content for the first tab...
  </.tabs_panel>

  <.tabs_panel name="tab2">
    Content for the second tab...
  </.tabs_panel>
  ```

  ## With Rich Content

  ```heex
  <.tabs_panel name="settings" class="space-y-4">
    <h3 class="text-lg font-medium">Settings</h3>
    <.form for={@form} phx-submit="save">
      <!-- Form fields -->
    </.form>
  </.tabs_panel>
  ```
  """
  @doc type: :component
  attr :name, :string,
    required: true,
    doc: """
    The unique identifier for this panel. This value **must exactly match** the `name` attribute
    of its corresponding `<:tab>` within the `<.tabs_list>`. This linkage is essential for
    functionality and accessibility.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to be applied to the panel element.
    """

  attr :active, :boolean,
    default: false,
    doc: """
    Controls the visibility of the panel. Set to `true` if this panel corresponds to the
    currently active tab. In LiveView, this is typically determined by comparing the panel's
    `name` with the state variable holding the active tab name (e.g., `active={@active_tab == "settings"}`).
    """

  attr :rest, :global,
    doc: """
    Allows passing additional HTML attributes (e.g., `data-*`, custom styling IDs) directly
    to the panel's `div` container.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content to be displayed within this panel when its corresponding tab is active.
    """

  def tabs_panel(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <div
      data-part="tabpanel"
      role="tabpanel"
      aria-labelledby={@name}
      aria-hidden={"#{!@active}"}
      id={"#{@name}-panel"}
      class={merge([@styles["panel"], @class])}
      hidden={!@active}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
