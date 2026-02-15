defmodule Fluxon.Components.Form do
  @moduledoc """
  A collection of form-related components for building accessible and consistent form interfaces.

  This module provides essential form components that work together to create cohesive form experiences.
  It includes components for labels, error messages, and other form-related elements, all designed with
  accessibility and user experience in mind.
  """

  use Fluxon.Component

  @doc """
  Renders a form label with optional sublabel and description.

  This component provides a standardized way to label form inputs with support for additional
  context through sublabels and descriptions. It automatically integrates with Phoenix form
  fields and maintains proper accessibility relationships.

  [INSERT LVATTRDOCS]

  ## Examples

  Basic label with sublabel:

  ```heex
  <.label for="email" sublabel="Required" description="We'll never share your email">
    Email Address
  </.label>
  ```
  ![Label with Sublabel](images/form/label.png)


  Integration with Phoenix form fields:

  ```heex
  <.form :let={f} for={@changeset} phx-submit="save">
    <.label for={f[:email]} sublabel="We'll never share your email">
      Email Address
    </.label>

    <.input field={f[:email]} type="email" />
  </.form>
  ```
  """
  @doc type: :component
  attr :for, :any,
    default: nil,
    doc: """
    The ID of the form control this label is associated with. When used with Phoenix form fields,
    this is automatically set to the field's ID.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the label element. Useful for controlling the appearance
    and layout of the label.
    """

  attr :description, :string,
    default: nil,
    doc: """
    Detailed description text that appears below the label. This text provides additional context
    about the form field being labeled.
    """

  attr :sublabel, :string,
    default: nil,
    doc: """
    Additional text displayed next to the main label. Useful for providing supplementary information
    like field requirements or constraints.
    """

  attr :rest, :global,
    doc: """
    Additional HTML attributes to be applied to the label element.
    """

  slot :inner_block,
    required: true,
    doc: """
    The main label text content. This is the primary text that describes the form field.
    """

  def label(%{for: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, for: field.id)
    |> label()
  end

  def label(assigns) do
    ~H"""
    <div class="inline-grid text-sm gap-y-1 [&+[data-part=field]]:mt-3" data-part="label">
      <div class="inline">
        <label for={@for} class={merge(["font-medium text-foreground", @class])} {@rest}>
          {render_slot(@inner_block)}
        </label>
        <span :if={@sublabel} data-part="sublabel" class="ml-1 text-foreground-softer">
          {@sublabel}
        </span>
      </div>

      <p :if={@description} data-part="description" class="text-foreground-soft">
        {@description}
      </p>
    </div>
    """
  end

  @doc """
  Renders an error message with an optional warning icon.

  This component provides consistent error message styling with an optional icon. It's designed
  to work seamlessly with form validation and can be used both within and outside of forms.

  [INSERT LVATTRDOCS]

  ## Examples

  Basic error message:

  ```heex
  <.error>This field is required</.error>
  ```
  ![Error Examples](images/form/errors.png)

  Error without icon:

  ```heex
  <.error icon={false}>
    Password must be at least 8 characters long
  </.error>
  ```

  Custom styling:

  ```heex
  <.error class="mt-4">
    Please fix the errors above before continuing
  </.error>
  ```
  """
  @doc type: :component
  attr :icon, :boolean,
    default: true,
    doc: """
    Controls the visibility of the warning icon. When true, displays a warning icon
    before the error message.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the error message container. Useful for customizing
    the appearance and layout of error messages.
    """

  slot :inner_block,
    required: true,
    doc: """
    The error message content. This is the text that describes the error condition.
    """

  def error(assigns) do
    ~H"""
    <p data-part="error" class={merge(["flex gap-x-2 text-sm text-danger font-medium", @class])}>
      <span :if={@icon} class="h-[20px] flex items-center">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="size-4">
          <path
            fill="currentColor"
            fill-rule="evenodd"
            d="M12.813 1.668a2 2 0 0 0-1.626 0c-.4.178-.659.49-.84.746-.177.25-.367.579-.576.94l-8.267 14.28c-.21.362-.4.692-.53.971-.132.285-.274.666-.229 1.102a2 2 0 0 0 .813 1.41c.355.258.757.326 1.069.355.306.028.687.028 1.106.028h16.534c.419 0 .8 0 1.106-.028.312-.029.714-.097 1.069-.354a2 2 0 0 0 .813-1.41c.045-.437-.097-.818-.229-1.103-.13-.28-.32-.609-.53-.971L14.23 3.354c-.21-.361-.4-.69-.577-.94-.18-.255-.44-.568-.84-.746M13 9a1 1 0 1 0-2 0v4a1 1 0 1 0 2 0zm-1 7a1 1 0 1 0 0 2h.01a1 1 0 1 0 0-2z"
            clip-rule="evenodd"
          />
        </svg>
      </span>

      <span>{render_slot(@inner_block)}</span>
    </p>
    """
  end
end
