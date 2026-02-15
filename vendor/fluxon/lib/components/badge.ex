defmodule Fluxon.Components.Badge do
  @moduledoc """
  Provides a versatile badge component for status indicators, categories, and notification counts.

  Badges are compact visual markers that highlight information and provide contextual meaning
  through semantic colors, size variants, and visual styles. They integrate seamlessly with
  your design system's color tokens and automatically adapt to light and dark modes.

  ## Basic Usage

  Render badges with content and optional styling attributes:

  ```heex
  <.badge>Default Badge</.badge>
  <.badge color="success">Active</.badge>
  <.badge color="danger" size="lg">Error</.badge>
  <.badge variant="ghost" color="info">Draft</.badge>
  ```

  ## Semantic Colors

  Use semantic colors to convey meaning and status:

  ```heex
  <.badge color="primary">Featured</.badge>
  <.badge color="info">Information</.badge>
  <.badge color="success">Completed</.badge>
  <.badge color="warning">Pending</.badge>
  <.badge color="danger">Failed</.badge>
  ```

  ## Visual Variants

  Choose from six visual styles based on emphasis needs:

  ```heex
  <.badge variant="solid" color="success">High Emphasis</.badge>
  <.badge variant="soft" color="info">Medium Emphasis</.badge>
  <.badge variant="surface" color="warning">Contained</.badge>
  <.badge variant="outline" color="primary">Outline</.badge>
  <.badge variant="dashed" color="warning">Draft State</.badge>
  <.badge variant="ghost" color="primary">Minimal</.badge>
  ```

  Each variant is designed for specific use cases:
  - `solid`: Filled badge with strongest visual weight, perfect for high-priority status
  - `soft`: Subtle background without border, ideal for informational badges
  - `surface`: Like soft but with a border, great for contained status indicators
  - `outline`: Border with transparent background, good for general purpose badges
  - `dashed`: Dashed border with transparent background, useful for draft or placeholder states
  - `ghost`: No border or background, minimal styling for subtle indicators

  ## Size Variants

  Scale badges appropriately for different contexts:

  ```heex
  <.badge size="xs">Extra Small</.badge>
  <.badge size="sm">Small</.badge>
  <.badge size="md">Medium</.badge>
  <.badge size="lg">Large</.badge>
  <.badge size="xl">Extra Large</.badge>
  ```

  ## With Icons

  Enhance badges with icons for better visual communication:

  ```heex
  <.badge color="success">
    <.icon name="hero-check-circle" class="icon" /> Verified
  </.badge>

  <.badge color="warning" size="sm">
    <.icon name="hero-clock" class="icon" /> Pending
  </.badge>

  <.badge color="danger" variant="ghost">
    <.icon name="hero-x-circle" class="icon" /> Failed
  </.badge>
  ```

  Icons automatically scale with badge size and require the `icon` class for proper alignment.

  ## Interactive Usage

  Badges can be made interactive with Phoenix LiveView events:

  ```heex
  <!-- Toggle selection state -->
  <.badge
    color={if @selected, do: "primary", else: "info"}
    variant={if @selected, do: "solid", else: "dashed"}
    phx-click="toggle_selection"
    class="cursor-pointer"
  >
    <.icon :if={@selected} name="hero-check" class="icon" />
    Category
  </.badge>

  <!-- Notification counter -->
  <.badge color="danger" phx-click="view_messages">
    {@message_count}
  </.badge>
  ```

  ## Common Patterns

  ### Status Indicators
  ```heex
  <div class="flex items-center gap-2">
    <span>Database</span>
    <.badge variant="solid" color="success">
      <.icon name="hero-check-circle" class="icon" /> Online
    </.badge>
  </div>
  ```

  ### Navigation Counts
  ```heex
  <div class="flex items-center justify-between">
    <span>Messages</span>
    <.badge color="info">12</.badge>
  </div>
  ```

  ### Filter Tags
  ```heex
  <.badge
    :for={tag <- @active_filters}
    variant="dashed"
    color="primary"
    phx-click="remove_filter"
    phx-value-tag={tag}
    class="cursor-pointer"
  >
    <.icon name="hero-x-mark" class="icon" /> {tag}
  </.badge>
  ```
  """
  use Fluxon.Component

  @styles %{
    "base" => [
      "size-max inline-flex items-center font-medium justify-center whitespace-nowrap",
      "gap-x-1 border",
      "[&_.icon]:shrink-0 [&_.icon]:-ms-px"
    ],
    "size" => %{
      "xs" => "h-4 px-1 text-[10px] [&_.icon]:size-2.5 rounded-[calc(var(--radius-badge)*0.75)]",
      "sm" => "h-5 px-1.5 text-xs [&_.icon]:size-3 rounded-[calc(var(--radius-badge)*0.875)]",
      "md" => "h-5.5 px-1.5 text-sm sm:text-xs [&_.icon]:size-3.5 rounded-badge",
      "lg" => "h-6 px-2 text-sm [&_.icon]:size-4 rounded-[calc(var(--radius-badge)*1.125)]",
      "xl" => "h-7 px-2.5 text-base [&_.icon]:size-4.5 rounded-[calc(var(--radius-badge)*1.25)]"
    },
    "variant" => %{
      "solid" => "border-transparent",
      "soft" => "border-transparent",
      "surface" => "",
      "outline" => "bg-transparent",
      "dashed" => "bg-transparent border-dashed",
      "ghost" => "bg-transparent border-transparent"
    },
    "color" => %{
      "primary" => %{
        "solid" => "bg-[color-mix(in_srgb,var(--primary),var(--background-base)_15%)] text-foreground-primary",
        "soft" => "bg-primary-soft text-foreground-soft",
        "surface" => "bg-primary-soft text-foreground-soft border-primary/30",
        "outline" => "text-foreground-soft border-primary/30",
        "dashed" => "text-foreground border-primary/30",
        "ghost" => "text-foreground"
      },
      "danger" => %{
        "solid" => "bg-danger text-foreground-danger",
        "soft" => "bg-danger-soft text-foreground-danger-soft",
        "surface" => "bg-danger-soft text-foreground-danger-soft border-danger",
        "outline" => "text-foreground-danger-soft border-danger",
        "dashed" => "text-foreground-danger-soft border-danger",
        "ghost" => "text-danger"
      },
      "warning" => %{
        "solid" => "bg-warning text-foreground-warning",
        "soft" => "bg-warning-soft text-foreground-warning-soft",
        "surface" => "bg-warning-soft text-foreground-warning-soft border-warning",
        "outline" => "text-foreground-warning-soft border-warning",
        "dashed" => "text-foreground-warning-soft border-warning",
        "ghost" => "text-warning"
      },
      "success" => %{
        "solid" => "bg-success text-foreground-success",
        "soft" => "bg-success-soft text-foreground-success-soft",
        "surface" => "bg-success-soft text-foreground-success-soft border-success",
        "outline" => "text-foreground-success-soft border-success",
        "dashed" => "text-foreground-success-soft border-success",
        "ghost" => "text-success"
      },
      "info" => %{
        "solid" => "bg-info text-foreground-info",
        "soft" => "bg-info-soft text-foreground-info-soft",
        "surface" => "bg-info-soft text-foreground-info-soft border-info",
        "outline" => "text-foreground-info-soft border-info",
        "dashed" => "text-foreground-info-soft border-info",
        "ghost" => "text-info"
      }
    }
  }

  @doc """
  Renders a badge component with customizable styling and semantic meaning.

  This component provides visual indicators that adapt to your design system's
  color palette and supports variants, colors, and sizes for different contexts.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the badge element.
    """

  attr :color, :string,
    default: "primary",
    values: ~w(primary info success warning danger),
    doc: """
    The semantic color that determines visual appearance and meaning.
    Available options: `primary`, `info`, `success`, `warning`, `danger`.
    """

  attr :size, :string,
    default: "md",
    values: ~w(xs sm md lg xl),
    doc: """
    The size variant that controls dimensions, typography, and icon scaling.
    """

  attr :variant, :string,
    default: "surface",
    values: ~w(solid soft surface outline dashed ghost),
    doc: """
    The visual style variant that determines emphasis level and background treatment:
     - `solid`: Filled badge with strongest visual weight (high-priority status).
     - `soft`: Subtle background without border (informational badges).
     - `surface`: Like soft but with border (contained status indicators).
     - `outline`: Border with transparent background (general purpose).
     - `dashed`: Dashed border with transparent background (draft/placeholder states).
     - `ghost`: No border or background, minimal styling (subtle indicators).
    """

  attr :rest, :global,
    doc: """
    Additional HTML attributes to apply to the badge element.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content to be displayed within the badge. Accepts text, icons, or both.
    When including icons, use the `icon` class for proper scaling and alignment.
    """

  def badge(assigns) do
    assigns = assign(assigns, :styles, @styles)

    ~H"""
    <span
      class={
        merge([
          @styles["base"],
          @styles["variant"][@variant],
          @styles["color"][@color][@variant],
          @styles["size"][@size],
          @class
        ])
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end
