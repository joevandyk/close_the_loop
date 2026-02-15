defmodule Fluxon.Components.Radio do
  use Fluxon.Component

  import Fluxon.Components.Form, only: [error: 1, label: 1]

  @moduledoc """
  A versatile radio component for building single-selection interfaces with rich styling options.

  This component provides a comprehensive solution for creating accessible radio button groups
  with support for both standard and card-based layouts. It seamlessly integrates with Phoenix
  forms and offers extensive customization options for building everything from simple option
  lists to visually rich selection interfaces.

  ## Usage

  The radio group component can be used in its simplest form for single selections:

  ```heex
  <.radio_group name="system" value="debian" label="Operating System">
    <:radio value="ubuntu" label="Ubuntu" />
    <:radio value="debian" label="Debian" />
    <:radio value="fedora" label="Fedora" />
  </.radio_group>
  ```
  ![Basic Radio Group](images/radio/basic-group.png)

  For more context, you can add sublabels and descriptions:

  ```heex
  <.radio_group
    name="system"
    label="Operating System"
    sublabel="Choose your preferred OS"
    description="Select the operating system that best suits your needs"
  >
    <:radio
      value="ubuntu"
      label="Ubuntu"
      sublabel="Popular and user-friendly"
      description="Ubuntu is a Debian-based Linux operating system"
    />
    <:radio
      value="debian"
      label="Debian"
      sublabel="Stable and reliable"
      description="Debian is a Linux distribution composed of free and open-source software"
    />
    <:radio
      value="fedora"
      label="Fedora"
      sublabel="Cutting-edge features"
      description="Fedora is a Linux distribution developed by the Fedora Project"
    />
  </.radio_group>
  ```
  ![Radio Group with Sublabels and Descriptions](images/radio/basic-sublabel-description.png)

  ## Form Integration

  The radio group component offers two ways to handle form data: using the `field` attribute for Phoenix form integration
  or using the `name` attribute for standalone radio groups. Each approach has its own benefits and use cases.

  ### Using with Phoenix Forms (Recommended)

  When working with Phoenix forms, use the `field` attribute to bind the radio group to a form field:

  ```heex
  <.form :let={f} for={@form} phx-change="validate" phx-submit="save">
    <.radio_group
      field={f[:subscription]}
      label="Subscription Plan"
      description="Choose your preferred subscription plan"
    >
      <:radio value="basic" label="Basic Plan" sublabel="$10/month" />
      <:radio value="pro" label="Pro Plan" sublabel="$20/month" />
      <:radio value="enterprise" label="Enterprise Plan" sublabel="$50/month" />
    </.radio_group>
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
  - Set the radio field's name based on the form structure
  - Display the current value from the form data
  - Show validation errors when present
  - Handle nested form data with proper input naming

  ### Using Standalone Radio Groups

  For simpler cases or when not using Phoenix forms, use the `name` attribute:

  ```heex
  <.radio_group
    name="theme"
    value={@current_theme}
    errors={@errors}
    label="Theme Selection"
  >
    <:radio value="light" label="Light Theme" />
    <:radio value="dark" label="Dark Theme" />
    <:radio value="system" label="System Theme" />
  </.radio_group>
  ```

  When using standalone radio groups:
  - You must provide the `name` attribute
  - Values must be managed manually via the `value` attribute
  - Errors must be passed explicitly via the `errors` attribute
  - Form submission handling needs to be implemented manually
  - Nested data requires manual name formatting (e.g., `user[preferences][theme]`)

  > #### When to Use Each Approach {: .tip}
  >
  > Use the `field` attribute when:
  > - Working with changesets and data validation
  > - Handling complex form data structures
  > - Need automatic error handling
  > - Building CRUD interfaces
  >
  > Use the `name` attribute when:
  > - Building simple selection interfaces
  > - Creating standalone filters
  > - Handling one-off form controls
  > - Need more direct control over the radio group behavior

  ## Card Variant

  The component offers a card variant that transforms radio buttons into rich, interactive selection cards:

  ```heex
  <.radio_group
    name="system"
    label="Choose a plan"
    description="Choose the plan that best suits your needs."
    variant="card"
    control="left"
    class="gap-0"
  >
    <:radio value="basic" label="Basic" sublabel="Perfect for small projects" class="rounded-none -my-px rounded-t-lg" />
    <:radio value="pro" label="Professional" checked sublabel="Most popular for growing teams" class="rounded-none -my-px" />
    <:radio value="business" label="Business" sublabel="Advanced features for larger teams" class="rounded-none -my-px" />
    <:radio value="enterprise" label="Enterprise" sublabel="Custom solutions for organizations" class="rounded-none -my-px" />
  </.radio_group>
  ```
  ![Radio Card Variant](images/radio/card-plans.png)

  ## Rich Content

  The card variant supports custom content through the radio slot, enabling highly customized selection interfaces:

  ```heex
  <.radio_group name="system" label="Category" variant="card" class="grid grid-cols-3">
    <:radio value="web-design" class="flex-1 group has-checked:border-blue-500 has-checked:bg-blue-50">
      <div class="flex flex-col justify-center items-center w-full gap-2">
        <.icon name="u-layout-alt-01-duotone" class="size-6 text-zinc-500 group-has-checked:text-blue-500" />
        <span class="font-medium text-sm group-has-checked:text-zinc-800">Web Design</span>
      </div>
    </:radio>
    <:radio value="ui-ux" class="flex-1 group has-checked:border-blue-500 has-checked:bg-blue-50">
      <div class="flex flex-col justify-center items-center w-full gap-2">
        <.icon name="u-pen-tool-01-duotone" class="size-6 text-zinc-500 group-has-checked:text-blue-500" />
        <span class="font-medium text-sm group-has-checked:text-zinc-800">UI/UX Design</span>
      </div>
    </:radio>
    <:radio value="development" class="flex-1 group has-checked:border-blue-500 has-checked:bg-blue-50">
      <div class="flex flex-col justify-center items-center w-full gap-2">
        <.icon name="u-laptop-02-duotone" class="size-6 text-zinc-500 group-has-checked:text-blue-500" />
        <span class="font-medium text-sm group-has-checked:text-zinc-800">Development</span>
      </div>
    </:radio>
  </.radio_group>
  ```
  ![Radio Rich Content](images/radio/rich-content.png)
  """

  @base_styles [
    # Base appearance and layout
    "peer appearance-none inline-block align-middle select-none shrink-0 size-4.5 p-0 rounded-full",
    "border border-input shadow-xs bg-input",

    # Focus styles & checked state
    "outline-hidden focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus focus-visible:transition-[box-shadow]",
    "checked:border-transparent checked:bg-primary",

    # Disabled state
    "disabled:shadow-none disabled:not-checked:bg-input-disabled disabled:opacity-75"
  ]

  @base_card_styles [
    # Base layout and appearance
    "group flex gap-x-2 p-4 rounded-base bg-surface border border-input shadow-xs",
    "not-has-data-[control]:*:data-[part=control]:sr-only relative",

    # State transitions
    "transition-[box-shadow] duration-100",

    # Interactive states (focus, checked, disabled)
    "outline-hidden has-focus-visible:border-focus has-focus-visible:ring-3 has-focus-visible:ring-focus",
    "has-checked:border-primary has-checked:bg-accent",
    "has-[input:disabled]:pointer-events-none has-[input:disabled]:opacity-75 has-[input:disabled]:bg-input-disabled"
  ]

  @doc """
  Renders a radio group for managing single-selection options.

  This component provides a flexible way to handle exclusive selections, with support for both
  standard radio lists and rich card-based interfaces. It includes built-in form integration,
  error handling, and accessibility features.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: """
    The unique identifier for the radio group. When not provided, a random ID will be generated.
    """

  attr :name, :string,
    doc: """
    The form name for the radio group. Required when not using the `field` attribute.
    """

  attr :value, :any,
    doc: """
    The current selected value of the radio group. When using forms, this is automatically
    handled by the `field` attribute.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The primary label for the radio group. This text is displayed above the radio buttons
    and is used for accessibility purposes.
    """

  attr :sublabel, :string,
    default: nil,
    doc: """
    Additional context displayed on the side of the main label. Useful for providing extra
    information about the radio group without cluttering the main label.
    """

  attr :description, :string,
    default: nil,
    doc: """
    Detailed description of the radio group. This text appears below the label and
    can contain longer explanatory text about the available options.
    """

  attr :errors, :list,
    default: [],
    doc: """
    List of error messages to display below the radio group. These are automatically
    handled when using the `field` attribute with form validation.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the radio group container. Useful for controlling
    layout, spacing, and visual styling of the group.
    """

  attr :field, Phoenix.HTML.FormField,
    doc: """
    The form field to bind to. When provided, the component automatically handles value
    tracking, errors, and form submission.
    """

  attr :disabled, :boolean,
    default: false,
    doc: """
    When true, disables all radio buttons in the group. Disabled radio buttons cannot be
    interacted with and appear visually muted.
    """

  attr :variant, :string,
    default: nil,
    doc: """
    The visual variant of the radio group. Currently supports:
    - `nil` (default): Standard stacked radio buttons
    - `"card"`: Rich selection cards with support for custom content
    """

  attr :control, :string,
    values: ["left", "right"],
    doc: """
    Controls the position of the radio input in card variants. It's only available when `variant="card"`.
    - `"left"`: Places the radio button on the left side of the card
    - `"right"`: Places the radio button on the right side of the card
    """

  attr :rest, :global,
    include: ~w(form),
    doc: """
    Additional attributes to pass to the radio input elements.
    """

  slot :radio,
    required: true,
    doc: """
    Defines the individual radio buttons within the group. Each radio button can have:
    - `value`: The value associated with this radio button
    - `label`: The radio button label
    - `sublabel`: Additional context on the side of the label
    - `description`: Detailed description of the option
    - `disabled`: Whether this specific radio button is disabled
    - `class`: Additional CSS classes for this radio button
    - `checked`: Whether this radio button should be checked by default
    """ do
    attr :value, :any, required: true
    attr :label, :string
    attr :sublabel, :string
    attr :description, :string
    attr :disabled, :boolean
    attr :class, :any
    attr :checked, :boolean
  end

  def radio_group(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> radio_group()
  end

  def radio_group(%{variant: "card"} = assigns) do
    assigns =
      assigns
      |> assign(:base_styles, @base_styles)
      |> assign(:base_card_styles, @base_card_styles)
      |> assign(:id, assigns.id || gen_id())
      |> assign_new(:value, fn -> nil end)
      |> assign_new(:control, fn -> false end)

    ~H"""
    <div class="flex flex-col gap-y-2" role="radiogroup">
      <.label :if={@label} sublabel={@sublabel} description={@description}>{@label}</.label>

      <div class={merge(["gap-3 grid", @class])}>
        <input type="hidden" name={@name} value="" disabled={@disabled} form={@rest[:form]} />
        <label
          :for={{%{value: value} = radio, index} <- Enum.with_index(@radio)}
          value={value}
          class={merge([@base_card_styles, radio[:class]])}
        >
          <div class="flex relative mt-0.25 self-start" data-part="control" data-control={@control}>
            <input
              type="radio"
              name={@name}
              id={"#{@id}-#{index}"}
              value={value}
              checked={to_string(@value) == to_string(value) || radio[:checked]}
              disabled={@disabled || radio[:disabled]}
              aria-invalid={not Enum.empty?(@errors)}
              class={merge([@base_styles, @control == "right" && "order-last"])}
              {@rest}
            />

            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 16 16"
              class="absolute text-foreground-primary opacity-0 peer-checked:opacity-100 inset-0 pointer-events-none"
            >
              <path fill="currentColor" d="M8 11 a3 3 0 1 0 0 -6 a3 3 0 0 0 0 6" />
            </svg>
          </div>

          <div :if={radio[:inner_block]} class="contents">
            {render_slot(radio)}
          </div>

          <.label
            :if={!radio[:inner_block] && radio[:label]}
            for={"#{@id}-#{index}"}
            sublabel={radio[:sublabel]}
            description={radio[:description]}
          >
            {radio[:label]}
          </.label>
        </label>
      </div>

      <.error :for={msg <- @errors} class="mt-2">{msg}</.error>
    </div>
    """
  end

  def radio_group(assigns) do
    assigns =
      assigns
      |> assign(:base_styles, @base_styles)
      |> assign(:id, assigns.id || gen_id())
      |> assign_new(:value, fn -> nil end)

    ~H"""
    <div class="flex flex-col gap-y-2">
      <.label :if={@label} sublabel={@sublabel} description={@description}>{@label}</.label>

      <div class={merge(["flex flex-col gap-3", @class])}>
        <input type="hidden" name={@name} value="" disabled={@disabled} form={@rest[:form]} />
        <div
          :for={{%{value: value} = radio, index} <- Enum.with_index(@radio)}
          data-part="field"
          class={[
            "has-data-[part=label]:grid has-data-[part=label]:grid-cols-[auto_1fr]",
            "has-data-[part=label]:gap-x-3 has-data-[part=label]:gap-y-1",
            "not-has-data-[part=label]:inline-flex",
            "has-data-[part=label]:*:data-[part=control]:mt-0.25",
            "has-[input:disabled]:opacity-75",
            "not-has-data-[part=description]:**:[label]:font-normal",
            "**:data-[part=error]:col-span-2"
          ]}
        >
          <div class="inline-flex shrink-0 self-start relative has-[input:disabled]:opacity-75" data-part="control">
            <input
              type="radio"
              name={@name}
              id={"#{@id}-#{index}"}
              value={value}
              checked={to_string(@value) == to_string(value) || radio[:checked]}
              disabled={@disabled || radio[:disabled]}
              class={merge([@base_styles, radio[:class]])}
              {@rest}
            />

            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 16 16"
              class="absolute text-foreground-primary opacity-0 peer-checked:opacity-100 inset-0 pointer-events-none"
            >
              <path fill="currentColor" d="M8 11 a3 3 0 1 0 0 -6 a3 3 0 0 0 0 6" />
            </svg>
          </div>

          <.label :if={radio[:label]} for={"#{@id}-#{index}"} sublabel={radio[:sublabel]} description={radio[:description]}>
            {radio[:label]}
          </.label>
        </div>
      </div>

      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end
end
