defmodule Fluxon.Components.Button do
  @moduledoc """
  A versatile button component that provides consistent, accessible, and visually appealing interactive elements.

  This component offers a comprehensive solution for building interactive elements across your application,
  from simple actions to complex workflows. It seamlessly integrates with Phoenix LiveView and automatically
  renders either a `<button>` or an `<a>` tag based on the provided attributes, making it suitable for navigation,
  form submissions, and general user interactions.

  ## Usage

  Buttons can be used in their simplest form for actions and interactions:

  ```heex
  <.button>Outline Button (Default)</.button>
  <.button variant="solid" color="primary">Solid Button</.button>
  <.button variant="soft" color="primary">Soft Button</.button>
  <.button variant="ghost">Ghost Button</.button>
  ```
  ![Basic Buttons](images/button/basic-buttons.png)

  ## Visual Variants

  The component supports six distinct visual styles:

  ```heex
  <.button variant="solid" color="primary">Solid</.button>
  <.button variant="soft" color="primary">Soft</.button>
  <.button variant="surface" color="primary">Surface</.button>
  <.button variant="outline">Outline (Default)</.button>
  <.button variant="dashed">Dashed</.button>
  <.button variant="ghost">Ghost</.button>
  ```
  ![Button Variants](images/button/button-variants.png)

  Each variant is designed for specific use cases:
  - `solid`: Filled button with strongest visual weight, perfect for primary actions
  - `soft`: Subtle background without border, ideal for secondary actions
  - `surface`: Like soft but with a border, great for contained secondary actions
  - `outline`: Button with border and transparent background, good for alternative actions (Default)
  - `dashed`: Similar to outline but with dashed border, useful for placeholder or draft actions
  - `ghost`: Borderless button with hover state, great for minimal actions

  ## Colors and Theming

  The button supports multiple semantic color schemes, each carefully designed for both light and dark modes:

  ```heex
  <.button color="primary" variant="solid">Primary</.button>
  <.button color="info" variant="soft">Info</.button>
  <.button color="success" variant="surface">Success</.button>
  <.button color="warning" variant="outline">Warning</.button>
  <.button color="danger" variant="ghost">Danger</.button>
  ```
  ![Button Colors](images/button/button-colors.png)

  Available colors and their common use cases:
  - `primary`: Most important actions (e.g., save, submit, continue)
  - `info`: Informational actions (e.g., view details, learn more)
  - `success`: Positive actions (e.g., confirm, approve)
  - `warning`: Actions that require attention (e.g., confirmation prompts)
  - `danger`: Destructive actions (e.g., delete, remove)

  Each color includes specific styling for all variants:
  - `solid`: Full color with contrasting foreground text
  - `soft`: Subtle color background with colored text
  - `surface`: Soft background with matching border and colored text
  - `outline`: Colored border and text with transparent background
  - `dashed`: Colored dashed border and text with transparent background
  - `ghost`: Colored text with transparent background

  ## Size Options

  The component offers various size variants to accommodate different UI needs:

  ```heex
  <.button size="xs">Extra Small</.button>
  <.button size="sm">Small</.button>
  <.button size="md">Medium (Default)</.button>
  <.button size="lg">Large</.button>
  <.button size="xl">Extra Large</.button>
  ```
  ![Button Sizes](images/button/button-sizes.png)

  ### Standard Sizes

  | Size | Height | Text | Icon Size | Use Case                  |
  |------|--------|------|-----------|---------------------------|
  | `xs` | 28px   | xs   | 14px      | Compact UI elements       |
  | `sm` | 32px   | sm   | 16px      | Secondary actions         |
  | `md` | 36px   | sm   | 20px      | Default size              |
  | `lg` | 40px   | base | 20px      | Primary actions           |
  | `xl` | 44px   | base | 20px      | Hero sections, prominent calls to action |

  ### Icon-Only Sizes

  Dedicated sizes are available for icon-only buttons, ensuring they are square and the icon is centered:

  ```heex
  <.button size="icon-sm">
    <.icon name="hero-pencil" class="icon" />
  </.button>
  <.button size="icon" variant="solid" color="primary">
    <.icon name="hero-magnifying-glass" class="icon" />
  </.button>
  <.button size="icon-lg" variant="ghost">
    <.icon name="hero-x-mark" class="icon" />
  </.button>
  ```
  ![Icon-Only Buttons](images/button/icon-only-buttons.png)

  | Size      | Dimensions | Icon Size | Use Case                     |
  |-----------|------------|-----------|------------------------------|
  | `icon-xs` | 28px x 28px| 14px      | Very compact icon actions    |
  | `icon-sm` | 32px x 32px| 16px      | Small icon actions           |
  | `icon-md` | 36px x 36px| 20px      | Standard icon actions (Default icon size) |
  | `icon`    | 36px x 36px| 20px      | Standard icon actions (Default icon size) |
  | `icon-lg` | 40px x 40px| 18px (special case) | Large icon actions           |
  | `icon-xl` | 44px x 44px| 20px      | Extra large icon actions     |

  ## Working with Icons

  The button component automatically handles icon sizing and spacing based on the chosen `size`. Place an icon component from `Fluxon.Components.Icon` directly inside the button's slot.

  ```heex
  <.button size="lg" variant="solid" color="success">
    <.icon name="hero-check-circle" class="icon" /> Order Confirmed
  </.button>

  <.button size="sm" variant="ghost" color="danger">
    <.icon name="hero-trash" class="icon" /> Remove Item
  </.button>

  <.button size="icon" phx-click="toggle-sidebar">
    <.icon name="hero-bars-3" class="icon" />
  </.button>
  ```
  ![Buttons with Icons](images/button/buttons-with-icons.png)

  > #### Icon Class Required {: .info}
  >
  > Remember to add the `icon` class to your `<.icon>` component for correct sizing and alignment:
  >
  > ```heex
  > <.button>
  >   <.icon name="hero-check" class="icon" /> <!-- Correct -->
  > </.button>
  > ```
  >
  > The `icon` class ensures the icon scales appropriately with the button's `size` attribute.

  ## Automatic Link Rendering

  The component intelligently renders either a `<button>` element or an anchor (`<a>`) tag based on the attributes provided. If you include `href`, `navigate`, or `patch`, it will automatically render as a link. Otherwise, it defaults to a button.

  ```heex
  <.button navigate={~p"/dashboard"} variant="solid" color="primary">
    Go to Dashboard
  </.button>

  <.button href="https://example.com" target="_blank" variant="soft">
    External Link
  </.button>

  <.button patch={~p"/users?sort=name"} variant="ghost">
    Sort by Name
  </.button>
  ```

  When rendered as a link, it supports all standard anchor attributes (`target`, `rel`, etc.) and Phoenix LiveView link attributes (`navigate`, `patch`, `replace`, `method`, `csrf_token`).

  When rendered as a button, it supports standard button attributes (`type`, `disabled`, `form`, `phx-click`, etc.).

  ## Real-World Examples

  ### Primary Action

  ```heex
  <.button variant="solid" color="primary" size="lg" phx-click="submit-form">
    <.icon name="hero-paper-airplane" class="icon" />
    Submit Application
  </.button>
  ```
  ![Primary Action Button](images/button/primary-action.png)

  ### Danger Action

  ```heex
  <.button variant="solid" color="danger" phx-click="delete_item" phx-value-id={@item.id} phx-confirm="Are you sure?">
    <.icon name="hero-trash" class="icon" />
    Delete Item
  </.button>
  ```
  ![Danger Action Button](images/button/danger-action.png)

  ### Navigation Link

  ```heex
  <.button navigate={~p"/settings"} variant="ghost" size="sm">
    <.icon name="hero-cog-6-tooth" class="icon" />
    Account Settings
  </.button>
  ```
  ![Navigation Link Button](images/button/navigation-link.png)

  ### Icon-Only Action

  ```heex
  <.button size="icon" variant="ghost" phx-click="show-details" phx-value-id={@user.id} aria-label="View user details">
    <.icon name="hero-eye" class="icon" />
  </.button>
  ```
  ![Icon Only Action Button](images/button/icon-only-action.png)
  """

  use Phoenix.Component
  import Fluxon.ClassMerge, only: [merge: 1]

  @styles %{
    "base" => [
      # Layout and positioning
      "relative isolate inline-flex items-center justify-center whitespace-nowrap",
      "text-sm font-medium no-underline",
      "rounded-base outline-hidden shrink-0",
      "border",

      # Focus states
      "focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus",
      "transition-[box-shadow] duration-100",

      # Disabled state
      "disabled:opacity-70 disabled:shadow-none disabled:pointer-events-none",
      "data-disabled:opacity-70 data-disabled:shadow-none data-disabled:pointer-events-none",

      # Icon styles
      "[&>.icon]:shrink-0 [&>[data-part=icon]]:shrink-0",
      "[&>.icon]:text-[color-mix(in_oklab,currentColor_70%,transparent)]",
      "[&>[data-part=icon]]:text-[color-mix(in_oklab,currentColor_70%,transparent)]",
      "hover:[&>.icon]:text-current hover:[&>[data-part=icon]]:text-current"
    ],
    "size" => %{
      "xs" => ["h-7 text-xs px-3 gap-x-2 [&>.icon]:size-4 [&>.icon]:-mx-0.5"],
      "sm" => ["h-8 text-sm px-3.5 gap-x-2.5 [&>.icon]:size-4.5 [&>.icon]:-mx-0.5"],
      "md" => ["h-9 text-sm px-3.5 gap-x-2.5 [&>.icon]:size-5 [&>.icon]:-mx-0.5"],
      "lg" => ["h-10 text-sm px-3.5 py-2.5 gap-x-2.5 [&>.icon]:size-5.5 [&>.icon]:-mx-0.5"],
      "xl" => ["h-11 text-base px-4 py-3 gap-x-3 [&>.icon]:size-6 [&>.icon]:-mx-0.5"],
      "icon-xs" => ["size-7 [&>.icon]:size-4"],
      "icon-sm" => ["size-8 [&>.icon]:size-4.5"],
      "icon-md" => ["size-9 [&>.icon]:size-5"],
      "icon" => ["size-9 [&>.icon]:size-5"],
      "icon-lg" => ["size-10 [&>.icon]:size-5.5"],
      "icon-xl" => ["size-11 [&>.icon]:size-6"]
    },
    "variant" => %{
      "solid" => [
        "shadow-base border-[color-mix(in_oklab,black_10%,transparent)]",
        "before:absolute before:inset-0 before:border before:border-white/12 before:mask-b-from-0%",
        "before:rounded-[calc(var(--radius-base)-1px)]",
        "before:pointer-events-none"
      ],
      "soft" => [
        "border-transparent before:hidden"
      ],
      "surface" => [
        "shadow-base before:hidden"
      ],
      "outline" => [
        "border-base bg-base",
        "inset-shadow-[0_-1px_0_rgba(0,0,0,.05)]",
        "shadow-base before:hidden"
      ],
      "dashed" => [
        "border-base border-dashed bg-transparent shadow-base before:hidden"
      ],
      "ghost" => [
        "border-transparent bg-transparent before:hidden"
      ]
    },
    "color" => %{
      "primary" => %{
        "solid" => [
          "bg-primary text-foreground-primary",
          "hover:bg-[color-mix(in_oklab,var(--primary),white_10%)]"
        ],
        "soft" => [
          "bg-primary-soft text-foreground",
          "hover:bg-[color-mix(in_oklab,var(--primary-soft),var(--primary)_5%)]"
        ],
        "surface" => [
          "bg-primary-soft text-foreground border-primary/20",
          "hover:bg-[color-mix(in_oklab,var(--primary-soft),var(--primary)_5%)]"
        ],
        "outline" => [
          "text-foreground border-base",
          "hover:bg-accent"
        ],
        "dashed" => [
          "text-primary border-base",
          "hover:bg-accent"
        ],
        "ghost" => [
          "text-primary",
          "hover:bg-accent"
        ]
      },
      "danger" => %{
        "solid" => [
          "bg-danger text-foreground-danger",
          "hover:bg-[color-mix(in_oklab,var(--danger),white_10%)]"
        ],
        "soft" => [
          "bg-danger-soft text-danger",
          "hover:bg-[color-mix(in_oklab,var(--danger-soft),var(--danger)_10%)]"
        ],
        "surface" => [
          "bg-danger-soft text-danger border-danger",
          "hover:bg-[color-mix(in_oklab,var(--danger-soft),var(--danger)_10%)]"
        ],
        "outline" => [
          "text-danger border-danger",
          "hover:bg-danger-soft"
        ],
        "dashed" => [
          "text-danger border-danger",
          "hover:bg-danger-s  oft"
        ],
        "ghost" => [
          "text-danger",
          "hover:bg-danger-soft"
        ]
      },
      "warning" => %{
        "solid" => [
          "bg-warning text-foreground-warning",
          "hover:bg-[color-mix(in_oklab,var(--warning),white_10%)]"
        ],
        "soft" => [
          "bg-warning-soft text-foreground-warning-soft",
          "hover:bg-[color-mix(in_oklab,var(--warning-soft),var(--warning)_10%)]"
        ],
        "surface" => [
          "bg-warning-soft text-foreground-warning-soft border-warning",
          "hover:bg-[color-mix(in_oklab,var(--warning-soft),var(--warning)_10%)]"
        ],
        "outline" => [
          "text-foreground-warning-soft border-warning",
          "hover:bg-warning-soft"
        ],
        "dashed" => [
          "text-foreground-warning-soft border-warning",
          "hover:bg-warning-soft"
        ],
        "ghost" => [
          "text-foreground-warning-soft",
          "hover:bg-warning-soft"
        ]
      },
      "success" => %{
        "solid" => [
          "bg-success text-foreground-success",
          "hover:bg-[color-mix(in_oklab,var(--success),white_10%)]"
        ],
        "soft" => [
          "bg-success-soft text-success",
          "hover:bg-[color-mix(in_oklab,var(--success-soft),var(--success)_10%)]"
        ],
        "surface" => [
          "bg-success-soft text-success border-success",
          "hover:bg-[color-mix(in_oklab,var(--success-soft),var(--success)_10%)]"
        ],
        "outline" => [
          "text-success border-success",
          "hover:bg-success-soft"
        ],
        "dashed" => [
          "text-success border-success",
          "hover:bg-success-soft"
        ],
        "ghost" => [
          "text-success",
          "hover:bg-success-soft"
        ]
      },
      "info" => %{
        "solid" => [
          "bg-info text-foreground-info",
          "hover:bg-[color-mix(in_oklab,var(--info),white_10%)]"
        ],
        "soft" => [
          "bg-info-soft text-info",
          "hover:bg-[color-mix(in_oklab,var(--info-soft),var(--info)_10%)]"
        ],
        "surface" => [
          "bg-info-soft text-info border-info",
          "hover:bg-[color-mix(in_oklab,var(--info-soft),var(--info)_10%)]"
        ],
        "outline" => [
          "text-info border-info",
          "hover:bg-info-soft"
        ],
        "dashed" => [
          "text-info border-info",
          "hover:bg-info-soft"
        ],
        "ghost" => [
          "text-info",
          "hover:bg-info-soft"
        ]
      }
    },
    "button_group" => [
      "inline-flex",
      "*:data-[part=button]:not-first:rounded-l-none *:data-[part=button]:not-last:rounded-r-none",
      "*:not-first:**:data-[part=button]:rounded-l-none *:not-last:**:data-[part=button]:rounded-r-none",
      "*:-ml-px",
      "**:data-[part=button]:focus:z-10",
      "**:data-[part=button]:before:rounded-[inherit]!",
      "*:data-[part=button]:not-first:before:border-l-0!",
      "*:data-[part=button]:not-last:before:border-r-0!"
    ]
  }

  @a_attrs ~w(target download rel hreflang type referrerpolicy)
  @link_attrs ~w(navigate patch href replace method csrf_token)
  @button_attrs ~w(autofocus disabled form formaction formenctype formmethod formnovalidate formtarget name type value)

  @doc """
  Renders a button or link with customizable styles and attributes.

  This component provides a flexible way to create interactive elements with consistent styling
  across your application. It supports various sizes, colors, and visual variants while maintaining
  proper accessibility and user experience standards.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :color, :string,
    default: "primary",
    values: ~w(primary danger warning success info),
    doc: """
    The semantic color scheme of the button. Each color includes specific styles for all variants
    and maintains proper contrast in both light and dark modes. Available options: `primary`,
    `danger`, `warning`, `success`, `info`.
    """

  attr :size, :string,
    default: "md",
    values: ~w(xs sm md lg xl icon-xs icon-sm icon-md icon icon-lg icon-xl),
    doc: """
    The size variant of the button. Affects height, padding, font size, and icon sizing.
    """

  attr :variant, :string,
    default: "outline",
    values: ~w(solid soft surface outline dashed ghost),
    doc: """
    The visual style variant of the button:
     - `solid`: Filled button with strongest visual weight (primary actions).
     - `soft`: Subtle background without border (secondary actions).
     - `surface`: Like soft but with border (contained secondary actions).
     - `outline`: Border with transparent background (alternative actions, default).
     - `dashed`: Dashed border with transparent background (placeholder/draft actions).
     - `ghost`: No border or background, minimal styling (utility actions).
    """

  attr :disabled, :boolean,
    default: false,
    doc: """
    Whether the button is disabled. When true, the button becomes non-interactive.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to be applied to the button. These are merged with
    the component's base classes, variant styles, and size styles.
    """

  attr :rest, :global,
    default: %{"data-part" => "button"},
    include: @a_attrs ++ @link_attrs ++ @button_attrs,
    doc: """
    Additional HTML attributes to apply to the underlying `<button>` or `<a>` element.
    The component automatically determines whether to render a button or an anchor based on the
    presence of `href`, `navigate`, or `patch` attributes. It supports attributes relevant
    to both element types.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content to be displayed within the button. Supports text and icons
    with automatic spacing and sizing based on the selected size variant.
    """

  def button(assigns) do
    assigns
    |> assign(styles: @styles)
    |> render()
  end

  defp render(%{rest: rest} = assigns) do
    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link
        data-disabled={@disabled}
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
      </.link>
      """
    else
      ~H"""
      <button
        disabled={@disabled}
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
      </button>
      """
    end
  end

  @doc """
  Renders a container to visually group multiple buttons.

  This component wraps multiple `<.button>` components, styling them to appear
  as a single, connected unit.

  ## Examples

  ```heex
  <.button_group>
    <.button>Year</.button>
    <.button>Month</.button>
    <.button>Week</.button>
  </.button_group>

  <.button_group>
    <.button variant="solid" color="info">Copy</.button>
    <.button variant="solid" color="info" size="icon-md">
      <.icon name="hero-clipboard-document" class="icon" />
    </.button>
  </.button_group>
  ```

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :class, :any, default: nil, doc: "Additional CSS classes for the group container."
  attr :rest, :global, doc: "Additional HTML attributes for the group container."

  slot :inner_block, required: true, doc: "The slot for the buttons to be grouped."

  def button_group(assigns) do
    assigns = assign(assigns, styles: @styles)

    ~H"""
    <div class={merge([@styles["button_group"], @class])} role="group" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
