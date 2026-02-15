defmodule Fluxon.Components.Dropdown do
  @moduledoc """
  A comprehensive dropdown system for creating accessible, interactive menus and selection interfaces.

  This component provides a flexible solution for building dropdown menus across your application.
  It offers a fully accessible implementation with keyboard navigation, automatic positioning, and
  proper focus management. The component is designed to work seamlessly with LiveView while
  maintaining proper accessibility standards.

  ## Usage

  Create a simple dropdown menu with default styling:

  ```heex
  <.dropdown>
    <.dropdown_link navigate={~p"/profile"}>Profile</.dropdown_link>
    <.dropdown_link navigate={~p"/settings"}>Settings</.dropdown_link>
    <.dropdown_separator />
    <.dropdown_link href={~p"/logout"} method="delete">Sign Out</.dropdown_link>
  </.dropdown>
  ```
  ![Basic Dropdown](images/dropdown/basic-dropdown.png)

  ## Custom Toggle

  Replace the default button with a custom toggle element:

  ```heex
  <.dropdown>
    <:toggle>
      <button class="flex items-center gap-x-2 bg-zinc-200/50 rounded-lg p-2">
        <img src={~p"/images/human-avatar-01.png"} alt="User" class="size-6 rounded-lg" />
        <div class="text-sm text-gray-800 font-semibold">John Doe</div>
        <.icon name="u-chevron-down" class="size-4" />
      </button>
    </:toggle>
    <.dropdown_button>Profile</.dropdown_button>
    <.dropdown_button>Billing</.dropdown_button>
    <.dropdown_button>Settings</.dropdown_button>
  </.dropdown>
  ```
  ![Custom Toggle](images/dropdown/custom-toggle.png)

  ## Disabled Items

  The dropdown supports disabled menu items that are automatically skipped during keyboard navigation
  and cannot be selected or activated:

  ```heex
  <.dropdown>
    <.dropdown_button>Account</.dropdown_button>
    <.dropdown_button disabled>Upgrade Plan</.dropdown_button>
    <.dropdown_separator />
    <.dropdown_link navigate={~p"/settings"}>Settings</.dropdown_link>
    <.dropdown_link navigate={~p"/restricted"} data-disabled>Admin Panel</.dropdown_link>
  </.dropdown>
  ```

  For button items, use the standard `disabled` attribute. For link items, use the `data-disabled`
  attribute since HTML links don't support the native `disabled` attribute. Disabled items are visually
  dimmed and are completely skipped during keyboard navigation.

  ## Rich Content

  Create complex dropdown interfaces with headers, separators, and custom content:

  ```heex
  <.dropdown class="w-64">
    <.dropdown_custom class="flex items-center p-2">
      <img src="https://i.pravatar.cc/150?u=1" alt="Avatar" class="size-9 rounded-full" />
      <div class="flex flex-col ml-3">
        <span class="text-sm font-medium">Emma Johnson</span>
        <span class="text-xs text-zinc-500">emma@acme.com</span>
      </div>
    </.dropdown_custom>

    <.dropdown_separator />

    <.dropdown_header>Account</.dropdown_header>
    <.dropdown_link navigate={~p"/profile"}>Profile</.dropdown_link>
    <.dropdown_link navigate={~p"/billing"}>Billing</.dropdown_link>

    <.dropdown_header>Support</.dropdown_header>
    <.dropdown_link navigate={~p"/help"}>Documentation</.dropdown_link>
    <.dropdown_link navigate={~p"/contact"}>Contact Us</.dropdown_link>

    <.dropdown_separator />

    <.dropdown_link href={~p"/logout"} method="delete" class="text-red-600">
      Sign Out
    </.dropdown_link>
  </.dropdown>
  ```
  ![Rich Content](images/dropdown/rich-content.png)

  ## Hover Interaction

  Enable hover-based opening with custom delays:

  ```heex
  <.dropdown open_on_hover hover_open_delay={200} hover_close_delay={300}>
    <.dropdown_link navigate={~p"/profile"}>Profile</.dropdown_link>
    <.dropdown_link navigate={~p"/settings"}>Settings</.dropdown_link>
  </.dropdown>
  ```

  ## Menu Positioning

  Control the dropdown's placement relative to its toggle:

  ```heex
  <.dropdown placement="bottom-end">
    <.dropdown_link>Bottom End Aligned</.dropdown_link>
  </.dropdown>

  <.dropdown placement="right-start">
    <.dropdown_link>Right Side Menu</.dropdown_link>
  </.dropdown>
  ```

  ## Custom Animations

  Customize the dropdown's enter/leave animations:

  ```heex
  <.dropdown
    animation="transition-all duration-300"
    animation_enter="opacity-100 translate-y-0"
    animation_leave="opacity-0 -translate-y-2"
  >
    <.dropdown_link>Smooth Slide Animation</.dropdown_link>
  </.dropdown>
  ```

  ## Keyboard Navigation

  The component provides comprehensive keyboard support following ARIA best practices:

  | Key | Element Focus | Description |
  |-----|--------------|-------------|
  | `Tab`/`Shift+Tab` | Toggle button | Moves focus to and from the dropdown toggle |
  | `Space`/`Enter` | Toggle button | Opens/closes the dropdown when focused |
  | `↑` | Toggle button | Opens dropdown and highlights last item |
  | `↓` | Toggle button | Opens dropdown and highlights first item |
  | `↑` | Menu item | Moves highlight to previous item |
  | `↓` | Menu item | Moves highlight to next item |
  | `Enter`/`Space` | Menu item | Activates the highlighted item |
  | `Escape` | Any | Closes the dropdown |

  ## Focus Management

  The dropdown implements sophisticated focus management to ensure a seamless user experience.
  Focus remains on the toggle button while users navigate through menu items using arrow keys.
  Menu items are not focusable through tab navigation, maintaining a streamlined keyboard
  interaction model. The component manages proper ARIA attributes to communicate the current
  selection to assistive technologies.

  ## Positioning System

  The dropdown menu intelligently positions itself relative to its toggle button. It automatically
  adjusts its placement based on available viewport space, ensuring optimal visibility regardless
  of the toggle button's position. The positioning system handles window resizing and scrolling,
  maintaining proper alignment in dynamic layouts.
  """

  use Fluxon.Component
  import Fluxon.Components.Button

  @styles %{
    # Container and positioning
    container: [
      "relative inline-flex"
    ],

    # Toggle button variants
    toggle_button: [
      "cursor-default"
    ],
    custom_toggle: [
      "cursor-default inline-flex"
    ],

    # Dropdown menu panel
    menu: [
      # Positioning and layout
      "fixed z-50 w-max overflow-y-auto",

      # Spacing
      "p-1.5",

      # Appearance
      "bg-overlay border border-base rounded-base shadow-base"
    ],

    # Menu content sections
    header: [
      # Layout
      "col-span-full grid grid-cols-[1fr_auto] gap-x-12",

      # Spacing
      "px-3.5 pb-1 pt-2 sm:px-3",

      # Typography
      "text-sm/5 sm:text-xs/5 font-medium text-foreground-softest"
    ],
    separator: [
      # Layout
      "col-span-full",

      # Spacing and appearance
      "my-1.5 -mx-1.5 h-px border-t border-base"
    ],
    custom_content: [
      # Spacing
      "px-3 py-1.5 sm:px-2.5"
    ],

    # Interactive menu items
    menu_item: [
      # Layout and positioning
      "w-full col-span-full grid grid-cols-[auto_1fr_auto] items-center justify-left group",
      "gap-x-2.5 sm:gap-x-2",

      # Spacing
      "px-3 py-2.5 sm:px-2.5 sm:py-1.5",

      # Typography
      "text-left text-sm/6 font-medium text-foreground-soft",

      # Appearance
      "rounded-base",

      # Interactive states
      "focus:outline-hidden",
      "disabled:opacity-50 data-disabled:opacity-50 data-disabled:pointer-events-none",
      "data-highlighted:bg-accent",

      # Icon positioning and styling
      "[&_.icon]:col-start-1 [&_.icon]:row-start-1 [&_.icon]:-ml-0.5",
      "[&_.icon]:size-5 [&_.icon]:text-current/80 data-highlighted:[&_.icon]:text-current"
    ],

    # UI elements
    chevron_icon: [
      # Size and positioning
      "size-4 -mr-1",

      # Appearance and animation
      "text-foreground-softest transition duration-300"
    ]
  }

  @doc """
  Renders a fully accessible dropdown menu with rich interaction support.

  This component provides a flexible way to create dropdown menus with proper keyboard
  navigation, focus management, and positioning. It supports both click and hover
  interactions, custom toggle elements, and various animation options.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :string,
    doc: """
    The unique identifier for the dropdown component. If not provided, one will be
    automatically generated.
    """

  attr :label, :string,
    default: "Menu",
    doc: """
    The text label for the default dropdown toggle button. Only used when no
    custom toggle is provided via the `:toggle` slot.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes for the dropdown menu panel. Useful for controlling
    width, max-height, and other menu-specific styles.
    """

  attr :container_class, :string,
    default: nil,
    doc: """
    Additional CSS classes for the dropdown's outer container. Affects the
    positioning wrapper element.
    """

  attr :toggle_class, :string,
    default: nil,
    doc: """
    Additional CSS classes for the dropdown toggle button. Only applies to
    the default toggle button, not custom toggles.
    """

  attr :disabled, :boolean,
    default: false,
    doc: """
    When true, disables the dropdown toggle and prevents the menu from opening.
    """

  attr :placement, :string,
    default: "bottom-start",
    values:
      ~w(top top-start top-end right right-start right-end bottom bottom-start bottom-end left left-start left-end),
    doc: """
    Controls the placement of the dropdown menu relative to its toggle button.
    Supports different positions with automatic repositioning when needed.

    The possible values are: `top`, `top-start`, `top-end`, `right`, `right-start`, `right-end`,
    `bottom`, `bottom-start`, `bottom-end`, `left`, `left-start`, `left-end`
    """

  attr :animation, :string,
    default: "transition ease-in-out duration-150",
    doc: """
    Base animation classes applied to the dropdown menu. Controls the transition
    timing and easing function.
    """

  attr :animation_enter, :string,
    default: "opacity-100 scale-100",
    doc: """
    Classes applied when the dropdown menu enters. Usually defines the final
    state of the animation.
    """

  attr :animation_leave, :string,
    default: "opacity-0 scale-95",
    doc: """
    Classes applied when the dropdown menu leaves. Usually defines the initial
    state of the exit animation.
    """

  attr :open_on_hover, :boolean,
    default: false,
    doc: """
    When true, opens the dropdown menu on mouse hover instead of click.
    Can be combined with hover delays for better user experience.
    """

  attr :hover_open_delay, :integer,
    default: 0,
    doc: """
    Delay in milliseconds before opening the menu when hovering. Only applies
    when `open_on_hover` is true.
    """

  attr :hover_close_delay, :integer,
    default: 0,
    doc: """
    Delay in milliseconds before closing the menu when mouse leaves. Only
    applies when `open_on_hover` is true.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content of the dropdown menu. Usually contains `dropdown_link`,
    `dropdown_button`, or other dropdown components.
    """

  slot :toggle,
    doc: """
    Optional custom toggle element. When provided, replaces the default button
    toggle while maintaining proper accessibility attributes.
    """ do
    attr :class, :any, doc: "Additional CSS classes for the wrapper of the custom toggle element."
  end

  def dropdown(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> gen_id() end)
      |> assign(:styles, @styles)
      |> update(:toggle, fn
        [] -> nil
        [toggle] -> toggle
      end)

    ~H"""
    <div
      id={@id}
      class={merge([@styles[:container], @container_class])}
      phx-hook="Fluxon.Dropdown"
      data-open-on-hover={@open_on_hover}
      data-hover-open-delay={@hover_open_delay}
      data-hover-close-delay={@hover_close_delay}
      data-placement={@placement}
    >
      <.button
        :if={is_nil(@toggle)}
        id={"#{@id}-toggle"}
        type="button"
        class={merge([@styles[:toggle_button], @toggle_class])}
        aria-haspopup="true"
        aria-expanded="false"
        aria-disabled={@disabled}
        aria-controls={"#{@id}-menu"}
        disabled={@disabled}
      >
        {@label}

        <.chevron_icon styles={@styles} />
      </.button>

      <div
        :if={@toggle}
        id={"#{@id}-toggle"}
        aria-haspopup="true"
        aria-expanded="false"
        aria-controls={"#{@id}-menu"}
        aria-disabled={@disabled}
        data-part="button"
        class={merge([@styles[:custom_toggle], @toggle[:class]])}
        disabled={@disabled}
      >
        {render_slot(@toggle)}
      </div>

      <div
        id={"#{@id}-menu"}
        class={merge([@styles[:menu], @class])}
        role="menu"
        aria-orientation="vertical"
        aria-labelledby={"#{@id}-toggle"}
        tabindex="-1"
        data-part="menu"
        hidden
        data-animation={@animation}
        data-animation-enter={@animation_enter}
        data-animation-leave={@animation_leave}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc ~S'''
  Renders a dropdown header.

  A dropdown header is used to visually group and label sections of menu items within a dropdown.
  It provides a non-interactive title or category for a set of related menu options.

  - Adds a visual separator and title to group related menu items
  - Not a navigable or selectable item in the dropdown menu
  - Typically styled differently from regular menu items (e.g., smaller font, different color)

  [INSERT LVATTRDOCS]

  ## Examples

  <!-- preview-open -->

  ```heex
  <.dropdown_header>Account Settings</.dropdown_header>
  <.dropdown_link patch={~p"/profile"}>Edit Profile</.dropdown_link>
  <.dropdown_link patch={~p"/settings"}>Preferences</.dropdown_link>

  <.dropdown_header>Help & Support</.dropdown_header>
  <.dropdown_link navigate={~p"/faq"}>FAQ</.dropdown_link>
  <.dropdown_link navigate={~p"/contact"}>Contact Us</.dropdown_link>
  ```

  <!-- preview-separator -->

  ![Custom Header](images/dropdown/header.png)

  <!-- preview-close -->
  '''
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes for the header element. The new classes will be merged with the default styles.
    """

  attr :rest, :global,
    doc: """
    Additional HTML attributes to apply to the header element.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content of the header. Usually contains text but can include other
    elements for complex headers.
    """

  def dropdown_header(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <header class={merge([@styles[:header], @class])}>
      {render_slot(@inner_block)}
    </header>
    """
  end

  @doc ~S'''
  Renders a dropdown separator.

  A separator is essentially a horizontal line that divides dropdown menu items,
  providing visual separation between groups of options.

  [INSERT LVATTRDOCS]

  ## Examples

  <!-- preview-open -->

  ```heex
  <.dropdown_link patch={~p"/profile"}>Edit Profile</.dropdown_link>
  <.dropdown_link patch={~p"/settings"}>Preferences</.dropdown_link>
  <.dropdown_separator />
  <.dropdown_link href={~p"/sign_out"} method="delete">Sign Out</.dropdown_link>
  ```

  <!-- preview-separator -->

  ![Custom Separator](images/dropdown/separator.png)

  <!-- preview-close -->
  '''
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes for the separator element. The new classes will be merged with the default styles.
    """

  attr :rest, :global,
    doc: """
    Additional HTML attributes to apply to the separator element.
    """

  def dropdown_separator(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <div aria-hidden="true" class={merge([@styles[:separator], @class])} {@rest}></div>
    """
  end

  @doc ~S'''
  Renders a custom content area within the dropdown menu.

  This function allows you to insert arbitrary content into the dropdown menu that is not
  treated as a standard menu item. It provides a flexible space where you can add any HTML
  elements or components, such as buttons, texts, or complex interactive elements.

  - Not treated as a navigable menu item in the dropdown's keyboard navigation flow.
  - Can contain focusable elements that are still accessible via tab navigation.
  - Useful for adding non-standard content or functionality to your dropdown menu.

  [INSERT LVATTRDOCS]

  ## Examples

  <!-- preview-open -->

  ```heex
  <.dropdown_custom class="flex items-center p-2">
    <img src="https://i.pravatar.cc/150?u=1" alt="Avatar" class="size-9 rounded-full" />
    <div class="flex flex-col ml-3 mr-10">
      <span class="text-sm font-medium leading-snug">Emma Johnson</span>
      <span class="text-xs text-zinc-500 leading-snug">emma@acme.com</span>
    </div>
    <.badge color="red" class="ml-auto">PRO</.badge>
  </.dropdown_custom>

  <.dropdown_custom class="flex items-center gap-x-10 bg-zinc-100/70 rounded-lg p-2">
    <div class="flex flex-col">
      <span class="text-sm font-medium">Available Tokens</span>
      <span class="text-sm text-zinc-500">Only 75 tokens available</span>
    </div>
    <.button size="xs" class="ml-auto">Manage</.button>
  </.dropdown_custom>
  ```

  <!-- preview-separator -->

  ![Custom Content](images/dropdown/custom-content.png)

  <!-- preview-close -->
  '''
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes for the custom content container. The new classes will be merged with the default styles.
    """

  attr :rest, :global,
    doc: """
    Additional HTML attributes to apply to the custom content container.
    """

  slot :inner_block,
    required: true,
    doc: """
    The custom content to be rendered. Can contain any HTML or components
    for creating complex dropdown items.
    """

  def dropdown_custom(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <div class={merge([@styles[:custom_content], @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a dropdown link item.

  A dropdown link is a navigable item within the dropdown menu. It renders as a `<.link>` component,
  which means it supports both standard HTML link attributes and LiveView-specific navigation options.

  - Supports LiveView navigation with `navigate` and `patch` attributes
  - Can be used with standard `href` for regular link behavior
  - Styled consistently with other dropdown items
  - Accessible, with appropriate ARIA attributes for menu interaction
  - Can be disabled with the `data-disabled` attribute

  [INSERT LVATTRDOCS]

  ## Examples

  ```heex
  <.dropdown_link navigate={~p"/dashboard"}>
    Dashboard
  </.dropdown_link>

  <.dropdown_link patch={~p"/settings"}>
    Settings
  </.dropdown_link>

  <.dropdown_link href="https://example.com" target="_blank">
    External Link
  </.dropdown_link>

  <.dropdown_link navigate={~p"/admin"} data-disabled>
    Admin Panel
  </.dropdown_link>
  ```
  """

  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes for the link element. The new classes will be merged with the default styles.
    """

  attr :rest, :global,
    include: ~w(navigate patch href replace method csrf_token download hreflang referrerpolicy rel target type),
    doc: """
    Additional HTML attributes for the link element. Supports both standard
    anchor attributes and LiveView navigation options.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content of the link item. Usually contains text but can include
    icons or other elements.
    """

  def dropdown_link(assigns) do
    assigns =
      assigns
      |> assign(:id, gen_id())
      |> assign(:styles, @styles)

    ~H"""
    <.link id={@id} class={merge([@styles[:menu_item], @class])} role="menuitem" tabindex="-1" data-part="menuitem" {@rest}>
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc ~S'''
  Renders a dropdown button item.

  A dropdown button is an interactive item within the dropdown menu that triggers an action
  rather than navigating to a new page. It renders as a `<button>` element, making it ideal
  for handling click events or other interactive behaviors.

  - Renders as a `<button type="button">` element
  - Styled consistently with other dropdown items
  - Supports Phoenix LiveView event bindings (e.g., `phx-click`)
  - Accessible, with appropriate ARIA attributes for menu interaction
  - Useful for actions that don't involve page navigation
  - Can be disabled with the `disabled` attribute

  [INSERT LVATTRDOCS]

  ## Examples

  ```heex
  <.dropdown_button phx-click={JS.push("update-view", value: %{view: "grid"})}>
    Grid
  </.dropdown_button>

  <.dropdown_button phx-click="update-view" phx-value-view="list">
    List
  </.dropdown_button>

  <.dropdown_button phx-click={Fluxon.open_dialog("new-user-dialog")}>
    New User
  </.dropdown_button>

  <.dropdown_button disabled>
    Unavailable Option
  </.dropdown_button>
  ```
  '''
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes for the button element. The new classes will be merged with the default styles.
    """

  attr :rest, :global,
    include: ~w(autofocus disabled form formaction formenctype formmethod formnovalidate formtarget name type value),
    doc: """
    Additional HTML attributes to apply to the button element. Useful for
    adding event handlers or data attributes.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content of the button item. Usually contains text but can include
    icons or other elements.
    """

  def dropdown_button(assigns) do
    assigns =
      assigns
      |> assign(:id, gen_id())
      |> assign(:styles, @styles)

    ~H"""
    <button
      id={@id}
      type="button"
      class={merge([@styles[:menu_item], @class])}
      role="menuitem"
      tabindex="-1"
      data-part="menuitem"
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  attr :styles, :map, required: true

  defp chevron_icon(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" class={@styles[:chevron_icon]} viewBox="0 0 24 24">
      <path
        fill="currentColor"
        fill-rule="evenodd"
        d="M5.293 8.293a1 1 0 0 1 1.414 0L12 13.586l5.293-5.293a1 1 0 1 1 1.414 1.414l-6 6a1 1 0 0 1-1.414 0l-6-6a1 1 0 0 1 0-1.414"
        clip-rule="evenodd"
      />
    </svg>
    """
  end
end
