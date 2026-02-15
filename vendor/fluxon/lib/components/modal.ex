defmodule Fluxon.Components.Modal do
  @moduledoc """
  A powerful and accessible modal component that provides a flexible way to display content in an overlay.
  Built with LiveView integration in mind, this component offers rich features for both client and server-side control.

  > #### Modal vs Sheet {: .info}
  >
  > The modal and sheet components share the same core functionality and API. They are interchangeable in terms of features
  > and behavior, differing mainly in their visual presentation. While modals are centered overlays suited for focused
  > interactions, sheets slide in from screen edges and are ideal for side panels and mobile interfaces. See `Fluxon.Components.Sheet`
  > if you need edge-anchored panels.

  ## Opening and Closing

  While opening and closing a modal is straightforward in most cases, the component provides various approaches to handle different scenarios, particularly when working with LiveView.

  ### Basic Client-Side Control

  The most common use case is opening a modal via button click and closing it through standard actions (click outside, "X" button, ESC key):

  ```heex
  <.button phx-click={Fluxon.open_dialog("most-basic-modal")}>Open</.button>

  <.modal id="most-basic-modal">
    Modal content

    <.button phx-click={Fluxon.close_dialog("most-basic-modal")}>Close</.button>
  </.modal>
  ```

  In this example, the `Fluxon.open_dialog/1` function handles the modal opening while the `Fluxon.close_dialog/1` function handles the modal closing, both handled on the client side.

  ### Open on Page Load

  For scenarios requiring an immediately visible modal, use the `open` attribute:

  ```heex
  <.modal id="modal-open-on-load" open>
  ```

  The modal will be displayed as soon as the LiveView is mounted, with proper focus management.

  ### Server-Side Control

  The component offers two approaches for server-side modal control:

  #### 1. Using the `open` attribute

  The `open` attribute provides declarative control based on server-side state:

  ```heex
  <.button phx-click="show-modal">Open</.button>

  <.modal id="modal-server-side-controlled" open={@show_modal}>
  ```

  The modal's visibility is tied to the `@show_modal` assign's value.

  #### 2. Using the `Fluxon.open_dialog/2` function

  For more programmatic control within LiveView:

  ```heex
  <.modal id="modal-server-side-controlled" prevent_closing>
    Server side controlled modal
  </.modal>
  ```

  ```elixir
  def handle_event("my-event", _params, socket) do
    {:noreply, socket |> Fluxon.open_dialog("modal-server-side-controlled")}
  end

  def handle_event("my-other-event", _params, socket) do
    {:noreply, socket |> Fluxon.close_dialog("modal-server-side-controlled")}
  end
  ```

  The `prevent_closing` attribute ensures the modal can only be closed through server-side events.

  > #### Client Side vs. Server Side State Synchronization {: .warning}
  >
  > When controlling a modal with LiveView assigns (e.g., `open={@show_modal}`), be aware that closing actions like ESC key, clicking outside, or the "X" button are handled client-side for better UX. This means the modal will close in the browser immediately, but the server's `@show_modal` assign will remain `true`, causing a state mismatch.
  >
  > You can handle this in two ways:
  >
  > **1. Using the `on_close` attribute (Recommended)**
  >
  > The `on_close` attribute lets you handle any modal closing event, whether triggered by client-side actions or server commands. Use it to push an event back to the server to update the LiveView state:
  >
  > ```heex
  > <.modal id="modal-server-side-controlled" open={@show_modal} on_close={JS.push("hide_modal")}>
  > ```
  >
  > **2. Server-Side Only Control**
  >
  > For complete control over the modal's lifecycle, use `prevent_closing` to disable all client-side closing behaviors. The modal will only respond to server commands, ensuring perfect state synchronization at the cost of standard modal interactions:
  >
  > ```heex
  > <.modal id="modal-server-side-controlled" open={@show_modal} prevent_closing>
  >   <.button phx-click="hide_modal">Close</.button>
  > </.modal>
  > ```
  >
  > **Note:** The second approach is best suited for critical operations like form submissions or multi-step workflows where you need to validate or process data before allowing the modal to close.

  ## Dynamic Content

  A very common use case is to display different content using the same modal component. For example, we have a table of items and we want to display more details about a specific item when clicking on it.
  This can be achieved by dynamically updating an assign in the server-side assigns and then using it in the modal component:

  ```heex
  <.modal id="user-details-modal" on_close={JS.push("reset-user-details")}>
    <div :if={@user_details}>
      <p>ID: {@user_details.user_id}</p>
      <p>Name: {@user_details.user_name}</p>
    </div>
  </.modal>

  <button phx-click={Fluxon.open_dialog("user-details-modal") |> JS.push("load-user-details", value: %{user_id: 1})}>
    John Doe
  </button>

  <button phx-click={Fluxon.open_dialog("user-details-modal") |> JS.push("load-user-details", value: %{user_id: 2})}>
    Jane Doe
  </button>
  ```

  In this example, there are a few important things to notice:

  1. The `Fluxon.open_dialog/1` function will be called to open the modal. This will happen in the client side so the modal will open instantly.
  2. The `JS.push/2` function will be called to push a new event to the server to update the `@user_details` assign with the new details of the user.
  3. When the `@user_details` assign is present (updated), it will be displayed in the modal.
  4. When the modal is closed, the `reset-user-details` event will be pushed to the server to reset the `@user_details` assign to `nil` so we don't see old details when opening the modal again.

  It's worth mentioning that this is a simple example and it's not optimized for a good UX. In a real scenario, you would want to display a loading state, have a fixed size modal to avoid content shifting, maybe an animation when the content is loaded, etc. Here's some ideas:

  ```heex
  <.modal id="user-details-modal" class="w-[400px]" on_close={JS.push("reset-user-details")}>
    <div class="min-h-[200px] relative">
      <div :if={!@user_details} class="absolute inset-0 flex items-center justify-center bg-white/80">
        <.loading />
      </div>

      <div :if={@user_details} class="animate-in fade-in duration-200">
        <p>ID: {@user_details.user_id}</p>
        <p>Name: {@user_details.user_name}</p>
      </div>
    </div>
  </.modal>
  ```

  ## Placement and Positioning

  The modal component provides flexible positioning options to accommodate different UI patterns. By default, modals are centered on the screen, but there are times when you might want different placements - like a side panel for filters, a bottom sheet for mobile interfaces, or a top banner for important announcements.

  ### Standard Placements

  The most common placement options position the modal relative to the viewport while maintaining some padding from the edges:

  ```heex
  <!-- Centered modal (default) -->
  <.modal id="centered-modal">
    This modal is centered both horizontally and vertically
  </.modal>

  <!-- Top-aligned modal, useful for notifications or alerts -->
  <.modal id="top-modal" placement="top">
    This appears at the top of the viewport
  </.modal>

  <!-- Right-aligned modal, great for side panels -->
  <.modal id="right-modal" placement="right" class="h-full max-w-md">
    This creates a side panel on the right
  </.modal>
  ```

  All standard placement options:
  - `center` (default): Centers the modal both horizontally and vertically
  - `top`: Aligns to the viewport top with horizontal centering
  - `bottom`: Aligns to the viewport bottom with horizontal centering
  - `left`: Aligns to the viewport left with vertical centering
  - `right`: Aligns to the viewport right with vertical centering

  ### Full-Size Placements

  When you need edge-to-edge modals that span the full width or height of the viewport, use the full-size placement options. These are particularly useful for responsive designs and mobile interfaces:

  ```heex
  <!-- Full-height side drawer -->
  <.modal id="side-drawer" placement="full-left" class="w-80">
    <nav class="h-full">
      <!-- Navigation items -->
    </nav>
  </.modal>

  <!-- Full-width bottom sheet (mobile-friendly) -->
  <.modal id="bottom-sheet" placement="full-bottom" class="rounded-t-xl">
    <div class="p-4">
      <!-- Bottom sheet content -->
    </div>
  </.modal>
  ```

  Full-size placement options:
  - `full-left`: Creates a full-height panel aligned to the left edge
  - `full-right`: Creates a full-height panel aligned to the right edge
  - `full-top`: Creates a full-width panel aligned to the top edge
  - `full-bottom`: Creates a full-width panel aligned to the bottom edge

  ## Size Control and Scrolling

  By default, the modal will center itself both horizontally and vertically, adapting its width to fit the content. When the content grows beyond the viewport height, the modal's wrapper will scroll, allowing the content to extend beyond the screen.

  However, this default behavior might not always provide the best user experience, especially when dealing with dynamic content or long lists. Here's how you can control the modal's dimensions and scrolling behavior:

  ```heex
  <.modal id="modal-with-sections" class="w-[600px]">
    <!-- Fixed header stays in view -->
    <header class="border-b border-zinc-100 px-6 py-4">
      <h2 class="text-lg font-semibold">Users List</h2>
    </header>

    <!-- Scrollable content area -->
    <div class="max-h-[400px] overflow-y-auto px-6 py-4">
      <div :for={user <- @users} class="py-2">
        <div class="font-medium">{user.name}</div>
        <div class="text-sm text-zinc-600">{user.email}</div>
      </div>
    </div>

    <!-- Fixed footer stays in view -->
    <footer class="border-t border-zinc-100 px-6 py-4 flex justify-end gap-3">
      <.button phx-click={Fluxon.close_dialog("modal-with-sections")}>
        Cancel
      </.button>
      <.button>Save Changes</.button>
    </footer>
  </.modal>
  ```

  In this example, we create a modal with:
  - A fixed width using `w-[600px]` to maintain consistent sizing
  - A non-scrolling header that stays in view
  - A scrollable content area with `max-h-[400px]` and `overflow-y-auto`
  - A fixed footer for actions

  ## Modal Stacking

  The modal component supports stacking multiple modals on top of each other, which is essential for complex workflows like confirmation dialogs, multi-step forms, or nested detail views. The stacking system automatically manages focus, z-index, and backdrop behavior.

  Here's an example of a workflow that uses stacked modals:

  ```heex
  <!-- Delete user workflow with confirmation -->
  <.modal id="user-details">
    <div class="space-y-4">
      <h3 class="text-lg font-semibold">User Details</h3>
      <div class="text-sm text-zinc-600">
        <p>Name: {@user.name}</p>
        <p>Email: {@user.email}</p>
      </div>

      <div class="flex justify-end gap-3">
        <.button phx-click={Fluxon.close_dialog("user-details")}>
          Close
        </.button>
        <.button phx-click={Fluxon.open_dialog("confirm-delete")} color="red">
          Delete User
        </.button>
      </div>
    </div>
  </.modal>

  <.modal id="confirm-delete">
    <div class="text-center space-y-4">
      <h3 class="text-lg font-semibold text-red-600">Confirm Deletion</h3>
      <p class="text-sm text-zinc-600">
        Are you sure you want to delete this user? This action cannot be undone.
      </p>

      <div class="flex justify-center gap-3">
        <.button phx-click={Fluxon.close_dialog("confirm-delete")}>
          Cancel
        </.button>
        <.button
          phx-click={
            Fluxon.close_dialog("confirm-delete")
            |> Fluxon.close_dialog("user-details")
            |> JS.push("delete_user", value: %{user_id: @user.id})
          }
          color="red"
        >
          Confirm Delete
        </.button>
      </div>
    </div>
  </.modal>
  ```

  When working with stacked modals:

  1. Each modal maintains its own focus trap, but only the topmost modal is interactive
  2. Background modals are visually dimmed but remain visible for context
  3. Closing a modal automatically restores focus to the previous modal
  4. You can chain multiple modal actions (open/close) with the `|>` operator

  ## Forms

  Forms in modals work just like regular LiveView forms. The modal component doesn't interfere with form handling, making it straightforward to implement create/edit workflows:

  ```heex
  <.modal id="new-user-modal" class="w-[400px]">
    <.form for={@form} phx-submit="save_user">
      <div class="space-y-4">
        <header class="mb-4">
          <h2 class="text-lg font-semibold">New User</h2>
          <p class="text-sm text-zinc-600">Create a new user account.</p>
        </header>

        <.input field={@form[:name]} label="Name" />
        <.input field={@form[:email]} type="email" label="Email" />

        <div class="flex justify-end gap-3 mt-6">
          <.button phx-click={Fluxon.close_dialog("new-user-modal")}>
            Cancel
          </.button>
          <.button type="submit" phx-disable-with="Creating...">
            Create User
          </.button>
        </div>
      </div>
    </.form>
  </.modal>
  ```

  For a better user experience, we can automatically close the modal after successful form submission using `Fluxon.close_dialog/2` in the LiveView callback:

  ```elixir
  def handle_event("save_user", %{"user" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> Fluxon.close_dialog("new-user-modal")}

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
      "outline-hidden fixed inset-0 overflow-y-auto px-4"
    ],
    placement_wrapper: [
      "min-h-full py-4 flex"
    ],
    content: [
      "p-6 relative bg-overlay rounded-base shadow-base"
    ],
    close_button: [
      "cursor-pointer absolute z-20 top-3 right-3 p-0.5",
      "text-foreground-soft hover:text-foreground",
      "transition-colors duration-200 rounded-base"
    ]
  }

  @placement %{
    "center" => "items-center justify-center",
    "top" => "items-start justify-center",
    "bottom" => "items-end justify-center",
    "left" => "justify-start items-center",
    "right" => "justify-end items-center",
    "full-left" => "justify-start",
    "full-right" => "justify-end",
    "full-top" => "items-start",
    "full-bottom" => "items-end"
  }

  @doc ~S'''
  Renders a modal component.

  The modal component provides a flexible and customizable way to display content in an overlay
  that focuses the user's attention. It includes built-in accessibility features, keyboard
  navigation support, and customizable animations.

  ## Features

  - Fully accessible with proper ARIA attributes and keyboard navigation
  - Customizable placement and animations
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
    The unique identifier for the modal component. This ID is used to target the modal
    for opening, closing, and managing focus. Must be unique across all modals on the page.
    """

  attr :open, :boolean,
    default: false,
    doc: """
    Whether the modal is initially open. When true, the modal will be displayed
    immediately when mounted. Useful for showing modals based on server-side conditions.
    """

  attr :on_close, JS,
    default: %JS{},
    doc: """
    JavaScript commands to execute when the modal is closed. Can be used to trigger
    additional actions or animations when the modal closes. Accepts a Phoenix.LiveView.JS
    command chain.
    """

  attr :on_open, JS,
    default: %JS{},
    doc: """
    JavaScript commands to execute when the modal is opened. Can be used to trigger
    additional actions or animations when the modal opens. Accepts a Phoenix.LiveView.JS
    command chain.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to be applied to the modal content container. These classes
    will be merged with the default styles. Useful for customizing the modal's appearance
    or dimensions.
    """

  attr :container_class, :any,
    default: nil,
    doc: """
    Additional CSS classes for the modal's outer container. Affects the positioning
    wrapper element. Useful for adjusting the modal's overall layout or stacking context.
    """

  attr :close_on_esc, :boolean,
    default: true,
    doc: """
    Whether to close the modal when the Escape key is pressed. When true, provides
    a standard keyboard shortcut for dismissing the modal, improving accessibility.
    """

  attr :close_on_outside_click, :boolean,
    default: true,
    doc: """
    Whether to close the modal when clicking outside of its content area. When false,
    prevents users from dismissing the modal by clicking on the backdrop overlay.
    """

  attr :prevent_closing, :boolean,
    default: false,
    doc: """
    When true, prevents the modal from being closed through standard interactions
    (Escape key, backdrop click, close button). Useful for critical dialogs that
    require explicit user action.
    """

  attr :hide_close_button, :boolean,
    default: false,
    doc: """
    Whether to hide the close button in the top-right corner. When true, removes
    the standard close button, useful when providing custom close controls or when
    the modal should only be closed through specific actions.
    """

  attr :animation, :string,
    default: "transition duration-200 ease-in-out",
    doc: """
    Base animation classes applied to the modal. Controls the transition timing
    and easing function. Can be customized to match your application's animation style.
    """

  attr :animation_enter, :string,
    doc: """
    Classes applied when the modal enters. Defines the final state of the animation
    when the modal becomes visible. Typically controls opacity and transform properties.
    """

  attr :animation_leave, :string,
    doc: """
    Classes applied when the modal leaves. Defines the state of the exit animation
    when the modal is being hidden. Typically controls opacity and transform properties.
    """

  attr :backdrop_class, :string,
    default: nil,
    doc: """
    Additional CSS classes for the modal backdrop overlay. These classes will be merged
    with the default backdrop styles. Useful for customizing the overlay's appearance.
    """

  attr :placement, :string,
    default: "center",
    values: ~w(center top bottom left right full-left full-right full-top full-bottom),
    doc: """
    Controls the placement of the modal relative to the viewport. Supports different
    positions with automatic repositioning when needed. Available options:

    - `center`: Centers the modal both horizontally and vertically
    - `top`: Aligns to the top of the viewport
    - `bottom`: Aligns to the bottom of the viewport
    - `left`: Aligns to the left of the viewport
    - `right`: Aligns to the right of the viewport
    - `full-left`: Full-height modal aligned to the left
    - `full-right`: Full-height modal aligned to the right
    - `full-top`: Full-width modal aligned to the top
    - `full-bottom`: Full-width modal aligned to the bottom
    """

  slot :inner_block,
    required: true,
    doc: """
    The content of the modal. Can contain any HTML or components to create
    complex modal interfaces. Common patterns include headers, content sections,
    and footer areas with action buttons.
    """

  def modal(assigns) do
    assigns =
      assigns
      |> assign(:styles, @styles)
      |> assign_new(:placement_class, fn -> @placement[assigns.placement] end)
      |> assign_new(:is_full_width, fn -> assigns.placement in ["full-top", "full-bottom"] end)
      |> assign_new(:animation_enter, fn %{placement: placement} ->
        case placement do
          "full-right" -> "opacity-100 translate-x-0"
          "full-left" -> "opacity-100 translate-x-0"
          "full-top" -> "opacity-100 translate-y-0"
          "full-bottom" -> "opacity-100 translate-y-0"
          _ -> "opacity-100 scale-100"
        end
      end)
      |> assign_new(:animation_leave, fn %{placement: placement} ->
        case placement do
          "full-right" -> "opacity-0 translate-x-[5%]"
          "full-left" -> "opacity-0 translate-x-[-5%]"
          "full-top" -> "opacity-0 -translate-y-[5%]"
          "full-bottom" -> "opacity-0 translate-y-[5%]"
          _ -> "opacity-0 scale-95"
        end
      end)

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
      <!-- Modal dialog -->
      <div
        role="dialog"
        aria-modal="true"
        data-part="dialog"
        class={merge([@styles[:dialog]])}
        data-animation={@animation}
        data-animation-enter={@animation_enter}
        data-animation-leave={@animation_leave}
      >
        <span id={"#{@id}-focus-start"} tabindex="0" aria-hidden="true"></span>
        <div class={merge([@styles[:placement_wrapper], @placement_class])}>
          <div data-part="content" class={merge([@styles[:content], @is_full_width && "w-full", @class])}>
            <button
              :if={!@prevent_closing && !@hide_close_button}
              phx-click={Fluxon.close_dialog(@id)}
              type="button"
              aria-label="Close modal"
              class={merge([@styles[:close_button]])}
            >
              <.close_icon />
            </button>

            {render_slot(@inner_block)}
          </div>
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
