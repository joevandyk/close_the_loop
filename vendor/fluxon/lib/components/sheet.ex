defmodule Fluxon.Components.Sheet do
  @moduledoc """
  A powerful and accessible sheet component that provides a sliding panel interface for displaying content.
  Built with LiveView integration in mind, this component offers rich features for both client and server-side control.

  > #### Sheet vs Modal {: .info}
  >
  > The sheet and modal components share the same core functionality and API. They are interchangeable in terms of features
  > and behavior, differing mainly in their visual presentation. While modals are centered overlays, sheets slide in from
  > the screen edges, making them better suited for side panels, drawers, and mobile-friendly interfaces. See `Fluxon.Components.Modal`
  > if you need a centered overlay.

  ## Opening and Closing

  While opening and closing a sheet is straightforward in most cases, the component provides various approaches to handle different scenarios, particularly when working with LiveView.

  ### Basic Client-Side Control

  The most common use case is opening a sheet via button click and closing it through standard actions (click outside, "X" button, ESC key):

  ```heex
  <.button phx-click={Fluxon.open_dialog("filters-sheet")}>Filters</.button>

  <.sheet id="filters-sheet">
    <h3 class="text-lg font-semibold mb-4">Filters</h3>

    <div class="space-y-4">
      <!-- Filter content -->
    </div>

    <.button phx-click={Fluxon.close_dialog("filters-sheet")}>Apply</.button>
  </.sheet>
  ```

  In this example, the `Fluxon.open_dialog/1` function handles the sheet opening while the `Fluxon.close_dialog/1` function handles the sheet closing, both handled on the client side.

  ### Open on Page Load

  For scenarios requiring an immediately visible sheet, use the `open` attribute:

  ```heex
  <.sheet id="welcome-sheet" open>
  ```

  The sheet will slide in as soon as the LiveView is mounted, with proper focus management.

  ### Server-Side Control

  The component offers two approaches for server-side sheet control:

  #### 1. Using the `open` attribute

  The `open` attribute provides declarative control based on server-side state:

  ```heex
  <.button phx-click="show-sheet">Open Filters</.button>

  <.sheet id="filters-sheet" open={@show_filters}>
  ```

  The sheet's visibility is tied to the `@show_filters` assign's value.

  #### 2. Using the `Fluxon.open_dialog/2` function

  For more programmatic control within LiveView:

  ```heex
  <.sheet id="filters-sheet" prevent_closing>
    Server controlled sheet
  </.sheet>
  ```

  ```elixir
  def handle_event("apply_filters", params, socket) do
    # Apply filters logic
    {:noreply, socket |> Fluxon.close_dialog("filters-sheet")}
  end
  ```

  The `prevent_closing` attribute ensures the sheet can only be closed through server-side events.

  > #### Client Side vs. Server Side State Synchronization {: .warning}
  >
  > When controlling a sheet with LiveView assigns (e.g., `open={@show_filters}`), be aware that closing actions like ESC key, clicking outside, or the "X" button are handled client-side for better UX. This means the sheet will close in the browser immediately, but the server's `@show_filters` assign will remain `true`, causing a state mismatch.
  >
  > You can handle this in two ways:
  >
  > **1. Using the `on_close` attribute (Recommended)**
  >
  > The `on_close` attribute lets you handle any sheet closing event, whether triggered by client-side actions or server commands. Use it to push an event back to the server to update the LiveView state:
  >
  > ```heex
  > <.sheet id="filters-sheet" open={@show_filters} on_close={JS.push("hide_filters")}>
  > ```
  >
  > **2. Server-Side Only Control**
  >
  > For complete control over the sheet's lifecycle, use `prevent_closing` to disable all client-side closing behaviors. The sheet will only respond to server commands, ensuring perfect state synchronization at the cost of standard interactions:
  >
  > ```heex
  > <.sheet id="filters-sheet" open={@show_filters} prevent_closing>
  >   <.button phx-click="hide_filters">Close</.button>
  > </.sheet>
  > ```
  >
  > Note: The second approach is best suited for critical operations like form submissions or multi-step workflows where you need to validate or process data before allowing the sheet to close.

  ## Dynamic Content

  A common use case is to use the same sheet component to display different content. For example, we might want to show different filter options based on the context:

  ```heex
  <.sheet id="filter-sheet" on_close={JS.push("reset_filters")}>
    <div :if={@filter_context}>
      <h3 class="text-lg font-semibold mb-4">{@filter_context.title}</h3>

      <div :for={filter <- @filter_context.filters} class="mb-4">
        <.input
          type="checkbox"
          label={filter.label}
          checked={filter.selected}
          phx-click="toggle_filter"
          phx-value-id={filter.id}
        />
      </div>
    </div>
  </.sheet>

  <.button phx-click={Fluxon.open_dialog("filter-sheet") |> JS.push("load_user_filters")}>
    User Filters
  </.button>

  <.button phx-click={Fluxon.open_dialog("filter-sheet") |> JS.push("load_date_filters")}>
    Date Filters
  </.button>
  ```

  In this example, there are a few important things to notice:

  1. The `Fluxon.open_dialog/1` function will be called to open the sheet. This will happen in the client side so the sheet will open instantly.
  2. The `JS.push/2` function will be called to push a new event to the server to update the `@filter_context` assign with the appropriate filters.
  3. When the `@filter_context` assign is present (updated), it will be displayed in the sheet.
  4. When the sheet is closed, the `reset_filters` event will be pushed to the server to reset the state.

  It's worth mentioning that this is a simple example and it's not optimized for a good UX. In a real scenario, you would want to display a loading state, have a fixed size sheet to avoid content shifting, maybe an animation when the content is loaded, etc. Here's some ideas:

  ```heex
  <.sheet id="filter-sheet" class="w-80" on_close={JS.push("reset_filters")}>
    <div class="min-h-[300px] relative">
      <div :if={!@filter_context} class="absolute inset-0 flex items-center justify-center">
        <.loading />
      </div>

      <div :if={@filter_context} class="animate-in slide-in-from-right">
        <h3 class="text-lg font-semibold mb-4">{@filter_context.title}</h3>
        <!-- Filter content -->
      </div>
    </div>
  </.sheet>
  ```

  ## Placement

  The sheet component provides four placement options to slide in from different edges of the screen. This is particularly useful for different types of interactions and content:

  ```heex
  <!-- Left drawer, great for navigation -->
  <.sheet id="nav-sheet" placement="left" class="w-80">
    <nav class="space-y-2">
      <!-- Navigation items -->
    </nav>
  </.sheet>

  <!-- Right sheet, perfect for filters or details -->
  <.sheet id="details-sheet" placement="right" class="w-96">
    <!-- Details content -->
  </.sheet>

  <!-- Top sheet, useful for notifications or banners -->
  <.sheet id="notification-sheet" placement="top" class="h-32">
    <!-- Notification content -->
  </.sheet>

  <!-- Bottom sheet, ideal for mobile interactions -->
  <.sheet id="actions-sheet" placement="bottom" class="h-96">
    <!-- Action items -->
  </.sheet>
  ```

  Available placement options:
  - `left`: Slides in from the left edge
  - `right`: Slides in from the right edge
  - `top`: Slides in from the top edge
  - `bottom`: Slides in from the bottom edge

  ## Size Control and Scrolling

  By default, the sheet will take up the full height (for left/right placement) or full width (for top/bottom placement) of the viewport. The width or height can be controlled via classes, and content will scroll when it exceeds the available space.

  Here's how you can control the sheet's dimensions and scrolling behavior:

  ```heex
  <.sheet id="settings-sheet" placement="right" class="w-96">
    <!-- Fixed header -->
    <header class="border-b border-zinc-100 -mx-6 px-6 pb-4 mb-4">
      <h2 class="text-lg font-semibold">Settings</h2>
    </header>

    <!-- Scrollable content -->
    <div class="space-y-4">
      <div :for={setting <- @settings} class="py-2 border-b border-zinc-100 last:border-0">
        <div class="font-medium">{setting.name}</div>
        <div class="text-sm text-zinc-600">{setting.description}</div>
      </div>
    </div>

    <!-- Fixed footer -->
    <div class="absolute bottom-0 left-0 right-0 border-t border-zinc-100 px-6 py-4 bg-white">
      <.button phx-click={Fluxon.close_dialog("settings-sheet")}>
        Close
      </.button>
    </div>
  </.sheet>
  ```

  ## Forms

  Forms in sheets work just like regular LiveView forms, making them perfect for collecting user input in a side panel:

  ```heex
  <.sheet id="new-user-sheet" placement="right" class="w-96">
    <.form for={@form} phx-submit="save_user">
      <div class="space-y-4">
        <header class="mb-4">
          <h2 class="text-lg font-semibold">New User</h2>
          <p class="text-sm text-zinc-600">Create a new user account.</p>
        </header>

        <.input field={@form[:name]} label="Name" />
        <.input field={@form[:email]} type="email" label="Email" />
        <.input field={@form[:role]} type="select" label="Role" options={["admin", "user"]} />

        <div class="flex justify-end gap-3 mt-6">
          <.button phx-click={Fluxon.close_dialog("new-user-sheet")}>
            Cancel
          </.button>
          <.button type="submit" phx-disable-with="Creating...">
            Create User
          </.button>
        </div>
      </div>
    </.form>
  </.sheet>
  ```

  For a better user experience, we can automatically close the sheet after successful form submission using `Fluxon.close_dialog/2` in the LiveView callback:

  ```elixir
  def handle_event("save_user", %{"user" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> Fluxon.close_dialog("new-user-sheet")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
  ```
  """

  use Fluxon.Component

  alias Phoenix.LiveView.JS

  @styles %{
    wrapper: [
      "z-[999] fixed inset-0"
    ],
    backdrop: [
      "fixed inset-0 bg-black/60 pointer-events-none"
    ],
    dialog: [
      "outline-hidden fixed inset-0 flex"
    ],
    content: [
      "p-6 overflow-y-auto relative bg-overlay shadow-base"
    ],
    close_button: [
      "cursor-pointer absolute z-20 top-3 right-3 p-0.5",
      "text-foreground-soft hover:text-foreground",
      "transition-colors duration-200 rounded-base"
    ]
  }

  @placement %{
    "left" => %{class: "justify-start", animation_enter: "translate-x-0", animation_leave: "-translate-x-full"},
    "right" => %{class: "justify-end", animation_enter: "translate-x-0", animation_leave: "translate-x-full"},
    "top" => %{class: "items-start", animation_enter: "translate-y-0", animation_leave: "-translate-y-full"},
    "bottom" => %{class: "items-end", animation_enter: "translate-y-0", animation_leave: "translate-y-full"}
  }

  @doc ~S'''
  Renders a sheet component.

  The sheet component provides a sliding panel interface for displaying content that enters from
  the edge of the screen. It includes built-in accessibility features, keyboard navigation
  support, and smooth slide animations.

  ## Features

  - Fully accessible with proper ARIA attributes and keyboard navigation
  - Smooth slide animations from any screen edge
  - Backdrop overlay with click-to-close functionality
  - Focus management and trapping
  - Flexible content area supporting any HTML or components
  - Customizable close behavior

  [INSERT LVATTRDOCS]
  '''
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: """
    The unique identifier for the sheet component. This ID is used to target the sheet
    for opening, closing, and managing focus. Must be unique across all sheets on the page.
    """

  attr :open, :boolean,
    default: false,
    doc: """
    Whether the sheet is initially open. When true, the sheet will slide in
    immediately when mounted. Useful for showing sheets based on server-side conditions.
    """

  attr :on_close, JS,
    default: %JS{},
    doc: """
    JavaScript commands to execute when the sheet is closed. Can be used to trigger
    additional actions or animations when the sheet closes. Accepts a Phoenix.LiveView.JS
    command chain.
    """

  attr :on_open, JS,
    default: %JS{},
    doc: """
    JavaScript commands to execute when the sheet is opened. Can be used to trigger
    additional actions or animations when the sheet opens. Accepts a Phoenix.LiveView.JS
    command chain.
    """

  attr :class, :any,
    default: "",
    doc: """
    Additional CSS classes to be applied to the sheet content container. These classes
    will be merged with the default styles. Useful for customizing the sheet's appearance
    or dimensions.
    """

  attr :close_on_esc, :boolean,
    default: true,
    doc: """
    Whether to close the sheet when the Escape key is pressed. When true, provides
    a standard keyboard shortcut for dismissing the sheet, improving accessibility.
    """

  attr :close_on_outside_click, :boolean,
    default: true,
    doc: """
    Whether to close the sheet when clicking outside of its content area. When true,
    allows users to dismiss the sheet by clicking on the backdrop overlay.
    """

  attr :prevent_closing, :boolean,
    default: false,
    doc: """
    When true, prevents the sheet from being closed through standard interactions
    (Escape key, backdrop click, close button). Useful for critical dialogs that
    require explicit user action.
    """

  attr :hide_close_button, :boolean,
    default: false,
    doc: """
    Whether to hide the close button in the top-right corner. When true, removes
    the standard close button, useful when providing custom close controls or when
    the sheet should only be closed through specific actions.
    """

  attr :animation, :string,
    default: "transition duration-200 ease-in-out",
    doc: """
    Base animation classes applied to the sheet. Controls the transition timing
    and easing function. Can be customized to match your application's animation style.
    """

  attr :animation_enter, :string,
    doc: """
    Classes applied when the sheet enters. Defines the final state of the slide animation
    when the sheet becomes visible. Automatically set based on placement.
    """

  attr :animation_leave, :string,
    doc: """
    Classes applied when the sheet leaves. Defines the state of the exit animation
    when the sheet is being hidden. Automatically set based on placement.
    """

  attr :backdrop_class, :string,
    default: "",
    doc: """
    Additional CSS classes for the sheet backdrop overlay. These classes will be merged
    with the default backdrop styles. Useful for customizing the overlay's appearance.
    """

  attr :placement, :string,
    default: "left",
    values: ["left", "right", "top", "bottom"],
    doc: """
    Controls which edge of the screen the sheet slides in from. Available options:

    - `left`: Slides in from the left edge
    - `right`: Slides in from the right edge
    - `top`: Slides in from the top edge
    - `bottom`: Slides in from the bottom edge
    """

  slot :inner_block,
    required: true,
    doc: """
    The content of the sheet. Can contain any HTML or components to create
    complex interfaces. Common patterns include headers, content sections,
    and footer areas with action buttons.
    """

  def sheet(assigns) do
    assigns =
      assigns
      |> assign(:styles, @styles)
      |> assign_new(:placement_class, fn -> @placement[assigns.placement].class end)
      |> assign_new(:animation_enter, fn -> @placement[assigns.placement].animation_enter end)
      |> assign_new(:animation_leave, fn -> @placement[assigns.placement].animation_leave end)
      |> assign_new(:is_full_width, fn -> assigns.placement in ["top", "bottom"] end)

    ~H"""
    <div
      hidden
      class={merge([@styles[:wrapper]])}
      phx-hook="Fluxon.Dialog"
      id={@id}
      data-on-close={@on_close}
      data-on-open={@on_open}
      data-close-on-esc={to_string(@close_on_esc)}
      data-close-on-outside-click={to_string(@close_on_outside_click)}
      data-prevent-closing={to_string(@prevent_closing)}
      data-open={to_string(@open)}
      data-part="dialog-wrapper"
    >
      <!-- Backdrop -->
      <div
        data-part="backdrop"
        class={merge([@styles[:backdrop], @backdrop_class])}
        data-animation="transition duration-200 ease-in-out"
        data-animation-enter="opacity-100"
        data-animation-leave="opacity-0"
      >
      </div>
      <!-- Sheet dialog -->
      <div
        role="dialog"
        aria-modal="true"
        data-part="dialog"
        class={merge([@styles[:dialog], @placement_class])}
        data-animation={@animation}
        data-animation-enter={@animation_enter}
        data-animation-leave={@animation_leave}
      >
        <span id={"#{@id}-focus-start"} tabindex="0" aria-hidden="true"></span>
        <div data-part="content" class={merge([@styles[:content], @is_full_width && "w-full", @class])}>
          <button
            :if={!@prevent_closing && !@hide_close_button}
            phx-click={Fluxon.close_dialog(@id)}
            type="button"
            aria-label="Close sheet"
            class={merge([@styles[:close_button]])}
          >
            <.close_icon />
          </button>

          {render_slot(@inner_block)}
        </div>
        <span id={"#{@id}-focus-end"} tabindex="0" aria-hidden="true"></span>
      </div>
    </div>
    """
  end

  defp close_icon(assigns) do
    ~H"""
    <svg fill="none" class="size-5" viewBox="0 0 24 24" aria-hidden="true" role="img">
      <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 6 6 18M6 6l12 12" />
    </svg>
    """
  end
end
