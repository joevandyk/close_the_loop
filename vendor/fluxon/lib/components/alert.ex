defmodule Fluxon.Components.Alert do
  @moduledoc """
  A versatile alert component for displaying status messages, notifications, and interactive feedback.
  Built with accessibility and flexibility in mind, it provides a comprehensive solution for
  communicating important information through visually distinct and accessible alerts.

  > #### Flash Messages {: .neutral}
  >
  > The alert component is not intended to replace Phoenix's flash messages. For a similar aesthetic
  > in flash messages, it's recommended to apply the alert component's styles to the original
  > `<.flash />` component.

  ## Usage

  The component can be used with simple text content for straightforward messages:

  ```heex
  <.alert>Simple alert message</.alert>
  ```

  ## Visual Colors

  The component supports different visual styles through the `color` attribute, each designed
  for specific types of messages:

  ```heex
  <.alert color="info" title="Update Available">
    A new version of the application is ready to install.
  </.alert>

  <.alert color="success" title="Order Confirmed">
    Your order has been successfully processed.
  </.alert>

  <.alert color="warning" title="Session Expiring">
    Your session will expire in 5 minutes.
  </.alert>

  <.alert color="danger" title="Connection Lost">
    Unable to connect to the server.
  </.alert>
  ```

  Each color comes with its own color scheme and icon, optimized for both light and dark modes:
  - `primary`: Primary styling for general messages
  - `info`: Blue accents for informational messages
  - `success`: Green accents for success messages
  - `warning`: Amber accents for warning messages
  - `danger`: Red accents for error messages

  ## Content Structure

  Alerts can display content in multiple ways to match your messaging needs:

  #### Simple Text

  For basic messages without additional context:

  ```heex
  <.alert>Your changes have been saved.</.alert>
  ```

  #### With Title

  For messages that need a clear heading:

  ```heex
  <.alert title="Profile Updated">
    Your profile changes have been saved successfully.
  </.alert>
  ```

  #### With Title and Subtitle

  For complex messages that need additional context:

  ```heex
  <.alert
    title="Scheduled Maintenance"
    subtitle="System Update"
    color="info">
    The system will be unavailable on Saturday from 2 AM to 4 AM.
  </.alert>
  ```

  ## Interactive Features

  ### Dismissible Alerts

  By default, alerts include a close button. This behavior can be customized:

  ```heex
  <!-- Non-dismissible alert -->
  <.alert hide_close>
    This alert cannot be dismissed
  </.alert>

  <!-- Custom close behavior -->
  <.alert on_close={JS.push("handle_alert_close", value: %{id: @alert_id})}>
    This alert triggers a custom event when closed
  </.alert>
  ```

  ### Custom Actions

  Alerts can include interactive elements for user actions:

  ```heex
  <.alert
    color="warning"
    title="Unsaved Changes"
    on_close={JS.push("dismiss_warning")}>
    You have unsaved changes that will be lost.

    <div class="mt-4 flex space-x-2">
      <.button size="xs">Save Changes</.button>
      <.button size="xs" color="ghost">Discard</.button>
    </div>
  </.alert>
  ```

  ## Icon Customization

  The component provides flexibility in how icons are displayed:

  ```heex
  <!-- No icon -->
  <.alert hide_icon>
    Message without icon
  </.alert>

  <!-- Custom icon -->
  <.alert>
    <:icon>
      <.icon name="hero-bell" class="size-5" />
    </:icon>
    Custom notification icon
  </.alert>
  ```
  """

  use Fluxon.Component
  alias Phoenix.LiveView.JS

  @styles %{
    "default" => %{
      "box" => "bg-base border border-base shadow-base",
      "icon" => "text-foreground-softer",
      "title" => "text-foreground",
      "subtitle" => "text-foreground-soft",
      "content" => "text-foreground-soft"
    },
    "primary" => %{
      "box" => "bg-primary-soft border border-base shadow-base",
      "icon" => "text-foreground-softer",
      "title" => "text-foreground",
      "subtitle" => "text-foreground-soft",
      "content" => "text-foreground-soft"
    },
    "danger" => %{
      "box" => "bg-danger-soft border border-danger shadow-base",
      "icon" => "text-danger",
      "title" => "text-foreground-danger-soft",
      "subtitle" => "text-foreground-danger-soft/90",
      "content" => "text-foreground-danger-soft/80"
    },
    "success" => %{
      "box" => "bg-success-soft border border-success shadow-base",
      "icon" => "text-success",
      "title" => "text-foreground-success-soft",
      "subtitle" => "text-foreground-success-soft/90",
      "content" => "text-foreground-success-soft/80"
    },
    "info" => %{
      "box" => "bg-info-soft border border-info shadow-base",
      "icon" => "text-info",
      "title" => "text-foreground-info-soft",
      "subtitle" => "text-foreground-info-soft/90",
      "content" => "text-foreground-info-soft/80"
    },
    "warning" => %{
      "box" => "bg-warning-soft border border-warning shadow-base",
      "icon" => "text-warning",
      "title" => "text-foreground-warning-soft",
      "subtitle" => "text-foreground-warning-soft/90",
      "content" => "text-foreground-warning-soft/80"
    }
  }

  @doc """
  Renders an alert component with support for various visual styles and interactive elements.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :string,
    doc: """
    The unique identifier for the alert element. If not provided, a random ID will be generated.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the alert element. These are merged with the component's
    base classes and color-specific styles.
    """

  attr :title, :string,
    default: nil,
    doc: """
    The main heading text of the alert. When provided, creates a title section styled according
    to the chosen color's color scheme.
    """

  attr :subtitle, :string,
    default: nil,
    doc: """
    Secondary text displayed alongside the title. Only rendered when either title or subtitle
    is present.
    """

  attr :color, :string,
    default: "default",
    values: ~w(default primary danger success info warning),
    doc: """
    The visual style color of the alert. Affects the entire component's appearance:
    - `default`: White background with default accents
    - `primary`: Light gray background with primary accents
    - `danger`: Light red background with danger accents
    - `success`: Light green background with success accents
    - `info`: Light blue background with info accents
    - `warning`: Light amber background with warning accents
    """

  attr :hide_icon, :boolean,
    default: false,
    doc: """
    When true, hides the alert's status icon.
    """

  attr :hide_close, :boolean,
    default: false,
    doc: """
    When true, hides the alert's close button.
    """

  attr :on_close, JS,
    default: %JS{},
    doc: """
    LiveView JS commands to execute when the alert is closed.
    """

  slot :inner_block,
    doc: """
    The main content to be displayed in the alert body. Renders with color-specific text colors.
    """

  slot :icon,
    doc: """
    Optional custom icon to replace the default status icon. If not provided and `hide_icon`
    is false, a default icon based on the variant will be shown.
    """

  def alert(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> gen_id() end)
      |> assign_new(:style, fn -> @styles[assigns.color] end)

    ~H"""
    <div
      id={@id}
      role="alert"
      class={merge(["grid grid-cols-[auto_1fr_auto] px-4 py-3 items-center gap-2 rounded-base", @style["box"], @class])}
    >
      <div :if={!@hide_icon} class={["flex items-center", [@style["icon"]]]}>
        <div :if={icon = render_slot(@icon)} class="contents">{icon}</div>

        <svg :if={@icon == []} xmlns="http://www.w3.org/2000/svg" fill="none" class="size-5" viewBox="0 0 24 24">
          <path
            :if={@color == "danger"}
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="m15 9-6 6m0-6 6 6m7-3c0 5.523-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2s10 4.477 10 10"
          />

          <path
            :if={@color == "info" || @color == "warning" || @color == "primary" || @color == "default"}
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 16v-4m0-4h.01M22 12c0 5.523-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2s10 4.477 10 10"
          />

          <path
            :if={@color == "success"}
            stroke="currentColor"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="m7.5 12 3 3 6-6m5.5 3c0 5.523-4.477 10-10 10S2 17.523 2 12 6.477 2 12 2s10 4.477 10 10"
          />
        </svg>
      </div>

      <div :if={@title || @subtitle} class="flex items-center gap-x-2">
        <p :if={@title} class={["text-sm/[1.5rem] font-medium", @style["title"]]}>{@title}</p>
        <p :if={@subtitle} class={["text-sm/[1.5rem]", @style["subtitle"]]}>{@subtitle}</p>
      </div>

      <div :if={!@hide_close} class={["flex items-center col-start-3 shrink-0", @style["icon"]]}>
        <button
          type="button"
          class="p-0.5 rounded-full cursor-pointer"
          aria-label="close"
          phx-click={@on_close |> hide_alert("##{@id}")}
        >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" class="size-4" viewBox="0 0 24 24">
            <path
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M18 6 6 18M6 6l12 12"
            />
          </svg>
        </button>
      </div>

      <div
        :if={content = render_slot(@inner_block)}
        class={[
          "text-sm/[1.5rem]",
          if(@hide_icon, do: "col-start-1", else: "col-start-2"),
          !@title && "row-start-1",
          @style["content"]
        ]}
      >
        {content}
      </div>
    </div>
    """
  end

  defp hide_alert(js, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition: {"transition-all transform ease-in duration-200", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
  end
end
