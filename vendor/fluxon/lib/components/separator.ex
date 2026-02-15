defmodule Fluxon.Components.Separator do
  @moduledoc """
  A versatile separator component for creating visual boundaries between content sections.

  This component provides a flexible solution for visually dividing content across your application.
  It supports both horizontal and vertical orientations, with optional text labels, making it suitable
  for various layout patterns and content organization needs.

  ## Usage

  The separator provides a subtle visual division between content sections:

  ```heex
  <div class="py-2">Content above</div>
  <.separator />
  <div class="py-2">Content below</div>
  ```
  ![Basic Separator](images/separator/basic-separator.png)

  ## Orientation Options

  The component supports both horizontal and vertical orientations:

  ```heex
  # Default horizontal separator
  <.separator />

  # Vertical separator for inline content
  <div class="flex h-8 items-center gap-4">
    <span>Left</span>
    <.separator vertical />
    <span>Right</span>
  </div>
  ```

  ## Text Separators

  Add text labels to create semantic divisions:

  ```heex
  <.separator text="or" />
  ```

  ## Customization

  The separator can be customized using Tailwind classes while maintaining its core styling:

  ```heex
  # Custom spacing
  <.separator class="my-8" />

  # Full-height vertical separator
  <.separator vertical class="mx-4 h-full" />

  # Text separator with custom spacing
  <.separator text="Section" class="my-6" />
  ```

  ## Common Use Cases

  ### Form Sections

  Use separators to organize form sections clearly:

  ```heex
  <div class="space-y-4">
    <div>Profile Information</div>
    <.separator />
    <div>Account Settings</div>
    <.separator />
    <div>Privacy Options</div>
  </div>
  ```
  ![Form Sections](images/separator/form-sections.png)

  ### Content Groups

  Create clear content divisions with labeled separators:

  ```heex
  <div class="space-y-4">
    <.separator text="Recent" />
    <div>Recent items...</div>

    <.separator text="Previous" />
    <div>Previous items...</div>
  </div>
  ```
  ![Content Groups](images/separator/content-groups.png)

  ### Inline Elements

  Use vertical separators to divide inline elements:

  ```heex
  <div class="flex items-center gap-4">
    <span>Profile</span>
    <.separator vertical />
    <span>Settings</span>
    <.separator vertical />
    <span>Logout</span>
  </div>
  ```
  ![Inline Separation](images/separator/inline-separation.png)
  """

  use Fluxon.Component

  @doc """
  Renders a separator with support for horizontal, vertical, and text variants.

  This component provides a flexible way to create visual divisions between content sections.
  It supports both horizontal and vertical orientations, with optional text labels, while
  maintaining consistent styling and accessibility.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :text, :string,
    default: nil,
    doc: """
    Optional text to display in the center of the separator. When provided,
    creates a separator with centered text and lines on either side.
    """

  attr :vertical, :boolean,
    default: false,
    doc: """
    When true, renders a vertical separator instead of the default horizontal
    orientation. Cannot be used together with the text attribute.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the separator. The component maintains
    its core visual styling while allowing customization of spacing and dimensions.
    """

  def separator(%{vertical: true} = assigns) do
    ~H"""
    <div role="separator" aria-orientation="vertical" class={merge(["border-l border-base self-stretch", @class])} />
    """
  end

  def separator(%{text: text} = assigns) when not is_nil(text) do
    ~H"""
    <div class={merge(["flex items-center gap-4", @class])} role="separator" aria-orientation="horizontal">
      <div class="flex-1 border-t border-base"></div>
      <span class="text-xs text-foreground-softer">{@text}</span>
      <div class="flex-1 border-t border-base"></div>
    </div>
    """
  end

  def separator(assigns) do
    ~H"""
    <div role="separator" aria-orientation="horizontal" class={merge(["border-t border-base", @class])} />
    """
  end
end
