defmodule Fluxon.Components.Popover do
  @moduledoc """
  A powerful and accessible popover component that displays floating content anchored to a trigger element.

  This component provides a flexible solution for building tooltips, contextual menus, and interactive
  content that needs to be anchored to specific elements on the page. It offers a fully accessible
  implementation with keyboard navigation, automatic positioning, and proper focus management.

  ## Usage

  Create a simple informational tooltip:

  ```heex
  <.popover open_on_hover>
    <.icon name="hero-information-circle" class="text-zinc-400" />

    <:content>
      <p class="text-sm">The invoice will be generated at the end of the month.</p>
    </:content>
  </.popover>
  ```
  ![Basic Tooltip](images/popover/basic-tooltip.png)

  ## Interactive Content

  Build rich interactive menus with forms and actions:

  ```heex
  <.popover placement="bottom-end" class="w-64">
    <.button variant="ghost">
      <.icon name="hero-cog-6-tooth" /> Settings
    </.button>

    <:content>
      <div class="space-y-4">
        <div class="flex items-center justify-between">
          <span class="text-sm font-medium">Dark Mode</span>
          <.switch name="dark_mode" checked />
        </div>

        <div class="flex items-center justify-between">
          <span class="text-sm font-medium">Notifications</span>
          <.switch name="notifications" />
        </div>

        <.button size="sm" class="w-full">
          <.icon name="hero-arrow-path" class="icon" /> Reset Preferences
        </.button>
      </div>
    </:content>
  </.popover>
  ```
  ![Interactive Menu](images/popover/interactive-menu.png)

  ## Search Suggestions

  Create dynamic search suggestions with focus interaction:

  ```heex
  <.popover open_on_focus placement="bottom-start" class="w-80">
    <.input type="search" placeholder="Search users..." phx-debounce="300" />

    <:content>
      <div :if={@loading} class="p-4 flex justify-center">
        <.loading />
      </div>

      <div :for={user <- @users} class="p-2 hover:bg-zinc-50 cursor-pointer">
        <div class="font-medium">{user.name}</div>
        <div class="text-sm text-zinc-600">{user.email}</div>
      </div>
    </:content>
  </.popover>
  ```
  ![Search Suggestions](images/popover/search-suggestions.png)

  ## Form Field Help

  Provide contextual help for form fields:

  ```heex
  <.input name="api-key" label="API Key" value="sk_test_..." class="font-mono">
    <:inner_suffix>
      <.popover open_on_hover placement="right">
        <.icon name="hero-question-mark-circle" class="text-zinc-400" />

        <:content>
          <div class="max-w-xs space-y-2">
            <p class="text-sm font-medium">About API Keys</p>
            <p class="text-sm text-zinc-600">
              Your API key is used to authenticate requests. Keep it secure and
              never share it publicly.
            </p>
            <.link class="text-sm text-blue-600 hover:underline" href="/docs/api-keys">
              Learn more about API keys →
            </.link>
          </div>
        </:content>
      </.popover>
    </:inner_suffix>
  </.input>
  ```
  ![Form Help](images/popover/input-help.png)

  ## Filters

  Create filter panels:

  ```heex
  <.popover placement="bottom-end" class="w-64">
    <.button variant="ghost">
      <.icon name="hero-adjustments-horizontal" class="icon" /> Table settings
    </.button>
    <:content>
      <h3 class="font-medium">Table settings</h3>
      <div class="flex items-center gap-2 text-sm mt-3">
        <.icon name="hero-arrows-up-down" class="text-zinc-700 size-4" /> Sort by
        <div class="ml-auto flex items-center gap-2">
          <.select
            native
            value="Name"
            options={["Name", "Date", "Size", "Type", "Modified"]}
            name="sort_by"
            size="sm"
            class="py-1 shadow-none"
          />
        </div>
      </div>
      <div class="flex items-center gap-2 text-sm mt-2">
        <.icon name="hero-view-columns" class="text-zinc-700 size-4" /> View
        <div class="ml-auto flex items-center gap-2">
          <.select
            native
            value="List"
            options={["List", "Board", "Calendar", "Timeline"]}
            name="view"
            size="sm"
            class="py-1 shadow-none"
          />
        </div>
      </div>

      <.separator class="my-4" />

      <h3 class="font-medium">Columns</h3>

      <div class="flex items-center justify-between mt-3">
        <.label for="name" class="text-zinc-700">Name</.label>
        <.switch name="name" checked id="name" />
      </div>

      <div class="flex items-center justify-between mt-3">
        <.label for="date" class="text-zinc-700">Date</.label>
        <.switch name="date" checked id="date" />
      </div>

      <div class="flex items-center justify-between mt-3">
        <.label for="size" class="text-zinc-700">Size</.label>
        <.switch name="size" checked id="size" />
      </div>

      <div class="flex items-center justify-between mt-3">
        <.label for="type" class="text-zinc-700">Type</.label>
        <.switch name="type" id="type" />
      </div>

      <div class="flex items-center justify-between mt-3">
        <.label for="modified" class="text-zinc-700">Modified</.label>
        <.switch name="modified" id="modified" />
      </div>
    </:content>
  </.popover>
  ```
  ![Filters](images/popover/filters.png)

  ## Programmatic Control

  The popover component supports programmatic opening and closing through JavaScript functions,
  allowing you to control popover visibility from button clicks, form submissions, or other user interactions.

  ### Basic Programmatic Control

  Use the `Fluxon.open_popover/1` and `Fluxon.close_popover/1` functions to control popover visibility:

  ```heex
  <.button phx-click={Fluxon.open_popover("settings-popover")}>
    Open Settings
  </.button>

  <.button phx-click={Fluxon.close_popover("settings-popover")}>
    Close Settings
  </.button>

  <.popover id="settings-popover" placement="bottom-end">
    <.button variant="ghost">
      <.icon name="hero-cog-6-tooth" /> Settings
    </.button>

    <:content>
      <div class="p-2 space-y-2">
        <.button size="sm" class="w-full justify-start">
          <.icon name="hero-user" class="icon" /> Profile
        </.button>
        <.button size="sm" class="w-full justify-start">
          <.icon name="hero-key" class="icon" /> Security
        </.button>
      </div>
    </:content>
  </.popover>
  ```

  ### Compatibility with Hover and Focus

  Programmatic control works alongside the existing `open_on_hover` and `open_on_focus` behaviors.
  When you call `Fluxon.open_popover/1` or `Fluxon.close_popover/1`, it will override the current
  state regardless of how the popover was originally opened:

  ```heex
  <!-- This popover opens on hover but can also be controlled programmatically -->
  <.popover id="tooltip-popover" open_on_hover>
    <.icon name="hero-information-circle" class="text-zinc-400" />

    <:content>
      <p class="text-sm">Helpful information tooltip</p>
      <.button phx-click={Fluxon.close_popover("tooltip-popover")} size="xs">
        Close
      </.button>
    </:content>
  </.popover>
  ```

  ## External Target Positioning

  When building complex workflows or when you need to position a popover relative to an element
  that's not the trigger, use the `target` attribute to specify an external positioning reference.

  ### Multi-Step Workflows

  Create step-by-step workflows where all popovers anchor to the same trigger element:

  ```heex
  <.button id="workflow-trigger" phx-click={Fluxon.open_popover("step-1")}>
    Start Workflow
  </.button>

  <!-- Step 1: anchored to the button above -->
  <.popover id="step-1" target="#workflow-trigger" placement="bottom">
    <:content>
      <div class="space-y-3 p-2">
        <p class="text-sm font-medium">Step 1: Choose Option</p>
        <div class="space-y-2">
          <.button
            size="sm"
            class="w-full justify-start"
            phx-click={Fluxon.close_popover("step-1") |> Fluxon.open_popover("step-2")}
          >
            Option A
          </.button>
          <.button
            size="sm"
            class="w-full justify-start"
            phx-click={Fluxon.close_popover("step-1") |> Fluxon.open_popover("step-2")}
          >
            Option B
          </.button>
        </div>
      </div>
    </:content>
  </.popover>

  <!-- Step 2: also anchored to the same button -->
  <.popover id="step-2" target="#workflow-trigger" placement="bottom">
    <:content>
      <div class="space-y-3 p-2">
        <p class="text-sm font-medium">Step 2: Confirm</p>
        <p class="text-sm text-gray-600">Ready to proceed?</p>
        <div class="flex gap-2">
          <.button size="sm" phx-click={Fluxon.close_popover("step-2")}>
            Finish
          </.button>
          <.button
            size="sm"
            variant="ghost"
            phx-click={Fluxon.close_popover("step-2") |> Fluxon.open_popover("step-1")}
          >
            Back
          </.button>
        </div>
      </div>
    </:content>
  </.popover>
  ```

  ### Remote Popover Positioning

  Position popovers relative to any element on the page, even when the trigger is elsewhere:

  ```heex
  <!-- The trigger can be anywhere -->
  <.button phx-click={Fluxon.open_popover("remote-menu")}>
    Show Menu
  </.button>

  <!-- This element is used for positioning -->
  <div id="menu-anchor" class="some-layout-element">
    Content here...
  </div>

  <!-- Popover positions relative to the anchor, not the button -->
  <.popover id="remote-menu" target="#menu-anchor" placement="right-start">
    <:content>
      <div class="p-2">Menu positioned relative to anchor element</div>
    </:content>
  </.popover>
  ```

  > #### Target Behavior {: .info}
  >
  > When using the `target` attribute:
  > - The popover positions relative to the target element, not any inner content
  > - `open_on_hover` and `open_on_focus` are automatically disabled
  > - The popover becomes programmatic-only and must be controlled via `Fluxon.open_popover/1` and `Fluxon.close_popover/1`
  > - You can omit the inner_block entirely since it's not needed for positioning
  """

  use Fluxon.Component

  @styles %{
    wrapper: [
      "contents"
    ],
    content: [
      "fixed z-50 p-4 bg-overlay rounded-base shadow-base border border-base"
    ],
    animation: [
      "transition ease-in-out"
    ]
  }

  ## Components

  @doc """
  Renders a popover component with rich interaction support and automatic positioning.

  This component provides a flexible way to create tooltips, contextual menus, and other
  floating content that needs to be anchored to specific elements. It supports multiple
  interaction modes and intelligent positioning while maintaining accessibility.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :string,
    doc: """
    Optional unique identifier for the popover. If not provided, a random ID will be generated.
    Useful when you need to programmatically control the popover.
    """

  attr :target, :string,
    default: nil,
    doc: """
    CSS selector of an external element to use as the positioning reference for the popover.
    When specified, the popover will position itself relative to this target element instead
    of the inner_block. This enables programmatic-only popovers that can be anchored to any
    element on the page. When using target, the popover becomes programmatic-only and
    Fluxon.open_popover/1 and Fluxon.close_popover/1 are required to open and close the popover.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to be applied to the popover content container.
    Useful for controlling width, padding, and other visual styles.
    """

  attr :open_on_hover, :boolean,
    default: false,
    doc: """
    When true, the popover will open when hovering over the trigger element.
    Perfect for tooltip-like behavior and quick information display.
    """

  attr :open_on_focus, :boolean,
    default: false,
    doc: """
    When true, the popover will open when the trigger element receives focus.
    Ideal for form helpers, search suggestions, and accessibility improvements.
    """

  attr :placement, :string,
    default: "top",
    values: [
      "top",
      "top-start",
      "top-end",
      "right",
      "right-start",
      "right-end",
      "left",
      "left-start",
      "left-end",
      "bottom",
      "bottom-start",
      "bottom-end"
    ],
    doc: """
    Controls the preferred placement of the popover relative to its trigger element.
    The actual placement may adjust automatically if there isn't enough space.

    Available options:
    - `top`, `top-start`, `top-end`: Above the trigger
    - `bottom`, `bottom-start`, `bottom-end`: Below the trigger
    - `left`, `left-start`, `left-end`: To the left of the trigger
    - `right`, `right-start`, `right-end`: To the right of the trigger

    The `-start` and `-end` variants control alignment along the cross axis.
    """

  slot :inner_block,
    doc: """
    The trigger element that will open the popover. This can be any HTML element
    or component, such as a button, input, or custom element. Optional when using
    the target attribute to specify an external positioning reference.
    """

  slot :content,
    required: true,
    doc: """
    The content to display in the popover. Can contain any HTML or components,
    from simple text to complex interactive elements like forms or menus.
    """

  def popover(assigns) do
    # Validate that either target or inner_block is provided
    if is_nil(assigns[:target]) && (!assigns[:inner_block] || assigns.inner_block == []) do
      raise ArgumentError, "Popover requires either a target attribute or inner_block content"
    end

    assigns =
      assigns
      |> assign(:styles, @styles)
      |> assign_new(:id, fn -> gen_id() end)

    ~H"""
    <div
      id={@id}
      phx-hook="Fluxon.Popover"
      data-placement={@placement}
      data-target={@target}
      data-open-on-hover={(@target && false) || @open_on_hover}
      data-open-on-focus={(@target && false) || @open_on_focus}
      class={merge([@styles[:wrapper]])}
    >
      {render_slot(@inner_block, %{rest: [{"data-part", "toggle"}]})}

      <div
        data-part="popover"
        role="dialog"
        hidden
        class={merge([@styles[:content], @class])}
        data-animation={Enum.join(@styles[:animation], " ")}
        data-animation-enter="opacity-100 scale-100"
        data-animation-leave="opacity-0 scale-95"
      >
        {render_slot(@content)}
      </div>
    </div>
    """
  end
end
