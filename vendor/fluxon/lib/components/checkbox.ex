defmodule Fluxon.Components.Checkbox do
  use Fluxon.Component

  import Fluxon.Components.Form, only: [error: 1, label: 1]

  @moduledoc """
  A versatile checkbox component for capturing single and multiple selections.

  This component provides a comprehensive solution for building accessible form inputs, selection interfaces,
  and rich interactive content. It seamlessly integrates with Phoenix forms and offers both standard and
  card variants to accommodate various design patterns, from simple boolean toggles to visually rich
  selection interfaces.

  ## Usage

  The checkbox component can be used in its simplest form for single selections:

  ```heex
  <.checkbox
    name="terms"
    label="I agree to the terms and conditions"
  />
  ```

  By default, the checkbox value will be `"true"` when checked and `"false"` when unchecked:

  ```elixir
  %{"_target" => ["terms"], "terms" => "true"}
  %{"_target" => ["terms"], "terms" => "false"}
  ```

  You can customize these values using `checked_value` and `unchecked_value`:

  ```heex
  <.checkbox
    name="active"
    label="Active"
    checked_value="1"
    unchecked_value="0"
  />
  ```

  This is useful when working with database columns that expect specific values:

  ```elixir
  # When checked
  %{"_target" => ["active"], "active" => "1"}

  # When unchecked
  %{"_target" => ["active"], "active" => "0"}
  ```

  For more context, you can add sublabels and descriptions:

  ```heex
  <.checkbox
    name="notifications"
    label="Enable notifications"
    sublabel="Receive updates about your account"
    description="We'll send you important updates about your account status and security."
  />
  ```

  ## Form Integration

  The checkbox component offers two ways to handle form data: using the `field` attribute for Phoenix form integration
  or using the `name` attribute for standalone checkboxes. Each approach has its own benefits and use cases.

  ### Using with Phoenix Forms (Recommended)

  When working with Phoenix forms, use the `field` attribute to bind the checkbox to a form field:

  ```heex
  <.form :let={f} for={@form} phx-change="validate" phx-submit="save">
    <.checkbox
      field={f[:marketing_emails]}
      label="Marketing emails"
      sublabel="Receive updates about new features and promotions"
    />

    <.checkbox
      field={f[:terms_accepted]}
      label="Terms and Conditions"
      description="I agree to the terms of service and privacy policy"
      value="accepted"
    />

    <.checkbox
      field={f[:newsletter_frequency]}
      label="Weekly newsletter"
      value="weekly"
      checked={@user.newsletter_frequency == "weekly"}
    />

    <.checkbox
      field={f[:active]}
      label="Active user"
      checked_value="1"
      unchecked_value="0"
    />
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
  - Set the checkbox field's name based on the form structure
  - Display the current value from the form data
  - Show validation errors when present
  - Handle nested form data with proper input naming

  ### Using Standalone Checkboxes

  For simpler cases or when not using Phoenix forms, use the `name` attribute:

  ```heex
  <.checkbox
    name="show_archived"
    checked={@show_archived}
    label="Show archived items"
  />

  <.checkbox
    name="user[preferences][dark_mode]"
    checked={@user_preferences.dark_mode}
    errors={@errors["dark_mode"]}
    label="Dark mode"
    sublabel="Use dark theme"
  />
  ```

  When using standalone checkboxes:
  - You must provide the `name` attribute
  - Values must be managed manually via the `checked` attribute
  - Errors must be passed explicitly via the `errors` attribute
  - Form submission handling needs to be implemented manually
  - Nested data requires manual name formatting (e.g., `user[preferences][dark_mode]`)

  > #### When to use each approach {: .tip}
  >
  > Use the `field` attribute when:
  > - Working with changesets and data validation
  > - Handling complex form data structures
  > - Need automatic error handling
  > - Building CRUD interfaces
  >
  > Use the `name` attribute when:
  > - Building simple toggle controls
  > - Creating standalone filters
  > - Handling one-off form controls
  > - Need more direct control over the checkbox behavior

  ## Card Variant

  The component offers a card variant that transforms checkboxes into rich, interactive selection cards:

  ```heex
   <.checkbox
      control="left"
      field={f[:notifications]}
      variant="card"
      label="Push Notifications"
      sublabel="Stay informed"
      description="Get real-time updates for messages and activity"
      value="enabled"
    />
  ```

  ## Checkbox Group

  Checkbox groups are used to map a list of options to a single form field:

  ```heex
  <.checkbox_group
    name="preferences"
    label="Notification Preferences"
    description="Choose when you want to receive notifications"
  >
    <:checkbox value="email" label="Email notifications" />
    <:checkbox value="push" label="Push notifications" />
    <:checkbox value="sms" label="SMS notifications" />
  </.checkbox_group>
  ```

  ### Form Integration

  Like the single checkbox component, checkbox groups seamlessly integrate with Phoenix forms. See the form integration section in the [Form Integration](#module-form-integration) section for a detailed guide on form handling.

  Here's a simple example using the `field` attribute:

  ```heex
  <.form :let={f} for={@form} phx-change="validate" phx-submit="save">
    <.checkbox_group
      field={f[:notification_preferences]}
      label="Notification Preferences"
      description="Choose how you want to be notified"
    >
      <:checkbox value="email" label="Email" sublabel="Get notified via email" />
      <:checkbox value="push" label="Push" sublabel="Receive push notifications" />
      <:checkbox value="sms" label="SMS" sublabel="Get SMS alerts" />
    </.checkbox_group>
  </.form>
  ```

  Different from the single checkbox, the group will send a list of selected values in the form submission:

  ```elixir
  %{"_target" => ["preferences"], "preferences" => ["", "email", "push"]}
  ```
  > #### Empty Values in Checkbox Groups {: .info}
  >
  > When working with checkbox groups, it's important to understand how browsers handle unselected checkboxes:
  >
  > - By HTML specification, browsers only submit values for checked checkboxes
  > - If no checkboxes are selected, the field will be completely absent from the form data
  >
  > To ensure consistent form handling, this component includes a hidden input with an empty value:
  >
  > ```elixir
  > <input type="hidden" name="group[]" value="" />
  > ```
  >
  > This means your form submissions will always include the field, with these possible values:
  >
  > ```elixir
  > # No checkboxes selected
  > %{"group" => [""]}
  >
  > # One or more selected
  > %{"group" => ["", "option1", "option2"]}
  > ```
  >
  > When processing the form data, you'll want to:
  > 1. Filter out the empty string value
  > 2. Handle an empty list as "no selection"
  >
  > ```elixir
  > # Example processing
  > selected = Enum.reject(params["group"] || [], &(&1 == ""))
  > ```

  ### Card Variant

  The card variant transforms checkboxes into rich, interactive selection cards:

  ```heex
  <.checkbox_group
    label="Weekdays"
    description="Select the days of the week you want to work"
    field={f[:weekdays]}
    variant="card"
    class="flex gap-x-2"
  >
    <:checkbox
      :for={{label, value} <- [{"S", "sun"}, {"M", "mon"}, {"T", "tue"}, {"W", "wed"}, {"T", "thu"}, {"F", "fri"}, {"S", "sat"}]}
      value={value}
      class="flex items-center justify-center rounded-full has-checked:bg-zinc-800 text-zinc-700 has-checked:text-white size-10"
    >
      <span class="text-sm font-medium">{label}</span>
    </:checkbox>
  </.checkbox_group>
  ```
  """

  @base_checkbox_styles [
    # Base layout and appearance
    "peer appearance-none inline-block align-middle select-none shrink-0 size-4.5 rounded-[0.3125rem] p-0 bg-origin-border",
    "border border-input shadow-xs bg-input duration-100",

    # Focus and checked states
    "outline-hidden focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus focus-visible:transition-[box-shadow]",
    "checked:border-transparent checked:bg-primary indeterminate:bg-primary indeterminate:border-transparent",

    # Disabled state
    "disabled:shadow-none disabled:not-checked:bg-input-disabled disabled:opacity-75"
  ]

  @base_card_styles [
    # Base layout and appearance
    "group flex gap-x-2 p-4 rounded-base bg-surface border border-input shadow-xs",
    "not-has-data-[control]:*:data-[part=control]:sr-only",

    # State transitions
    "has-checked:relative",

    # Interactive states (focus, checked, disabled)
    "outline-hidden has-focus-visible:border-focus has-focus-visible:ring-3 has-focus-visible:ring-focus",
    "has-checked:border-primary has-checked:bg-accent",
    "has-[input:disabled]:pointer-events-none has-[input:disabled]:opacity-75 has-[input:disabled]:bg-input-disabled"
  ]

  @doc """
  Renders a checkbox group for managing multiple related selections.

  This component provides a flexible way to handle multiple choice selections, with support for both
  standard checkbox lists and rich card-based interfaces. It includes built-in form integration,
  error handling, and accessibility features.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: """
    The unique identifier for the checkbox group. When not provided, a random ID will be generated.
    """

  attr :name, :string,
    doc: """
    The form name for the checkbox group. For groups, this will be suffixed with `[]` to support
    multiple selections. Required when not using the `field` attribute.
    """

  attr :value, :any,
    doc: """
    The current value(s) of the checkbox group. For groups, this should be a list of selected values.
    When using forms, this is automatically handled by the `field` attribute.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The primary label for the checkbox group. This text is displayed above the checkboxes
    and is used for accessibility purposes.
    """

  attr :sublabel, :string,
    default: nil,
    doc: """
    Additional context displayed on the side of the main label. Useful for providing extra information
    about the checkbox group without cluttering the main label.
    """

  attr :description, :string,
    default: nil,
    doc: """
    Detailed description of the checkbox group. This text appears below the label and
    can contain longer explanatory text about the available options.
    """

  attr :errors, :list,
    default: [],
    doc: """
    List of error messages to display below the checkbox group. These are automatically
    handled when using the `field` attribute with form validation.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the checkbox group container. Useful for controlling
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
    When true, disables all checkboxes in the group. Disabled checkboxes cannot be
    interacted with and appear visually muted.
    """

  attr :variant, :string,
    default: nil,
    doc: """
    The visual variant of the checkbox group. Currently supports:
    - `nil` (default): Standard stacked checkboxes
    - `"card"`: Rich selection cards with support for custom content
    """

  attr :control, :string,
    values: ["left", "right"],
    doc: """
    Controls the position of the checkbox input in card variants. It's only available when `variant="card"`.
    - `"left"`: Places the checkbox on the left side of the card
    - `"right"`: Places the checkbox on the right side of the card
    """

  attr :rest, :global,
    include: ~w(disabled form),
    doc: """
    Additional HTML attributes to apply to the checkbox input.
    """

  slot :checkbox,
    required: true,
    doc: """
    Defines the individual checkboxes within the group. Each checkbox can have:
    - `value`: The value associated with this checkbox
    - `label`: The checkbox label
    - `sublabel`: Additional context on the side of the label
    - `description`: Detailed description of the option
    - `disabled`: Whether this specific checkbox is disabled
    - `class`: Additional CSS classes for this checkbox
    - `checked`: Whether this checkbox should be checked by default
    """ do
    attr :value, :any, required: true
    attr :label, :string
    attr :sublabel, :string
    attr :description, :string
    attr :disabled, :boolean
    attr :class, :any
    attr :checked, :boolean
  end

  def checkbox_group(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value || [] end)
    |> checkbox_group()
  end

  def checkbox_group(%{variant: "card"} = assigns) do
    assigns =
      assigns
      |> assign(:base_styles, @base_checkbox_styles)
      |> assign(:base_card_styles, @base_card_styles)
      |> assign(:id, assigns.id || gen_id())
      |> assign_new(:value, fn -> [] end)
      |> assign(:name, assigns.name <> "[]")
      |> assign_new(:control, fn -> false end)

    ~H"""
    <div class="flex flex-col gap-y-2" role="group">
      <.label :if={@label} sublabel={@sublabel} description={@description}>{@label}</.label>

      <div class={merge(["gap-3 grid", @class])}>
        <input type="hidden" name={@name} value="" form={@rest[:form]} />
        <label
          :for={{%{value: value} = checkbox, index} <- Enum.with_index(@checkbox)}
          value={value}
          class={merge([@base_card_styles, checkbox[:class]])}
        >
          <div class="flex relative mt-px" data-part="control" data-control={@control}>
            <input
              type="checkbox"
              id={"#{@id}-#{index}"}
              name={@name}
              value={value}
              checked={value in @value || checkbox[:checked]}
              disabled={checkbox[:disabled] || @disabled}
              class={merge([@base_styles, @control == "right" && "order-last"])}
              {@rest}
            />
            <svg
              viewBox="0 0 16 16"
              fill="currentColor"
              xmlns="http://www.w3.org/2000/svg"
              class="absolute text-foreground-primary opacity-0 peer-[:checked:not(:indeterminate)]:opacity-100 inset-0 pointer-events-none"
            >
              <path d="M12.207 4.793a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-2-2a1 1 0 011.414-1.414L6.5 9.086l4.293-4.293a1 1 0 011.414 0z" />
            </svg>

            <svg
              viewBox="0 0 16 16"
              fill="currentColor"
              xmlns="http://www.w3.org/2000/svg"
              class="absolute text-foreground-primary opacity-0 peer-indeterminate:opacity-100 inset-0 pointer-events-none"
            >
              <path
                fill="currentColor"
                fill-rule="evenodd"
                d="M3.75 8a1 1 0 0 1 1-1h6.5a1 1 0 0 1 0 2h-6.5a1 1 0 0 1-1-1"
                clip-rule="evenodd"
              />
            </svg>
          </div>

          <div :if={checkbox[:inner_block]} class="contents">
            {render_slot(checkbox)}
          </div>

          <.label
            :if={checkbox[:label] && !checkbox[:inner_block]}
            for={"#{@id}-#{index}"}
            sublabel={checkbox[:sublabel]}
            description={checkbox[:description]}
          >
            {checkbox[:label]}
          </.label>
        </label>
      </div>

      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def checkbox_group(assigns) do
    assigns =
      assigns
      |> assign(:base_checkbox_styles, @base_checkbox_styles)
      |> assign(:id, assigns.id || gen_id())
      |> assign_new(:value, fn -> [] end)
      |> assign(:name, assigns.name <> "[]")

    ~H"""
    <div class="flex flex-col gap-y-2" role="group">
      <.label :if={@label} sublabel={@sublabel} description={@description}>{@label}</.label>

      <div class={merge(["flex flex-col gap-3", @class])}>
        <input type="hidden" name={@name} value="" form={@rest[:form]} />
        <div
          :for={{%{value: value} = checkbox, index} <- Enum.with_index(@checkbox)}
          data-part="field"
          class={[
            "has-data-[part=label]:grid has-data-[part=label]:grid-cols-[auto_1fr]",
            "has-data-[part=label]:gap-x-3 has-data-[part=label]:gap-y-1",
            "inline-flex",
            "has-data-[part=label]:*:data-[part=control]:mt-px",
            "has-[input:disabled]:*:data-[part=label]:opacity-75",
            "not-has-data-[part=description]:**:[label]:font-normal",
            "**:data-[part=error]:col-span-2"
          ]}
        >
          <div class="inline-flex relative has-[input:disabled]:opacity-75" data-part="control">
            <input
              type="checkbox"
              id={"#{@id}-#{index}"}
              name={@name}
              value={value}
              checked={value in @value || checkbox[:checked]}
              disabled={checkbox[:disabled] || @disabled}
              class={merge([@base_checkbox_styles, checkbox[:class]])}
              {@rest}
            />
            <svg
              viewBox="0 0 16 16"
              fill="currentColor"
              xmlns="http://www.w3.org/2000/svg"
              class="absolute text-foreground-primary opacity-0 peer-[:checked:not(:indeterminate)]:opacity-100 inset-0 pointer-events-none"
            >
              <path d="M12.207 4.793a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-2-2a1 1 0 011.414-1.414L6.5 9.086l4.293-4.293a1 1 0 011.414 0z" />
            </svg>

            <svg
              viewBox="0 0 16 16"
              fill="currentColor"
              xmlns="http://www.w3.org/2000/svg"
              class="absolute text-foreground-primary opacity-0 peer-indeterminate:opacity-100 inset-0 pointer-events-none"
            >
              <path
                fill="currentColor"
                fill-rule="evenodd"
                d="M3.75 8a1 1 0 0 1 1-1h6.5a1 1 0 0 1 0 2h-6.5a1 1 0 0 1-1-1"
                clip-rule="evenodd"
              />
            </svg>
          </div>

          <.label
            :if={checkbox[:label]}
            for={"#{@id}-#{index}"}
            sublabel={checkbox[:sublabel]}
            description={checkbox[:description]}
          >
            {checkbox[:label]}
          </.label>
        </div>
      </div>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a single checkbox input for capturing boolean or single-value selections.

  This component provides a flexible way to build form inputs with support for labels,
  descriptions, and rich styling options. It includes built-in form integration, error
  handling, and accessibility features.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: """
    The unique identifier for the checkbox. When not provided, a random ID will be generated.
    """

  attr :name, :any,
    doc: """
    The form name for the checkbox. Required when not using the `field` attribute.
    """

  attr :checked, :boolean,
    doc: """
    Whether the checkbox is checked. When using forms, this is automatically handled
    by the `field` attribute.
    """

  attr :value, :any,
    doc: """
    The value associated with the checkbox. When using forms, this is the current value
    from the form data. For standalone checkboxes, this determines if the checkbox is checked.
    """

  attr :checked_value, :any,
    default: "true",
    doc: """
    The value to be sent when the checkbox is checked. Defaults to `"true"`.

    ## Examples

        # Sending "1" when checked
        <.checkbox name="active" checked_value="1" unchecked_value="0" />

        # Sending "yes" when checked
        <.checkbox name="agree" checked_value="yes" unchecked_value="no" />
    """

  attr :unchecked_value, :any,
    default: "false",
    doc: """
    The value to be sent when the checkbox is unchecked. Defaults to `"false"`.
    This value is submitted via a hidden input to ensure the field is always present in form data.
    """

  attr :errors, :list,
    default: [],
    doc: """
    List of error messages to display below the checkbox. These are automatically
    handled when using the `field` attribute with form validation.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The primary label for the checkbox. This text is displayed next to the checkbox
    and is used for accessibility purposes.
    """

  attr :sublabel, :string,
    default: nil,
    doc: """
    Additional context displayed to the side of the main label. Useful for providing extra
    information without cluttering the main label.
    """

  attr :description, :string,
    default: nil,
    doc: """
    Detailed description of the checkbox option. This text appears below the label
    and can contain longer explanatory text.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the checkbox. Useful for controlling the
    appearance of the checkbox.
    """

  attr :field, Phoenix.HTML.FormField,
    doc: """
    The form field to bind to. When provided, the component automatically handles
    value tracking, errors, and form submission.
    """

  attr :rest, :global,
    include: ~w(disabled form),
    doc: """
    Additional HTML attributes to apply to the checkbox input.
    """

  attr :variant, :string,
    default: nil,
    doc: """
    The visual variant of the checkbox. Currently supports:
    - `nil` (default): Standard checkbox with label
    - `"card"`: Rich selection card with support for custom content
    """

  attr :control, :string,
    values: ["left", "right"],
    doc: """
    Controls the position of the checkbox input in card variants. It's only available when `variant="card"`.
    - `"left"`: Places the checkbox on the left side of the card
    - `"right"`: Places the checkbox on the right side of the card
    """

  slot :inner_block,
    required: false,
    doc: """
    Optional custom content for the checkbox. When provided in card variants,
    this content replaces the standard label/sublabel/description structure.
    """

  def checkbox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> checkbox()
  end

  def checkbox(%{variant: "card"} = assigns) do
    assigns =
      assigns
      |> assign(:base_styles, @base_checkbox_styles)
      |> assign(:base_card_styles, @base_card_styles)
      |> assign(:id, assigns.id || gen_id())
      |> assign_new(:value, fn -> nil end)
      |> assign_new(:control, fn -> false end)
      |> assign_new(:checked, fn ->
        Phoenix.HTML.html_escape(assigns[:value]) == Phoenix.HTML.html_escape(assigns[:checked_value])
      end)

    ~H"""
    <div data-part="field">
      <input type="hidden" name={@name} value={@unchecked_value} disabled={@rest[:disabled]} form={@rest[:form]} />
      <label class={merge([@base_card_styles, @class])}>
        <div class="flex relative mt-px self-start" data-part="control" data-control={@control}>
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value={@checked_value}
            checked={@checked}
            class={merge([@base_styles, @control == "right" && "order-last"])}
            {@rest}
          />
          <svg
            viewBox="0 0 16 16"
            fill="currentColor"
            xmlns="http://www.w3.org/2000/svg"
            class="absolute text-foreground-primary opacity-0 peer-[:checked:not(:indeterminate)]:opacity-100 inset-0 pointer-events-none"
          >
            <path d="M12.207 4.793a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-2-2a1 1 0 011.414-1.414L6.5 9.086l4.293-4.293a1 1 0 011.414 0z" />
          </svg>

          <svg
            viewBox="0 0 16 16"
            fill="currentColor"
            xmlns="http://www.w3.org/2000/svg"
            class="absolute text-foreground-primary opacity-0 peer-indeterminate:opacity-100 inset-0 pointer-events-none"
          >
            <path
              fill="currentColor"
              fill-rule="evenodd"
              d="M3.75 8a1 1 0 0 1 1-1h6.5a1 1 0 0 1 0 2h-6.5a1 1 0 0 1-1-1"
              clip-rule="evenodd"
            />
          </svg>
        </div>

        <div :if={@inner_block != []} class="contents">
          {render_slot(@inner_block)}
        </div>

        <.label :if={@inner_block == [] && @label} for={@id} sublabel={@sublabel} description={@description}>
          {@label}
        </.label>
      </label>

      <.error :for={msg <- @errors} class="mt-2">{msg}</.error>
    </div>
    """
  end

  def checkbox(assigns) do
    assigns =
      assigns
      |> assign(:base_checkbox_styles, @base_checkbox_styles)
      |> assign(:id, assigns.id || gen_id())
      |> assign_new(:checked, fn ->
        Phoenix.HTML.html_escape(assigns[:value]) == Phoenix.HTML.html_escape(assigns[:checked_value])
      end)

    ~H"""
    <div
      data-part="field"
      class={[
        "has-data-[part=label]:grid has-data-[part=label]:grid-cols-[auto_1fr]",
        "has-data-[part=label]:gap-x-3 has-data-[part=label]:gap-y-1",
        "inline-flex",
        "has-data-[part=label]:*:data-[part=control]:mt-px",
        "has-[input:disabled]:*:data-[part=label]:opacity-75",
        "not-has-data-[part=description]:**:[label]:font-normal",
        "**:data-[part=error]:col-span-2"
      ]}
    >
      <div class="inline-flex relative has-[input:disabled]:opacity-75" data-part="control">
        <input type="hidden" name={@name} value={@unchecked_value} disabled={@rest[:disabled]} form={@rest[:form]} />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value={@checked_value}
          checked={@checked}
          class={merge([@base_checkbox_styles, @class])}
          {@rest}
        />
        <svg
          viewBox="0 0 16 16"
          fill="currentColor"
          xmlns="http://www.w3.org/2000/svg"
          class="absolute text-foreground-primary opacity-0 peer-[:checked:not(:indeterminate)]:opacity-100 inset-0 pointer-events-none"
        >
          <path d="M12.207 4.793a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-2-2a1 1 0 011.414-1.414L6.5 9.086l4.293-4.293a1 1 0 011.414 0z" />
        </svg>

        <svg
          viewBox="0 0 16 16"
          fill="currentColor"
          xmlns="http://www.w3.org/2000/svg"
          class="absolute text-foreground-primary opacity-0 peer-indeterminate:opacity-100 inset-0 pointer-events-none"
        >
          <path
            fill="currentColor"
            fill-rule="evenodd"
            d="M3.75 8a1 1 0 0 1 1-1h6.5a1 1 0 0 1 0 2h-6.5a1 1 0 0 1-1-1"
            clip-rule="evenodd"
          />
        </svg>
      </div>
      <.label :if={@label} sublabel={@sublabel} description={@description} for={@id}>
        {@label}
      </.label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end
end
