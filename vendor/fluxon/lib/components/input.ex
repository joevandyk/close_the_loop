defmodule Fluxon.Components.Input do
  @moduledoc """
  Provides `<.input>` and `<.input_group>` components for flexible text input fields.

  This module offers a versatile `<.input>` component for various text entry needs,
  including standard text fields, search bars, and specialized inputs like password
  or email fields. It supports multiple size variants, integration with Phoenix forms,
  and a system for adding prefix and suffix content both inside and outside the
  input field.

  It also includes an `<.input_group>` component to visually group multiple related
  inputs or controls together.

  ## Basic Usage

  Render simple input fields by providing a `name`. A `label` is recommended for accessibility.

  ```heex
  <.input name="username" label="Username" placeholder="Enter username..." />
  <.input name="password" type="password" label="Password" />
  <.input name="email" type="email" label="Email" />
  ```

  ## Size Variants

  The component offers five size variants (`xs`, `sm`, `md`, `lg`, `xl`) using the `size` attribute.
  The default size is `md`.

  ```heex
  <.input name="input_xs" size="xs" placeholder="Extra Small" />
  <.input name="input_sm" size="sm" placeholder="Small" />
  <.input name="input_md" size="md" placeholder="Medium (Default)" />
  <.input name="input_lg" size="lg" placeholder="Large" />
  <.input name="input_xl" size="xl" placeholder="Extra Large" />
  ```

  ## Labels, Helper Text & Descriptions

  Use `label`, `sublabel`, `description`, and `help_text` attributes to provide context
  and guidance for the input field.

  ```heex
  <.input
    name="full_example_md"
    label="Email Address"
    sublabel="(required)"
    description="We'll send a confirmation link here."
    size="md"
    help_text="We never share your email."
    placeholder="you@example.com"
  />
  ```

  ## Form Integration

  The input component offers two ways to handle form data: using the `field` attribute for Phoenix form integration
  or using the `name` attribute for standalone inputs. Each approach has its own benefits and use cases.

  ### Using with Phoenix Forms (Recommended)

  When working with Phoenix forms, use the `field` attribute to bind the input to a form field:

  ```heex
  <.form :let={f} for={@form}>
    <.input field={f[:email]} type="email" label="Email" />
    <.input field={f[:password]} type="password" label="Password" />
  </.form>
  ```

  Using the `field` attribute provides several advantages:
  - Automatic value handling from the form data
  - Built-in error handling and validation messages
  - Proper form submission with correct field names
  - Integration with changesets for data validation
  - Automatic ID generation for accessibility
  - Proper handling of nested form data

  The component will automatically:
  - Set the input's name based on the form structure
  - Display the current value from the form data
  - Show validation errors when present
  - Handle nested form data with proper input naming

  ### Using Standalone Inputs

  For simpler cases or when not using Phoenix forms, use the `name` attribute:

  ```heex
  <.input name="search" placeholder="Search..." />
  <.input name="email" type="email" value={@email} errors={@errors} />
  ```

  When using standalone inputs:
  - You must provide the `name` attribute
  - Values must be managed manually via the `value` attribute
  - Errors must be passed explicitly via the `errors` attribute
  - Form submission handling needs to be implemented manually
  - Nested data requires manual name formatting (e.g., `user[email]`)

  > #### When to Use Each Approach {: .tip}
  >
  > Use the `field` attribute when:
  > - Working with changesets and data validation
  > - Handling complex form data structures
  > - Need automatic error handling
  > - Building CRUD interfaces
  >
  > Use the `name` attribute when:
  > - Building simple search inputs
  > - Creating standalone filters
  > - Handling one-off form controls
  > - Need more direct control over the input behavior

  ## Input States (Disabled, Readonly, Errors)

  Control input interactivity and feedback using boolean attributes and the `errors` list.

  ```heex
  # Disabled input (cannot be focused or edited)
  <.input name="disabled_input" value="Cannot change" disabled />

  # Readonly input (can be focused but not edited)
  <.input name="readonly_input" value="Readonly value" readonly />

  # Input with errors (displays error messages below)
  <.input name="error_input" value="invalid@" errors={["Must be a valid email."]} />

  # Disabled via fieldset
  <fieldset disabled>
    <.input name="fieldset_disabled" value="Inherits disabled state" />
  </fieldset>
  ```

  ## Input Types

  Supports standard HTML input types via the `type` attribute.

  ```heex
  <.input type="date" name="date_input" label="Appointment Date" />
  <.input type="time" name="time_input" label="Start Time" />
  <.input type="number" name="count" label="Quantity" min="1" max="10" />
  <.input type="search" name="site_search" placeholder="Search site..." />
  ```

  ## Inner Affixes

  Use the `:inner_prefix` and `:inner_suffix` slots to add content *inside* the input's border.
  Useful for icons, text hints, or small controls like password visibility toggles.

  ```heex
  # Email input with icon prefix
  <.input name="email_icon" placeholder="user@example.com">
    <:inner_prefix>
      <.icon name="hero-at-symbol" class="icon" />
    </:inner_prefix>
  </.input>

  # Password with visibility toggle suffix
  <.input name="password_toggle" type="password" value="secretpassword">
    <:inner_suffix>
      <.button variant="tertiary" size="icon-sm" title="Show password">
        <.icon name="hero-eye" class="icon" />
      </.button>
    </:inner_suffix>
  </.input>

  # URL input with static text prefix
  <.input name="url_prefix" placeholder="yourdomain.com">
    <:inner_prefix class="pointer-events-none text-tertiary">https://www.</:inner_prefix>
  </.input>

  # Input with loading indicator suffix
  <.input name="search_loading" placeholder="Searching..." disabled>
    <:inner_suffix>
      <.loading variant="ring-bg" />
    </:inner_suffix>
  </.input>
  ```

  ## Outer Affixes

  Use the `:outer_prefix` and `:outer_suffix` slots to add content *outside* the input's border.
  Ideal for buttons, select dropdowns, or static text labels that shouldn't be part of the input value.

  ```heex
  # Invite email with send button suffix
  <.input name="invite_user" placeholder="user@example.com">
    <:inner_prefix>
      <.icon name="hero-at-symbol" class="icon" />
    </:inner_prefix>
    <:outer_suffix>
      <.button variant="solid" color="primary">
        <.icon name="hero-paper-airplane" class="icon" /> Invite
      </.button>
    </:outer_suffix>
  </.input>

  # Currency input with dropdown prefix and button suffix
  <.input name="currency_amount" placeholder="100.00">
    <:inner_prefix>$</:inner_prefix>
    <:outer_prefix>
      <select class="h-full w-full rounded-l-lg border-none focus:ring-0 px-2">
        <option value="USD">USD</option>
        <option value="CAD">CAD</option>
      </select>
    </:outer_prefix>
    <:outer_suffix>
      <.button variant="soft" color="primary">Check Balance</.button>
    </:outer_suffix>
  </.input>

  # Website URL input with fixed prefix and suffix
  <.input name="website_full_url" placeholder="mysite">
    <:outer_prefix class="px-2 text-tertiary">https://</:outer_prefix>
    <:outer_suffix class="px-2 text-tertiary">.example.com</:outer_suffix>
  </.input>

  # Weight input with unit suffix
  <.input name="weight_input" type="number" placeholder="50">
    <:outer_suffix class="px-2 text-tertiary">kg</:outer_suffix>
  </.input>
  ```

  > #### Button Size Matching {: .important}
  >
  > When using buttons within `outer_prefix` or `outer_suffix` slots, ensure the button's `size` matches
  > the input's `size` for proper alignment. For example, if the input is `size="lg"`, use a button with
  > `size="lg"` as well.

  ## Input Groups

  Use the `<.input_group>` component to visually combine multiple inputs or related
  controls (like buttons or selects) into a single, seamless unit. It automatically
  adjusts borders and rounding for elements placed within its default slot.

  ```heex
  # Grouping first and last name inputs
  <.input_group label="Full Name">
    <.input name="first_name" placeholder="First Name" />
    <.input name="last_name" placeholder="Last Name" />
  </.input_group>

  # Grouping inputs with a separator element
  <.input_group label="Price Range">
    <.input name="min_price" placeholder="Min price">
      <:inner_prefix>$</:inner_prefix>
    </.input>
    <div class="shrink-0 bg-emphasis border-y border-base shadow-xs self-stretch flex items-center justify-center px-2 text-foreground-softest">
      to
    </div>
    <.input name="max_price" placeholder="Max price">
      <:inner_prefix>$</:inner_prefix>
    </.input>
  </.input_group>

  # Grouping an input with action buttons
  <.input_group>
    <.input name="grouped_action_1" placeholder="Action 1...">
      <:outer_prefix>
        <.button variant="soft" color="primary">Go</.button>
      </:outer_prefix>
    </.input>
    <.input name="grouped_action_2" placeholder="Action 2...">
      <:outer_suffix>
        <.button variant="solid" color="primary">Submit</.button>
      </:outer_suffix>
    </.input>
  </.input_group>

  # Grouping payment card details
  <.input_group>
    <.input name="card_number" placeholder="Card Number">
      <:inner_prefix><.icon name="hero-credit-card" class="icon" /></:inner_prefix>
    </.input>
    <.input name="expiry" placeholder="MM / YY" size="sm" class="w-24" />
    <.input name="cvc" placeholder="CVC" size="sm" class="w-20" />
  </.input_group>

  # Grouping inputs of different sizes (maintains alignment)
  <.input_group>
    <.input name="group_lg_1" size="lg" placeholder="Username" />
    <.input name="group_lg_2" size="lg" placeholder="Code">
      <:outer_suffix>
        <.button variant="soft" color="primary" size="lg">Verify</.button>
      </:outer_suffix>
    </.input>
  </.input_group>
  ```
  """

  use Fluxon.Component

  import Fluxon.Components.Form, only: [error: 1, label: 1]

  @styles %{
    root: [
      "group/root flex",
      "isolate **:has-focus:z-10",
      "*:border *:border-input",
      "*:first:rounded-l-base *:last:rounded-r-base",

      # Overlap border with outer prefix and suffix
      "*:data-[part=outer-prefix]:-mr-px",
      "*:data-[part=outer-suffix]:-ml-px",

      # Conditionally hide border for outer suffix with buttons
      "*:data-[part=outer-prefix]:has-data-[part=button]:border-0",
      "*:data-[part=outer-suffix]:has-data-[part=button]:border-0",

      # Overlap field border when using input group
      "[[data-part=input-group]>*_&]:-mr-px"
    ],
    field: [
      # Base layout and appearance
      "group relative flex items-center w-full bg-input text-foreground shadow-base cursor-text",

      # Focus state
      "has-[input:focus-visible]:border-focus has-[input:focus-visible]:ring-3 has-[input:focus-visible]:ring-focus transition-[box-shadow] duration-100",

      # Error/invalid state
      "data-invalid:border-danger has-[input:focus-visible]:data-invalid:border-focus-danger has-[input:focus-visible]:data-invalid:ring-focus-danger",

      # Disabled state
      "has-[input:disabled]:shadow-none has-[input:disabled]:pointer-events-none has-[input:disabled]:bg-input-disabled has-[input:disabled]:text-foreground-soft"
    ],
    input: [
      "w-full bg-transparent bg-none outline-hidden placeholder:text-foreground-softest"
    ],
    affix: [
      "flex items-center justify-center text-sm text-foreground-soft shrink-0"
    ],
    size: %{
      "xs" => %{
        field: "gap-2 px-2 h-7",
        input: "sm:text-xs",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-3.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-3.5"
        ]
      },
      "sm" => %{
        field: "gap-2 px-2.5 h-8",
        input: "sm:text-sm",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-4",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-4"
        ]
      },
      "md" => %{
        field: "gap-2 px-3 h-9",
        input: "sm:text-sm",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-4.5 **:[.icon]:-mx-0.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-4.5"
        ]
      },
      "lg" => %{
        field: "gap-2 px-3 h-10",
        input: "sm:text-base",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-5"
        ]
      },
      "xl" => %{
        field: "gap-2 px-3 h-11",
        input: "sm:text-lg",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-5.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-5.5"
        ]
      }
    }
  }

  @doc """
  Renders a flexible input field with support for various types, sizes, affixes, and form integration.

  This component handles the rendering of the `<input>` element itself, along with its surrounding
  label, help text, error messages, and any provided prefix/suffix content via slots.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: """
    Sets the HTML `id` attribute for the input element. Defaults to `nil`, in which case an ID is
    automatically generated if needed (e.g., when a `label` is provided or when used with a `field`).
    If integrating with a `Phoenix.HTML.Form` via the `field` attribute, the ID is derived from the field.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The text content for the input's `<label>`. The label is associated with the input via the `for`
    attribute, using the input's `id`.
    """

  attr :sublabel, :string,
    default: nil,
    doc: """
    Optional text displayed inline next to the main `label`. Useful for short hints like "Optional".
    """

  attr :help_text, :string,
    default: nil,
    doc: """
    Optional descriptive text displayed below the input field to provide guidance or clarification.
    """

  attr :description, :string,
    default: nil,
    doc: """
    Optional text displayed below the `label` but above the input field. Suitable for more detailed
    explanations about the input's purpose.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply directly to the input's wrapping `<label data-part="field">` element.
    Allows for custom styling or layout adjustments of the core input container.
    """

  attr :size, :string,
    default: "md",
    values: ~w(xs sm md lg xl),
    doc: """
    Defines the visual size (height, padding, font size) of the input field.
    Available options are: `"xs"`, `"sm"`, `"md"` (default), `"lg"`, `"xl"`.
    """

  attr :disabled, :boolean,
    default: false,
    doc: """
    If `true`, disables the input field, preventing user interaction and applying disabled styles.
    """

  attr :field, Phoenix.HTML.FormField,
    doc: """
    A `Phoenix.HTML.FormField` struct, typically obtained from a form binding (e.g., `f[:email]`).
    When provided, the input's `name`, `id`, `value`, and `errors` are automatically derived from
    this struct, simplifying form integration.
    """

  attr :value, :any,
    doc: """
    The value attribute for the input element. This is required when not using the `field` attribute
    and you need to control the input's value. If `field` is provided, this attribute is ignored
    in favor of `field.value`.
    """

  attr :name, :any,
    doc: """
    The name attribute for the input element. Required when not using the `field` attribute.
    If `field` is provided, this attribute is ignored in favor of `field.name`.
    """

  attr :errors, :list,
    default: [],
    doc: """
    A list of error messages (strings) to display below the input. If the `field` attribute is used,
    errors are automatically extracted from `field.errors`. This attribute is useful for displaying
    errors for standalone inputs.
    """

  attr :type, :string,
    default: "text",
    values: ~w(color date datetime-local email month number password search tel text time url week hidden),
    doc: """
    Sets the `type` attribute of the HTML `<input>` element (e.g., `"text"`, `"password"`, `"email"`).
    Defaults to `"text"`.
    """

  attr :rest, :global,
    include:
      ~w(accept autocomplete capture cols form list max maxlength min minlength pattern placeholder readonly required rows size step),
    doc: """
    Passes any additional HTML attributes supported by the `<input>` element (e.g., `placeholder`,
    `required`, `maxlength`).
    """

  slot :inner_prefix,
    doc: """
    Content placed *inside* the input field's border, before the text entry area.
    Ideal for icons or short textual prefixes (e.g., '$', 'https://'). Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner prefix container."
  end

  slot :outer_prefix,
    doc: """
    Content placed *outside* and before the input field. Useful for buttons, dropdowns, or
    other interactive elements associated with the input's start. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer prefix container."
  end

  slot :inner_suffix,
    doc: """
    Content placed *inside* the input field's border, after the text entry area.
    Suitable for icons, clear buttons, or password visibility toggles. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner suffix container."
  end

  slot :outer_suffix,
    doc: """
    Content placed *outside* and after the input field. Useful for action buttons (e.g., 'Send', 'Search')
    or other controls related to the input's end. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer suffix container."
  end

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || assigns.name)
      |> assign_new(:value, fn -> nil end)

    ~H"""
    <input type="hidden" name={@name} id={@id} value={@value} {@rest} />
    """
  end

  def input(assigns) do
    assigns =
      assigns
      |> assign(styles: @styles)
      |> assign(:id, assigns.id || assigns.name)
      |> assign_new(:value, fn -> nil end)

    ~H"""
    <div class="w-full flex flex-col gap-y-2">
      <.label :if={@label} for={@id} sublabel={@sublabel} description={@description}>
        {@label}
      </.label>

      <div
        class={@styles[:root]}
        data-part="field-root"
        data-outer-prefix={!!(@outer_prefix != [])}
        data-outer-suffix={!!(@outer_suffix != [])}
        data-inner-prefix={!!(@inner_prefix != [])}
        data-inner-suffix={!!(@inner_suffix != [])}
      >
        <div
          :for={slot <- @outer_prefix}
          data-part="outer-prefix"
          class={
            merge([
              # Apply shadow only if the slot content doesn't already have from the button
              "not-has-data-[part=button]:shadow-base",

              # Adjust button rounding when used as an outer prefix
              "**:data-[part=button]:rounded-r-none!",
              "**:data-[part=button]:before:rounded-[inherit]!",
              @styles[:affix],
              slot[:class]
            ])
          }
        >
          {render_slot(slot)}
        </div>

        <label
          for={@id}
          data-part="field"
          data-invalid={@errors != []}
          class={merge([@styles[:field], @styles[:size][@size][:field], @class])}
        >
          <div
            :for={slot <- @inner_prefix}
            data-part="inner-prefix"
            class={
              merge([
                @styles[:affix],
                @styles[:size][@size][:affix],
                slot[:class]
              ])
            }
          >
            {render_slot(slot)}
          </div>

          <input
            class={merge([@styles[:input], @styles[:size][@size][:input]])}
            type={@type}
            name={@name}
            id={@id}
            value={Phoenix.HTML.Form.normalize_value(@type, @value)}
            aria-invalid={@errors != []}
            disabled={@disabled}
            data-part="input"
            {@rest}
          />

          <div
            :for={slot <- @inner_suffix}
            data-part="inner-suffix"
            class={merge([@styles[:affix], @styles[:size][@size][:affix], slot[:class]])}
          >
            {render_slot(slot)}
          </div>
        </label>

        <div
          :for={slot <- @outer_suffix}
          data-part="outer-suffix"
          class={
            merge([
              # Apply shadow only if the slot content doesn't already have from the button
              "not-has-data-[part=button]:shadow-base",

              # Adjust button rounding when used as an outer suffix
              "**:data-[part=button]:rounded-l-none!",
              "**:data-[part=button]:before:rounded-[inherit]!",
              @styles[:affix],
              slot[:class]
            ])
          }
        >
          {render_slot(slot)}
        </div>
      </div>

      <div :if={@help_text} class="text-foreground-softer text-sm flex items-center">
        {@help_text}
      </div>

      <.error :for={error <- @errors}>{error}</.error>
    </div>
    """
  end

  @doc """
  Renders a set of input elements to visually group them together.

  This component adjusts the styling (borders, rounding) of its direct `<.input>`
  children to make them appear as a single, connected unit. It also provides attributes
  for adding a label, description, and help text for the group as a whole.

  > #### Size Consistency {: .important}
  >
  > All inputs within the group should have the same `size` attribute value (e.g., all `"lg"` or all `"md"`).
  > Using inputs with different sizes will break the visual cohesion and border connections between elements.

  ## Examples

  ```heex
  <.input_group label="Login Credentials">
    <.input name="email" placeholder="Email" size="lg" />
    <.input name="password" type="password" placeholder="Password" size="lg" />
  </.input_group>
  ```

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes applied to the outermost `div` wrapping the input group elements (the `div` with `data-part="input-group"`).
    Allows for custom layout or spacing of the group itself, distinct from the label/help text container.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The primary label text displayed above the entire input group.
    """

  attr :sublabel, :string,
    default: nil,
    doc: """
    Optional text displayed inline next to the group's main `label`.
    """

  attr :description, :string,
    default: nil,
    doc: """
    Optional descriptive text displayed below the group `label` but above the grouped input elements.
    """

  attr :help_text, :string,
    default: nil,
    doc: """
    Optional help text displayed below the grouped input elements.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content of the input group, typically one or more `<.input>`, `<.select>`, or `<.button>` components
    that should be visually joined together.
    """

  def input_group(assigns) do
    ~H"""
    <div class="w-full flex flex-col gap-y-2">
      <.label :if={@label} sublabel={@sublabel} description={@description}>
        {@label}
      </.label>

      <div
        data-part="input-group"
        class={
          merge([
            # Base layout
            "flex items-start",

            # Focus and validation states
            "isolate **:has-focus:z-10 **:has-[[data-part=field][data-invalid]]:z-10",

            # Border radius control for inner elements
            "[&_[data-part=field-root]>*]:rounded-none",
            "[&_[data-part=button]]:rounded-none",

            # Left side border radius
            "[&>div:first-child_[data-part]:first-child]:rounded-l-base",
            "[&>div:first-child_[data-part]:first-child>[data-part=button]]:rounded-l-base",

            # Right side border radius
            "[&>div:last-child_[data-part]:last-child]:rounded-r-base",
            "[&>div:last-child_[data-part]:last-child>[data-part=button]]:rounded-r-base",
            @class
          ])
        }
      >
        {render_slot(@inner_block)}
      </div>

      <div :if={@help_text} class="text-foreground-softer text-sm flex items-center">
        {@help_text}
      </div>
    </div>
    """
  end
end
