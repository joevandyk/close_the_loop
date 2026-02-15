defmodule Fluxon.Components.Switch do
  @moduledoc """
  A toggle switch component for binary choices and settings.

  The switch component provides an accessible and customizable toggle control that serves as an alternative
  to checkboxes, particularly suited for immediate actions and settings toggles. While checkboxes are better
  suited for form submissions and multiple selections, switches are designed for toggling states with immediate effect,
  making them suitable for settings panels, feature toggles, and preference controls.

  ## Basic Usage

  The switch component can be used standalone or within forms:

  ```heex
  <.switch
    name="notifications"
    label="Enable Notifications"
    checked={@settings.notifications}
    phx-click="toggle_setting"
    phx-value-setting="notifications"
  />
  ```

  By default, the switch sends `"true"` when on and `"false"` when off. You can customize these values:

  ```heex
  <.switch
    name="status"
    label="Active"
    checked_value="1"
    unchecked_value="0"
    value={@user.status}
  />
  ```

  The component supports both controlled and uncontrolled usage patterns, adapting to your application's state management needs.

  ## Size Variants

  The switch component offers three size variants to accommodate different interface needs:

  ```heex
  <!-- Small switch for compact interfaces -->
  <.switch
    name="small_switch"
    label="Small Switch"
    size="sm"
    checked={@settings.compact_mode}
  />

  <!-- Default size for most use cases -->
  <.switch
    name="default_switch"
    label="Default Switch"
    size="md"
    checked={@settings.default_setting}
  />

  <!-- Large switch for touch interfaces or emphasis -->
  <.switch
    name="large_switch"
    label="Large Switch"
    size="lg"
    checked={@settings.important_setting}
  />
  ```

  Each size variant adjusts the track and thumb dimensions proportionally:

  - `"sm"`: Small (h-4 w-6), suitable for dense layouts and compact UIs
  - `"md"`: Default (h-5 w-8), recommended for most use cases
  - `"lg"`: Large (h-6 w-10), suitable for touch interfaces and prominent settings

  ## Labels and Context

  Provide detailed context and guidance with various labeling options:

  ```heex
  <!-- Basic label -->
  <.switch
    name="simple"
    label="Enable Feature"
    checked={@feature_enabled}
  />

  <!-- Label with sublabel for additional context -->
  <.switch
    name="with_sublabel"
    label="Auto Save"
    sublabel="Recommended"
    checked={@settings.auto_save}
  />

  <!-- Label with detailed description -->
  <.switch
    name="with_description"
    label="Public Profile"
    description="Make your profile visible to other users on the platform"
    checked={@settings.public_profile}
  />

  <!-- Complete example with all text features -->
  <.switch
    name="comprehensive"
    label="Advanced Analytics"
    sublabel="Beta"
    description="Share detailed usage patterns to help improve the product experience"
    checked={@settings.analytics_enabled}
  />
  ```

  ## Color Variants

  Use semantic colors to convey meaning and context:

  ```heex
  <!-- Primary color (default) -->
  <.switch
    name="primary"
    label="Default Setting"
    color="primary"
    checked={@settings.default}
  />

  <!-- Success color for positive actions -->
  <.switch
    name="success"
    label="Enable Backup"
    color="success"
    checked={@settings.backup_enabled}
  />

  <!-- Warning color for caution -->
  <.switch
    name="warning"
    label="Beta Features"
    sublabel="Experimental"
    color="warning"
    checked={@settings.beta_features}
  />

  <!-- Danger color for sensitive settings -->
  <.switch
    name="danger"
    label="Public Profile"
    color="danger"
    checked={@settings.public_profile}
  />

  <!-- Info color for informational toggles -->
  <.switch
    name="info"
    label="Usage Analytics"
    color="info"
    checked={@settings.analytics}
  />
  ```

  ## Form Integration

  The switch component integrates with Phoenix forms in two ways: using the `field` attribute for form integration or using the `name` attribute for standalone inputs.

  ### Using with Phoenix Forms (Recommended)

  Use the `field` attribute to bind the switch to a form field:

  ```heex
  <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save">
    <.switch
      field={f[:notifications_enabled]}
      label="Push Notifications"
      sublabel="Real-time updates"
      description="Receive notifications about important account activity"
    />

    <.switch
      field={f[:email_marketing]}
      label="Email Marketing"
      sublabel="Optional"
      description="Receive promotional emails about new features"
    />
  </.form>
  ```

  Using the `field` attribute provides:
  - Automatic value handling from form data
  - Integration with changesets and validation
  - Proper form submission with correct field names
  - Error handling and display

  ### Complete Form Example

  ```elixir
  defmodule MyApp.UserSettings do
    use Ecto.Schema
    import Ecto.Changeset

    schema "user_settings" do
      field :notifications_enabled, :boolean, default: true
      field :email_marketing, :boolean, default: false
      field :dark_mode, :boolean, default: false
      belongs_to :user, MyApp.User
      timestamps()
    end

    def changeset(settings, attrs) do
      settings
      |> cast(attrs, [:notifications_enabled, :email_marketing, :dark_mode])
      |> validate_required([])
    end
  end

  # In your LiveView
  def mount(_params, _session, socket) do
    settings = MyApp.Accounts.get_user_settings(socket.assigns.current_user)
    changeset = UserSettings.changeset(settings, %{})

    {:ok, assign(socket, settings: settings, form: to_form(changeset))}
  end

  def render(assigns) do
    ~H\"\"\"
    <.form :let={f} for={@form} phx-change="validate" phx-submit="save">
      <div class="space-y-4">
        <.switch
          field={f[:notifications_enabled]}
          label="Push Notifications"
          description="Receive real-time notifications on your devices"
        />

        <.switch
          field={f[:email_marketing]}
          label="Marketing Emails"
          description="Get updates about new features and promotions"
        />

        <.switch
          field={f[:dark_mode]}
          label="Dark Mode"
          description="Switch to dark theme for better viewing in low light"
        />

        <.switch
          field={f[:status]}
          label="Active Status"
          description="Set your account status"
          checked_value="1"
          unchecked_value="0"
        />
      </div>

      <.button type="submit">Save Settings</.button>
    </.form>
    \"\"\"
  end

  def handle_event("validate", %{"user_settings" => params}, socket) do
    changeset =
      socket.assigns.settings
      |> UserSettings.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"user_settings" => params}, socket) do
    case MyApp.Accounts.update_user_settings(socket.assigns.settings, params) do
      {:ok, settings} ->
        {:noreply, assign(socket, settings: settings) |> put_flash(:info, "Settings updated!")}
      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
  ```

  ### Using Standalone Switches

  For simpler cases or when not using Phoenix forms, use the name attribute with event handlers:

  ```heex
  <.switch
    name="theme_toggle"
    label="Dark Mode"
    checked={@dark_mode}
    phx-click="toggle_theme"
  />
  ```

  ## Switch States

  The switch component supports various states for different use cases:

  ### Disabled State

  Disable switches to prevent user interaction:

  ```heex
  <!-- Disabled in off state -->
  <.switch
    name="disabled_off"
    label="Unavailable Feature"
    description="This feature is currently unavailable"
    disabled
    checked={false}
  />

  <!-- Disabled in on state -->
  <.switch
    name="disabled_on"
    label="Premium Feature"
    sublabel="Upgrade required"
    description="This feature requires a premium subscription"
    disabled
    checked={true}
  />
  ```

  Disabled switches are visually muted and cannot be toggled by the user, making them suitable for representing features that are unavailable due to permissions, subscription status, or system state.

  ## Settings Panels

  Switches work well in settings interfaces where users need to toggle multiple preferences:

  ```heex
  <!-- Notification Settings Panel -->
  <div class="space-y-4">
    <h3 class="font-semibold">Notification Preferences</h3>

    <.switch
      name="push_notifications"
      label="Push Notifications"
      sublabel="Mobile & Desktop"
      description="Receive push notifications on your devices when new activity occurs"
      checked={@settings.push_notifications}
      phx-click="toggle_setting"
      phx-value-setting="push_notifications"
    />

    <.switch
      name="email_notifications"
      label="Email Notifications"
      description="Receive email updates about important account activity"
      checked={@settings.email_notifications}
      phx-click="toggle_setting"
      phx-value-setting="email_notifications"
    />

    <.switch
      name="marketing_emails"
      label="Marketing Communications"
      sublabel="Optional"
      description="Receive promotional emails about new features and updates"
      color="info"
      checked={@settings.marketing_emails}
      phx-click="toggle_setting"
      phx-value-setting="marketing_emails"
    />
  </div>
  ```
  """

  use Fluxon.Component

  import Fluxon.Components.Form, only: [label: 1]

  @styles %{
    wrapper: [
      "flex items-start gap-3"
    ],
    label: [
      "flex items-center select-none",
      "text-foreground"
    ],
    label_disabled: [
      "cursor-not-allowed opacity-70"
    ],
    track: [
      "flex items-center rounded-full",
      "border border-transparent",
      "bg-switch",
      "transition-colors duration-300",
      "has-[input:focus-visible]:border-focus has-[input:focus-visible]:ring-3 has-[input:focus-visible]:ring-focus transition-[box-shadow] duration-100",
      "has-[input:disabled]:opacity-90 not-has-[input:disabled]:shadow-inner"
    ],
    thumb: [
      "rounded-full bg-surface transition-transform duration-200 shadow-sm"
    ],
    input: [
      "peer sr-only"
    ],
    size: %{
      "sm" => %{
        track: "h-4 w-6 p-[1px]",
        thumb: "size-3 peer-checked:translate-x-2"
      },
      "md" => %{
        track: "h-5 w-8 p-[2px]",
        thumb: "size-3.5 peer-checked:translate-x-3"
      },
      "lg" => %{
        track: "h-6 w-10 p-[3px]",
        thumb: "size-4 peer-checked:translate-x-4"
      }
    },
    color: %{
      "primary" => "has-[input:checked]:bg-primary",
      "danger" => "has-[input:checked]:bg-danger",
      "success" => "has-[input:checked]:bg-success",
      "warning" => "has-[input:checked]:bg-warning",
      "info" => "has-[input:checked]:bg-info"
    }
  }

  @doc """
  Renders a switch component for toggling between two states.

  This component provides an accessible toggle switch that can be used standalone or within forms.
  It supports various sizes, colors, and states, making it suitable for different UI contexts.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: """
    The unique identifier for the switch. When not provided, the `name` attribute will be used.
    """

  attr :name, :string,
    doc: """
    The form name for the switch. Required when not using the `field` attribute.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the switch wrapper. Useful for controlling
    layout and spacing.
    """

  attr :checked, :boolean,
    doc: """
    Whether the switch is in the on position. When using forms, this is automatically
    handled by the `field` attribute.
    """

  attr :disabled, :boolean,
    default: false,
    doc: """
    When true, disables the switch. Disabled switches cannot be interacted with
    and appear visually muted.
    """

  attr :value, :any,
    doc: """
    The value associated with the switch. When using forms, this is the current value
    from the form data. For standalone switches, this determines if the switch is checked.
    """

  attr :checked_value, :any,
    default: "true",
    doc: """
    The value to be sent when the switch is in the on position. Defaults to `"true"`.

    ## Examples

        # Sending "1" when on
        <.switch name="active" checked_value="1" unchecked_value="0" />

        # Sending "on" when on
        <.switch name="feature" checked_value="on" unchecked_value="off" />
    """

  attr :unchecked_value, :any,
    default: "false",
    doc: """
    The value to be sent when the switch is in the off position. Defaults to `"false"`.
    This value is submitted via a hidden input to ensure the field is always present in form data.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The primary label for the switch. This text is displayed next to the switch
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
    Detailed description of the switch option. This text appears below the label
    and can contain longer explanatory text.
    """

  attr :size, :string,
    default: "md",
    values: ~w(sm md lg),
    doc: """
    Controls the size of the switch:
    - `"sm"`: Small switch, suitable for compact UIs
    - `"md"`: Default size, works well in most contexts
    - `"lg"`: Large switch, good for touch interfaces or emphasis
    """

  attr :color, :string,
    default: "primary",
    values: ~w(primary danger success warning info),
    doc: """
    The color theme of the switch when in the on position. Supports semantic colors from the theme:
    - `"primary"`: Default theme color
    - `"danger"`: Red color for destructive actions
    - `"success"`: Green color for positive actions
    - `"warning"`: Yellow color for cautionary actions
    - `"info"`: Blue color for informational actions
    """

  attr :field, Phoenix.HTML.FormField,
    doc: """
    The form field to bind to. When provided, the component automatically handles
    value tracking and form submission.
    """

  attr :rest, :global,
    include: ~w(form),
    doc: """
    Additional attributes to pass to the form element.
    """

  def switch(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> switch()
  end

  def switch(assigns) do
    assigns =
      assigns
      |> assign(:styles, @styles)
      |> assign(:id, assigns.id || assigns.name)
      |> assign_new(:checked, fn ->
        Phoenix.HTML.html_escape(assigns[:value]) == Phoenix.HTML.html_escape(assigns[:checked_value])
      end)

    ~H"""
    <div class={merge([@styles[:wrapper]])}>
      <label for={@id} class={merge([@styles[:label], @disabled && @styles[:label_disabled]])}>
        <div class={
          merge([
            @styles[:track],
            @styles[:color][@color],
            @styles[:size][@size][:track],
            @class
          ])
        }>
          <input type="hidden" name={@name} value={@unchecked_value} disabled={@disabled} {@rest} />
          <input
            type="checkbox"
            value={@checked_value}
            id={@id}
            name={@name}
            checked={@checked}
            disabled={@disabled}
            class={merge([@styles[:input]])}
            {@rest}
          />
          <div class={merge([@styles[:thumb], @styles[:size][@size][:thumb]])}></div>
        </div>
      </label>

      <.label :if={@label} for={@id} sublabel={@sublabel} description={@description}>
        {@label}
      </.label>
    </div>
    """
  end
end
