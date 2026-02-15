defmodule Fluxon.Components.Loading do
  @moduledoc """
  A versatile loading indicator component for displaying loading states and animations.

  This component provides a comprehensive solution for indicating loading states across your application.
  It offers multiple animation styles and customization options while maintaining consistent performance
  and accessibility. The animations are implemented using SVG and CSS, ensuring smooth performance
  even during heavy page loads.

  ## Usage

  The loading component can be used in its simplest form to indicate loading states:

  ```heex
  <.loading />
  <.loading variant="ring-bg" />
  <.loading variant="dots-bounce" />
  <.loading variant="dots-fade" />
  <.loading variant="dots-scale" />
  ```

  ## Animation Variants

  The component offers five distinct animation styles, each designed for specific use cases:

  ```heex
  <!-- Simple rotating ring -->
  <.loading variant="ring" />

  <!-- Ring with background for better visibility -->
  <.loading variant="ring-bg" />

  <!-- Playful bouncing dots -->
  <.loading variant="dots-bounce" />

  <!-- Subtle fading dots -->
  <.loading variant="dots-fade" />

  <!-- Scaling dots for emphasis -->
  <.loading variant="dots-scale" />
  ```

  Each variant is optimized for different contexts:
  - `ring`: Clean, minimal loading indicator for general use
  - `ring-bg`: Enhanced visibility with a static background ring
  - `dots-bounce`: Playful animation for lighter, more casual interfaces
  - `dots-fade`: Subtle, professional animation for serious applications
  - `dots-scale`: Eye-catching animation for important loading states

  ## Customization

  The component supports customization through CSS classes:

  ### Size Variations

  Adjust the size using Tailwind's size utilities:

  ```heex
  <.loading class="size-4" />
  <.loading class="size-6" />
  <.loading class="size-8" />
  <.loading class="size-10" />
  ```

  ### Color Variations

  Change the color using Tailwind's text color utilities:

  ```heex
  <.loading class="text-blue-500" />
  <.loading class="text-green-500" />
  <.loading class="text-red-500" />
  <.loading class="text-amber-500" />
  ```

  ## Common Use Cases

  ### Button Loading States

  Loading indicators can be used within buttons to show processing states:

  ```heex
  <.button disabled>
    <.loading class="size-4" /> Loading...
  </.button>

  <.button variant="solid" color="blue" disabled>
    <.loading class="size-4 text-white" /> Processing
  </.button>
  ```

  ### Page Loading

  For full-page loading states, center the indicator with appropriate sizing:

  ```heex
  <div class="flex items-center justify-center min-h-[400px]">
    <.loading class="size-8" />
  </div>
  ```

  ### Section Loading

  For loading specific sections or components:

  ```heex
  <div class="relative">
    <div class="absolute inset-0 flex items-center justify-center bg-white/80">
      <.loading class="size-6" />
    </div>
    <!-- Content here -->
  </div>
  ```
  """

  use Fluxon.Component

  @doc """
  Renders an animated loading indicator with customizable styles and behaviors.

  This component provides a flexible way to indicate loading states with various animation
  styles. It supports customization of size, color, animation duration, and visual style
  while maintaining consistent performance.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the SVG element. Useful for customizing
    size and color. Default size is `size-5` and color is `text-zinc-600`.
    """

  attr :duration, :integer,
    default: 600,
    doc: """
    The duration of one complete animation cycle in milliseconds.
    Affects all animation variants consistently.
    """

  attr :variant, :string,
    default: "ring",
    values: ~w(ring ring-bg dots-bounce dots-fade dots-scale),
    doc: """
    The animation style to display:
    - `ring`: Simple rotating ring
    - `ring-bg`: Rotating ring with background
    - `dots-bounce`: Bouncing dots sequence
    - `dots-fade`: Fading dots sequence
    - `dots-scale`: Scaling dots sequence
    """

  attr :id, :any,
    default: nil,
    doc: """
    The unique identifier for the loading component. When not provided, a random ID will be generated.
    """

  def loading(%{variant: "ring"} = assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || gen_id())
      |> assign(duration: assigns.duration / 1000)

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class={merge(["size-5 text-zinc-600", @class])}>
      <path
        fill="currentColor"
        stroke="currentColor"
        d="M12 4a8 8 0 0 1 7.89 6.7 1.53 1.53 0 0 0 1.49 1.3 1.5 1.5 0 0 0 1.48-1.75 11 11 0 0 0-21.72 0A1.5 1.5 0 0 0 2.62 12a1.53 1.53 0 0 0 1.49-1.3A8 8 0 0 1 12 4Z"
      >
        <animateTransform
          attributeName="transform"
          dur={@duration}
          repeatCount="indefinite"
          type="rotate"
          values="0 12 12;360 12 12"
        />
      </path>
    </svg>
    """
  end

  def loading(%{variant: "ring-bg"} = assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || gen_id())
      |> assign(duration: assigns.duration / 1000)

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class={merge(["size-5 text-zinc-600", @class])}>
      <path
        fill="currentColor"
        d="M12 1a11 11 0 1 0 11 11A11 11 0 0 0 12 1Zm0 19a8 8 0 1 1 8-8 8 8 0 0 1-8 8Z"
        opacity=".25"
      />
      <path
        fill="currentColor"
        d="M12 4a8 8 0 0 1 7.89 6.7 1.53 1.53 0 0 0 1.49 1.3 1.5 1.5 0 0 0 1.48-1.75 11 11 0 0 0-21.72 0A1.5 1.5 0 0 0 2.62 12a1.53 1.53 0 0 0 1.49-1.3A8 8 0 0 1 12 4Z"
      >
        <animateTransform
          attributeName="transform"
          dur={@duration}
          repeatCount="indefinite"
          type="rotate"
          values="0 12 12;360 12 12"
        />
      </path>
    </svg>
    """
  end

  def loading(%{variant: "dots-bounce"} = assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || gen_id())
      |> assign(duration: assigns.duration / 1000)

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class={merge(["size-5 text-zinc-600", @class])}>
      <circle cx="4" cy="12" r="3" fill="currentColor">
        <animate
          id={"#{@id}_b"}
          attributeName="cy"
          begin={"0;#{@id}_a.end+0.25s"}
          calcMode="spline"
          dur={@duration}
          keySplines=".33,.66,.66,1;.33,0,.66,.33"
          values="12;6;12"
        />
      </circle>
      <circle cx="12" cy="12" r="3" fill="currentColor">
        <animate
          attributeName="cy"
          begin={"#{@id}_b.begin+0.1s"}
          calcMode="spline"
          dur={@duration}
          keySplines=".33,.66,.66,1;.33,0,.66,.33"
          values="12;6;12"
        />
      </circle>
      <circle cx="20" cy="12" r="3" fill="currentColor">
        <animate
          id={"#{@id}_a"}
          attributeName="cy"
          begin={"#{@id}_b.begin+0.2s"}
          calcMode="spline"
          dur={@duration}
          keySplines=".33,.66,.66,1;.33,0,.66,.33"
          values="12;6;12"
        />
      </circle>
    </svg>
    """
  end

  def loading(%{variant: "dots-fade"} = assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || gen_id())
      |> assign(duration: assigns.duration / 1000)

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class={merge(["size-5 text-foreground-soft", @class])}>
      <circle cx="4" cy="12" r="3" fill="currentColor">
        <animate
          id={"#{@id}_b"}
          fill="freeze"
          attributeName="opacity"
          begin={"0;#{@id}_a.end-0.25s"}
          dur={@duration}
          values="1;.2"
        />
      </circle>
      <circle cx="12" cy="12" r="3" fill="currentColor" opacity=".4">
        <animate fill="freeze" attributeName="opacity" begin={"#{@id}_b.begin+0.15s"} dur={@duration} values="1;.2" />
      </circle>
      <circle cx="20" cy="12" r="3" fill="currentColor" opacity=".3">
        <animate
          id={"#{@id}_a"}
          fill="freeze"
          attributeName="opacity"
          begin={"#{@id}_b.begin+0.3s"}
          dur={@duration}
          values="1;.2"
        />
      </circle>
    </svg>
    """
  end

  def loading(%{variant: "dots-scale"} = assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || gen_id())
      |> assign(duration: assigns.duration / 1000)

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class={merge(["size-5 text-foreground-soft", @class])}>
      <circle cx="4" cy="12" r="3" fill="currentColor">
        <animate id={"#{@id}_b"} attributeName="r" begin={"0;#{@id}_a.end-0.25s"} dur={@duration} values="3;.2;3" />
      </circle>
      <circle cx="12" cy="12" r="3" fill="currentColor">
        <animate attributeName="r" begin={"#{@id}_b.end-0.6s"} dur={@duration} values="3;.2;3" />
      </circle>
      <circle cx="20" cy="12" r="3" fill="currentColor">
        <animate id={"#{@id}_a"} attributeName="r" begin={"#{@id}_b.end-0.45s"} dur={@duration} values="3;.2;3" />
      </circle>
    </svg>
    """
  end
end
