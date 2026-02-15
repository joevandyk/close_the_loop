defmodule Fluxon.Components.Autocomplete do
  @moduledoc ~S'''
  A modern, accessible autocomplete component with rich search capabilities.

  The autocomplete component provides a text input that filters a list of options as the user types,
  with keyboard navigation and accessibility features. It supports both client-side and server-side
  search capabilities, making it suitable for both small and large datasets.

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
  > | Clearing Selection | Supported | Supported |

  ## Basic Usage

  Simple autocomplete with a list of options:

  ```heex
  <.autocomplete
    name="country"
    options={[{"United States", "us"}, {"Canada", "ca"}]}
    placeholder="Search countries..."
  />
  ```

  The autocomplete component follows the same options API as [`Phoenix.HTML.Form.options_for_select/2`](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#options_for_select/2),
  supporting multiple formats:

  ```heex
  # List of strings
  <.autocomplete
    name="fruits"
    options={["Apple", "Banana", "Cherry", "Date", "Elderberry"]}
    placeholder="Search fruits..."
  />

  # List of tuples (label, value)
  <.autocomplete
    name="countries"
    options={[
      {"United States", "us"},
      {"Canada", "ca"},
      {"United Kingdom", "uk"},
      {"Germany", "de"}
    ]}
    placeholder="Search countries..."
  />

  # Keyword list
  <.autocomplete
    name="languages"
    options={[english: "en", spanish: "es", french: "fr", german: "de"]}
    placeholder="Search languages..."
  />

  # Grouped options
  <.autocomplete
    name="products"
    options={[
      {"Fruits", [{"Apple", "apple"}, {"Banana", "banana"}]},
      {"Vegetables", [{"Carrot", "carrot"}, {"Broccoli", "broccoli"}]},
      {"Grains", [{"Rice", "rice"}, {"Wheat", "wheat"}]}
    ]}
    placeholder="Search products..."
  />

  # Multi-level nested groups (flattened with visual indentation)
  <.autocomplete
    name="city"
    options={[
      {"Europe", [
        {"France", [{"Paris", 1}, {"Lyon", 2}, {"Marseille", 3}]},
        {"Italy", [{"Rome", 4}, {"Milan", 5}, {"Naples", 6}]}
      ]},
      {"Asia", [
        {"China", [{"Beijing", 7}, {"Shanghai", 8}, {"Guangzhou", 9}]}
      ]}
    ]}
    placeholder="Search cities..."
  />
  ```

  ## Size Variants

  The autocomplete component offers five size variants to accommodate different interface needs:

  ```heex
  <.autocomplete name="xs" size="xs" placeholder="Extra small" options={@options} />
  <.autocomplete name="sm" size="sm" placeholder="Small" options={@options} />
  <.autocomplete name="md" size="md" placeholder="Medium (Default)" options={@options} />
  <.autocomplete name="lg" size="lg" placeholder="Large" options={@options} />
  <.autocomplete name="xl" size="xl" placeholder="Extra large" options={@options} />
  ```

  Each size variant adjusts the height, padding, font size, and icon dimensions proportionally:

  - `"xs"`: Extra small (h-7), suitable for compact UIs and dense layouts
  - `"sm"`: Small (h-8), good for secondary or supporting inputs
  - `"md"`: Default (h-9), recommended for most use cases
  - `"lg"`: Large (h-10), suitable for prominent or important inputs
  - `"xl"`: Extra large (h-11), ideal for hero sections or primary actions

  ## Labels and Descriptions

  Provide context and guidance with comprehensive labeling options:

  ```heex
  # Basic label
  <.autocomplete
    name="language"
    label="Programming Language"
    placeholder="Select your favorite..."
    options={["Elixir", "Phoenix", "LiveView", "Ecto", "OTP"]}
  />

  # Label with sublabel
  <.autocomplete
    name="database"
    label="Database"
    sublabel="Required"
    placeholder="Choose database..."
    options={["PostgreSQL", "MySQL", "SQLite", "MongoDB"]}
  />

  # Label with description
  <.autocomplete
    name="framework"
    label="Framework"
    description="Choose the web framework for your project"
    placeholder="Search frameworks..."
    options={["Phoenix", "Rails", "Django", "Express", "FastAPI"]}
  />

  # Complete example with all text features
  <.autocomplete
    name="deployment"
    label="Deployment Platform"
    sublabel="Optional"
    description="This will determine your deployment configuration"
    help_text="Choose from our supported platforms"
    placeholder="Select platform..."
    options={["Fly.io", "Railway", "Heroku", "Render", "AWS"]}
  />
  ```

  ## Form Integration

  The autocomplete component integrates with Phoenix forms in two ways: using the `field` attribute for form integration
  or using the `name` attribute for standalone inputs.

  ### Using with Phoenix Forms (Recommended)

  Use the `field` attribute to bind the autocomplete to a form field:

  ```heex
  <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save">
    <.autocomplete
      field={f[:user_id]}
      label="Assigned To"
      options={@users}
    />
  </.form>
  ```

  Using the `field` attribute provides:
  - Automatic value handling from form data
  - Error handling and validation messages
  - Form submission with correct field names
  - Integration with changesets
  - Nested form data handling

  Complete example with changeset implementation:

  ```elixir
  defmodule MyApp.Task do
    use Ecto.Schema
    import Ecto.Changeset

    schema "tasks" do
      field :title, :string
      belongs_to :assigned_to, MyApp.User
      timestamps()
    end

    def changeset(task, attrs) do
      task
      |> cast(attrs, [:assigned_to_id, :title])
      |> validate_required([:assigned_to_id])
    end
  end

  # In your LiveView
  def mount(_params, _session, socket) do
    users = MyApp.Accounts.list_active_users() |> Enum.map(&{&1.name, &1.id})
    changeset = Task.changeset(%Task{}, %{})

    {:ok, assign(socket, users: users, form: to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <.form :let={f} for={@form} phx-change="validate">
      <.autocomplete
        field={f[:assigned_to_id]}
        options={@users}
        label="Assigned To"
        placeholder="Search users..."
      />
    </.form>
    """
  end

  def handle_event("validate", %{"task" => params}, socket) do
    changeset =
      %Task{}
      |> Task.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end
  ```

  ### Using Standalone Autocomplete

  For simpler cases or when not using Phoenix forms, use the `name` attribute:

  ```heex
  <.autocomplete
    name="search_user"
    options={@users}
    value={@user_id}
    placeholder="Search users..."
  />
  ```

  ## Input States

  The autocomplete component supports various input states for different use cases:

  ### Disabled State

  Disable the autocomplete to prevent user interaction:

  ```heex
  # Disabled empty autocomplete
  <.autocomplete
    name="disabled_empty"
    label="Unavailable Option"
    disabled
    placeholder="This option is currently disabled"
    options={["Option 1", "Option 2", "Option 3"]}
  />

  # Disabled with pre-selected value
  <.autocomplete
    name="disabled_selected"
    label="Read-only Selection"
    disabled
    value="Option 2"
    options={["Option 1", "Option 2", "Option 3"]}
  />
  ```

  ### Error States

  Display validation errors below the autocomplete:

  ```heex
  # Single error
  <.autocomplete
    name="single_error"
    label="Required Field"
    placeholder="This field is required"
    options={["Option 1", "Option 2", "Option 3"]}
    errors={["This field is required"]}
  />

  # Multiple errors
  <.autocomplete
    name="multiple_errors"
    label="Field with Multiple Issues"
    placeholder="Multiple validation errors"
    options={["Option 1", "Option 2", "Option 3"]}
    errors={["This field is required", "Please select a valid option"]}
  />
  ```

  ## Inner Affixes

  Use the `:inner_prefix` and `:inner_suffix` slots to add content *inside* the autocomplete's border.
  This is useful for icons, status indicators, or visual enhancements that should appear within the input field.

  ```heex
  # Search icon prefix
  <.autocomplete name="user_search" options={@users} placeholder="Search users...">
    <:inner_prefix>
      <.icon name="hero-magnifying-glass" class="size-4" />
    </:inner_prefix>
  </.autocomplete>

  # Email validation with status
  <.autocomplete name="email" options={@emails} placeholder="user@example.com">
    <:inner_prefix>
      <.icon name="hero-at-symbol" class="size-4" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-check-circle" class="size-4 text-green-500" />
    </:inner_suffix>
  </.autocomplete>

  # Location search with emoji
  <.autocomplete name="location" options={@locations} placeholder="City name">
    <:inner_prefix class="text-foreground-softest">📍</:inner_prefix>
  </.autocomplete>

  # Both inner affixes combined
  <.autocomplete name="comprehensive" options={@options} placeholder="Search...">
    <:inner_prefix>
      <.icon name="hero-magnifying-glass" class="size-4" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-information-circle" class="size-4" />
    </:inner_suffix>
  </.autocomplete>
  ```

  ## Outer Affixes

  Use the `:outer_prefix` and `:outer_suffix` slots to add content *outside* the autocomplete's border.
  This is ideal for buttons, labels, or interactive elements that complement the search functionality.

  ```heex
  # Simple text prefix
  <.autocomplete name="filtered" options={@options} placeholder="Search...">
    <:outer_prefix class="px-3 text-foreground-soft">Filter:</:outer_prefix>
  </.autocomplete>

  # Action button suffix
  <.autocomplete name="with_action" options={@options} placeholder="Search...">
    <:outer_suffix>
      <.button size="md">Search</.button>
    </:outer_suffix>
  </.autocomplete>

  # User invitation with send button
  <.autocomplete name="invite_user" options={@users} placeholder="Search users...">
    <:inner_prefix>
      <.icon name="hero-user-plus" class="size-4" />
    </:inner_prefix>
    <:outer_suffix>
              <.button variant="solid" color="primary" size="md">
        <.icon name="hero-paper-airplane" class="size-4" /> Invite
      </.button>
    </:outer_suffix>
  </.autocomplete>

  # All affixes combined
  <.autocomplete name="comprehensive" options={@options} placeholder="Search...">
    <:outer_prefix class="px-2">Search</:outer_prefix>
    <:inner_prefix>
      <.icon name="hero-magnifying-glass" class="size-4" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-information-circle" class="size-4" />
    </:inner_suffix>
    <:outer_suffix>
      <.button size="md">Go</.button>
    </:outer_suffix>
  </.autocomplete>
  ```

  > #### Size Matching with Affixes {: .important}
  >
  > When using buttons or other components within affix slots, ensure their `size` attribute matches
  > the autocomplete's `size` for proper visual alignment. For example, if the autocomplete is `size="lg"`,
  > use buttons with `size="lg"` as well.

  ## Search Behavior

  The autocomplete component offers flexible search strategies to handle different use cases and data sources.

  ### Client-side Search

  Client-side search provides immediate feedback as users type, filtering the provided options directly
  in the browser. This approach is ideal for small to medium datasets.

  #### Search Modes

  Control how options are matched against the search query:

  ```heex
  # Contains (default) - matches anywhere in the option
  <.autocomplete
    name="contains_search"
    label="Contains Search"
    search_mode="contains"
    placeholder="Type any part of the word..."
    options={["JavaScript", "TypeScript", "CoffeeScript", "ReScript"]}
  />

  # Starts with - matches only at the beginning
  <.autocomplete
    name="starts_with_search"
    label="Starts With Search"
    search_mode="starts-with"
    placeholder="Type beginning of word..."
    options={["JavaScript", "TypeScript", "CoffeeScript", "ReScript"]}
  />

  # Exact match - requires exact matching
  <.autocomplete
    name="exact_search"
    label="Exact Match"
    search_mode="exact"
    placeholder="Type exact match..."
    options={["JavaScript", "TypeScript", "CoffeeScript", "ReScript"]}
  />
  ```

  #### Search Thresholds

  Control when filtering begins based on the number of characters typed:

  ```heex
  # No threshold - search immediately
  <.autocomplete
    name="no_threshold"
    label="Immediate Search"
    search_threshold={0}
    placeholder="Search immediately..."
    options={["React", "Vue", "Angular", "Svelte", "Solid"]}
  />

  # 2 character threshold
  <.autocomplete
    name="threshold_2"
    label="2 Character Minimum"
    search_threshold={2}
    placeholder="Type 2+ characters..."
    options={["React", "Vue", "Angular", "Svelte", "Solid"]}
  />

  # 3 character threshold
  <.autocomplete
    name="threshold_3"
    label="3 Character Minimum"
    search_threshold={3}
    placeholder="Type 3+ characters..."
    options={["React", "Vue", "Angular", "Svelte", "Solid"]}
  />
  ```

  ### Server-side Search

  For large datasets, dynamic data sources, or when complex search logic is required, the component
  supports server-side search through LiveView integration:

  ```heex
  <.autocomplete
    name="movie"
    options={@movies}
    on_search="search_movies"
    search_threshold={2}
    placeholder="Type to search movies..."
  />
  ```

  In your LiveView, handle the search event to fetch and update the options:

  ```elixir
  def mount(_params, _session, socket) do
    {:ok, assign(socket, movies: [])}
  end

  def handle_event("search_movies", %{"query" => query}, socket) when byte_size(query) >= 2 do
    case MyApp.Movies.search(query) do
      {:ok, movies} ->
        {:noreply, assign(socket, movies: movies)}
      {:error, _reason} ->
        {:noreply, assign(socket, movies: [])}
    end
  end
  ```

  The component automatically manages the search state, including:
  - Debouncing requests to prevent excessive server calls
  - Displaying a loading indicator during searches
  - Maintaining the selected value while searching
  - Handling empty states and error conditions

  #### ⚠️ Selected Value and Initial Options

  When using server-side search with a selected value, ensure that the selected option is included
  in the initial options list:

  ```elixir
  def mount(_params, _session, socket) do
    featured_users = MyApp.Accounts.featured_users() |> Enum.map(&{&1.name, &1.id})
    selected_user = MyApp.Accounts.get_user!(2)

    # Good: Include the selected user in initial options
    {:ok, assign(socket,
      selected_user_id: selected_user.id,
      users: [{selected_user.name, selected_user.id} | featured_users]
    )}
  end
  ```

  ## Advanced Features

  ### Open on Focus

  By default, the listbox opens when users start typing. Enable `open_on_focus` to show options
  immediately when the input is focused:

  ```heex
  # Normal behavior - opens when typing
  <.autocomplete
    name="normal"
    label="Normal Behavior"
    placeholder="Type to see options..."
    options={["Option 1", "Option 2", "Option 3"]}
  />

  # Opens immediately on focus
  <.autocomplete
    name="open_on_focus"
    label="Open on Focus"
    open_on_focus
    placeholder="Click to see all options..."
    options={["Option 1", "Option 2", "Option 3"]}
  />
  ```

  ### Clearable Selection

  Add a clear button to allow users to easily reset their selection:

  ```heex
  # Not clearable (default)
  <.autocomplete
    name="not_clearable"
    label="Standard Autocomplete"
    placeholder="No clear button..."
    options={["Option 1", "Option 2", "Option 3"]}
  />

  # Clearable - adds × button when value is selected
  <.autocomplete
    name="clearable"
    label="Clearable Autocomplete"
    clearable
    placeholder="Has clear button when selected..."
    options={["Option 1", "Option 2", "Option 3"]}
  />

  # Clearable with initial value
  <.autocomplete
    name="clearable_with_value"
    label="Pre-selected with Clear"
    clearable
    value="Option 2"
    options={["Option 1", "Option 2", "Option 3"]}
  />
  ```

  ## Custom Option Rendering

  The autocomplete component supports rich, custom option rendering through the `:option` slot. Each option
  receives a tuple `{label, value}` that you can use to create sophisticated option displays:

  ```heex
  # User selection with avatars
  <.autocomplete
    name="users"
    label="Assign Task To"
    placeholder="Search team members..."
    options={[
      {"John Doe", "john"},
      {"Jane Smith", "jane"},
      {"Bob Johnson", "bob"},
      {"Alice Brown", "alice"}
    ]}
  >
    <:option :let={{label, value}}>
      <div class="flex items-center gap-3 p-2 rounded-lg in-data-highlighted:bg-zinc-100 in-data-selected:bg-blue-100">
        <div class="size-8 rounded-full bg-gradient-to-r from-blue-500 to-purple-500 flex items-center justify-center text-white text-sm font-bold">
          {String.first(label)}
        </div>
        <div>
          <div class="font-medium text-sm">{label}</div>
          <div class="text-xs text-zinc-500">@{value}</div>
        </div>
      </div>
    </:option>
  </.autocomplete>

  # Product selection with status and icons
  <.autocomplete
    name="products"
    label="Select Product"
    placeholder="Search inventory..."
    options={[
      {"MacBook Pro 16\"", "mbp16"},
      {"MacBook Air 13\"", "mba13"},
      {"iMac 24\"", "imac24"},
      {"Mac Studio", "studio"}
    ]}
  >
    <:option :let={{label, value}}>
      <div class="flex items-center justify-between p-2 rounded-lg in-data-highlighted:bg-zinc-100">
        <div class="flex items-center gap-3">
          <div class="size-10 rounded bg-zinc-100 flex items-center justify-center">
            <.icon name="hero-computer-desktop" class="size-5 text-zinc-600" />
          </div>
          <div>
            <div class="font-medium text-sm">{label}</div>
            <div class="text-xs text-zinc-500">Model: {value}</div>
          </div>
        </div>
        <div class="text-xs text-green-600 font-medium">In Stock</div>
      </div>
    </:option>
  </.autocomplete>
  ```

  ## Header and Footer Content

  Add custom content at the top and bottom of the listbox using the `:header` and `:footer` slots:

  ```heex
  # Simple header
  <.autocomplete field={f[:category]} options={@categories}>
    <:header class="p-3 border-b border-base bg-zinc-50">
      <div class="text-sm font-medium text-zinc-700">Popular Categories</div>
    </:header>
  </.autocomplete>

  # Footer with action button
  <.autocomplete field={f[:item]} options={@items}>
    <:footer class="p-2 border-t border-base">
      <.button type="button" size="sm" class="w-full">
        <.icon name="hero-plus" class="size-4" /> Create New Item
      </.button>
    </:footer>
  </.autocomplete>

  # Both header and footer with filters
  <.autocomplete field={f[:product]} options={@products}>
    <:header class="p-2 border-b border-base">
      <div class="flex gap-2">
        <.button size="xs" class="rounded-full" phx-click="filter" phx-value-type="all">All</.button>
        <.button size="xs" class="rounded-full" phx-click="filter" phx-value-type="active">Active</.button>
        <.button size="xs" class="rounded-full" phx-click="filter" phx-value-type="draft">Draft</.button>
      </div>
    </:header>
    <:footer class="p-2 border-t border-base">
      <.button type="button" size="sm" class="w-full" variant="tertiary">
        <.icon name="hero-plus" class="size-4" /> Add New Product
      </.button>
    </:footer>
  </.autocomplete>
  ```

  ## Empty State Customization

  Customize the message displayed when no options match the search query:

  ```heex
  # Default empty state
  <.autocomplete
    name="default_empty"
    label="Default Empty Message"
    no_results_text="No results found for '%{query}'"
    placeholder="Search to see default message..."
    options={["Apple", "Banana", "Cherry"]}
  />

  # Custom empty state with icon and actions
  <.autocomplete
    name="custom_empty"
    label="Custom Empty State"
    placeholder="Search to see custom empty state..."
    options={["Apple", "Banana", "Cherry"]}
  >
    <:empty_state>
      <div class="p-4 text-center">
        <div class="text-zinc-400">
          <.icon name="hero-face-frown" class="size-8 mx-auto mb-2" />
          <p class="font-medium">No results found</p>
          <p class="text-sm">Try a different search term or check your spelling</p>
        </div>
      </div>
    </:empty_state>
  </.autocomplete>
  ```

  ## Keyboard Support

  The autocomplete component provides comprehensive keyboard navigation:

  | Key | Element Focus | Description |
  |-----|---------------|-------------|
  | `Tab`/`Shift+Tab` | Input | Moves focus to and from the input |
  | `↑` | Input | Opens listbox and highlights last option |
  | `↓` | Input | Opens listbox and highlights first option |
  | `↑` | Option | Moves highlight to previous visible option |
  | `↓` | Option | Moves highlight to next visible option |
  | `Enter` | Option | Selects the highlighted option |
  | `Escape` | Any | Closes the listbox |
  | Type characters | Input | Filters options based on input |

  ## Real-world Examples

  ### Task Assignment Interface

  ```heex
  <.autocomplete
    name="assigned_user"
    label="Assign Task To"
    description="Select a team member to assign this task"
    placeholder="Search by name or email..."
    clearable
    search_threshold={2}
    options={[
      {"John Doe (john@example.com)", "john"},
      {"Jane Smith (jane@example.com)", "jane"},
      {"Bob Johnson (bob@example.com)", "bob"}
    ]}
  >
    <:inner_prefix>
      <.icon name="hero-magnifying-glass" class="size-4" />
    </:inner_prefix>
    <:option :let={{label, value}}>
      <div class="flex items-center gap-3 p-2">
        <div class="size-8 rounded-full bg-blue-500 flex items-center justify-center text-white text-sm font-bold">
          {String.first(label)}
        </div>
        <div class="flex-1">
          <div class="font-medium text-sm">{String.split(label, " (") |> hd()}</div>
          <div class="text-xs text-zinc-500">
            {String.split(label, "(") |> Enum.at(1, "") |> String.replace(")", "")}
          </div>
        </div>
      </div>
    </:option>
  </.autocomplete>
  ```

  ### E-commerce Product Search

  ```heex
  <.autocomplete
    name="product_search"
    label="Product Catalog"
    sublabel="Required"
    description="Choose a product from our catalog"
    help_text="Start typing to search through 1000+ products"
    placeholder="Search products..."
    clearable
    search_threshold={3}
    options={[
      {"Electronics",
       [
         {"iPhone 15 Pro", "iphone15pro"},
         {"MacBook Air M2", "macbook-air-m2"},
         {"AirPods Pro 2", "airpods-pro-2"}
       ]},
      {"Clothing",
       [
         {"Men's T-Shirt", "mens-tshirt"},
         {"Women's Jeans", "womens-jeans"},
         {"Winter Jacket", "winter-jacket"}
       ]}
    ]}
  >
    <:inner_prefix>
      <.icon name="hero-magnifying-glass" class="size-4" />
    </:inner_prefix>
    <:outer_suffix>
      <.button size="md">Browse</.button>
    </:outer_suffix>
    <:header class="p-2 border-b border-base bg-zinc-50">
      <div class="text-sm text-zinc-600">🔥 Popular products shown first</div>
    </:header>
    <:footer class="p-2 border-t border-base">
      <.button type="button" size="sm" class="w-full" variant="ghost">
        Can't find what you're looking for? <span class="text-blue-600">Contact us</span>
      </.button>
    </:footer>
  </.autocomplete>
  ```

  ### Server-side User Search

  ```elixir
  defmodule MyApp.UsersLive do
    use MyAppWeb, :live_view

    def mount(_params, _session, socket) do
      {:ok, socket |> assign(users: fetch_users()) |> assign(form: to_form(%{}, as: :search))}
    end

    def render(assigns) do
      ~H"""
      <.form :let={f} for={@form} phx-change="search">
        <.autocomplete field={f[:user_id]} options={user_options(@users)} on_search="search_users" clearable>
          <:option :let={{label, value}}>
            <div class="flex items-center gap-3 p-2 rounded-lg in-data-highlighted:bg-zinc-100 in-data-selected:bg-blue-100">
              <img src={user_by_id(value, @users)["image"]} class="size-8 rounded-full" />
              <div>
                <div class="font-medium text-sm">{label}</div>
                <div class="text-xs text-zinc-500">{user_by_id(value, @users)["email"]}</div>
              </div>
            </div>
          </:option>
          <:empty_state>
            <div class="p-4 text-center text-zinc-500">
              <p>No matching users found</p>
              <p class="text-sm">Try searching by name or email</p>
            </div>
          </:empty_state>
        </.autocomplete>
      </.form>
      """
    end

    def handle_event("search_users", %{"query" => query}, socket) do
      {:noreply, assign(socket, users: fetch_users(query))}
    end

    def handle_event("search", _params, socket), do: {:noreply, socket}

    defp fetch_users(query \\ "") do
      case Req.get("https://dummyjson.com/users/search", params: [limit: 10, q: query]) do
        {:ok, %{body: %{"users" => users}}} -> users
        _ -> []
      end
    end

    defp user_options(users), do: Enum.map(users, &{&1["firstName"] <> " " <> &1["lastName"], &1["id"]})
    defp user_by_id(id, users), do: Enum.find(users, &(&1["id"] == id))
  end
  ```
  '''
  use Fluxon.Component

  import Fluxon.Components.Form, only: [label: 1, error: 1]

  @styles %{
    root: [
      "group/root flex",
      "isolate **:has-focus:z-10",
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
    field: [
      # Base layout and appearance
      "group relative flex items-center w-full bg-input text-foreground shadow-base cursor-text",

      # Focus state
      "has-[input:focus-visible]:border-focus has-[input:focus-visible]:ring-3 has-[input:focus-visible]:ring-focus transition-[box-shadow] duration-100",

      # Error/invalid state
      "data-invalid:border-danger has-[input:focus-visible]:data-invalid:border-focus-danger has-[input:focus-visible]:data-invalid:ring-focus-danger",

      # Disabled state
      "has-[input:disabled]:shadow-none has-[input:disabled]:pointer-events-none has-[input:disabled]:bg-input-disabled has-[input:disabled]:text-foreground-soft"
    ],
    input: [
      "w-full bg-transparent bg-none outline-hidden placeholder:text-foreground-softest"
    ],
    affix: [
      # Adjusted colors from Input
      "flex items-center justify-center text-sm text-foreground-softer shrink-0"
    ],
    size: %{
      "xs" => %{
        field: "gap-2 px-2 h-7",
        input: "sm:text-xs",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-4",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-4"
        ]
      },
      "sm" => %{
        field: "gap-2 px-2.5 h-8",
        input: "sm:text-sm",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-4.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-4.5"
        ]
      },
      "md" => %{
        field: "gap-2 px-3 h-9",
        input: "sm:text-sm",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-5"
        ]
      },
      "lg" => %{
        field: "gap-2 px-3 h-10",
        input: "sm:text-base",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-5.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-5.5"
        ]
      },
      "xl" => %{
        field: "gap-2 px-3 h-11",
        input: "sm:text-lg",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-6",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-6"
        ]
      }
    },
    listbox: [
      "[&:not([hidden])]:flex [&:not([hidden])]:flex-col",
      "fixed z-50 w-full rounded-base mt-1",
      "bg-overlay border border-base",
      "shadow-base overflow-hidden"
    ],
    listbox_option: [
      "cursor-default text-sm rounded-base",
      "flex items-center justify-between",
      "py-2 pr-2 pl-[calc(theme(spacing.2)+var(--depth)*theme(spacing.3))]",
      "text-foreground",
      "in-data-highlighted:bg-accent"
    ]
  }

  @doc """
  Renders an autocomplete component with rich search capabilities and full keyboard navigation support.

  This component provides a flexible way to build search interfaces with real-time filtering,
  server-side search capabilities, and rich option rendering. It includes built-in form integration,
  error handling, and accessibility features.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: """
    The unique identifier for the autocomplete component.
    """

  attr :name, :any,
    doc: """
    The form name for the autocomplete. Required when not using the `field` attribute.
    """

  attr :field, Phoenix.HTML.FormField,
    doc: """
    The form field to bind to. When provided, the component automatically handles
    value tracking, errors, and form submission.
    """

  attr :class, :any,
    default: nil,
    doc: """
    Additional CSS classes to apply directly to the autocomplete's field wrapper element
    (`label[data-part=field]` or `div[data-part=field]`). Allows for custom styling or layout
    adjustments of the core input container.
    """

  attr :label, :string,
    default: nil,
    doc: """
    The primary label for the autocomplete. This text is displayed above the input
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
    Help text to display below the autocomplete. This can provide additional context
    or instructions for using the input.
    """

  attr :description, :string,
    default: nil,
    doc: """
    A longer description to provide more context about the autocomplete. This appears
    below the label but above the input element.
    """

  attr :placeholder, :string,
    default: nil,
    doc: """
    Text to display in the input when empty. This text appears in the search input
    and helps guide users to start typing.
    """

  attr :autofocus, :boolean,
    default: false,
    doc: """
    Whether the input should have the autofocus attribute.
    """

  attr :disabled, :boolean,
    default: false,
    doc: """
    When true, disables the autocomplete component. Disabled inputs cannot be
    interacted with and appear visually muted.
    """

  attr :size, :string,
    default: "md",
    values: ~w(xs sm md lg xl),
    doc: """
    Controls the size of the autocomplete component:
    - `"xs"`: Extra small size, suitable for compact UIs
    - `"sm"`: Small size, suitable for compact UIs
    - `"md"`: Default size, suitable for most use cases
    - `"lg"`: Large size, suitable for prominent inputs
    - `"xl"`: Extra large size, suitable for hero sections
    """

  attr :search_threshold, :integer,
    default: 0,
    doc: """
    The minimum number of characters required before showing suggestions.
    This helps prevent unnecessary searches and improves performance.
    """

  attr :no_results_text, :string,
    default: "No results found for \"%{query}\".",
    doc: """
    Text to display when no options match the search query. Use `%{query}` as a
    placeholder for the actual search term. This is only shown when no custom
    empty state is provided.
    """

  attr :on_search, :string,
    default: nil,
    doc: """
    Name of the LiveView event to be triggered when searching. If provided, filtering
    will be handled server-side. The event receives `%{"query" => query}` as parameters.
    """

  attr :debounce, :integer,
    default: 200,
    doc: """
    The debounce time in milliseconds for server-side searches. This delays the `on_search`
    event until the user stops typing for the specified duration.
    """

  attr :search_mode, :string,
    default: "contains",
    values: ~w(contains starts-with exact),
    doc: """
    The mode of the client-side search to use for the autocomplete:
    - `"contains"`: Match if option contains the search query (default)
    - `"starts-with"`: Match if option starts with the search query
    - `"exact"`: Match only if option exactly matches the search query
    """

  attr :open_on_focus, :boolean,
    default: false,
    doc: """
    When true, the listbox opens when the input is focused, even if no search
    query has been entered yet.
    """

  attr :value, :any,
    doc: """
    The current selected value of the autocomplete. When using forms, this is
    automatically handled by the `field` attribute.
    """

  attr :errors, :list,
    default: [],
    doc: """
    List of error messages to display below the autocomplete. These are automatically
    handled when using the `field` attribute with form validation.
    """

  attr :options, :list,
    required: true,
    doc: """
    A list of options for the autocomplete. Can be provided in multiple formats:
    - List of strings: `["Option 1", "Option 2"]`
    - List of tuples: `[{"Label 1", "value1"}, {"Label 2", "value2"}]`
    - List of keyword pairs: `[key: "value"]`
    """

  attr :animation, :string,
    default: "transition duration-150 ease-in-out",
    doc: """
    The animation style for the listbox. This controls how the listbox appears
    and disappears when opening/closing.
    """

  attr :animation_enter, :string,
    default: "opacity-100 scale-100",
    doc: """
    CSS classes applied to the listbox when it enters (opens).
    """

  attr :animation_leave, :string,
    default: "opacity-0 scale-95",
    doc: """
    CSS classes applied to the listbox when it leaves (closes).
    """

  attr :clearable, :boolean,
    default: false,
    doc: """
    When true, displays a clear button to remove the current selection.
    This allows users to easily reset the input value without having to delete it manually.
    """

  attr :rest, :global,
    include: ~w(form),
    doc: """
    Additional attributes to pass to the form element element.
    """

  # --- Affix Slots ---
  slot :inner_prefix,
    doc: """
    Content placed *inside* the input field's border, before the text entry area.
    Ideal for icons or short textual prefixes. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner prefix container."
  end

  slot :outer_prefix,
    doc: """
    Content placed *outside* and before the input field. Useful for buttons, dropdowns, or
    other interactive elements associated with the input's start. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer prefix container."
  end

  slot :inner_suffix,
    doc: """
    Content placed *inside* the input field's border, after the text entry area.
    Suitable for icons, clear buttons, or loading indicators. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner suffix container."
  end

  slot :outer_suffix,
    doc: """
    Content placed *outside* and after the input field. Useful for action buttons or
    other controls related to the input's end. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer suffix container."
  end

  # --- End Affix Slots ---

  slot :option,
    doc: """
    Optional slot for custom option rendering. When provided, each option can be
    fully customized with rich content. The slot receives a tuple `{label, value}`
    for each option.
    """ do
    attr :class, :any, doc: "Additional CSS classes to apply to the option container."
  end

  slot :empty_state,
    doc: """
    Optional slot for custom empty state rendering. When provided, this content is shown
    instead of the default "no results" message when no options match the search query.
    """ do
    attr :class, :any, doc: "Additional CSS classes to apply to the empty state container."
  end

  slot :header,
    doc: """
    Optional slot for custom header rendering. When provided, this content is shown
    in the top of the listbox.
    """ do
    attr :class, :any, doc: "Additional CSS classes to apply to the header container."
  end

  slot :footer,
    doc: """
    Optional slot for custom footer rendering. When provided, this content is shown
    in the bottom of the listbox.
    """ do
    attr :class, :any, doc: "Additional CSS classes to apply to the footer container."
  end

  def autocomplete(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> autocomplete()
  end

  def autocomplete(assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || assigns.name)
      |> assign(:styles, @styles)
      |> update(:options, &normalize_options(&1))
      |> assign_new(:value, fn -> assigns[:value] end)
      |> assign_new(:input_value, &get_input_value(&1))

    ~H"""
    <div
      phx-hook="Fluxon.Autocomplete"
      data-component="Autocomplete"
      id={@id <> "-autocomplete"}
      class={["relative w-full flex flex-col gap-y-2"]}
      data-search-threshold={@search_threshold}
      data-search-mode={@search_mode}
      data-no-results-text={@no_results_text}
      data-on-search={@on_search}
      data-open-on-focus={@open_on_focus}
      data-clearable={@clearable}
      data-debounce-ms={@debounce}
    >
      <.label :if={@label} for={@id} sublabel={@sublabel} description={@description}>
        {@label}
      </.label>

      <input
        type="text"
        hidden
        id={@id <> "-value"}
        name={@name}
        value={@value}
        disabled={@disabled}
        data-part="hidden-input"
        {@rest}
      />

      <div class="relative w-full">
        <div
          data-part="field-root"
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
                # Apply size-specific affix styles - Need to get size atom first
                # @styles[:size][String.to_existing_atom(@size)][:affix],
                slot[:class]
              ])
            }
          >
            {render_slot(slot)}
          </div>

          <.autocomplete_input {assigns} />

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
                # Apply size-specific affix styles - Need to get size atom first
                # @styles[:size][String.to_existing_atom(@size)][:affix],
                slot[:class]
              ])
            }
          >
            {render_slot(slot)}
          </div>
        </div>
        <.autocomplete_listbox {assigns} />
      </div>

      <div :if={@help_text} class="text-foreground-softer text-sm">{@help_text}</div>
      <.error :for={error <- @errors}>{error}</.error>
    </div>
    """
  end

  # Internal function components
  defp autocomplete_input(assigns) do
    ~H"""
    <label
      for={@id}
      data-part="field"
      data-invalid={@errors != []}
      class={merge([@styles[:field], @styles[:size][@size][:field], @class])}
    >
      <div
        :for={slot <- @inner_prefix}
        data-part="inner-prefix"
        class={merge([@styles[:affix], @styles[:size][@size][:affix], slot[:class]])}
      >
        {render_slot(slot)}
      </div>

      <input
        name="query"
        type="text"
        tabindex="0"
        id={@id}
        value={@input_value}
        data-part="input"
        disabled={@disabled}
        placeholder={@placeholder}
        autofocus={@autofocus}
        autocomplete="off"
        spellcheck="false"
        autocapitalize="off"
        data-1p-ignore
        role="combobox"
        aria-expanded="false"
        aria-autocomplete="list"
        aria-controls={@id <> "-listbox"}
        aria-haspopup="listbox"
        aria-label={@label}
        aria-owns={@id <> "-listbox"}
        class={merge([@styles[:input], @styles[:size][@size][:input]])}
      />

      <.clear_icon :if={@clearable and !@disabled} enabled={@value != nil && @value != ""} styles={@styles} size={@size} />

      <div
        :for={slot <- @inner_suffix}
        data-part="inner-suffix"
        class={merge([@styles[:affix], @styles[:size][@size][:affix], slot[:class]])}
      >
        {render_slot(slot)}
      </div>
    </label>
    """
  end

  defp autocomplete_listbox(assigns) do
    ~H"""
    <div
      hidden
      id={@id <> "-listbox"}
      role="listbox"
      aria-label="List of options"
      data-part="listbox"
      class={merge([@styles[:listbox], @class])}
      data-animation={@animation}
      data-animation-enter={@animation_enter}
      data-animation-leave={@animation_leave}
    >
      <div :for={slot <- @header} class={slot[:class]}>
        {render_slot(slot)}
      </div>

      <.loading />
      <.empty_state {assigns} />
      <.options_list {assigns} />

      <div :for={slot <- @footer} class={slot[:class]}>
        {render_slot(slot)}
      </div>
    </div>
    """
  end

  defp loading(assigns) do
    ~H"""
    <div
      data-part="loading"
      class="[&:not([hidden])]:flex gap-x-2 items-center justify-center p-2 text-sm text-foreground-softer"
      hidden
    >
      <.loading_spinner /> Loading...
    </div>
    """
  end

  defp loading_spinner(assigns) do
    ~H"""
    <svg class="animate-spin size-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
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

  defp empty_state(assigns) do
    ~H"""
    <div
      phx-update="ignore"
      id={@id <> "-empty-message"}
      data-part="empty-message"
      class="w-full p-4 text-foreground-softer text-sm"
      hidden
    >
    </div>

    <div :for={slot <- @empty_state} :if={@empty_state != []} data-part="empty-state" class={slot[:class]} hidden>
      {render_slot(slot)}
    </div>
    """
  end

  defp options_list(assigns) do
    ~H"""
    <div
      data-part="options-list"
      class="overflow-y-auto grow p-1.5 [&:not([hidden])]:grid [&:not([hidden])]:grid-cols-1"
      tabindex="-1"
    >
      <%= for item <- @options do %>
        <.render_option_or_group item={item} id={@id} value={@value} styles={@styles} option_slot={@option} />
      <% end %>
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
            class="pl-[calc(theme(spacing.2)+var(--depth)*theme(spacing.3))] pr-2 py-1.5 text-sm font-medium text-foreground-softer"
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
          option={{label, value}}
          depth={depth}
          styles={@styles}
          option_slot={@option_slot}
        />
    <% end %>
    """
  end

  defp option_button(%{option: {label, value}} = assigns) do
    assigns =
      assigns
      |> assign(:option_label, label)
      |> assign(:option_value, value)
      |> assign_new(:depth, fn -> 0 end)
      |> assign(
        :selected,
        Phoenix.HTML.html_escape(value) == Phoenix.HTML.html_escape(assigns.value)
      )

    ~H"""
    <button
      tabindex="-1"
      type="button"
      class="text-left"
      style={"--depth: #{@depth}"}
      data-value={@option_value}
      data-label={@option_label}
      data-part="option"
      role="option"
      aria-selected={to_string(@selected)}
      data-selected={@selected}
      keep-data-highlighted
    >
      {render_slot(@option_slot, {@option_label, @option_value}) ||
        default_option_slot(%{label: @option_label, styles: @styles})}
    </button>
    """
  end

  defp default_option_slot(assigns) do
    ~H"""
    <div class={merge(@styles[:listbox_option])}>
      {@label}

      <svg class="hidden in-data-selected:block shrink-0 size-3.5 text-foreground" fill="none" viewBox="0 0 24 24">
        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 6 9 17l-5-5" />
      </svg>
    </div>
    """
  end

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

  defp get_input_value(%{options: options, value: value}) do
    escaped_value = Phoenix.HTML.html_escape(value)
    find_option_label(options, escaped_value) || value
  end

  defp find_option_label(options, escaped_value) do
    Enum.find_value(options, fn
      {:option, _depth, label, v} ->
        if Phoenix.HTML.html_escape(v) == escaped_value, do: label, else: nil

      {:group, _depth, _label, children} ->
        find_option_label(children, escaped_value)

      _other ->
        nil
    end)
  end

  defp clear_icon(assigns) do
    ~H"""
    <button
      type="button"
      data-part="clear-button"
      class={[
        "data-enabled:visible invisible",
        "items-center justify-center",
        "shrink-0",
        "text-foreground-softer hover:text-foreground-softest",
        "cursor-pointer"
      ]}
      aria-label="Clear selection"
      role="button"
      data-enabled={@enabled}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        class={
          merge([
            # Use standardized icon sizes that match other components
            case @size do
              "xs" -> "size-4"
              "sm" -> "size-4.5"
              "md" -> "size-5"
              "lg" -> "size-5.5"
              "xl" -> "size-6"
              _ -> "size-5"
            end,
            "pointer-events-none"
          ])
        }
      >
        <path
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M6 18 18 6M6 6l12 12"
        />
      </svg>
    </button>
    """
  end
end
