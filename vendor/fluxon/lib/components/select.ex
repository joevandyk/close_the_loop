defmodule Fluxon.Components.Select do
  @moduledoc """
  A select component that implements a modern, accessible selection interface.

  This component can be used to build both simple and complex selection interfaces.
  It supports single and multiple selections, option searching, custom option rendering, and keyboard navigation.
  The component can be used either as a custom select or as a native select element.

  The component is built on top of the standard HTML `<select>` element.
  In native mode (`native`), it's a direct wrapper around the HTML select, while in its default custom mode,
  it creates an accessible UI while still using a hidden select element to handle form submissions.
  Multiple selection uses the HTML `select multiple` attribute, ensuring all form integrations
  (changesets, validations, etc.) work as expected.

  > #### Select vs Autocomplete {: .info}
  >
  > While both components enable users to choose from a list of options, they offer different interaction patterns
  > that may better suit certain use cases.
  >
  > **Select Component**
  > Best suited for browsing through predefined options, especially when users benefit from seeing
  > all choices at once. Supports multiple selection.
  >
  > **Autocomplete Component**
  > Optimized for searching through large datasets, with both client and server-side filtering.
  > Features a type-to-search interface with custom empty states and loading indicators.
  >
  > **Key Differences:**
  >
  > | Feature | Select | Autocomplete |
  > |---------|---------|--------------|
  > | Primary Interaction | Click to browse | Type to search |
  > | Data Size | Small to medium lists | Any size dataset |
  > | Filtering | Client-side only | Client or server-side |
  > | Multiple Selection | Supported | Not supported |
  > | Clearing Selection | Supported | Not supported |

  ## Usage

  Basic usage with a list of options:

  ```heex
  <.select
    name="country"
    options={[{"United States", "US"}, {"Canada", "CA"}]}
  />
  ```

  The select component uses `Phoenix.HTML.Form.options_for_select/2` to generate the select options.
  Options can be provided in these formats:

  - List of strings: `["Option 1", ...]`
  - List of tuples: `[{"Label 1", "value1"}, ...]`
  - List of keyword pairs: `[Label: "value", ...]`
  - Grouped options: `[{"Group 1", ["Option 1", "Option 2"]}, ...]`

  A full-feature example would look like this:

  ```heex
  <.select
    name="payment_method"
    label="Payment Method"
    sublabel="Select payment type"
    description="Choose your preferred payment method"
    help_text="We securely process all payment information"
    placeholder="Select payment method"
    options={[
      {"Credit Card", "credit_card"},
      {"PayPal", "paypal"},
      {"Bank Transfer", "bank_transfer"},
      {"Cryptocurrency", "crypto"}
    ]}
  />
  ```

  ### Native Select

  The component defaults to a custom select interface, but you can use the native browser select element by setting `native`:

  ```heex
  <.select
    name="country"
    native
    options={[{"United States", "US"}, {"Canada", "CA"}]}
  />
  ```

  Native selects are useful for:
  - Mobile interfaces where native controls are preferred
  - Simple selection needs
  - Maximum browser compatibility
  - Performance optimization

  Note that features like search, multiple selection, and clearing are only available in the custom select mode.

  ## Form Integration

  The select component integrates with Phoenix forms in two ways: using the `field` attribute for form integration
  or using the `name` attribute for standalone selects.

  ### Using with Phoenix Forms (Recommended)

  Use the `field` attribute to bind the select to a form field:

  ```heex
  <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save">
    <.select
      field={f[:country]}
      label="Country"
      options={@countries}
      errors={f[:country].errors}
    />
  </.form>
  ```

  Using the `field` attribute provides:
  - Automatic value handling from form data
  - Error handling and validation messages
  - Form submission with correct field names
  - Integration with changesets
  - ID generation for accessibility
  - Nested form data handling

  Example with a complete changeset implementation:

  ```elixir
  defmodule MyApp.User do
    use Ecto.Schema
    import Ecto.Changeset

    schema "users" do
      field :country, :string
      field :languages, {:array, :string}
      timestamps()
    end

    def changeset(user, attrs) do
      user
      |> cast(attrs, [:country, :languages])
      |> validate_required([:country])
      |> validate_subset(:languages, ["en", "es", "fr", "de"])
    end
  end

  # In your LiveView
  def mount(_params, _session, socket) do
    countries = [{"United States", "US"}, {"Canada", "CA"}, {"Mexico", "MX"}]
    languages = [{"English", "en"}, {"Spanish", "es"}, {"French", "fr"}, {"German", "de"}]

    changeset = User.changeset(%User{}, %{})

    {:ok, assign(socket, countries: countries, languages: languages, form: to_form(changeset))}
  end

  def render(assigns) do
    ~H\"\"\"
    <.form :let={f} for={@form} phx-change="validate">
      <.select clearable field={f[:country]} options={@countries} />
      <.select clearable multiple field={f[:languages]} options={@languages} />
    </.form>
    \"\"\"
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> User.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end
  ```

  ### Using Standalone Selects

  For simpler cases or when not using Phoenix forms, use the `name` attribute:

  ```heex
  <.select
    name="sort_by"
    options={[
      {"Newest First", "newest"},
      {"Oldest First", "oldest"},
      {"Name A-Z", "name_asc"}
    ]}
  />
  ```

  When using standalone selects:
  - The `name` attribute determines the form field name
  - Values are managed through the `value` attribute
  - Errors are passed via the `errors` attribute

  ## Searchable

  The select component includes search functionality to filter options in large lists.
  Enable search by setting the `searchable` attribute:

  ```heex
  <.select
    name="country"
    searchable
    search_input_placeholder="Search for a country"
    search_no_results_text="No countries found for %{query}"
    options={[
      {"United States", "US"},
      {"Canada", "CA"},
      {"Mexico", "MX"}
    ]}
  />
  ```

  ### Search Behavior

  The search runs on the client-side with these features:
  - Case-insensitive matching
  - Diacritics-insensitive (accents are ignored)
  - Filtering updates as you type
  - Keyboard navigation during search
  - Search input focus when select opens

  The search matches option labels. For example, searching for "united" will match "United States" regardless of case or accents.

  ### Custom Search Messages

  Two attributes control the search text:
  - `search_input_placeholder`: Text shown in the search input
  - `search_no_results_text`: Text shown when no options match

  The no results message can include the search term with `%{query}`:

  ```heex
  <.select
    searchable
    search_input_placeholder="Find a country..."
    search_no_results_text="No countries matching '%{query}'"
    options={@countries}
  />
  ```

  ### Search with Multiple Selection

  When using search with multiple selection, the component maintains the selected state of filtered-out options:

  ```heex
  <.select
    multiple
    searchable
    options={@countries}
    placeholder="Select countries"
    search_input_placeholder="Search countries..."
  />
  ```

  Selected options remain visible in the toggle button even when filtered out by the search. This helps users keep track of their selections while searching for additional options.

  ### Search with Custom Options

  The search functionality works with custom option rendering. The search matches against the option labels while preserving your custom rendering:

  ```heex
  <.select searchable options={@users}>
    <:option :let={{label, value}}>
      <div class="flex items-center gap-2 px-3 py-2">
        <img src={avatar_url(value)} class="size-8 rounded-full" />
        <div>
          <div class="font-medium">{label}</div>
          <div class="text-sm text-zinc-500">{user_role(value)}</div>
        </div>
      </div>
    </:option>
  </.select>
  ```

  > #### Search Implementation Details {: .info}
  >
  > The search functionality:
  > - Runs entirely on the client side for immediate feedback
  > - Uses a normalized version of the text for matching (lowercase, no accents)
  > - Matches against the full option label
  > - Updates the filtered list without changing the selected values
  > - Maintains all keyboard navigation features during search

  ### Server-Side Search

  For large datasets or when search results need to be computed on the server, you can enable server-side search
  by providing the `on_search` attribute with a LiveView event name:

  ```heex
  <.select
    field={f[:user_id]}
    searchable
    search_threshold={2}
    debounce={500}
    on_search="search_users"
    search_input_placeholder="Search users..."
    search_no_results_text="No users found for '%{query}'"
    options={@filtered_users}
  />
  ```

  When server-side search is enabled:
  - The `on_search` event is triggered when the user types in the search input
  - The event receives `%{"query" => query, "id" => component_id}` as parameters
  - A loading indicator is shown while the search is in progress
  - The component waits for the LiveView to update the options list

  > #### Important: Selected Options and Search Results {: .warning}
  >
  > **This is a fundamental constraint of server-side search that requires careful consideration in your implementation.**
  >
  > When using server-side search, the select component's toggle label is derived from the currently available options
  > in the `options` attribute. If a user has selected an option and then performs a search that filters out that
  > selected option, **the toggle label will disappear or become empty** until the search reveals the selected option again.
  >
  > This behavior occurs because:
  > 1. LiveView re-renders the component with new filtered options from your search event handler
  > 2. The component looks for the selected value's label within the current options list
  > 3. If the selected option is not in the filtered results, no label can be found
  > 4. The toggle displays an empty state until the user clears the search or finds the selected option
  >
  > **Recommended Implementation:** To maintain a consistent user experience and prevent selected labels from disappearing,
  > you should always include currently selected options in your search results, even when they don't match the search query.

  #### Search Configuration

  Several attributes control the server search behavior:

  - `search_threshold`: Minimum characters before triggering search (default: 0)
  - `debounce`: Milliseconds to wait after typing stops before searching (default: 300)
  - `on_search`: LiveView event name to trigger for server searches

  Example with all search options configured:

  ```heex
  <.select
    field={f[:product_id]}
    searchable
    search_threshold={3}
    debounce={400}
    on_search="search_products"
    search_input_placeholder="Type at least 3 characters to search..."
    search_no_results_text="No products found matching '%{query}'"
    options={@products}
  />
  ```



  ## Multiple Selection

  Enable multiple selection with the `multiple` attribute:

  ```heex
  <.select
    name="countries"
    multiple
    options={[{"United States", "US"},{"Canada", "CA"},{"Mexico", "MX"}]}
  />
  ```

  This allows selecting multiple options and submits an array of values:

  ```elixir
  %{"_target" => ["country"], "country" => ["", "US", "CA", "MX"]}
  ```

  > #### Empty values in multiple select {: .info}
  >
  > According to the HTML specification, when submitting a form with a multiple select field:
  > - Only selected options are included in the form submission
  > - When no options are selected, the field is omitted from the form data
  > - This differs from single select fields, which always submit a value
  >
  > To ensure the field is always present in the form data, the component adds
  > a hidden input with an empty value:
  >
  > ```html
  > <input type="hidden" name="select[]" value="" />
  > <select multiple name="select[]">
  >   <!-- options here -->
  > </select>
  > ```
  >
  > This results in consistent form submissions:
  >
  > ```elixir
  > # No options selected (hidden input provides the empty value)
  > %{"select" => [""]}
  >
  > # One or more options selected (hidden input value is included)
  > %{"select" => ["", "option1", "option2"]}
  > ```
  >
  > When processing the form data:
  > 1. Filter out the empty string value
  > 2. Handle an empty list as "no selection"
  >
  > ```elixir
  > # Example processing
  > selected = Enum.reject(params["select"] || [], &(&1 == ""))
  > ```

  By default, there is no limit on the number of selections. If no options are selected, the `[""]` array is sent.

  ### Maximum Selections

  Use the `max` attribute to limit the number of selections:

  ```heex
  <.select name="countries" multiple max={2} />
  ```

  ## Clearable

  By default, single selections cannot be unselected. The `clearable` attribute adds this ability and shows a clear button.
  Pressing backspace when the select is focused also clears the selection. For multiple selections, the clear button unselects
  all options.

  ```heex
  <.select name="country" clearable />
  ```

  When clearing a single selection, an empty option (`<option value="">`) is selected, sending an empty string in the form data.
  This matches how multiple select handles empty states by sending (`[""]`).

  ## Inner Affixes

  Add content *inside* the select's border using inner affix slots. Used for icons, status indicators, and visual elements:

  ```heex
  <!-- Search icon prefix -->
  <.select name="category" options={@categories} placeholder="Select category">
    <:inner_prefix>
      <.icon name="hero-folder" class="icon" />
    </:inner_prefix>
  </.select>

  <!-- Status indicators with dual affixes -->
  <.select name="status" options={@statuses} placeholder="Select status">
    <:inner_prefix>
      <.icon name="hero-flag" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-check-circle" class="icon text-green-500!" />
    </:inner_suffix>
  </.select>
  ```

  ### Advanced Inner Affix Patterns

  ```heex
  <!-- Priority selection with warning indicators -->
  <.select name="priority" options={@priorities} placeholder="Select priority">
    <:inner_prefix>
      <.icon name="hero-exclamation-triangle" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-bell" class="icon text-red-500!" />
    </:inner_suffix>
  </.select>

  <!-- Size-matched icons for different variants -->
  <.select name="small_category" size="sm" options={@categories} placeholder="Category">
    <:inner_prefix>
      <.icon name="hero-folder" class="icon" />
    </:inner_prefix>
  </.select>

  <.select name="large_category" size="lg" options={@categories} placeholder="Category">
    <:inner_prefix>
      <.icon name="hero-folder" class="icon" />
    </:inner_prefix>
  </.select>
  ```

  > #### Inner Suffix Replaces Chevron {: .info}
  >
  > When you provide an `inner_suffix` slot, it replaces the default chevron down arrow.
  > The chevron is only shown when no `inner_suffix` is provided, maintaining the
  > expected select behavior while allowing customization.

  ## Outer Affixes

  Place content *outside* the select's border using outer affix slots. Used for buttons, labels, and interactive elements:

  ```heex
  <!-- Simple text prefix -->
  <.select name="filtered" options={@options} placeholder="Select option">
    <:outer_prefix class="px-3 text-foreground-soft">Filter:</:outer_prefix>
  </.select>

  <!-- Action button integration -->
  <.select name="with_action" options={@options} placeholder="Select option">
    <:outer_suffix>
      <.button size="md">Apply</.button>
    </:outer_suffix>
  </.select>
  ```

  ### Complete Affix Compositions

  ```heex
  <!-- Full-featured selection interface -->
  <.select name="product" options={@products} placeholder="Select product">
    <:outer_prefix class="px-2">Choose</:outer_prefix>
    <:inner_prefix>
      <.icon name="hero-shopping-bag" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-star" class="icon text-yellow-500!" />
    </:inner_suffix>
    <:outer_suffix>
      <.button size="md">Add to Cart</.button>
    </:outer_suffix>
  </.select>

  <!-- User role selection with permissions -->
  <.select name="user_role" options={@roles} placeholder="Select role">
    <:outer_prefix class="px-3">Role:</:outer_prefix>
    <:inner_prefix>
      <.icon name="hero-user-group" class="icon" />
    </:inner_prefix>
    <:outer_suffix>
      <.button size="md">View Permissions</.button>
    </:outer_suffix>
  </.select>
  ```

  > #### Size Matching with Affixes {: .important}
  >
  > When using buttons or components within affix slots, match their `size` attribute to the
  > select's `size` for proper visual alignment:
  >
  > ```heex
  > <.select name="example" size="lg" options={@options}>
  >   <:outer_suffix>
  >     <.button size="lg">Action</.button>  <!-- Matches select size -->
  >   </:outer_suffix>
  > </.select>
  > ```

  ## Custom Option Rendering

  The select component supports custom option rendering through its `:option` slot. For each option in the list,
  the component passes a tuple `{label, value}` to the slot, which can be accessed using the `:let` binding:

  ```heex
  <.select
    name="role"
    placeholder="Select role"
    options={[
      {"Admin", "admin"},
      {"Editor", "editor"},
      {"Viewer", "viewer"}
    ]}
  >
    <:option :let={{label, value}}>
      <div class={[
        "flex items-center justify-between",
        "rounded-lg py-2 px-3",
        "in-data-selected:bg-zinc-100",
        "in-data-highlighted:bg-zinc-50"
      ]}>
        <div>
          <div class="font-medium text-sm">{label}</div>
          <div class="text-zinc-500 text-xs">
            {case value do
              "admin" -> "Full access to all features"
              "editor" -> "Can create and modify content"
              "viewer" -> "Read-only access to content"
            end}
          </div>
        </div>
        <.icon :if={value == "admin"} name="u-shield-check" class="size-4 text-blue-500" />
      </div>
    </:option>
  </.select>
  ```

  > #### Toggle Label {: .info}
  >
  > While you can customize how options are rendered in the select, the toggle button will always display
  > the option's label. This ensures consistent behavior. For example, if you have
  > an option `{"Admin User", "admin"}` with custom rendering, the toggle will show "Admin User" when selected,
  > regardless of how the option is rendered in the select.

  ### Option States

  Custom options can respond to these states using data attributes:

  - `[data-highlighted]`: When the option is highlighted via keyboard or mouse hover
  - `[data-selected]`: When the option is currently selected

  Example of styling these states:

  ```heex
  <.select options={@countries}>
    <:option :let={{label, value}}>
      <div class={[
        # Base styles
        "flex items-center gap-2 px-3 py-2",
        "cursor-default select-none",

        # State styles using Tailwind's state selectors
        "in-data-highlighted:bg-zinc-100",
        "in-data-selected:font-medium",
      ]}>
        <.icon name={"flag-\#{String.downcase(value)}"} class="size-5" />
        <span>{label}</span>
      </div>
    </:option>
  </.select>
  ```

  ### Rich Content Examples

  #### User Selection with Avatar

  ```heex
  <.select field={f[:user]} options={@users} searchable>
    <:option :let={{label, value}}>
      <div class="flex items-center gap-3 p-2">
        <img src={"https://i.pravatar.cc/150?u=\#{value}"} class="size-8 rounded-full" />
        <div>
          <div class="font-medium">{label}</div>
          <div class="text-sm text-zinc-500">{user_email(value)}</div>
        </div>
      </div>
    </:option>
  </.select>
  ```

  #### Product Selection with Image and Price

  ```heex
  <.select field={f[:product]} options={@products} searchable>
    <:option :let={{label, value}}>
      <div class="flex items-center gap-3 p-2">
        <img src={product_image_url(value)} class="size-12 rounded-lg object-cover" />
        <div class="flex-1">
          <div class="font-medium">{label}</div>
          <div class="text-sm text-zinc-500">SKU: {value}</div>
        </div>
        <div class="font-medium text-zinc-900">
          {format_price(product_price(value))}
        </div>
      </div>
    </:option>
  </.select>
  ```

  ## Header and Footer Content

  The select component allows you to add custom content at the top and bottom of the listbox using
  the `:header` and `:footer` slots. This is useful for adding actions, filters, or additional information
  to the dropdown.

  ```heex
  <.select field={f[:product]} options={@products}>
    <:header class="p-2 border-b">
      <div class="flex gap-2">
        <.button size="xs" class="rounded-full" phx-click="filter" phx-value-type="all">All</.button>
        <.button size="xs" class="rounded-full" phx-click="filter" phx-value-type="active">Active</.button>
      </div>
    </:header>

    <:footer class="p-2 border-t">
      <.button type="button" size="sm" class="w-full" as="link" navigate={~p"/products/new"}>
        <.icon name="u-plus" class="size-4" /> Create new
      </.button>
    </:footer>
  </.select>
  ```

  Both slots support a `class` attribute for custom styling and maintain proper borders
  with the options list.

  ## Keyboard Support

  The select component supports keyboard navigation for accessibility:

  | Key | Element Focus | Description |
  |-----|---------------|-------------|
  | `Tab`/`Shift+Tab` | Toggle button | Moves focus to and from the select |
  | `Space`/`Enter` | Toggle button | Opens/closes the select |
  | `↑` | Toggle button | Opens select and highlights last option |
  | `↓` | Toggle button | Opens select and highlights first option |
  | `↑` | Option | Moves highlight to previous visible option |
  | `↓` | Option | Moves highlight to next visible option |
  | `Home` | Option | Moves highlight to first visible option |
  | `End` | Option | Moves highlight to last visible option |
  | `Enter`/`Space` | Option | Selects the highlighted option |
  | `Escape` | Any | Closes the select |
  | `Backspace` | Toggle button | Clears selection (when `clearable={true}`) |
  | Type characters | Toggle button/Option | Finds and highlights matching option |

  When `searchable={true}`, the search input receives focus when the select opens.

  For multiple selection mode (`multiple={true}`):
  - `Space`/`Enter` toggles the selection state of the highlighted option
  - Selected options can be deselected by highlighting and pressing `Space`/`Enter` again
  - The select stays open after selection for additional choices

  ## LiveView Integration

  The select component integrates with LiveView's real-time updates. When the options list changes
  in the LiveView's assigns, the component automatically updates to reflect these changes while
  maintaining the current selection state.

  ```heex
  <.form :let={f} for={@form} phx-change="validate">
    <.select
      field={f[:country]}
      options={@countries}
      label="Country"
      searchable
    />
  </form>
  ```

  The options list can be updated through any LiveView event:

  ```elixir
  def handle_event("add_country", %{"country" => params}, socket) do
    # Add a new country to the list
    updated_countries = [{params["name"], params["code"]} | socket.assigns.countries]
    {:noreply, assign(socket, :countries, updated_countries)}
  end

  def handle_info({:country_added, new_country}, socket) do
    # Handle a PubSub broadcast about a new country
    updated_countries = [new_country | socket.assigns.countries]
    {:noreply, assign(socket, :countries, updated_countries)}
  end
  ```

  The component handles these updates by:
  - Preserving the current selection if selected options still exist
  - Maintaining search state and filtered results
  - Keeping the select open/closed state
  - Retaining keyboard focus and navigation

  ## Common Use Cases

  ### Cascading Selects

  Here's how to implement dependent select fields, where selecting a value in one field
  affects the options in subsequent fields:

  ```heex
  <.form :let={f} for={@location} phx-change="update">
    <.select
      field={f[:country]}
      options={@countries}
      label="Country"
      placeholder="Select a country..."
      clearable
    />
    <.select
      field={f[:state]}
      options={@states}
      label="State"
      placeholder="Select a state..."
      disabled={@states == []}
      clearable
    />
    <.select
      field={f[:city]}
      options={@cities}
      label="City"
      placeholder="Select a city..."
      disabled={@cities == []}
    />
  </form>
  ```

  The LiveView updates the options based on selections:

  ```elixir
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       # Initial data - only countries are loaded
       countries: [{"United States", "US"}, {"Brazil", "BR"}],
       states: [],
       cities: [],
       location: to_form(%{})
     )}
  end

  def handle_event("update", %{"location" => params}, socket) do
    case params do
      # When country changes
      %{"country" => country} when country != "" ->
        states = fetch_states_for_country(country)
        {:noreply, assign(socket, states: states, cities: [], location: to_form(params))}

      # When state changes and country is selected
      %{"country" => country, "state" => state} when country != "" and state != "" ->
        cities = fetch_cities_for_state(state)
        {:noreply, assign(socket, cities: cities, location: to_form(params))}

      # When any field is cleared, reset subsequent fields
      _ ->
        {:noreply, assign(socket, states: [], cities: [], location: to_form(params))}
    end
  end
  ```

  This implementation:
  - Disables selects until their parent has a value
  - Uses `clearable` to reset the selection chain
  - Loads options when needed
  - Resets dependent fields when parent is cleared
  """

  use Fluxon.Component

  import Fluxon.Components.Form, only: [label: 1, error: 1]

  @styles %{
    # Native select styles
    native_select: [
      # Base appearance and layout
      "block w-full overflow-hidden rounded-base leading-[1.375rem]",
      "bg-no-repeat bg-[position:right_0.5rem_center] bg-[length:1rem]",
      "bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGZpbGw9Im5vbmUiIHZpZXdCb3g9IjAgMCAyNCAyNCI+CiAgPHBhdGggZmlsbD0iI0ExQTFBQSIgZmlsbC1ydWxlPSJldmVub2RkIiBkPSJNNS4yOTMgOC4yOTNhMSAxIDAgMCAxIDEuNDE0IDBMMTIgMTMuNTg2bDUuMjkzLTUuMjkzYTEgMSAwIDEgMSAxLjQxNGwtNiA2YTEgMSAwIDAgMS0xLjQxNCAwbC02LTZhMSAxIDAgMCAxIDAtMS40MTQiIGNsaXAtcnVsZT0iZXZlbm9kZCIvPgo8L3N2Zz4K')]",
      "appearance-none",

      # Colors and states
      "text-foreground placeholder:text-foreground-softest",
      "bg-input border border-input shadow-base",

      # Focus state
      "outline-hidden focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus transition-[box-shadow] duration-100",

      # Disabled state
      "disabled:bg-input-disabled disabled:opacity-70 disabled:shadow-none",

      # Placeholder styling
      "has-[[data-part=option-placeholder]:checked]:text-foreground-softest",

      # Error state using data-invalid
      "data-invalid:border-danger data-invalid:focus-visible:border-focus-danger data-invalid:focus-visible:ring-focus-danger"
    ],
    native_select_size: %{
      "xs" => "px-2 pr-6 h-7 sm:text-xs",
      "sm" => "px-2.5 pr-6 h-8 sm:text-sm",
      "md" => "px-3 pr-6 h-9 sm:text-sm",
      "lg" => "px-3 pr-6 h-10 sm:text-base",
      "xl" => "px-3 pr-6 h-11 sm:text-lg"
    },

    # Custom select styles
    root: [
      "group/root flex",
      "isolate **:focus:z-10",
      "*:border *:border-input",
      "*:first:rounded-l-base *:last:rounded-r-base",

      # Overlap border with outer prefix and suffix
      "*:data-[part=outer-prefix]:-mr-px",
      "*:data-[part=outer-suffix]:-ml-px",

      # Conditionally hide border for outer suffix with buttons
      "*:data-[part=outer-prefix]:has-data-[part=button]:border-0",
      "*:data-[part=outer-suffix]:has-data-[part=button]:border-0",

      # Overlap field border when using input group
      "[[data-part=input-group]>*_&]:-mr-px"
    ],
    toggle: [
      # Base layout and appearance
      "relative flex w-full items-center flex-nowrap",
      "text-left leading-[1.375rem]",
      "border shadow-base cursor-default",

      # Colors and states
      "bg-input text-foreground border-input",

      # Focus states
      "outline-hidden",
      "focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus transition-[box-shadow] duration-100",
      "data-focused:border-focus data-focused:ring-3 data-focused:ring-focus transition-[box-shadow] duration-100",

      # Disabled state
      "disabled:bg-input-disabled disabled:opacity-70 disabled:shadow-none",

      # Error state using data-invalid
      "data-invalid:border-danger data-invalid:focus-visible:border-focus-danger data-invalid:focus-visible:ring-focus-danger"
    ],
    toggle_size: %{
      "xs" => "gap-2 px-2 h-7 sm:text-xs",
      "sm" => "gap-2 px-2.5 h-8 sm:text-sm",
      "md" => "gap-2 px-3 h-9 sm:text-sm",
      "lg" => "gap-2 px-3 h-10 sm:text-base",
      "xl" => "gap-2 px-3 h-11 sm:text-lg"
    },
    toggle_label: [
      # Layout and sizing
      "w-full h-full min-h-[1.375rem] flex items-center",
      "truncate flex-1",

      # Text styling
      "text-foreground",

      # Empty state styling
      "[&>span:empty]:text-foreground-softest",
      "[&>span:empty:before]:content-[attr(data-placeholder)]"
    ],

    # Affix styles
    affix: [
      "flex items-center justify-center text-sm text-foreground-softer shrink-0"
    ],
    size: %{
      "xs" => %{
        toggle: "gap-2 px-2 h-7 sm:text-xs",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-4",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-4"
        ]
      },
      "sm" => %{
        toggle: "gap-2 px-2.5 h-8 sm:text-sm",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-4.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-4.5"
        ]
      },
      "md" => %{
        toggle: "gap-2 px-3 h-9 sm:text-sm",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-5"
        ]
      },
      "lg" => %{
        toggle: "gap-2 px-3 h-10 sm:text-base",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-5.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-5.5"
        ]
      },
      "xl" => %{
        toggle: "gap-2 px-3 h-11 sm:text-lg",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-6",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-6"
        ]
      }
    },

    # Icons
    chevron_icon: [
      "shrink-0 text-foreground-softest"
    ],
    chevron_icon_size: %{
      "xs" => "size-4",
      "sm" => "size-4.5",
      "md" => "size-5",
      "lg" => "size-5.5",
      "xl" => "size-6"
    },
    clear_icon: [
      "shrink-0 text-foreground-softest hover:text-foreground-soft rounded-xs",
      "cursor-pointer outline-hidden focus-visible:border focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus"
    ],
    clear_icon_size: %{
      "xs" => "size-4",
      "sm" => "size-4.5",
      "md" => "size-5",
      "lg" => "size-5.5",
      "xl" => "size-6"
    },

    # Search input
    search_container: [
      "sticky top-0 w-full border-b border-base",
      "flex items-center px-3 py-1"
    ],
    search_icon: [
      "flex items-center size-4 text-foreground-softest"
    ],
    search_input: [
      "row-start-1 col-start-1 w-full px-2 py-1.5",
      "md:text-sm shadow-none focus:ring-0 focus:outline-hidden",
      "bg-transparent text-foreground placeholder:text-foreground-softest",
      "autocomplete-off spellcheck-false autocapitalize-off autocorrect-off",
      "data-1p-ignore"
    ],

    # Listbox
    listbox: [
      # Display and positioning
      "[&:not([hidden])]:flex [&:not([hidden])]:flex-col",
      "fixed z-50 w-max rounded-base",

      # Appearance
      "bg-overlay border border-base shadow-base overflow-hidden"
    ],

    # Options
    options_list: [
      "overflow-y-auto grow p-1.5",
      "[&:not([hidden])]:grid [&:not([hidden])]:grid-cols-1"
    ],
    option: [
      # Layout and interaction
      "cursor-default text-sm rounded-base",
      "flex items-center justify-between py-2 px-2",

      # Colors and states
      "text-foreground focus:outline-hidden",
      "focus:bg-accent in-data-highlighted:bg-accent"
    ],
    option_group: [
      "hidden has-[>button:not([hidden])]:grid grid-cols-1",
      "mt-2 first:mt-0"
    ],
    option_group_label: [
      "px-2 py-1.5 text-sm font-medium text-foreground-softest"
    ],

    # Checkmark icon for selected options
    option_checkmark: [
      "hidden in-data-selected:block shrink-0 size-3.5 text-foreground"
    ],

    # Loading state
    loading: [
      "[&:not([hidden])]:flex gap-x-2 items-center justify-center",
      "p-2 text-sm text-foreground-softer"
    ],
    loading_spinner: [
      "animate-spin size-4"
    ],

    # Empty message
    empty_message: [
      "w-full p-4 text-foreground-softer text-sm"
    ],

    # Help text
    help_text: [
      "text-foreground-softer text-sm"
    ]
  }

  @doc """
  Renders a select component with rich features and full keyboard navigation support.

  This component provides a flexible way to build selection interfaces, from simple selects
  to complex searchable multi-select fields. It includes built-in form integration, error
  handling, and accessibility features.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: """
    The unique identifier for the select component. When not provided, a random ID will be generated.
    """

  attr :name, :any,
    doc: """
    The form name for the select. Required when not using the `field` attribute.
    For multiple selections, this will be automatically suffixed with `[]`.
    """

  attr :field, Phoenix.HTML.FormField,
    doc: """
    The form field to bind to. When provided, the component automatically handles
    value tracking, errors, and form submission.
    """

  attr :native, :boolean,
    default: false,
    doc: """
    When true, renders a native HTML select element instead of the custom select.
    This is useful for simple use cases or when native mobile behavior is preferred.
    Note that features like search and multiple selection are not available in native mode.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply to the select component. For the custom select,
    this affects the listbox container. For native selects, it applies to the select element.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The primary label for the select. This text is displayed above the select
    and is used for accessibility purposes.
    """

  attr :sublabel, :string,
    default: nil,
    doc: """
    Additional context displayed to the side of the main label. Useful for providing
    extra information without cluttering the main label.
    """

  attr :help_text, :string,
    default: nil,
    doc: """
    Help text to display below the select. This can provide additional context
    or instructions for using the select.
    """

  attr :description, :string,
    default: nil,
    doc: """
    A longer description to provide more context about the select. This appears
    below the label but above the select element.
    """

  attr :placeholder, :string,
    default: nil,
    doc: """
    Text to display when no option is selected. This text appears in the select
    toggle and helps guide users to make a selection.
    """

  attr :searchable, :boolean,
    default: false,
    doc: """
    When true, adds a search input to filter options. The search is case and
    diacritics insensitive. Only available for custom selects.
    """

  attr :disabled, :boolean,
    default: false,
    doc: """
    When true, disables the select component. Disabled selects cannot be
    interacted with and appear visually muted.
    """

  attr :size, :string,
    default: "md",
    values: ~w(xs sm md lg xl),
    doc: """
    Controls the size of the select component:
    - `"xs"`: Extra small size, suitable for compact UIs
    - `"sm"`: Small size, suitable for compact UIs
    - `"md"`: Default size, suitable for most use cases
    - `"lg"`: Large size, suitable for prominent selections
    - `"xl"`: Extra large size, suitable for hero sections
    """

  attr :search_input_placeholder, :string,
    default: "Search...",
    doc: """
    Placeholder text for the search input when `searchable={true}`.
    """

  attr :search_no_results_text, :string,
    default: "No results found for %{query}.",
    doc: """
    Text to display when no options match the search query. Use `%{query}` as a
    placeholder for the actual search term.
    """

  attr :search_threshold, :integer,
    default: 0,
    doc: """
    The minimum number of characters required before filtering options or performing
    server searches. This helps prevent unnecessary operations for very short queries.
    """

  attr :debounce, :integer,
    default: 300,
    doc: """
    The debounce time in milliseconds for server-side searches. This delays the `on_search`
    event to avoid excessive API calls while the user is typing.
    """

  attr :on_search, :string,
    default: nil,
    doc: """
    Name of the LiveView event to be triggered when searching. If provided, filtering
    will be handled server-side. The event receives `%{"query" => query}` as parameters.
    """

  attr :multiple, :boolean,
    default: false,
    doc: """
    When true, allows selecting multiple options. This changes the behavior to use
    checkboxes in the select and submits an array of values. Not available when
    `native={true}`.
    """

  attr :value, :any,
    doc: """
    The current selected value(s). For multiple selections, this should be a list.
    When using forms, this is automatically handled by the `field` attribute.
    """

  attr :errors, :list,
    default: [],
    doc: """
    List of error messages to display below the select. These are automatically
    handled when using the `field` attribute with form validation.
    """

  attr :options, :list,
    required: true,
    doc: """
    A list of options for the select. Can be provided in multiple formats:
    - List of strings: `["Option 1", "Option 2"]`
    - List of tuples: `[{"Label 1", "value1"}, {"Label 2", "value2"}]`
    - List of keyword pairs: `[key: "value"]`
    - Grouped options: `[{"Group 1", ["Option 1", "Option 2"]}, {"Group 2", [{"Label 1", "value1"}]}]`
    """

  attr :max, :integer,
    default: nil,
    doc: """
    Maximum number of options that can be selected when `multiple={true}`.
    When reached, other options become unselectable.
    """

  attr :clearable, :boolean,
    default: false,
    doc: """
    When true, this option displays a clear button to remove the current selection(s). It also allows users to clear the selection by clicking on the selected option in non-multiple selects.
    """

  attr :include_hidden, :boolean,
    default: true,
    doc: """
    When true, includes a hidden input for the select. This ensures the field
    is always present in form submissions, even when no option is selected.
    """

  attr :animation, :string,
    default: "transition duration-150 ease-in-out",
    doc: "The animation style for the custom select."

  attr :animation_enter, :string, default: "opacity-100 scale-100", doc: "CSS classes for the select enter animation."
  attr :animation_leave, :string, default: "opacity-0 scale-95", doc: "CSS classes for the select leave animation."

  attr :rest, :global,
    include: ~w(form),
    doc: """
    Additional attributes to pass to the select element.
    """

  slot :option,
    doc: """
    Optional slot for custom option rendering. When provided, each option can be
    fully customized with rich content.
    """ do
    attr :class, :any
  end

  slot :toggle,
    doc: """
    Optional slot for custom toggle rendering. This allows complete customization
    of the select's trigger button.
    """ do
    attr :class, :any
  end

  slot :header,
    doc: """
    Optional slot for custom header rendering. When provided, this content is shown
    in the top of the listbox.
    """ do
    attr :class, :any, doc: "Additional CSS classes to apply to the header."
  end

  slot :footer,
    doc: """
    Optional slot for custom footer rendering. When provided, this content is shown
    in the bottom of the listbox.
    """ do
    attr :class, :any, doc: "Additional CSS classes to apply to the footer."
  end

  # --- Affix Slots ---
  slot :inner_prefix,
    doc: """
    Content placed *inside* the select field's border, before the selected value display.
    Ideal for icons or short textual prefixes. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner prefix container."
  end

  slot :outer_prefix,
    doc: """
    Content placed *outside* and before the select field. Useful for buttons, dropdowns, or
    other interactive elements associated with the select's start. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer prefix container."
  end

  slot :inner_suffix,
    doc: """
    Content placed *inside* the select field's border, after the selected value display.
    Suitable for icons, clear buttons, or loading indicators. Takes precedence over the default chevron icon.
    Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner suffix container."
  end

  slot :outer_suffix,
    doc: """
    Content placed *outside* and after the select field. Useful for action buttons or
    other controls related to the select's end. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer suffix container."
  end

  # --- End Affix Slots ---

  def select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate(&1)))
    |> assign_new(:name, fn ->
      if assigns.multiple, do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> select()
  end

  def select(%{native: true} = assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || gen_id())
      |> assign(:styles, @styles)
      |> assign_new(:value, fn -> assigns[:value] end)

    ~H"""
    <div class="flex flex-col gap-y-2">
      <.label :if={@label} for={@id} sublabel={@sublabel} description={@description}>
        {@label}
      </.label>

      <select
        name={@name}
        id={@id}
        disabled={@disabled}
        data-invalid={@errors != []}
        class={
          merge([
            @styles[:native_select],
            @styles[:native_select_size][@size],
            @class
          ])
        }
        {@rest}
      >
        <option :if={@placeholder} value="" data-part="option-placeholder">{@placeholder}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>

      <div :if={@help_text} class={@styles[:help_text]}>{@help_text}</div>
      <.error :for={error <- @errors}>{error}</.error>
    </div>
    """
  end

  def select(assigns) do
    normalized_options = normalize_options(assigns.options)

    assigns =
      assigns
      |> assign(:toggle, if(assigns.toggle != [], do: List.first(assigns.toggle), else: nil))
      |> assign(:id, assigns.id || assigns.name)
      |> assign(:styles, @styles)
      |> assign(
        :value,
        (assigns[:value] || []) |> List.wrap() |> Enum.reject(&(&1 == "")) |> Enum.map(&Phoenix.HTML.html_escape/1)
      )
      |> assign(:normalized_options, normalized_options)
      |> assign_new(:toggle_label, fn
        %{normalized_options: _, value: []} ->
          nil

        %{normalized_options: normalized_options, value: value} ->
          value
          |> Enum.map(&find_option_label(normalized_options, &1))
          |> Enum.reject(&is_nil/1)
          |> Enum.join(", ")
      end)

    ~H"""
    <div
      phx-hook="Fluxon.Select"
      id={@id <> "-wrapper"}
      class={["relative w-full flex flex-col gap-y-2"]}
      data-multiple={@multiple}
      data-max-selections={@max}
      data-placeholder={@placeholder}
      data-searchable={@searchable}
      data-search-no-results-text={@search_no_results_text}
      data-search-threshold={@search_threshold}
      data-debounce-ms={@debounce}
      data-clearable={@clearable}
      data-on-search={@on_search}
    >
      <.label :if={@label} for={"#{@id}-toggle"} sublabel={@sublabel} description={@description}>
        {@label}
      </.label>

      <.select_toggle {assigns} />
      <.select_help_text {assigns} />
      <.select_errors {assigns} />
      <.select_hidden_inputs {assigns} />
      <.select_listbox {assigns} />
    </div>
    """
  end

  defp select_toggle(%{toggle: nil} = assigns) do
    ~H"""
    <div class="relative w-full">
      <div
        data-part="root"
        class={@styles[:root]}
        data-outer-prefix={!!(@outer_prefix != [])}
        data-outer-suffix={!!(@outer_suffix != [])}
        data-inner-prefix={!!(@inner_prefix != [])}
        data-inner-suffix={!!(@inner_suffix != [])}
      >
        <div
          :for={slot <- @outer_prefix}
          data-part="outer-prefix"
          class={
            merge([
              # Apply shadow only if the slot content doesn't already have from the button
              "not-has-data-[part=button]:shadow-base",

              # Adjust button rounding when used as an outer prefix
              "**:data-[part=button]:rounded-r-none!",
              "**:data-[part=button]:before:rounded-[inherit]!",
              # Apply base affix styles
              @styles[:affix],
              # Apply size-specific affix styles
              @styles[:size][@size][:affix],
              slot[:class]
            ])
          }
        >
          {render_slot(slot)}
        </div>

        <button
          id={@id <> "-toggle"}
          type="button"
          data-part="toggle"
          keep-data-focused
          tabindex="0"
          disabled={@disabled}
          data-invalid={@errors != []}
          class={
            merge([
              @styles[:toggle],
              @styles[:size][@size][:toggle]
            ])
          }
        >
          <div
            :for={slot <- @inner_prefix}
            data-part="inner-prefix"
            class={merge([@styles[:affix], @styles[:size][@size][:affix], slot[:class]])}
          >
            {render_slot(slot)}
          </div>

          <div class={@styles[:toggle_label]} id={@id <> "-toggle-label"}>
            <span data-placeholder={@placeholder} data-part="toggle-label" class="truncate">{@toggle_label}</span>
          </div>

          <.clear_icon :if={@clearable and !@disabled} hidden={!@clearable || @value == []} size={@size} styles={@styles} />

          <div
            :for={slot <- @inner_suffix}
            data-part="inner-suffix"
            class={merge([@styles[:affix], @styles[:size][@size][:affix], slot[:class]])}
          >
            {render_slot(slot)}
          </div>

          <.chevron_icon :if={@inner_suffix == []} size={@size} styles={@styles} />
        </button>

        <div
          :for={slot <- @outer_suffix}
          data-part="outer-suffix"
          class={
            merge([
              # Apply shadow only if the slot content doesn't already have from the button
              "not-has-data-[part=button]:shadow-base",

              # Adjust button rounding when used as an outer suffix
              "**:data-[part=button]:rounded-l-none!",
              "**:data-[part=button]:before:rounded-[inherit]!",
              # Apply base affix styles
              @styles[:affix],
              # Apply size-specific affix styles
              @styles[:size][@size][:affix],
              slot[:class]
            ])
          }
        >
          {render_slot(slot)}
        </div>
      </div>
    </div>
    """
  end

  defp select_help_text(assigns) do
    ~H"""
    <div :if={@help_text} class={@styles[:help_text]}>{@help_text}</div>
    """
  end

  defp select_errors(assigns) do
    ~H"""
    <.error :for={error <- @errors}>{error}</.error>
    """
  end

  defp select_hidden_inputs(assigns) do
    ~H"""
    <input :if={@multiple and @include_hidden} type="hidden" name={@name} />
    <select
      id={@id}
      name={@name}
      multiple={@multiple}
      class="hidden"
      aria-hidden="true"
      disabled={@disabled}
      data-part="select"
      {@rest}
    >
      <option value=""></option>
      {Phoenix.HTML.Form.options_for_select(@options, @value)}
    </select>
    """
  end

  defp select_listbox(assigns) do
    ~H"""
    <div
      hidden
      id={@id <> "-listbox"}
      role="listbox"
      data-part="listbox"
      class={merge([@styles[:listbox], @class])}
      data-animation={@animation}
      data-animation-enter={@animation_enter}
      data-animation-leave={@animation_leave}
    >
      <.search_input :if={@searchable} {assigns} />
      <.listbox_header {assigns} />
      <.loading styles={@styles} />
      <div data-part="empty-message" class={@styles[:empty_message]} hidden></div>
      <.options_list {assigns} />
      <.listbox_footer {assigns} />
    </div>
    """
  end

  defp search_input(assigns) do
    ~H"""
    <div class={@styles[:search_container]} phx-update="ignore" id={@id <> "-search-input"}>
      <div class={@styles[:search_icon]}><.search_icon /></div>
      <input
        tabindex="-1"
        class={@styles[:search_input]}
        type="text"
        data-part="search-input"
        autocomplete="off"
        data-1p-ignore
        spellcheck="false"
        autocapitalize="off"
        autocorrect="off"
        role="searchbox"
        aria-autocomplete="list"
        placeholder={@search_input_placeholder}
        inputmode="search"
      />
    </div>
    """
  end

  defp listbox_header(assigns) do
    ~H"""
    <div :for={slot <- @header} class={slot[:class]}>
      {render_slot(slot)}
    </div>
    """
  end

  defp loading(%{styles: styles} = assigns) do
    assigns = assign(assigns, :styles, styles)

    ~H"""
    <div data-part="loading" class={@styles[:loading]} hidden>
      <.loading_spinner styles={@styles} /> Loading...
    </div>
    """
  end

  defp loading_spinner(%{styles: styles} = assigns) do
    assigns = assign(assigns, :styles, styles)

    ~H"""
    <svg class={@styles[:loading_spinner]} xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      >
      </path>
    </svg>
    """
  end

  defp options_list(assigns) do
    ~H"""
    <div class={@styles[:options_list]} data-part="options-list">
      <.render_option_or_group
        :for={item <- @normalized_options}
        item={item}
        id={@id}
        value={@value}
        styles={@styles}
        option_slot={@option}
      />
    </div>
    """
  end

  defp render_option_or_group(assigns) do
    ~H"""
    <%= case @item do %>
      <% {:group, depth, group_label, children} -> %>
        <div data-part="group-container" class="contents [&:not(:has(button[data-part=option]:not([hidden])))]:hidden">
          <div
            data-part="group-label"
            class="pl-[calc(theme(spacing.2)+var(--depth)*theme(spacing.3))] pr-2 py-1.5 text-sm font-medium text-foreground-softest"
            style={"--depth: #{depth}"}
          >
            {group_label}
          </div>
          <%= for child <- children do %>
            <.render_option_or_group item={child} id={@id} value={@value} styles={@styles} option_slot={@option_slot} />
          <% end %>
        </div>
      <% {:option, depth, label, value} -> %>
        <.option_button
          id={@id}
          value={@value}
          label={label}
          option_value={value}
          depth={depth}
          styles={@styles}
          option_slot={@option_slot}
        />
    <% end %>
    """
  end

  defp option_button(assigns) do
    assigns =
      assign(
        assigns,
        :selected,
        Phoenix.HTML.html_escape(assigns.option_value) == Phoenix.HTML.html_escape(assigns.value)
      )

    ~H"""
    <button
      tabindex="-1"
      type="button"
      class="text-left"
      data-value={@option_value}
      data-label={@label}
      data-part="option"
      role="option"
      aria-selected={to_string(@selected)}
      data-selected={@selected}
      keep-data-highlighted
      style={"--depth: #{@depth}"}
    >
      {render_slot(@option_slot, {@label, @option_value}) ||
        default_option_with_depth(%{label: @label, depth: @depth, styles: @styles})}
    </button>
    """
  end

  defp default_option_with_depth(assigns) do
    ~H"""
    <div class={["pl-[calc(theme(spacing.2)+var(--depth)*theme(spacing.3))]", @styles[:option]]}>
      {@label}

      <svg class={@styles[:option_checkmark]} fill="none" viewBox="0 0 24 24">
        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 6 9 17l-5-5" />
      </svg>
    </div>
    """
  end

  defp listbox_footer(assigns) do
    ~H"""
    <div :for={slot <- @footer} class={slot[:class]}>
      {render_slot(slot)}
    </div>
    """
  end

  defp chevron_icon(%{styles: styles} = assigns) do
    assigns = assign(assigns, :styles, styles)

    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      class={merge([@styles[:chevron_icon], @styles[:chevron_icon_size][@size]])}
      viewBox="0 0 24 24"
    >
      <path
        fill="currentColor"
        fill-rule="evenodd"
        d="M5.293 8.293a1 1 0 0 1 1.414 0L12 13.586l5.293-5.293a1 1 0 1 1 1.414 1.414l-6 6a1 1 0 0 1-1.414 0l-6-6a1 1 0 0 1 0-1.414"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  defp clear_icon(%{styles: styles} = assigns) do
    assigns = assign(assigns, :styles, styles)

    ~H"""
    <div
      hidden={@hidden}
      data-part="clear"
      class={merge([@styles[:clear_icon], @styles[:clear_icon_size][@size]])}
      aria-label="Clear selection"
      role="button"
      tabindex="0"
    >
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="pointer-events-none">
        <path
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M6 18 18 6M6 6l12 12"
        />
      </svg>
    </div>
    """
  end

  defp search_icon(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" class="size-4 text-foreground-softest" viewBox="0 0 24 24">
      <path
        fill="currentColor"
        fill-rule="evenodd"
        d="M10 2a8 8 0 1 0 4.906 14.32l5.387 5.387a1 1 0 0 0 1.414-1.414l-5.387-5.387A8 8 0 0 0 10 2m-6 8a6 6 0 1 1 12 0 6 6 0 0 1-12 0"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  # Helper functions

  defp normalize_options(options) do
    normalize_options(options, 0)
  end

  defp normalize_options(options, depth) do
    Enum.map(options, fn
      {group_label, group_options} when is_list(group_options) ->
        # Create group at current depth, children are always at depth + 1
        {:group, depth, group_label, normalize_options(group_options, depth + 1)}

      option ->
        normalize_option(option, depth)
    end)
  end

  defp normalize_option({label, value}, depth), do: {:option, depth, label, value}
  defp normalize_option(value, depth) when is_binary(value), do: {:option, depth, value, value}

  # Handle keyword list format: [key: "Label", value: "val"]
  defp normalize_option([{:key, label}, {:value, value}], depth), do: {:option, depth, label, value}
  defp normalize_option([{:value, value}, {:key, label}], depth), do: {:option, depth, label, value}

  # Handle keyword list with additional options like disabled
  defp normalize_option(option, depth) when is_list(option) and is_tuple(hd(option)) do
    label = Keyword.fetch!(option, :key)
    value = Keyword.fetch!(option, :value)
    {:option, depth, label, value}
  end

  # Handle any other value (atoms, integers, etc.)
  defp normalize_option(value, depth), do: {:option, depth, to_string(value), to_string(value)}

  defp find_option_label(options, escaped_value) do
    Enum.find_value(options, fn
      {:group, _depth, _group_label, children} -> find_option_label(children, escaped_value)
      {:option, _depth, label, value} -> if Phoenix.HTML.html_escape(value) == escaped_value, do: label, else: nil
      _other -> nil
    end)
  end
end
