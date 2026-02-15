defmodule Fluxon.Components.Navlist do
  @moduledoc """
  A comprehensive navigation system for building structured, accessible navigation menus.

  This component provides a flexible solution for creating navigation interfaces across your application.
  It offers a hierarchical structure with support for sections, headings, and interactive links, making
  it suitable for sidebars, settings pages, and other navigation-heavy interfaces.

  The navigation system consists of three main components working together:
  - `navlist`: The main container that provides structure and spacing
  - `navheading`: Optional section headers for organizing navigation groups
  - `navlink`: Interactive navigation items with LiveView integration

  The navigation system follows a structured hierarchical organization:

  ```
  navlist
  ├── navheading (optional)
  ├── navlink
  ├── navlink
  └── navlink
  ```

  This structure ensures proper spacing, accessibility, and visual organization while maintaining
  flexibility for various navigation patterns, including nested and expandable navigation.

  ## Usage

  The navlist component provides a structured way to build navigation menus:

  ```heex
  <.navlist heading="Main Navigation">
    <.navlink navigate={~p"/dashboard"} active>
      <.icon name="hero-home" class="size-5" /> Dashboard
    </.navlink>
    <.navlink navigate={~p"/projects"}>
      <.icon name="hero-folder" class="size-5" /> Projects
    </.navlink>
    <.navlink navigate={~p"/settings"}>
      <.icon name="hero-cog-6-tooth" class="size-5" /> Settings
    </.navlink>
  </.navlist>
  ```
  ![Basic Navlist](images/navlist/basic-navlist.png)

  ## Multiple Sections

  Create structured navigation with multiple sections:

  ```heex
  <.navlist heading="Main">
    <.navlink navigate={~p"/dashboard"} active>
      <.icon name="hero-home" class="size-5" /> Dashboard
    </.navlink>
    <.navlink navigate={~p"/projects"}>
      <.icon name="hero-folder" class="size-5" /> Projects
    </.navlink>
  </.navlist>

  <.navlist heading="Settings">
    <.navlink navigate={~p"/profile"}>
      <.icon name="hero-user" class="size-5" /> Profile
    </.navlink>
    <.navlink navigate={~p"/preferences"}>
      <.icon name="hero-cog-6-tooth" class="size-5" /> Preferences
    </.navlink>
  </.navlist>
  ```
  ![Multiple Sections](images/navlist/multiple-sections.png)

  ## Badges and Counters

  Enhance navigation items with badges and counters:

  ```heex
  <.navlist heading="Inbox">
    <.navlink href="/inbox/unread">
      Unread
      <.badge variant="pill" color="red" class="ml-auto">23</.badge>
    </.navlink>

    <.navlink href="/inbox/starred">
      Starred
      <.badge variant="pill" class="ml-auto">5</.badge>
    </.navlink>
  </.navlist>
  ```
  ![Navigation with Badges](images/navlist/navigation-with-badges.png)

  ## Expandable Navigation

  Create hierarchical navigation with expandable sections using LiveView's JS commands:

  ```heex
  <.navlist heading="Sales">
    <.navlink phx-click={JS.toggle_attribute({"data-expanded", ""})}>
      <.icon name="hero-users" class="size-5" /> Customers
      <.icon
        name="hero-chevron-right"
        class="size-3 ml-auto text-zinc-500 in-data-expanded:rotate-90 transition-transform duration-200"
      />
    </.navlink>
    <div class="grid grid-rows-[0fr] [[data-expanded]~&]:grid-rows-[1fr] transition-all duration-200">
      <div class="overflow-hidden px-4 -mr-4 border-l ml-3">
        <.navlist>
          <.navlink phx-click={JS.toggle_attribute({"data-expanded", ""})}>
            Orders
            <.icon
              name="hero-chevron-right"
              class="size-3 ml-auto text-zinc-500 in-data-expanded:rotate-90 transition-transform duration-200"
            />
          </.navlink>
          <div class="grid grid-rows-[0fr] [[data-expanded]+&]:grid-rows-[1fr] transition-all duration-200">
            <div class="overflow-hidden px-4 border-l ml-3">
              <.navlist>
                <.navlink navigate="/invoices">Invoices</.navlink>
                <.navlink navigate="/orders">Orders</.navlink>
              </.navlist>
            </div>
          </div>

          <.navlink navigate="/customer-groups">Customer Groups</.navlink>

          <.navlink phx-click={JS.toggle_attribute({"data-expanded", ""})}>
            Segments
            <.icon
              name="hero-chevron-right"
              class="size-3 ml-auto text-zinc-500 in-data-expanded:rotate-90 transition-transform duration-200"
            />
          </.navlink>
          <div class="grid grid-rows-[0fr] [[data-expanded]+&]:grid-rows-[1fr] transition-all duration-200">
            <div class="overflow-hidden px-4 border-l ml-3">
              <.navlist>
                <.navlink navigate="/segments/active">Active</.navlink>
                <.navlink navigate="/segments/at-risk">At Risk</.navlink>
              </.navlist>
            </div>
          </div>
        </.navlist>
      </div>
    </div>
    <.navlink navigate="/subscriptions">
      <.icon name="hero-arrow-path" class="size-5" /> Subscriptions
    </.navlink>
  </.navlist>
  ```
  ![Expandable Navigation](images/navlist/expandable-navigation.png)

  The expandable navigation pattern uses several key techniques:
  - `JS.toggle_attribute/1` for client-side toggling of expanded state
  - Grid-based height animation for smooth transitions
  - Nested navlists for hierarchical structure
  - Visual indicators with rotating chevron icons
  - Left border and padding for visual hierarchy

  ## Rich Navigation Examples

  Create visually rich navigation interfaces with custom styling:

  ```heex
  <.navlist>
    <.navheading class="text-xs uppercase font-medium text-zinc-400">
      Customers
    </.navheading>

    <.navlink
      :for={
        {icon, label, badge, path, active} <- [
          {"hero-users", "Customers", nil, ~p"/customers", false},
          {"hero-shopping-bag", "Subscriptions", "23", ~p"/subscriptions", true},
          {"hero-cube", "Products", nil, ~p"/products", false},
          {"hero-tag", "Coupons", nil, ~p"/coupons", false}
        ]
      }
      navigate={path}
      active={active}
      class={[
        "group py-2 relative",
        "hover:text-blue-600 hover:bg-white hover:shadow-sm",
        "hover:ring-1 ring-zinc-200",
        "hover:after:absolute hover:after:inset-y-0 hover:after:left-0",
        "hover:after:my-1.5 hover:after:w-1 hover:after:bg-blue-600",
        "hover:after:rounded-r-md"
      ]}
    >
      <.icon class="size-5 text-zinc-500 group-hover:text-blue-600" name={icon} />
      <span class="grow">{label}</span>
      <.badge :if={badge} color="blue">{badge}</.badge>
    </.navlink>
  </.navlist>
  ```
  ![Customized Navigation](images/navlist/customized-navigation.png)
  """

  use Fluxon.Component

  @styles %{
    navlist: [
      "[&+[data-part=navlist]]:mt-6 flex flex-col space-y-1"
    ],
    navheading: [
      "text-sm font-medium text-foreground-softest mb-2 flex items-center"
    ],
    navlink: [
      "flex items-center rounded-base -ml-2 px-2.5 py-2 font-medium text-sm gap-x-3",
      "text-foreground-soft",
      "hover:text-foreground",
      "hover:bg-accent",
      "data-active:bg-accent data-active:text-foreground",
      "[&_.icon]:size-5"
    ]
  }

  @a_attrs ~w(target download rel hreflang type referrerpolicy)
  @link_attrs ~w(navigate patch href replace method csrf_token)
  @button_attrs ~w(autofocus disabled form formaction formenctype formmethod formnovalidate formtarget name type value)

  @doc """
  Renders a navigation list container with optional heading and structured content.

  This component serves as the foundation for building navigation menus, providing proper
  spacing, structure, and accessibility features. It works in conjunction with `navheading`
  and `navlink` components to create comprehensive navigation interfaces.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :heading, :string,
    default: nil,
    doc: """
    Optional heading text for the navigation section. When provided, renders
    a heading element above the navigation items.
    """

  attr :class, :any,
    default: nil,
    doc: "Additional CSS classes for the nav container."

  attr :rest, :global, doc: "Additional attributes for the nav container."

  slot :inner_block, required: true, doc: "The content of the navigation section. Usually a list of navlinks."

  def navlist(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <nav class={merge([@styles[:navlist], @class])} data-part="navlist" {@rest}>
      <.navheading :if={@heading}>{@heading}</.navheading>

      {render_slot(@inner_block)}
    </nav>
    """
  end

  @doc """
  Renders a navigation section heading with proper styling and spacing.

  This component helps organize navigation sections by providing visual hierarchy
  through styled headings. It's typically used within a `navlist` component to
  label groups of navigation items.

  [INSERT LVATTRDOCS]

  ## Basic Usage

  ```heex
  <.navheading>Main Navigation</.navheading>
  ```

  ## Custom Styling

  ```heex
  <.navheading class="text-xs uppercase tracking-wider">
    Account Settings
  </.navheading>
  ```
  """
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: "Additional CSS classes for the heading element."

  slot :inner_block, required: true, doc: "The text content of the heading element."

  def navheading(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <h3 class={merge([@styles[:navheading], @class])}>
      {render_slot(@inner_block)}
    </h3>
    """
  end

  @doc """
  Renders an interactive navigation link with support for active states and LiveView integration.

  This component provides a flexible way to create navigation items with consistent styling,
  proper spacing, and full LiveView integration. It supports icons, badges, and custom content
  while maintaining accessibility and interactive states.

  [INSERT LVATTRDOCS]

  ## Basic Usage

  ```heex
  <.navlink navigate={~p"/dashboard"} active>Dashboard</.navlink>
  ```

  ## With Icons

  ```heex
  <.navlink navigate={~p"/inbox"}>
    <.icon name="hero-envelope" class="size-5" /> Inbox
    <.badge class="ml-auto">99+</.badge>
  </.navlink>

  <.navlink navigate={~p"/archive"}>
    <.icon name="hero-archive-box" class="size-5" /> Archive
  </.navlink>

  <.navlink navigate={~p"/trash"} class="text-red-600">
    <.icon name="hero-trash" class="size-5" /> Trash
  </.navlink>
  ```
  ![Navlink with Icons](images/navlist/navlist-with-icons.png)

  ## LiveView Navigation

  The component supports all LiveView link attributes:

  ```heex
  <.navlink patch={~p"/messages"} replace={true}>
    Messages
  </.navlink>

  <.navlink navigate={~p"/settings"}>
    Settings
  </.navlink>
  ```

  ## Active State

  Navigation items can be marked as active using the `active` attribute:

  ```heex
  <.navlink active={@current_path == "/dashboard"}>
    Dashboard
  </.navlink>
  ```
  """
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes for the link element. These are merged with the
    component's base styles for hover and active states.
    """

  attr :active, :boolean,
    default: false,
    doc: """
    When true, applies active styling to the link including background
    color and enhanced text contrast.
    """

  attr :rest, :global,
    include: @a_attrs ++ @link_attrs ++ @button_attrs,
    doc: """
    Additional HTML attributes supported by LiveView links including
    navigation attributes (patch, navigate) and standard link attributes.
    """

  slot :inner_block, required: true

  def navlink(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <.link data-active={@active} class={merge([@styles[:navlink], @class])} {@rest}>
      {render_slot(@inner_block)}
    </.link>
    """
  end
end
