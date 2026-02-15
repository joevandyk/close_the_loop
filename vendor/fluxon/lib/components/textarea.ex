defmodule Fluxon.Components.Textarea do
  @moduledoc """
  A versatile textarea component for capturing multi-line text input.

  This component provides a comprehensive solution for building accessible multi-line text inputs
  with support for labels, help text, and error handling. It seamlessly integrates with Phoenix
  forms and offers multiple size variants to accommodate different use cases.
  """

  use Fluxon.Component
  import Fluxon.Components.Form, only: [error: 1, label: 1]

  @styles %{
    root: [
      "flex flex-col gap-y-2"
    ],
    textarea: [
      # Base layout and appearance
      "w-full min-h-[80px] overflow-hidden rounded-base bg-input text-foreground shadow-base",
      "border border-input placeholder:text-foreground-softest",

      # Focus states
      "outline-hidden focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus transition-[box-shadow] duration-100",

      # Disabled state
      "disabled:bg-input-disabled disabled:opacity-50 disabled:shadow-none disabled:pointer-events-none",

      # Error/invalid state
      "data-invalid:border-danger focus-visible:data-invalid:border-focus-danger focus-visible:data-invalid:ring-focus-danger"
    ],
    help_text: [
      "text-foreground-softer text-sm flex items-center"
    ],
    size: %{
      "sm" => "py-1.5 px-3 sm:text-sm",
      "md" => "py-2 px-3 sm:text-sm",
      "lg" => "py-2.5 px-3.5 text-base",
      "xl" => "py-3 px-4 text-lg"
    }
  }

  @doc """
  Renders a textarea input for capturing multi-line text.

  This component provides a flexible way to build form inputs with support for labels,
  help text, and error handling. It includes built-in form integration and
  accessibility features.

  [INSERT LVATTRDOCS]

  ## Size Variants

  The component offers four size variants to match different UI requirements:

  ```heex
  <.textarea
    name="description"
    label="Small"
    size="sm"
    placeholder="A compact textarea"
  />

  <.textarea
    name="description"
    label="Base (Default)"
    placeholder="Standard size textarea"
  />

  <.textarea
    name="description"
    label="Large"
    size="lg"
    placeholder="Larger textarea for more emphasis"
  />

  <.textarea
    name="description"
    label="Extra Large"
    size="xl"
    placeholder="Maximum emphasis textarea"
  />
  ```

  ## Form Integration

  The component seamlessly integrates with Phoenix forms, handling field bindings,
  validation errors, and form submission:

  ```heex
  <.form :let={f} for={@form} phx-change="validate" phx-submit="save">
    <.textarea
      field={f[:description]}
      label="Description"
      help_text="Provide a detailed description of your project"
    />
  </.form>
  ```

  ## Error Handling

  When used with forms, the component automatically displays validation errors.
  You can also manually provide errors:

  ```heex
  <.textarea
    name="description"
    label="Description"
    errors={["Description must be at least 10 characters"]}
  />
  ```

  ## Examples

  Basic usage with a label and help text:

  ```heex
  <.textarea
    name="bio"
    label="Biography"
    help_text="Tell us about yourself"
    rows={5}
  />
  ```

  Rich form with additional context:

  ```heex
  <.form :let={f} for={@form} phx-change="validate">
    <.textarea
      field={f[:description]}
      label="Project Description"
      sublabel="Optional"
      description="Provide details about your project's goals and scope"
      help_text="Be specific and concise"
      rows={6}
    />
  </.form>
  ```

  Custom styling with additional classes:

  ```heex
  <.textarea
    name="notes"
    label="Meeting Notes"
    size="lg"
    class="font-mono"
    rows={10}
  />
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: """
    The unique identifier for the textarea. When not provided, a random ID will be generated.
    """

  attr :field, Phoenix.HTML.FormField,
    doc: """
    The form field to bind to. When provided, the component automatically handles value
    tracking, errors, and form submission.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the textarea. Useful for controlling the
    appearance and layout of the input.
    """

  attr :help_text, :string,
    default: nil,
    doc: """
    Optional help text displayed below the textarea. Use this to provide additional
    context or instructions to users.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The primary label for the textarea. This text is displayed above the input
    and is used for accessibility purposes.
    """

  attr :sublabel, :string,
    default: nil,
    doc: """
    Additional context displayed to the side of the main label. Useful for providing
    extra information without cluttering the main label.
    """

  attr :description, :string,
    default: nil,
    doc: """
    Detailed description of the textarea field. This text appears below the label
    and can contain longer explanatory text.
    """

  attr :value, :string,
    doc: """
    The current value of the textarea. When using forms, this is automatically
    handled by the `field` attribute.
    """

  attr :errors, :list,
    default: [],
    doc: """
    List of error messages to display below the textarea. These are automatically
    handled when using the `field` attribute with form validation.
    """

  attr :name, :string,
    doc: """
    The form name for the textarea. Required when not using the `field` attribute.
    """

  attr :rows, :integer,
    default: 3,
    doc: """
    The number of visible text lines.
    """

  attr :disabled, :boolean,
    default: false,
    doc: """
    When true, the textarea becomes non-interactive and appears visually muted.
    """

  attr :size, :string,
    default: "md",
    values: ~w(sm md lg xl),
    doc: """
    Controls the size of the textarea:
    - `"sm"`: Compact size for space-constrained UIs
    - `"md"`: Default size suitable for most use cases
    - `"lg"`: Larger size for increased visibility
    - `"xl"`: Extra large size for maximum emphasis
    """

  attr :rest, :global,
    include:
      ~w(autocomplete cols dirname disabled form maxlength minlength name placeholder readonly required rows wrap spellcheck),
    doc: """
    Additional HTML attributes to apply to the textarea element.
    """

  def textarea(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> textarea()
  end

  def textarea(assigns) do
    assigns =
      assigns
      |> assign(styles: @styles)
      |> assign(:id, assigns.id || assigns.name)
      |> assign_new(:value, fn -> "" end)

    ~H"""
    <div class={@styles[:root]}>
      <.label :if={@label} for={@id} sublabel={@sublabel} description={@description}>
        {@label}
      </.label>

      <textarea
        id={@id}
        name={@name}
        class={merge([@styles[:textarea], @styles[:size][@size], @class])}
        data-invalid={@errors != []}
        disabled={@disabled}
        rows={@rows}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>

      <div :if={@help_text} class={@styles[:help_text]}>
        {@help_text}
      </div>

      <.error :for={error <- @errors}>{error}</.error>
    </div>
    """
  end
end
