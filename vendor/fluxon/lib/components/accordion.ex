defmodule Fluxon.Components.Accordion do
  @moduledoc """
  A flexible and accessible accordion component for organizing content into collapsible sections.
  Built with progressive disclosure in mind, it provides an interactive way to manage content density
  while maintaining full keyboard navigation and screen reader support.

  The accordion system consists of two main components working together:
  - `accordion`: The main container that manages state, accessibility, and animations
  - `accordion_item`: Individual sections containing headers and expandable panels

  The accordion follows a structured hierarchical organization:

  ```
  accordion
  ├── accordion_item
  │   ├── header (slot)
  │   └── panel (slot)
  ├── accordion_item
  │   ├── header (slot)
  │   └── panel (slot)
  └── accordion_item
      ├── header (slot)
      └── panel (slot)
  ```

  Each `accordion_item` consists of two required slots:
  - `header`: The always-visible clickable area that toggles the panel
  - `panel`: The expandable content area that shows/hides on interaction

  This structure ensures proper state management, accessibility, and visual organization while
  maintaining flexibility for various content patterns, from simple text to complex interactive
  components.

  ## Usage

  The accordion component consists of two main parts: the container (`accordion`) and individual
  sections (`accordion_item`). Each section has a header that toggles visibility and a panel
  that contains the expandable content:

  ```heex
  <.accordion>
    <.accordion_item>
      <:header>What is Fluxon?</:header>
      <:panel>
        Fluxon is a powerful UI component library for Phoenix LiveView applications.
      </:panel>
    </.accordion_item>

    <.accordion_item>
      <:header>How do I get started?</:header>
      <:panel>
        Add Fluxon to your dependencies and follow the installation guide.
      </:panel>
    </.accordion_item>
  </.accordion>
  ```

  ## Expansion Behavior

  The accordion supports two primary modes of operation: single-section and multi-section expansion.
  You can also control whether all sections can be collapsed simultaneously.

  ### Single Section Expansion (Default)

  By default, only one section can be expanded at a time. Opening a new section automatically
  closes the previously expanded one:

  ```heex
  <.accordion>
    <.accordion_item>
      <:header>Section 1</:header>
      <:panel>Content for section 1</:panel>
    </.accordion_item>
    <.accordion_item>
      <:header>Section 2</:header>
      <:panel>Content for section 2</:panel>
    </.accordion_item>
  </.accordion>
  ```

  ### Multiple Section Expansion

  Enable multiple section expansion by setting the `multiple` attribute:

  ```heex
  <.accordion multiple>
    <.accordion_item>
      <:header>Section 1</:header>
      <:panel>Can be open while other sections are expanded</:panel>
    </.accordion_item>
    <.accordion_item>
      <:header>Section 2</:header>
      <:panel>Also can remain open with other sections</:panel>
    </.accordion_item>
  </.accordion>
  ```

  ### Preventing All Closed State

  For cases where at least one section should always remain expanded, use `prevent_all_closed`:

  ```heex
  <.accordion prevent_all_closed>
    <.accordion_item expanded>
      <:header>Always One Open</:header>
      <:panel>This or another section will always be expanded</:panel>
    </.accordion_item>
    <.accordion_item>
      <:header>Another Section</:header>
      <:panel>More content here</:panel>
    </.accordion_item>
  </.accordion>
  ```

  ## Rich Headers

  Headers can contain complex content including icons, badges, or additional text. This is useful
  for creating more informative and visually appealing accordions:

  ```heex
  <.accordion>
    <.accordion_item>
      <:header class="flex items-center gap-3">
        <.icon name="document" class="size-5 text-zinc-400" />
        <div>
          <h3 class="font-medium">Documentation</h3>
          <p class="text-sm text-zinc-500">View the complete documentation</p>
        </div>
        <.badge class="ml-auto">New</.badge>
      </:header>
      <:panel>
        Detailed documentation content...
      </:panel>
    </.accordion_item>
  </.accordion>
  ```

  ## Keyboard Support

  The accordion component implements the WAI-ARIA Accordion Pattern with comprehensive keyboard navigation:

  | Key | Element Focus | Description |
  |-----|---------------|-------------|
  | `Tab`/`Shift+Tab` | Header | Moves focus between accordion headers and other focusable elements |
  | `Space`/`Enter` | Header | Toggles the expansion state of the focused section |
  | `↑` | Header | Moves focus to the previous accordion header |
  | `↓` | Header | Moves focus to the next accordion header |
  | `Home` | Header | Moves focus to the first accordion header |
  | `End` | Header | Moves focus to the last accordion header |
  | `Tab` | Panel | When panel is expanded, allows navigation through focusable elements within |
  """

  use Fluxon.Component

  @doc """
  Renders an accordion component with customizable attributes and slots.

  The accordion component serves as a container for collapsible sections, managing their state,
  interactions, and accessibility. It provides a foundation for building expandable content areas
  with proper keyboard navigation, ARIA support, and animation capabilities.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :string,
    doc: """
    Unique identifier for the accordion container. When not provided, a random ID will be generated.
    This ID is used to establish ARIA relationships between components and manage focus state.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the accordion container. These classes will be merged
    with the default styles. Useful for controlling spacing, width, borders, and other visual
    properties of the entire accordion.
    """

  attr :multiple, :boolean,
    default: false,
    doc: """
    When true, allows multiple accordion items to be expanded simultaneously. When false
    (default), expanding one item will automatically collapse any other expanded items,
    maintaining a single-section view.
    """

  attr :prevent_all_closed, :boolean,
    default: false,
    doc: """
    When true, prevents all accordion items from being closed simultaneously. This ensures
    that at least one item remains expanded at all times, useful for maintaining content
    visibility in critical interfaces.
    """

  attr :animation_duration, :integer,
    default: 300,
    doc: """
    Duration of the expand/collapse animation in milliseconds. This value controls the
    transition speed of panels opening and closing. Adjust this to match your application's
    animation preferences or accessibility requirements.
    """

  attr :rest, :global, doc: "Additional HTML attributes to apply to the accordion container."

  slot :inner_block,
    required: true,
    doc: """
    Content to be rendered inside the accordion. This should contain one or more
    accordion_item components that define the collapsible sections. Each item consists
    of a header and panel slot.
    """

  def accordion(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> gen_id() end)

    ~H"""
    <div
      id={@id}
      phx-hook="Fluxon.Accordion"
      class={@class}
      data-multiple={@multiple}
      data-prevent-all-closed={@prevent_all_closed}
      data-animation-duration={@animation_duration}
      style={"--animation-duration: #{@animation_duration}ms"}
      role="region"
      aria-label="Accordion"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders an individual accordion item with a header and expandable panel.

  Each accordion item consists of a clickable header that toggles the visibility of its associated
  panel. The component handles all necessary ARIA attributes, state management, and animations to
  ensure proper accessibility and user interaction.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :string,
    doc: """
    Unique identifier for the accordion item. When not provided, a random ID will be generated.
    This ID is used to establish ARIA relationships between the header button and its associated
    panel, ensuring proper accessibility.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the accordion item container. These classes will be
    merged with the default styles. Useful for customizing the appearance of individual
    sections, such as borders, backgrounds, or spacing.
    """

  attr :expanded, :boolean,
    default: false,
    doc: """
    Controls the initial expanded state of the accordion item. When true, the item will be
    expanded when first rendered. This is useful for pre-expanding important content or
    maintaining state across renders.
    """

  attr :icon, :boolean,
    default: true,
    doc: """
    Controls the visibility of the chevron icon that indicates expand/collapse state.
    Set to false to hide the icon for a more minimal appearance or when using custom
    indicators in the header slot.
    """

  attr :rest, :global, doc: "Additional HTML attributes to apply to the accordion item."

  slot :panel,
    required: true,
    doc: """
    Content to be displayed in the expandable panel. This content is hidden when the
    accordion item is collapsed and visible when expanded. The panel supports any HTML
    content, including other Phoenix components and LiveView features.
    """ do
    attr :class, :any,
      doc: """
      Additional CSS classes to apply to the panel content container. Useful for styling
      the expanded content area with custom padding, typography, or other visual properties.
      """
  end

  slot :header,
    required: true,
    doc: """
    Content to be displayed in the clickable header. This is always visible and toggles
    the expansion state when clicked. The header can contain complex content including
    icons, text, or other interactive elements.
    """ do
    attr :class, :any,
      doc: """
      Additional CSS classes to apply to the header button. Useful for customizing the
      appearance of the clickable area, including layout, spacing, and hover states.
      """
  end

  def accordion_item(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> gen_id() end)
      |> update(:header, fn
        [] -> []
        [header | _] -> header
      end)
      |> update(:panel, fn
        [] -> []
        [panel | _] -> panel
      end)

    ~H"""
    <div data-part="item" class={merge(["group/accordion-item", @class])} data-expanded={@expanded} {@rest}>
      <button
        type="button"
        data-part="header"
        id={"#{@id}-header"}
        aria-expanded={"#{@expanded}"}
        aria-controls={"#{@id}-panel"}
        class={
          merge([
            "cursor-pointer group/accordion-header flex w-full items-center text-left gap-x-10 justify-between font-medium py-4 text-foreground",
            @header[:class]
          ])
        }
      >
        {render_slot(@header)}

        <.chevron_icon :if={@icon} />
      </button>

      <div
        id={"#{@id}-panel"}
        role="region"
        class="w-full overflow-hidden transition-[height] duration-[var(--animation-duration)]"
        aria-labelledby={"#{@id}-header"}
        aria-hidden="true"
        data-part="panel"
        hidden
      >
        <div class={merge(["pr-8 text-foreground-softer", @panel[:class]])}>
          {render_slot(@panel)}
        </div>
      </div>
    </div>
    """
  end

  defp chevron_icon(assigns) do
    ~H"""
    <svg
      fill="none"
      viewBox="0 0 24 24"
      class="size-4 text-foreground-softest transition-transform duration-[var(--animation-duration)] group-data-expanded/accordion-item:rotate-180 group-hover/accordion-item:text-foreground-softer shrink-0"
      aria-hidden="true"
    >
      <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m6 9 6 6 6-6" />
    </svg>
    """
  end
end
