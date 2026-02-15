defmodule Fluxon.Components.DatePicker do
  @moduledoc """
  A date picker component with calendar-based date selection and time support.

  The date picker component provides calendar-based date selection with support for single dates,
  multiple dates, and date ranges. It includes time picking capabilities, configurable sizing,
  and affix slots for UI customization.

  ## Basic Usage

  The component provides three functions for different date selection modes:

  ```heex
  <!-- Single date selection -->
  <.date_picker
    name="appointment"
    label="Appointment Date"
    placeholder="Select a date"
  />

  <!-- Date and time selection -->
  <.date_time_picker
    name="meeting"
    label="Meeting Time"
    time_format="12"
    placeholder="Select date and time"
  />

  <!-- Date range selection -->
  <.date_range_picker
    start_name="check_in"
    end_name="check_out"
    label="Stay Period"
    placeholder="Select date range"
  />
  ```

  ### Common Examples

  Examples for typical use cases:

  ```heex
  <!-- Simple appointment booking -->
  <.date_picker
    name="appointment"
    label="Appointment Date"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 60)}
    placeholder="Select your appointment date"
  />

  <!-- Hotel booking with date range -->
  <.date_range_picker
    start_name="check_in"
    end_name="check_out"
    label="Stay Duration"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 365)}
    placeholder="Select your dates"
  />

  <!-- Meeting scheduler with time -->
  <.date_time_picker
    name="meeting"
    label="Meeting Schedule"
    time_format="12"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 30)}
    placeholder="Choose meeting time"
  />
  ```

  ## Size Variants

  Five size variants are available:

  ```heex
  <.date_picker name="xs" size="xs" label="Compact Date" placeholder="Extra small" />
  <.date_picker name="sm" size="sm" label="Small Date" placeholder="Small" />
  <.date_picker name="md" size="md" label="Standard Date" placeholder="Medium (Default)" />
  <.date_picker name="lg" size="lg" label="Prominent Date" placeholder="Large" />
  <.date_picker name="xl" size="xl" label="Hero Date" placeholder="Extra large" />
  ```

  Size variants adjust height, padding, font size, and icon dimensions:

  - `"xs"` (h-7): Compact layouts, dashboard widgets
  - `"sm"` (h-8): Secondary inputs, sidebar forms
  - `"md"` (h-9): **Default size** - standard applications
  - `"lg"` (h-10): Prominent inputs, primary actions
  - `"xl"` (h-11): Hero sections, landing pages

  ### Context-Specific Sizing

  ```heex
  <!-- Dashboard widget - compact -->
  <.date_picker
    name="dashboard_filter"
    size="xs"
    label="Filter Date"
    placeholder="Filter by date..."
  />

  <!-- Main form - standard -->
  <.date_picker
    name="main_date"
    size="md"
    label="Event Date"
    placeholder="Choose event date..."
  />

  <!-- Hero section - prominent -->
  <.date_picker
    name="hero_date"
    size="xl"
    label="Launch Date"
    placeholder="When do you want to launch?"
  />
  ```

  ## Labels and Descriptions

  Configure labels and descriptions using available attributes:

  ```heex
  <!-- Complete labeling example -->
  <.date_picker
    name="event_date"
    label="Event Date"
    sublabel="Required"
    description="Choose when your event will take place"
    help_text="Events can be scheduled up to 6 months in advance"
    placeholder="Select event date"
  />
  ```

  ### Real-World Labeling Scenarios

  ```heex
  <!-- Professional appointment booking -->
  <.date_picker
    name="appointment_date"
    label="Appointment Date"
    description="Select your preferred consultation date"
    help_text="Available Monday-Friday, 9 AM to 5 PM"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 60)}
    placeholder="Choose your appointment date"
  />

  <!-- Project management deadline -->
  <.date_picker
    name="project_deadline"
    label="Project Deadline"
    sublabel="Required"
    description="When should this project be completed?"
    help_text="Deadlines must be at least 1 day in the future"
    min={Date.add(Date.utc_today(), 1)}
    max={Date.add(Date.utc_today(), 90)}
    placeholder="Set project deadline"
  />

  <!-- User profile information -->
  <.date_picker
    name="birth_date"
    label="Date of Birth"
    description="We use this to verify your age"
    help_text="Your information is kept private and secure"
    min={~D[1900-01-01]}
    max={Date.utc_today()}
    navigation="select"
    placeholder="Enter your birth date"
  />
  ```

  ## Inner Affixes

  Add content *inside* the date picker's border using inner affix slots. Used for icons, status indicators, and visual elements:

  ```heex
  <!-- Standard calendar icon -->
  <.date_picker name="appointment" label="Appointment Date" placeholder="Select date">
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
  </.date_picker>

  <!-- Status indicators with dual affixes -->
  <.date_picker name="event_date" label="Event Date" placeholder="Event date">
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-check-circle" class="icon text-green-500!" />
    </:inner_suffix>
  </.date_picker>
  ```

  ### Advanced Inner Affix Patterns

  ```heex
  <!-- Booking system with validation -->
  <.date_picker name="check_in" label="Check-in Date" placeholder="Select check-in">
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-check-circle" class="icon text-green-500!" />
    </:inner_suffix>
  </.date_picker>

  <!-- Urgent deadline with warning indicators -->
  <.date_picker name="urgent_deadline" label="Urgent Deadline" placeholder="Set deadline">
    <:inner_prefix>
      <.icon name="hero-clock" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-exclamation-triangle" class="icon text-red-500!" />
    </:inner_suffix>
  </.date_picker>

  <!-- Size-matched icons for different variants -->
  <.date_picker name="small_with_icon" size="sm" label="Small Date" placeholder="Small">
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
  </.date_picker>

  <.date_picker name="large_with_icon" size="lg" label="Large Date" placeholder="Large">
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
  </.date_picker>
  ```

  ## Outer Affixes

  Place content *outside* the date picker's border using outer affix slots. Used for buttons, labels, and interactive elements:

  ```heex
  <!-- Simple text prefix -->
  <.date_picker name="filtered" label="Due Date" placeholder="Select date">
    <:outer_prefix class="px-3 text-foreground-soft">Due:</:outer_prefix>
  </.date_picker>

  <!-- Action button integration -->
  <.date_picker name="with_action" label="Reminder Date" placeholder="Select date">
    <:outer_suffix>
      <.button size="md">Set Reminder</.button>
    </:outer_suffix>
  </.date_picker>
  ```

  ### Complete Affix Compositions

  ```heex
  <!-- Full-featured booking interface -->
  <.date_picker name="appointment" label="Appointment" placeholder="Select appointment">
    <:outer_prefix class="px-2">Book</:outer_prefix>
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-clock" class="icon" />
    </:inner_suffix>
    <:outer_suffix>
      <.button size="md">Confirm</.button>
    </:outer_suffix>
  </.date_picker>

  <!-- Hotel reservation system -->
  <.date_range_picker
    start_name="check_in"
    end_name="check_out"
    label="Stay Duration"
    placeholder="Select dates"
  >
    <:outer_prefix class="px-3">Stay:</:outer_prefix>
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
    <:outer_suffix>
      <.button size="md">Check Availability</.button>
    </:outer_suffix>
  </.date_range_picker>
  ```

  > #### Size Matching with Affixes {: .important}
  >
  > When using buttons or components within affix slots, match their `size` attribute to the
  > date picker's `size` for proper visual alignment:
  >
  > ```heex
  > <.date_picker name="example" size="lg" label="Large Date">
  >   <:outer_suffix>
  >     <.button size="lg">Action</.button>  <!-- Matches date picker size -->
  >   </:outer_suffix>
  > </.date_picker>
  > ```

  ## Date Constraints and Validation

  Control selectable dates using `min` and `max` attributes. These provide client-side validation only - always implement corresponding server-side validation for security:

  ### Basic Constraint Patterns

  ```heex
  <!-- Future dates only -->
  <.date_picker
    name="future_only"
    label="Future Dates Only"
    min={Date.utc_today()}
    description="Cannot select past dates"
    placeholder="Select future date"
  />

  <!-- Specific time window -->
  <.date_picker
    name="deadline"
    label="Project Deadline"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 30)}
    description="Select within next 30 days"
    placeholder="Choose deadline"
  />
  ```

  ### Business Logic Constraints

  ```heex
  <!-- Appointment booking (business hours consideration) -->
  <.date_picker
    name="appointment_date"
    label="Appointment Date"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 60)}
    description="Appointments available for the next 2 months"
    help_text="Monday-Friday, 9 AM to 5 PM"
    placeholder="Select appointment date"
  />

  <!-- Event planning (advance notice required) -->
  <.date_picker
    name="event_date"
    label="Event Date"
    min={Date.add(Date.utc_today(), 90)}
    max={Date.add(Date.utc_today(), 180)}
    description="Events must be planned 3-6 months ahead"
    placeholder="Choose event date"
  />

  <!-- Birth date with reasonable bounds -->
  <.date_picker
    name="birth_date"
    label="Date of Birth"
    min={~D[1900-01-01]}
    max={Date.utc_today()}
    navigation="select"
    description="Enter your date of birth"
    placeholder="Select birth date"
  />
  ```

  ### Custom Disabled Dates

  Beyond `min` and `max` constraints, the `disabled_dates` attribute provides flexible date disabling through specific dates, ranges, and pattern matching. All patterns are evaluated together using union logic - a date is disabled if it matches ANY of the provided criteria.

  #### Exact Date Matching

  **Specific dates** (`~D[YYYY-MM-DD]`) disable individual dates. This is useful for blocking known unavailable dates like holidays or specific blocked days. Multiple dates can be provided in the list.

  **Date ranges** (`Date.range/2`) disable all dates within a continuous range, inclusive of start and end dates. Ranges are automatically expanded server-side, making them efficient for blocking vacation periods or extended closures.

  #### Pattern-Based Disabling

  **Shortcut patterns** provide quick access to common scenarios:
  - `:weekends` - Disables all Saturdays and Sundays
  - `:weekdays` - Disables Monday through Friday (inverse of weekends)

  **Day of month patterns** (`{:day, N}`) disable a specific day number across all months and years. For example, `{:day, 15}` disables the 15th of every month. When a month doesn't have the specified day (like day 31 in February), the pattern has no effect for that month.

  **Weekday patterns** (`{:weekday, N}`) disable specific days of the week using ISO-8601 standard numbering (1=Monday, 7=Sunday). For example, `{:weekday, 3}` disables all Wednesdays. Multiple weekday patterns can be combined to create custom weekly availability schedules.

  **ISO week patterns** (`{:week, N}`) disable all dates within a specific ISO week number (1-53). ISO weeks always start on Monday and are calculated according to ISO-8601 standard.

  **Month-day patterns** (`{:month_day, M, D}`) disable recurring annual dates, such as holidays that fall on the same calendar date each year. For example, `{:month_day, 12, 25}` disables December 25th across all years.

  **Month patterns** (`{:month, M}`) disable entire months across all years. Month numbers are 1-based (1=January, 12=December).

  **Year patterns** (`{:year, YYYY}`) disable all dates within a specific year.

  #### Examples

  ```heex
  <!-- Business days only: disable all weekends -->
  <.date_picker
    name="business_date"
    label="Appointment Date"
    disabled_dates={[:weekends]}
  />

  <!-- Block specific dates and ranges together -->
  <.date_picker
    name="booking"
    label="Booking Date"
    disabled_dates={[
      ~D[2025-12-25],
      ~D[2025-01-01],
      Date.range(~D[2026-01-02], ~D[2026-01-15])
    ]}
  />

  <!-- Complex pattern combination -->
  <.date_picker
    name="availability"
    label="Available Date"
    disabled_dates={[
      :weekends,              # No weekends
      {:weekday, 3},          # No Wednesdays
      {:day, 15},             # No 15th of any month
      {:month_day, 12, 25},   # No Christmas
      {:month, 4},            # No April dates
      {:week, 33}             # No ISO week 33
    ]}
  />
  ```

  ### Constraint Behavior

  When constraints are applied, the component automatically:
  - Disables and visually styles dates outside the allowed range
  - Prevents keyboard navigation to disabled dates
  - Disables navigation buttons when the target month contains no selectable dates
  - Opens the calendar to a month containing valid dates
  - Maintains constraints across month/year navigation
  - Clears invalid selections when constraints change dynamically

  > #### Security Warning {: .warning}
  >
  > Date constraints provide **client-side validation only**. Always implement corresponding
  > server-side validation using Ecto changesets:
  >
  > ```elixir
  > def changeset(appointment, attrs) do
  >   appointment
  >   |> cast(attrs, [:date])
  >   |> validate_future_date(:date)
  > end
  >
  > defp validate_future_date(changeset, field) do
  >   validate_change(changeset, field, fn _, date ->
  >     if Date.compare(date, Date.utc_today()) == :lt do
  >       [{field, "must be in the future"}]
  >     else
  >       []
  >     end
  >   end)
  > end
  > ```

  ## Selection Granularity

  Control the level of date precision using the `granularity` attribute. This determines whether users select specific days, entire months, or entire years:

  ### Day Granularity (Default)

  Standard date selection for specific days:

  ```heex
  <.date_picker
    name="appointment"
    label="Appointment Date"
    granularity="day"
    placeholder="Select a specific day"
  />
  ```

  ### Month Granularity

  Select entire months, with dates normalized to the first day of the selected month. The calendar displays a grid of months instead of days:

  ```heex
  <.date_picker
    name="billing_period"
    label="Billing Period"
    granularity="month"
    placeholder="Select a month"
  />
  ```

  ### Year Granularity

  Select entire years, with dates normalized to January 1st of the selected year. The calendar displays a grid of years:

  ```heex
  <.date_picker
    name="graduation_year"
    label="Graduation Year"
    granularity="year"
    placeholder="Select a year"
  />
  ```

  ### Practical Use Cases

  ```heex
  <!-- Financial reporting - month selection -->
  <.date_picker
    name="report_month"
    label="Report Period"
    granularity="month"
    min={~D[2020-01-01]}
    max={Date.utc_today()}
    description="Select the month for financial reporting"
    placeholder="Choose reporting month"
  />

  <!-- Academic year selection -->
  <.date_picker
    name="academic_year"
    label="Academic Year"
    granularity="year"
    min={~D[2000-01-01]}
    max={Date.add(Date.utc_today(), 365)}
    description="Select your graduation year"
    placeholder="Select year"
  />

  <!-- Contract period - month range -->
  <.date_range_picker
    start_name="contract_start"
    end_name="contract_end"
    label="Contract Period"
    granularity="month"
    description="Select contract duration by month"
    placeholder="Select month range"
  />

  <!-- Birth date with year-first selection -->
  <.date_picker
    name="birth_date"
    label="Date of Birth"
    granularity="day"
    navigation="select"
    min={~D[1900-01-01]}
    max={Date.utc_today()}
    description="Select your date of birth"
    placeholder="Select birth date"
  />
  ```

  ### Granularity Behavior

  When using different granularity levels:
  - **Date Normalization**: Selected dates are automatically normalized to the start of the period (first of month for `"month"`, January 1st for `"year"`)
  - **Display Format**: Format automatically adjusts unless explicitly overridden with `display_format`
  - **Time Picker**: Automatically disabled for `"month"` and `"year"` modes (only available with `"day"`)
  - **Range Selection**: Works with all granularity levels, applying normalization to both start and end dates
  - **Constraints**: `min` and `max` constraints apply at the selected granularity level

  > #### Time Picker Compatibility {: .info}
  >
  > The time picker is only available when `granularity="day"`. When using `"month"` or `"year"`
  > granularity, the time picker is automatically disabled regardless of the `time_picker` attribute
  > value, since time selection is only meaningful at the day level.

  ## Multiple Date Selection

  Enable multiple date selection using the `multiple` attribute. Used for scheduling recurring events, selecting holidays, or planning multiple appointments:

  ```heex
  <!-- Basic multiple selection -->
  <.date_picker
    name="holidays[]"
    label="Company Holidays"
    multiple
    description="Select all company holidays for the year"
    help_text="Click dates to toggle selection"
    placeholder="Select multiple dates"
  />
  ```

  ### Multiple Selection Use Cases

  ```heex
  <!-- Vacation planning -->
  <.date_picker
    name="vacation_days[]"
    label="Vacation Days"
    multiple
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 365)}
    close="manual"
    description="Select all your vacation days"
    help_text="You can select multiple non-consecutive dates"
    placeholder="Choose vacation days"
  />

  <!-- Recurring meeting dates -->
  <.date_picker
    name="meeting_dates[]"
    label="Meeting Dates"
    multiple
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 90)}
    navigation="extended"
    close="manual"
    description="Select all meeting dates for the quarter"
    help_text="Meetings will be scheduled on these dates"
    placeholder="Select meeting dates"
  />

  <!-- Availability calendar -->
  <.date_picker
    name="available_dates[]"
    label="Available Dates"
    multiple
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 30)}
    description="Mark your available dates"
    help_text="Others can book appointments on these dates"
    placeholder="Mark availability"
  />
  ```

  ### Multiple Selection Behavior

  When multiple selection is enabled:
  - Calendar remains open after each selection for continued picking
  - Selected dates are visually highlighted
  - Clicking selected dates deselects them
  - Toggle button shows "X dates selected" for multiple selections
  - Time picker integration is not supported
  - Auto-close mode is automatically disabled

  > #### Form Submission Behavior {: .info}
  >
  > Multiple selection fields use array notation (`name="dates[]"`) and handle browser
  > form submission edge cases automatically:
  >
  > ```elixir
  > # When dates are selected
  > %{"holidays" => ["2025-05-15", "2025-05-14", "2025-05-22"]}
  >
  > # When no dates are selected (hidden input provides empty value)
  > %{"holidays" => [""]}  # Instead of field being omitted
  > ```

  ## Date and Time Formatting

  Customize how dates are displayed using the `display_format` attribute with [strftime](https://hexdocs.pm/calendar/Calendar.Strftime.html#strftime/3) patterns:

  ### Common Date Formats

  ```heex
  <!-- ISO format -->
  <.date_picker
    name="iso_date"
    label="ISO Date"
    display_format="%Y-%m-%d"  <!-- 2024-01-01 -->
  />

  <!-- US format -->
  <.date_picker
    name="us_date"
    label="US Date"
    display_format="%m/%d/%Y"  <!-- 01/01/2024 -->
  />

  <!-- European format -->
  <.date_picker
    name="eu_date"
    label="European Date"
    display_format="%d/%m/%Y"  <!-- 01/01/2024 -->
  />

  <!-- Full month name -->
  <.date_picker
    name="full_date"
    label="Full Date"
    display_format="%B %-d, %Y"  <!-- January 1, 2024 -->
  />
  ```

  ### DateTime Formatting

  For `date_time_picker`, include time patterns in your format:

  ```heex
  <!-- 12-hour format with full context -->
  <.date_time_picker
    name="appointment"
    label="Appointment"
    time_format="12"
    display_format="%B %-d, %Y at %I:%M %p"  <!-- January 1, 2024 at 02:30 PM -->
  />

  <!-- 24-hour format, compact -->
  <.date_time_picker
    name="meeting"
    label="Meeting"
    time_format="24"
    display_format="%Y-%m-%d %H:%M"  <!-- 2024-01-01 14:30 -->
  />

  <!-- Casual format -->
  <.date_time_picker
    name="event"
    label="Event"
    time_format="12"
    display_format="%a, %b %-d at %I:%M %p"  <!-- Mon, Jan 1 at 02:30 PM -->
  />
  ```

  > #### Format Compatibility {: .info}
  >
  > Time-related format specifiers (`%H`, `%M`, `%S`, `%I`, `%p`) should only be used with
  > `date_time_picker`. Using them with `date_picker` or `date_range_picker` will cause
  > formatting errors since these components don't handle time values.

  ## Week Start Configuration

  Customize which day appears in the first column using the `week_start` attribute to accommodate different cultural preferences:

  ```heex
  <!-- Monday start (common in Europe) -->
  <.date_picker
    name="european_date"
    label="Date"
    week_start={1}
  />

  <!-- Friday start (common in Islamic countries) -->
  <.date_picker
    name="islamic_date"
    label="Date"
    week_start={5}
  />
  ```

  | Value | Weekday   | Common Usage |
  |-------|-----------|--------------|
  | 0     | Sunday    | Default (US, Canada) |
  | 1     | Monday    | Europe, ISO 8601 |
  | 2     | Tuesday   | |
  | 3     | Wednesday | |
  | 4     | Thursday  | |
  | 5     | Friday    | Islamic countries |
  | 6     | Saturday  | Nepal |

  The calendar grid, keyboard navigation, and week-based interactions all adapt to the configured week start.

  ## Date Time Picker

  The `date_time_picker` function combines date selection with precise time input, supporting both 12-hour and 24-hour formats:

  ```heex
  <!-- 12-hour format with AM/PM -->
  <.date_time_picker
    name="appointment"
    label="Appointment Time"
    time_format="12"
    display_format="%B %-d, %Y at %I:%M %p"
  />

  <!-- 24-hour format -->
  <.date_time_picker
    name="meeting_start"
    label="Meeting Start"
    time_format="24"
    display_format="%d/%m/%Y %H:%M"
  />
  ```

  ### Time Input Features

  The time interface provides:
  - Direct keyboard input for quick entry
  - Up/down arrow keys for increment/decrement
  - Automatic value constraints (hours: 0-23 or 1-12, minutes: 0-59)
  - Tab navigation between time fields
  - AM/PM toggle with 'a' and 'p' keys (12-hour mode)
  - Enter key to confirm and close

  ### Data Type Requirements

  Date time pickers require `NaiveDateTime` or `DateTime` field types:

  ```elixir
  # In your schema
  schema "appointments" do
    field :scheduled_at, :naive_datetime  # Required for date_time_picker
    # field :date_only, :date             # Use with date_picker instead
  end
  ```

  > #### Timezone Handling {: .warning}
  >
  > The component currently treats all dates and times as UTC. Timezone support
  > is planned for future versions. Handle timezone conversion in your application logic.

  ## Date Range Picker

  The `date_range_picker` function provides range selection with visual feedback and interaction patterns:

  ```heex
  <!-- Form integration -->
  <.form :let={f} for={@changeset}>
    <.date_range_picker
      start_field={f[:start_date]}
      end_field={f[:end_date]}
      label="Booking Period"
      min={Date.utc_today()}
      max={Date.add(Date.utc_today(), 90)}
    />
  </.form>

  <!-- Standalone usage -->
  <.date_range_picker
    start_name="check_in"
    end_name="check_out"
    start_value={@check_in}
    end_value={@check_out}
    label="Stay Period"
    description="Select your check-in and check-out dates"
  />
  ```

  ### Range Selection Patterns

  The component supports these interaction patterns:
  - Click two different dates to select a range
  - Click the same date twice for single-day ranges
  - Click within an existing range to shrink it
  - Click outside an existing range to expand it
  - Click a selected date to clear and restart selection

  ### Form Integration Example

  ```elixir
  # Schema with separate start/end fields
  schema "bookings" do
    field :start_date, :date
    field :end_date, :date
    timestamps()
  end

  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:start_date, :end_date])
    |> validate_required([:start_date, :end_date])
    |> validate_start_before_end()
  end

  defp validate_start_before_end(changeset) do
    case {get_field(changeset, :start_date), get_field(changeset, :end_date)} do
      {start_date, end_date} when not is_nil(start_date) and not is_nil(end_date) ->
        if Date.compare(end_date, start_date) == :lt do
          add_error(changeset, :end_date, "must be after start date")
        else
          changeset
        end
      _ ->
        changeset
    end
  end
  ```

  ## Closing Strategies

  Control when the calendar closes using the `close` attribute:

  ### Auto Mode (Default)

  Closes immediately after selection:

  ```heex
  <.date_picker name="simple" close="auto" label="Simple Date" />
  ```

  ### Manual Mode

  Keeps calendar open for comparison and multiple adjustments:

  ```heex
  <.date_picker name="manual" close="manual" label="Manual Close" />
  ```

  ### Confirm Mode

  Requires explicit confirmation:

  ```heex
  <.date_picker name="confirm" close="confirm" label="Confirmed Date" />
  ```

  > #### Automatic Mode Fallback {: .tip}
  >
  > The component automatically switches to manual mode when using features that require
  > multiple interactions (time picker, range selection, multiple selection).

  ## Navigation Modes

  Choose from three navigation interfaces based on your use case:

  ### Default Mode
  Simple month-to-month navigation with arrow buttons:

  ```heex
  <.date_picker name="default_nav" navigation="default" />
  ```

  ### Extended Mode
  Adds year navigation arrows for faster long-distance navigation:

  ```heex
  <.date_picker name="extended_nav" navigation="extended" />
  ```

  ### Select Mode
  Combines arrows with dropdown menus for direct month/year access:

  ```heex
  <.date_picker name="select_nav" navigation="select" />
  ```

  > #### Smart Navigation Constraints {: .info}
  >
  > Navigation automatically adapts to date constraints:
  > - Buttons disable when reaching min/max limits
  > - Calendar ensures visible months contain selectable dates
  > - Dropdown options are limited to valid ranges

  ## Form Integration

  The date picker supports Phoenix form fields and standalone usage.

  ### Phoenix Forms

  Use the `field` attribute for form integration:

  ```heex
  <.form :let={f} for={@changeset} phx-change="validate">
    <.date_picker
      field={f[:appointment_date]}
      label="Appointment Date"
      min={Date.utc_today()}
    />
  </.form>
  ```

  Benefits of form integration:
  - Automatic value handling from form data
  - Built-in error handling and validation messages
  - Proper form submission with correct field names
  - Seamless changeset integration
  - Automatic ID generation for accessibility
  - Type conversion between form data and Elixir date types

  ### Complete Form Example

  ```elixir
  defmodule MyApp.Booking do
    use Ecto.Schema
    import Ecto.Changeset

    schema "bookings" do
      field :appointment_date, :date
      field :meeting_datetime, :naive_datetime
      field :blocked_dates, {:array, :date}
      field :start_date, :date
      field :end_date, :date
      timestamps()
    end

    def changeset(booking, attrs) do
      booking
      |> cast(attrs, [:appointment_date, :meeting_datetime, :blocked_dates, :start_date, :end_date])
      |> validate_required([:appointment_date])
      |> validate_future_date(:appointment_date)
      |> validate_date_range()
    end

    defp validate_future_date(changeset, field) do
      validate_change(changeset, field, fn _, date ->
        if Date.compare(date, Date.utc_today()) == :lt do
          [{field, "must be in the future"}]
        else
          []
        end
      end)
    end

    defp validate_date_range(changeset) do
      case {get_field(changeset, :start_date), get_field(changeset, :end_date)} do
        {start_date, end_date} when not is_nil(start_date) and not is_nil(end_date) ->
          if Date.compare(end_date, start_date) == :lt do
            add_error(changeset, :end_date, "must be after start date")
          else
            changeset
          end
        _ ->
          changeset
      end
    end
  end
  ```

  ### Standalone Usage

  For simpler cases or non-Phoenix forms:

  ```heex
  <!-- Single date -->
  <.date_picker
    name="filter_date"
    label="Filter By Date"
    value={@selected_date}
  />

  <!-- Multiple dates -->
  <.date_picker
    name="holiday_dates[]"
    label="Holiday Dates"
    multiple
    value={@selected_dates}
  />

  <!-- Date range -->
  <.date_range_picker
    start_name="check_in"
    end_name="check_out"
    start_value={@check_in}
    end_value={@check_out}
    label="Stay Period"
  />
  ```

  > #### Type Handling {: .info}
  >
  > The component automatically handles conversion between string values and Elixir date types:
  > - `:date` fields work with `Date` structs
  > - `:naive_datetime` fields work with `NaiveDateTime` structs
  > - `:datetime` fields work with `DateTime` structs
  > - Multiple selection fields work with lists of these types
  > - Standalone mode always uses ISO 8601 string format

  ## Keyboard Navigation

  The component provides comprehensive keyboard support for accessibility:

  ### Toggle Button Navigation
  | Key | Action |
  |-----|--------|
  | `Tab`/`Shift+Tab` | Move focus to/from date picker |
  | `Space`/`Enter` | Open/close calendar |
  | `Backspace` | Clear selection (when clearable) |

  ### Calendar Navigation

  Navigation behavior adapts based on the selected granularity:

  **Day Granularity:**
  | Key | Action |
  |-----|--------|
  | `↑`/`↓` | Move to same day in previous/next week (7 days) |
  | `←`/`→` | Move to previous/next day |
  | `Home`/`End` | Move to first/last day of current week |
  | `PageUp`/`PageDown` | Move to same day in previous/next month |
  | `Enter`/`Space` | Select focused date |
  | `Escape` | Close calendar |

  **Month Granularity:**
  | Key | Action |
  |-----|--------|
  | `↑`/`↓` | Move up/down by 3 months (grid row) |
  | `←`/`→` | Move to previous/next month |
  | `Enter`/`Space` | Select focused month |
  | `Escape` | Close calendar |

  **Year Granularity:**
  | Key | Action |
  |-----|--------|
  | `↑`/`↓` | Move up/down by 3 years (grid row) |
  | `←`/`→` | Move to previous/next year |
  | `Enter`/`Space` | Select focused year |
  | `Escape` | Close calendar |

  ### Time Picker Navigation (when enabled)
  | Key | Action |
  |-----|--------|
  | `↑`/`↓` | Increment/decrement time values |
  | `0-9` | Direct value input |
  | `a`/`p` | Switch AM/PM (12-hour format) |

  The component implements focus trapping when open, ensuring keyboard navigation stays within the calendar interface.

  ## Implementation Examples

  Complete implementations for common scenarios:

  ### Appointment Booking System

  ```heex
  <.date_picker
    name="appointment_date"
    label="Appointment Date"
    description="Select your preferred appointment date"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 60)}
    navigation="select"
    help_text="Appointments available Monday-Friday, 9 AM to 5 PM"
    placeholder="Choose your appointment date"
  >
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
    <:outer_suffix>
              <.button variant="solid" color="primary" size="md">Book Appointment</.button>
    </:outer_suffix>
  </.date_picker>
  ```

  ### Hotel Reservation System

  ```heex
  <.date_range_picker
    start_name="check_in"
    end_name="check_out"
    label="Hotel Reservation"
    description="Select your check-in and check-out dates"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 365)}
    display_format="%a, %b %-d"
    help_text="Minimum stay: 1 night, Maximum stay: 30 nights"
    placeholder="Select your stay dates"
  >
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
    <:outer_suffix>
              <.button size="md" variant="solid" color="primary">Check Availability</.button>
    </:outer_suffix>
  </.date_range_picker>
  ```

  ### Meeting Scheduler

  ```heex
  <.date_time_picker
    name="meeting_schedule"
    label="Meeting Schedule"
    description="Schedule your meeting"
    time_format="12"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 30)}
    display_format="%B %-d, %Y at %I:%M %p"
    help_text="Meeting rooms available 8 AM to 6 PM"
    placeholder="Choose meeting time"
  >
    <:inner_prefix>
      <.icon name="hero-clock" class="icon" />
    </:inner_prefix>
    <:outer_suffix>
              <.button variant="solid" color="primary" size="md">
        <.icon name="hero-plus" class="size-4" /> Schedule Meeting
      </.button>
    </:outer_suffix>
  </.date_time_picker>
  ```

  ### Project Management Dashboard

  ```heex
  <.date_picker
    name="project_milestones[]"
    label="Project Milestones"
    multiple
    description="Select key project milestone dates"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 180)}
    close="manual"
    help_text="You can select multiple dates for different milestones"
    placeholder="Choose milestone dates"
  >
    <:inner_prefix>
      <.icon name="hero-calendar-days" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-queue-list" class="icon" />
    </:inner_suffix>
    <:outer_suffix>
              <.button size="md" variant="soft" color="primary">Add to Schedule</.button>
    </:outer_suffix>
  </.date_picker>
  ```

  ### Event Planning Interface

  ```heex
  <.date_time_picker
    name="event_scheduler"
    label="Event Start Time"
    description="When does your event start?"
    time_format="12"
    min={Date.utc_today()}
    navigation="extended"
    close="confirm"
    display_format="%a, %B %-d at %I:%M %p"
    placeholder="Schedule your event"
  >
    <:outer_prefix class="px-3">Event:</:outer_prefix>
    <:inner_prefix>
      <.icon name="hero-clock" class="icon" />
    </:inner_prefix>
    <:inner_suffix>
      <.icon name="hero-bell" class="icon" />
    </:inner_suffix>
    <:outer_suffix>
              <.button size="md" variant="solid" color="primary">Create Event</.button>
    </:outer_suffix>
  </.date_time_picker>
  ```

  ### User Profile - Birth Date

  ```heex
  <.date_picker
    name="birthday_picker"
    label="Date of Birth"
    description="Select your birth date"
    min={~D[1900-01-01]}
    max={Date.utc_today()}
    navigation="select"
    display_format="%B %-d, %Y"
    week_start={1}
    placeholder="Enter your birth date"
  >
    <:inner_prefix>
      <.icon name="hero-cake" class="icon" />
    </:inner_prefix>
  </.date_picker>
  ```

  ### Financial Reporting - Month Selection

  ```heex
  <.date_picker
    name="reporting_month"
    label="Reporting Period"
    description="Select the month for financial reporting"
    granularity="month"
    min={~D[2020-01-01]}
    max={Date.utc_today()}
    help_text="Reports are generated monthly"
    placeholder="Choose reporting month"
  >
    <:inner_prefix>
      <.icon name="hero-chart-bar" class="icon" />
    </:inner_prefix>
    <:outer_suffix>
      <.button size="md" variant="solid" color="primary">Generate Report</.button>
    </:outer_suffix>
  </.date_picker>
  ```

  ### Academic Records - Year Selection

  ```heex
  <.date_picker
    name="graduation_year"
    label="Graduation Year"
    description="Select your graduation year"
    granularity="year"
    min={~D[1950-01-01]}
    max={Date.add(Date.utc_today(), 3650)}
    navigation="default"
    placeholder="Select year"
  >
    <:inner_prefix>
      <.icon name="hero-academic-cap" class="icon" />
    </:inner_prefix>
  </.date_picker>
  ```

  ### Subscription Period - Month Range

  ```heex
  <.date_range_picker
    start_name="subscription_start"
    end_name="subscription_end"
    label="Subscription Period"
    description="Select your subscription period"
    granularity="month"
    min={Date.utc_today()}
    max={Date.add(Date.utc_today(), 730)}
    help_text="Subscriptions are billed monthly"
    placeholder="Choose subscription period"
  >
    <:inner_prefix>
      <.icon name="hero-calendar" class="icon" />
    </:inner_prefix>
    <:outer_suffix>
      <.button size="md" variant="solid" color="primary">Calculate Price</.button>
    </:outer_suffix>
  </.date_range_picker>
  ```
  """

  use Fluxon.Component
  import Fluxon.Components.Form, only: [error: 1, label: 1]
  import Fluxon.Components.Button, only: [button: 1]

  @styles %{
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
      # Layout and positioning
      "group relative flex items-center w-full text-left truncate",
      "w-full",

      # Background and appearance
      "bg-input text-foreground shadow-base",

      # Focus state
      "focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus transition-[box-shadow] duration-100",

      # Error/invalid state
      "data-invalid:border-danger focus-visible:data-invalid:border-danger focus-visible:data-invalid:ring-focus-danger",

      # Disabled state
      "disabled:shadow-none disabled:pointer-events-none disabled:bg-input-disabled disabled:text-foreground-soft",

      # Remove default button styles
      "outline-none"
    ],
    toggle_text: [
      "truncate flex-1 min-w-0 w-full",
      "[&>[data-part=toggle-text]]:empty:text-foreground-softest [&>[data-part=toggle-text]]:empty:before:content-[attr(data-placeholder)]"
    ],
    affix: [
      "flex items-center justify-center text-sm text-foreground-soft shrink-0"
    ],
    calendar_icon: [
      "shrink-0 text-foreground-softest"
    ],
    calendar_icon_size: %{
      "xs" => "size-4",
      "sm" => "size-4.5",
      "md" => "size-5",
      "lg" => "size-5.5",
      "xl" => "size-6"
    },
    size: %{
      "xs" => %{
        toggle: "gap-2 px-2 h-7",
        toggle_text: "sm:text-xs",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-4",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-4"
        ]
      },
      "sm" => %{
        toggle: "gap-2 px-2.5 h-8",
        toggle_text: "sm:text-sm",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-4.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-4.5"
        ]
      },
      "md" => %{
        toggle: "gap-2 px-3 h-9",
        toggle_text: "sm:text-sm",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-5"
        ]
      },
      "lg" => %{
        toggle: "gap-2 px-3 h-10",
        toggle_text: "sm:text-base",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-5.5",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-5.5"
        ]
      },
      "xl" => %{
        toggle: "gap-2 px-3 h-11",
        toggle_text: "sm:text-lg",
        affix: [
          "**:[.icon]:text-foreground-softest **:[.icon]:size-6",
          "**:data-[part=icon]:text-foreground-softest **:data-[part=icon]:size-6"
        ]
      }
    },
    day_button: [
      # Base styles
      "w-full min-w-9 min-h-9 flex items-center justify-center rounded-base relative",
      # Square aspect for day view only
      "data-[view='days']:aspect-square",
      # Text color
      "text-foreground",
      # Interactive states
      "hover:not-data-disabled:not-data-selected:bg-accent",
      "data-disabled:opacity-50 data-disabled:line-through",
      # Selected state
      "data-selected:bg-primary data-selected:text-foreground-primary",
      # Other month days
      "data-other-month:text-foreground-softest",
      # Range state
      "data-in-range:relative data-in-range:isolate",
      "data-in-range:before:absolute data-in-range:before:inset-0 data-in-range:before:-mx-[1px]",
      "data-in-range:before:bg-accent data-in-range:before:-z-1",
      # Day view: 7 columns per row
      "[&[data-view='days'][data-in-range]:nth-child(7n)]:before:rounded-r-lg",
      "[&[data-view='days'][data-in-range]:nth-child(7n+1)]:before:rounded-l-lg",
      # Month/Year view: 3 columns per row
      "[&[data-view='months'][data-in-range]:nth-child(3n)]:before:rounded-r-lg",
      "[&[data-view='months'][data-in-range]:nth-child(3n+1)]:before:rounded-l-lg",
      "[&[data-view='years'][data-in-range]:nth-child(3n)]:before:rounded-r-lg",
      "[&[data-view='years'][data-in-range]:nth-child(3n+1)]:before:rounded-l-lg",
      # Range start/end styles
      "data-range-start:relative data-range-start:before:absolute data-range-start:before:inset-0",
      "data-range-start:before:bg-accent data-range-start:before:-z-1",
      "data-range-start:before:rounded-l-lg data-range-start:before:right-[-1px]",
      "data-range-end:relative data-range-end:before:absolute data-range-end:before:inset-0",
      "data-range-end:before:bg-accent data-range-end:before:-z-1",
      "data-range-end:before:rounded-r-lg data-range-end:before:left-[-1px]",
      # Selected day styles
      "data-range-start:bg-primary data-range-start:text-foreground-primary data-range-start:hover:bg-primary",
      "data-range-end:bg-primary data-range-end:text-foreground-primary data-range-end:hover:bg-primary",
      # Range continuity: remove inner rounding for complete ranges only
      "[[data-range-complete]_&]:data-range-start:rounded-r-none",
      "[[data-range-complete]_&]:data-range-end:rounded-l-none",
      # Focus
      "outline-hidden",
      "focus-visible:border focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus"
    ],
    time_input: [
      # Base styles
      "flex-1 rounded-base text-center min-w-0",
      # Typography
      "text-foreground",
      "placeholder:text-foreground-softest",
      # Background and border
      "bg-input",
      "border border-base",
      # Shadow and outline
      "shadow-xs",
      "outline-focus",
      # Transitions
      "transition-all duration-200 ease-in-out",
      # Disabled state
      "disabled:bg-input-disabled",
      "disabled:opacity-50 disabled:shadow-none",
      # Spacing
      "py-1 px-2 caret-transparent",
      # Hide spin buttons (webkit and Firefox)
      "[&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none",
      "[-moz-appearance:textfield]",
      "[appearance:textfield]"
    ],
    select_navigation: [
      "bg-no-repeat bg-[position:right_0.5rem_center] bg-[length:1rem]",
      "bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGZpbGw9Im5vbmUiIHZpZXdCb3g9IjAgMCAyNCAyNCI+CiAgPHBhdGggZmlsbD0iI0ExQTFBQSIgZmlsbC1ydWxlPSJldmVub2RkIiBkPSJNNS4yOTMgOC4yOTNhMSAxIDAgMCAxIDEuNDE0IDBMMTIgMTMuNTg2bDUuMjkzLTUuMjkzYTEgMSAwIDEgMSAxLjQxNGwtNiA2YTEgMSAwIDAgMS0xLjQxNCAwbC02LTZhMSAxIDAgMCAxIDAtMS40MTQiIGNsaXAtcnVsZT0iZXZlbm9kZCIvPgo8L3N2Zz4K')]",
      "appearance-none rounded-base overflow-hidden",
      "block",
      "border border-base",
      "shadow-xs",
      "text-foreground",
      "placeholder:text-foreground-softest",
      "outline-hidden focus-visible:outline-2 focus-visible:outline-focus outline-offset-[-2px]",
      "disabled:bg-input-disabled disabled:opacity-70 disabled:shadow-none",
      "py-1 pr-6 pl-2 text-sm"
    ],
    calendar_wrapper: [
      "min-w-60 rounded-base bg-overlay border border-base"
    ]
  }

  @shared_component_attrs [
    id: [
      type: :any,
      default: nil,
      doc: """
      The unique identifier for the date picker component. When not provided, a random ID will be generated.
      """
    ],
    autofocus: [
      type: :boolean,
      default: false,
      doc: """
      Whether the input should have the autofocus attribute.
      """
    ],

    # Date Constraints and Selection Mode
    min: [
      type: Date,
      default: nil,
      doc: """
      The earliest date that can be selected. Dates before this will be disabled.
      """
    ],
    max: [
      type: Date,
      default: nil,
      doc: """
      The latest date that can be selected. Dates after this will be disabled.
      """
    ],

    # Display and Formatting
    week_start: [
      type: :integer,
      default: 0,
      values: 0..6,
      doc: """
      The day of the week that should appear in the first column.
      - `0`: Sunday (default)
      - `1`: Monday
      - `2`: Tuesday
      - `3`: Wednesday
      - `4`: Thursday
      - `5`: Friday
      - `6`: Saturday
      """
    ],
    size: [
      type: :string,
      default: "md",
      values: ~w(xs sm md lg xl),
      doc: """
      Controls the size of the date picker component:
      - `"xs"`: Extra small size, suitable for compact UIs
      - `"sm"`: Small size, suitable for compact UIs
      - `"md"`: Default size, suitable for most use cases
      - `"lg"`: Large size, suitable for prominent selections
      - `"xl"`: Extra large size, suitable for hero sections
      """
    ],
    class: [
      type: :any,
      default: nil,
      doc: """
      Additional CSS classes to be applied to the date picker calendar container.
      These classes will be merged with the default styles.
      """
    ],

    # Behavior and Interaction
    granularity: [
      type: :string,
      default: "day",
      values: ~w(day month year),
      doc: """
      Controls the selection granularity:
      - `"day"`: Select specific days (default)
      - `"month"`: Select entire months (dates normalized to first of month)
      - `"year"`: Select entire years (dates normalized to first of year)
      """
    ],
    close: [
      type: :string,
      default: "auto",
      values: ~w(auto manual confirm),
      doc: """
      Controls how the date picker closes after selection:
      - `"auto"`: Closes immediately after selection (default)
      - `"manual"`: Stays open after selection
      - `"confirm"`: Requires explicit confirmation via button
      """
    ],
    navigation: [
      type: :string,
      default: "default",
      values: ~w(default extended select),
      doc: """
      Controls the calendar navigation interface:
      - `"default"`: Month arrows only
      - `"extended"`: Month and year arrows
      - `"select"`: Month arrows + year/month dropdowns
      """
    ],
    inline: [
      type: :boolean,
      default: false,
      doc: """
      When true, renders the calendar inline instead of in a dropdown.
      """
    ],
    disabled: [
      type: :boolean,
      default: false,
      doc: """
      When true, disables the date picker component. Disabled date pickers cannot be
      interacted with and appear visually muted.
      """
    ],

    # Labels and Help Text
    label: [
      type: :string,
      default: nil,
      doc: """
      The primary label for the date picker. This text is displayed above the date picker
      and is used for accessibility purposes.
      """
    ],
    sublabel: [
      type: :string,
      default: nil,
      doc: """
      Additional context displayed to the side of the main label. Useful for providing
      extra information without cluttering the main label.
      """
    ],
    description: [
      type: :string,
      default: nil,
      doc: """
      A longer description to provide more context about the date picker. This appears
      below the label but above the date picker element.
      """
    ],
    help_text: [
      type: :string,
      default: nil,
      doc: """
      Help text to display below the date picker. This can provide additional context
      or instructions for using the date picker.
      """
    ],
    placeholder: [
      type: :string,
      default: nil,
      doc: """
      Text to display when no date is selected. This text appears in the date picker
      toggle and helps guide users to make a selection.
      """
    ],

    # Validation
    errors: [
      type: :list,
      default: [],
      doc: """
      List of error messages to display below the date picker. These are automatically
      handled when using the `field` attribute with form validation.
      """
    ],

    # Custom Disabled Dates
    disabled_dates: [
      type: :list,
      default: [],
      doc: """
      List of dates, date ranges, or patterns to disable. Accepts:
      - Specific dates: `~D[2025-01-15]`
      - Date ranges: `Date.range(~D[2025-01-01], ~D[2025-01-10])`
      - Day shortcuts: `:weekends`, `:weekdays`
      - Day of month: `{:day, 15}` (disables 15th of every month)
      - Weekday: `{:weekday, 3}` (disables all Wednesdays; 1=Monday, 7=Sunday)
      - ISO week: `{:week, 33}` (disables entire ISO week 33)
      - Recurring annual dates: `{:month_day, 12, 25}` (disables December 25th every year)
      - Month pattern: `{:month, 4}` (disables all April dates)
      - Year pattern: `{:year, 2025}` (disables all 2025 dates)

      All strategies work together (union) - a date is disabled if it matches ANY of the criteria.
      """
    ]
  ]

  @single_date_attrs [
    field: [
      type: Phoenix.HTML.FormField,
      doc: """
      The form field to bind to. When provided, the component automatically handles
      value tracking, errors, and form submission.
      """
    ],
    name: [
      type: :any,
      doc: """
      The form name for the date picker. Required when not using the `field` attribute.
      For multiple selections, this will be automatically suffixed with `[]`.
      """
    ],
    value: [
      type: :any,
      doc: """
      The current selected value(s). For multiple selections, this should be a list.
      When using forms, this is automatically handled by the `field` attribute.
      """
    ]
  ]

  @date_range_attrs [
    start_field: [
      type: Phoenix.HTML.FormField,
      doc: """
      The form field for the start date when using range selection with forms.
      Required when `range={true}` and using form integration.
      """
    ],
    end_field: [
      type: Phoenix.HTML.FormField,
      doc: """
      The form field for the end date when using range selection with forms.
      Required when `range={true}` and using form integration.
      """
    ],
    start_name: [
      type: :any,
      doc: """
      The form name for the start date when using range selection without forms.
      Required when `range={true}` and not using form integration.
      """
    ],
    end_name: [
      type: :any,
      doc: """
      The form name for the end date when using range selection without forms.
      Required when `range={true}` and not using form integration.
      """
    ],
    start_value: [
      type: :any,
      doc: """
      The current start date value when using range selection without forms.
      """
    ],
    end_value: [
      type: :any,
      doc: """
      The current end date value when using range selection without forms.
      """
    ]
  ]

  @doc """
  Renders a date time picker component with time selection.

  The date time picker combines calendar-based date selection with time input fields,
  supporting both 12-hour and 24-hour time formats. It includes date picker features
  with hour, minute, and optional AM/PM controls for datetime selection.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  for {name, opts} <- @single_date_attrs do
    attr name, opts[:type], Keyword.delete(opts, :type)
  end

  for {name, opts} <- @shared_component_attrs do
    attr name, opts[:type], Keyword.delete(opts, :type)
  end

  # Shared affix slots
  slot :inner_prefix,
    doc: """
    Content placed *inside* the date picker field's border, before the date display.
    Ideal for icons or short textual prefixes. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner prefix container."
  end

  slot :outer_prefix,
    doc: """
    Content placed *outside* and before the date picker field. Useful for buttons, dropdowns, or
    other interactive elements associated with the date picker's start. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer prefix container."
  end

  slot :inner_suffix,
    doc: """
    Content placed *inside* the date picker field's border, after the date display.
    Suitable for icons, clear buttons, or loading indicators. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner suffix container."
  end

  slot :outer_suffix,
    doc: """
    Content placed *outside* and after the date picker field. Useful for action buttons or
    other controls related to the date picker's end. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer suffix container."
  end

  attr :time_format, :string,
    default: "12",
    values: ~w(12 24),
    doc: """
    The time format to use:
    - `"12"`: 12-hour format with AM/PM selection
    - `"24"`: 24-hour format
    """

  attr :display_format, :string,
    default: "%b %-d %I:%M %p",
    doc: """
    The format string used to display the selected date in the toggle button. Uses strftime format.
    Common patterns:
    - `"%Y-%m-%d %H:%M:%S"`: ISO format with 24h time (2024-01-01 14:30:00)
    - `"%B %-d, %Y at %I:%M %p"`: Full month with 12h time (January 1, 2024 at 02:30 PM)
    - `"%d/%m/%Y %H:%M"`: European format with 24h time (01/01/2024 14:30)
    - `"%m/%d/%Y %I:%M %p"`: US format with 12h time (01/01/2024 02:30 PM)
    - `"%a, %b %-d at %I:%M %p"`: Short format (Mon, Jan 1 at 02:30 PM)
    """

  def date_time_picker(assigns) do
    assigns
    |> assign(:time_picker, true)
    |> date_picker()
  end

  @doc """
  Renders a date range picker component for selecting start and end dates.

  The date range picker provides a calendar interface for selecting date ranges with
  visual feedback and range highlighting. It supports form integration and standalone usage
  with validation, error handling, and affix customization.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  for {name, opts} <- @date_range_attrs do
    attr name, opts[:type], Keyword.delete(opts, :type)
  end

  for {name, opts} <- @shared_component_attrs do
    attr name, opts[:type], Keyword.delete(opts, :type)
  end

  # Shared affix slots
  slot :inner_prefix,
    doc: """
    Content placed *inside* the date picker field's border, before the date display.
    Ideal for icons or short textual prefixes. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner prefix container."
  end

  slot :outer_prefix,
    doc: """
    Content placed *outside* and before the date picker field. Useful for buttons, dropdowns, or
    other interactive elements associated with the date picker's start. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer prefix container."
  end

  slot :inner_suffix,
    doc: """
    Content placed *inside* the date picker field's border, after the date display.
    Suitable for icons, clear buttons, or loading indicators. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner suffix container."
  end

  slot :outer_suffix,
    doc: """
    Content placed *outside* and after the date picker field. Useful for action buttons or
    other controls related to the date picker's end. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer suffix container."
  end

  attr :display_format, :string,
    default: "%b %-d, %Y",
    doc: """
    The format string used to display the selected date(s) in the toggle button. Uses strftime format.
    Common patterns:
    - `"%Y-%m-%d"`: ISO format (2024-01-01)
    - `"%b %-d, %Y"`: Short month (Jan 1, 2024)
    - `"%B %-d, %Y"`: Full month (January 1, 2024)
    - `"%d/%m/%Y"`: European format (01/01/2024)
    - `"%m/%d/%Y"`: US format (01/01/2024)
    """

  def date_range_picker(%{start_field: %Phoenix.HTML.FormField{}, end_field: %Phoenix.HTML.FormField{}} = assigns) do
    errors =
      [assigns.start_field, assigns.end_field]
      |> Enum.filter(&Phoenix.Component.used_input?/1)
      |> Enum.flat_map(& &1.errors)

    assigns
    |> assign(
      start_field: nil,
      end_field: nil,
      id: assigns.id || assigns.end_field.id,
      errors: Enum.map(errors, &translate(&1))
    )
    |> assign_new(:start_name, fn -> assigns.start_field.name end)
    |> assign_new(:start_value, fn -> assigns.start_field.value end)
    |> assign_new(:end_name, fn -> assigns.end_field.name end)
    |> assign_new(:end_value, fn -> assigns.end_field.value end)
    |> date_range_picker()
  end

  def date_range_picker(assigns) do
    start_value = parse_value(assigns[:start_value])
    end_value = parse_value(assigns[:end_value])

    assigns
    |> assign(
      time_picker: false,
      range: true,
      id: assigns.id || assigns.start_name <> "-" <> assigns.end_name,
      start_value: start_value,
      end_value: end_value
    )
    |> assign_new(:display_value, fn assigns ->
      format_range_dates(assigns.start_value, assigns.end_value, assigns.display_format)
    end)
    |> assign_new(:selected_dates, fn assigns ->
      normalize_dates([assigns.start_value, assigns.end_value])
    end)
    |> assign_new(:current_date, fn assigns -> find_initial_date(assigns) end)
    |> render_component()
  end

  @doc """
  Renders a date picker component for single or multiple date selection.

  The date picker provides a calendar-based interface for date selection with support
  for single and multiple date picking modes. It includes form integration,
  validation handling, affix customization, and keyboard navigation support.

  [INSERT LVATTRDOCS]
  """
  @doc type: :component
  for {name, opts} <- @single_date_attrs do
    attr name, opts[:type], Keyword.delete(opts, :type)
  end

  for {name, opts} <- @shared_component_attrs do
    attr name, opts[:type], Keyword.delete(opts, :type)
  end

  attr :multiple, :boolean,
    default: false,
    doc: """
    When true, allows selecting multiple dates. This submits an array of dates and keeps
    the calendar open after each selection to facilitate choosing multiple dates.
    """

  attr :display_format, :string,
    default: "%b %-d, %Y",
    doc: """
    The format string used to display the selected date(s) in the toggle button. Uses strftime format.
    Common patterns:
    - `"%Y-%m-%d"`: ISO format (2024-01-01)
    - `"%b %-d, %Y"`: Short month (Jan 1, 2024)
    - `"%B %-d, %Y"`: Full month (January 1, 2024)
    - `"%d/%m/%Y"`: European format (01/01/2024)
    - `"%m/%d/%Y"`: US format (01/01/2024)
    """

  # --- Affix Slots ---
  slot :inner_prefix,
    doc: """
    Content placed *inside* the date picker field's border, before the date display.
    Ideal for icons or short textual prefixes. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner prefix container."
  end

  slot :outer_prefix,
    doc: """
    Content placed *outside* and before the date picker field. Useful for buttons, dropdowns, or
    other interactive elements associated with the date picker's start. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer prefix container."
  end

  slot :inner_suffix,
    doc: """
    Content placed *inside* the date picker field's border, after the date display.
    Suitable for icons, clear buttons, or loading indicators. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the inner suffix container."
  end

  slot :outer_suffix,
    doc: """
    Content placed *outside* and after the date picker field. Useful for action buttons or
    other controls related to the date picker's end. Can be used multiple times.
    """ do
    attr :class, :any, doc: "CSS classes for styling the outer suffix container."
  end

  # --- End Affix Slots ---

  def date_picker(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
    value = normalize_value(if assigns.multiple, do: List.wrap(field.value), else: field.value)

    assigns
    |> assign(field: nil, id: assigns.id || field.id, errors: Enum.map(errors, &translate(&1)), value: value)
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> date_picker()
  end

  def date_picker(assigns) do
    value = normalize_value(assigns[:value] || if(assigns.multiple, do: [], else: nil))

    assigns
    |> assign(
      id: assigns.id || assigns.name,
      value: value,
      current_date: find_initial_date(assigns)
    )
    |> assign_new(:display_value, fn assigns ->
      format_date(assigns.value, assigns.display_format)
    end)
    |> assign_new(:selected_dates, fn assigns -> normalize_dates([assigns.value]) end)
    |> render_component()
  end

  defp render_component(assigns) do
    assigns =
      assigns
      |> assign_defaults()
      |> assign_time_values()
      |> assign(:styles, @styles)

    ~H"""
    <.date_picker_container {assigns}>
      <.label :if={@label} for={if not @inline, do: @id <> "-toggle"} sublabel={@sublabel} description={@description}>
        {@label}
      </.label>

      <.date_picker_field
        :if={not @inline}
        id={@id}
        disabled={@disabled}
        errors={@errors}
        size={@size}
        placeholder={@placeholder}
        display_value={@display_value}
        autofocus={@autofocus}
        styles={@styles}
        inner_prefix={@inner_prefix}
        outer_prefix={@outer_prefix}
        inner_suffix={@inner_suffix}
        outer_suffix={@outer_suffix}
      />

      <.calendar_wrapper
        id={@id}
        styles={@styles}
        hidden={not @inline}
        class={if @inline, do: [], else: ["fixed z-50 mt-1 w-full shadow-lg", @class]}
        phx-update="ignore"
      >
        <span :if={not @inline} id={"#{@id}-focus-start"} tabindex="0" aria-hidden="true"></span>
        <.calendar_header
          current_date={@current_date}
          navigation={@navigation}
          min={@min}
          max={@max}
          disabled={@disabled}
          styles={@styles}
        />

        <.calendar
          id={@id}
          week_start={@week_start}
          selected_dates={@selected_dates}
          current_date={@current_date}
          min={@min}
          max={@max}
          range={@range}
          disabled={@disabled}
          granularity={@granularity}
          disabled_dates={@disabled_dates}
          styles={@styles}
        />

        <.time_picker
          :if={@time_picker}
          time_format={@time_format}
          time={@time}
          disabled={Enum.empty?(@selected_dates) || @disabled}
          styles={@styles}
        />

        <.confirmation :if={@close == "confirm"} />

        <span :if={not @inline} id={"#{@id}-focus-end"} tabindex="0" aria-hidden="true"></span>
      </.calendar_wrapper>

      <div :if={@help_text} class="text-foreground-softer text-sm">{@help_text}</div>
      <.error :for={error <- @errors}>{error}</.error>
    </.date_picker_container>
    """
  end

  defp assign_defaults(assigns) do
    assigns
    |> assign_new(:range, fn -> false end)
    |> assign_new(:granularity, fn -> "day" end)
    |> assign_new(:time_picker, fn -> false end)
    |> assign_new(:multiple, fn -> false end)
    |> assign_new(:time_format, fn -> "12" end)
    |> then(fn assigns ->
      # Disable time_picker if granularity is not "day"
      time_picker = if assigns.granularity == "day", do: assigns.time_picker, else: false
      assign(assigns, :time_picker, time_picker)
    end)
  end

  attr :id, :string, required: true
  attr :disabled, :boolean, required: true
  attr :errors, :list, required: true
  attr :size, :string, required: true
  attr :placeholder, :string, required: true
  attr :display_value, :string, required: true
  attr :autofocus, :boolean, default: false
  attr :styles, :map, required: true
  attr :inner_prefix, :list, default: []
  attr :outer_prefix, :list, default: []
  attr :inner_suffix, :list, default: []
  attr :outer_suffix, :list, default: []

  defp date_picker_field(assigns) do
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
          type="button"
          id={@id <> "-toggle"}
          data-part="toggle"
          data-invalid={@errors != []}
          disabled={@disabled}
          aria-haspopup="true"
          aria-expanded="false"
          role="button"
          tabindex="0"
          autofocus={@autofocus}
          class={merge([@styles[:toggle], @styles[:size][@size][:toggle]])}
        >
          <div
            :for={slot <- @inner_prefix}
            data-part="inner-prefix"
            class={merge([@styles[:affix], @styles[:size][@size][:affix], slot[:class]])}
          >
            {render_slot(slot)}
          </div>

          <.calendar_icon :if={@inner_prefix == []} size={@size} styles={@styles} />

          <span class={merge([@styles[:toggle_text], @styles[:size][@size][:toggle_text]])}>
            <span data-part="toggle-text" data-placeholder={@placeholder}>{@display_value}</span>
          </span>

          <div
            :for={slot <- @inner_suffix}
            data-part="inner-suffix"
            class={merge([@styles[:affix], @styles[:size][@size][:affix], slot[:class]])}
          >
            {render_slot(slot)}
          </div>
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

  attr :id, :any, default: nil
  attr :week_start, :integer, default: 0, values: 0..6
  attr :selected_dates, :list, default: []
  attr :current_date, :any
  attr :min, :string, default: nil
  attr :max, :string, default: nil
  attr :range, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :granularity, :string, default: "day"
  attr :disabled_dates, :list, default: []
  attr :styles, :map, required: true

  defp calendar(assigns) do
    view_mode =
      case assigns[:granularity] || "day" do
        "month" -> "months"
        "year" -> "years"
        _ -> "days"
      end

    assigns =
      assigns
      |> assign(
        calendar_days: prepare_calendar_days(assigns),
        weekdays: get_ordered_weekdays(assigns.week_start),
        view_mode: view_mode
      )
      |> assign_new(:current_date, fn -> Date.utc_today() end)

    ~H"""
    <div class="p-2">
      <div
        class="grid grid-cols-7 text-center text-xs leading-6 text-foreground-softest mb-1 font-medium"
        role="row"
        aria-label="Week days"
        data-part="weekdays"
      >
        <div :for={day <- @weekdays} role="columnheader" aria-label={day}>
          {day}
        </div>
      </div>
      <div
        data-part="calendar"
        role="row"
        class="grid auto-rows-min gap-0.5 text-sm data-[view='days']:grid-cols-7 data-[view='months']:grid-cols-3 data-[view='years']:grid-cols-3"
        data-view={@view_mode}
      >
        <button
          :for={day <- @calendar_days}
          type="button"
          role="gridcell"
          aria-selected={day.date in @selected_dates}
          tabindex={if day.date == @current_date, do: 0, else: -1}
          data-date={format_date(day.date, "%Y-%m-%d")}
          data-selected={day.date in @selected_dates}
          data-view={@view_mode}
          disabled={day.disabled? || @disabled}
          aria-disabled={day.disabled?}
          data-disabled={day.disabled?}
          data-other-month={day.other_month?}
          data-today={day.today?}
          data-range-start={day.range_start?}
          data-range-end={day.range_end?}
          data-in-range={day.in_range?}
          data-weekend={day.weekend?}
          data-weekday={!day.weekend?}
          class={@styles[:day_button]}
        >
          <span data-part="date-text" class="pointer-events-none">{day.date.day}</span>
          <span class="pointer-events-none absolute bottom-1 left-1/2 -translate-x-1/2 h-0.5 w-3 bg-current rounded-full hidden in-data-today:block">
          </span>
        </button>
      </div>
      <template data-part="day-template">
        <button type="button" role="gridcell" class={@styles[:day_button]}>
          <span data-part="date-text" class="pointer-events-none"></span>

          <span class="pointer-events-none absolute bottom-1 left-1/2 -translate-x-1/2 h-0.5 w-3 bg-current rounded-full hidden in-data-today:block">
          </span>
        </button>
      </template>
    </div>
    """
  end

  defp calendar_header(assigns) do
    assigns =
      assigns
      |> assign(
        years_range: get_years_range(assigns.min, assigns.max),
        current_month: assigns.current_date.month - 1,
        current_year: assigns.current_date.year,
        prev_month_disabled: is_navigation_disabled?(assigns.current_date, assigns.min, assigns.max, :prev_month),
        next_month_disabled: is_navigation_disabled?(assigns.current_date, assigns.min, assigns.max, :next_month),
        prev_year_disabled: is_navigation_disabled?(assigns.current_date, assigns.min, assigns.max, :prev_year),
        next_year_disabled: is_navigation_disabled?(assigns.current_date, assigns.min, assigns.max, :next_year)
      )

    ~H"""
    <div class={[
      "grid p-2 gap-x-2",
      @navigation == "default" && "grid-cols-[auto_1fr_auto]",
      @navigation == "extended" && "grid-cols-[auto_auto_1fr_auto_auto]",
      @navigation == "select" && "grid-cols-[auto_1fr_auto_auto]"
    ]}>
      <.navigation_button
        :if={@navigation == "extended"}
        part="prev-year"
        disabled={@prev_year_disabled || @disabled}
        label="Previous year"
      >
        <.prev_year_icon />
      </.navigation_button>

      <.navigation_button part="prev-month" disabled={@prev_month_disabled || @disabled} label="Previous month">
        <.prev_month_icon />
      </.navigation_button>

      <select
        :if={@navigation == "select"}
        data-part="month-select"
        name="month"
        class={@styles[:select_navigation]}
        disabled={@disabled}
      >
        <option value="0" selected={@current_month == 0}>January</option>
        <option value="1" selected={@current_month == 1}>February</option>
        <option value="2" selected={@current_month == 2}>March</option>
        <option value="3" selected={@current_month == 3}>April</option>
        <option value="4" selected={@current_month == 4}>May</option>
        <option value="5" selected={@current_month == 5}>June</option>
        <option value="6" selected={@current_month == 6}>July</option>
        <option value="7" selected={@current_month == 7}>August</option>
        <option value="8" selected={@current_month == 8}>September</option>
        <option value="9" selected={@current_month == 9}>October</option>
        <option value="10" selected={@current_month == 10}>November</option>
        <option value="11" selected={@current_month == 11}>December</option>
      </select>

      <select
        :if={@navigation == "select"}
        data-part="year-select"
        name="year"
        class={@styles[:select_navigation]}
        disabled={@disabled}
      >
        <option :for={year <- @years_range} value={year} selected={year == @current_year}>{year}</option>
      </select>

      <div
        :if={@navigation == "default" || @navigation == "extended"}
        data-part="current-month-title"
        class="text-sm font-medium text-foreground flex items-center justify-center"
      >
        {Calendar.strftime(@current_date, "%B %Y")}
      </div>

      <.navigation_button part="next-month" disabled={@next_month_disabled || @disabled} label="Next month">
        <.next_month_icon />
      </.navigation_button>

      <.navigation_button
        :if={@navigation == "extended"}
        part="next-year"
        disabled={@next_year_disabled || @disabled}
        label="Next year"
      >
        <.next_year_icon />
      </.navigation_button>
    </div>
    """
  end

  defp get_years_range(min, max) do
    current_year = Date.utc_today().year
    min_year = current_year - 100

    start_year =
      case parse_date(min) do
        nil -> min_year
        date -> max(date.year, min_year)
      end

    end_year =
      case parse_date(max) do
        nil -> current_year
        date -> date.year
      end

    start_year..end_year
  end

  defp date_picker_container(assigns) do
    ~H"""
    <div
      id={@id <> "-container"}
      phx-hook="Fluxon.DatePicker"
      class="w-full flex flex-col gap-y-2"
      data-display-format={@display_format}
      data-week-start={@week_start}
      data-min={@min}
      data-max={@max}
      data-disabled-dates={serialize_disabled_dates(@disabled_dates)}
      data-range={@range}
      data-inline={@inline}
      data-multiple={@multiple}
      data-time-picker={@time_picker}
      data-close={@close}
      data-time-format={@time_format}
      data-granularity={@granularity}
    >
      <div :if={@multiple} class="contents">
        <input :if={Enum.empty?(@value)} type="text" hidden name={@name} value="" data-part="input" />
        <input
          :for={value <- @value}
          :if={!Enum.empty?(@value)}
          type="text"
          hidden
          name={@name}
          value={value}
          data-part="input"
        />
      </div>
      <input :if={!@range && !@multiple} type="text" hidden name={@name} value={@value} data-part="input" />
      <input :if={@range} type="text" hidden name={@start_name} value={@start_value} data-part="input-start" />
      <input :if={@range} type="text" hidden name={@end_name} value={@end_value} data-part="input-end" />

      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :help_text, :string, default: nil
  attr :errors, :list, default: []
  attr :id, :string, required: true
  attr :styles, :map, required: true
  attr :class, :any, default: nil
  attr :hidden, :boolean, default: false
  attr :rest, :global

  slot :inner_block, required: true

  defp calendar_wrapper(assigns) do
    ~H"""
    <div
      data-part="wrapper"
      role="dialog"
      aria-modal="true"
      aria-label="Choose date"
      class={merge([@styles[:calendar_wrapper], @class])}
      data-animation="transition duration-150 ease-in-out"
      data-animation-enter="opacity-100 scale-100"
      data-animation-leave="opacity-0 scale-95"
      id={@id <> "-calendar"}
      hidden={@hidden}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp prev_month_icon(assigns) do
    ~H"""
    <svg class="size-4 text-foreground-softer" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M15 6L9 12.0001L15 18"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-miterlimit="16"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    """
  end

  defp next_month_icon(assigns) do
    ~H"""
    <svg class="size-4 text-foreground-softer" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M9.00005 6L15 12L9 18"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-miterlimit="16"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    """
  end

  defp prev_year_icon(assigns) do
    ~H"""
    <svg class="size-4 text-foreground-softer" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M11.5 6L5.5 12L11.5 18"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M18.5 6L12.5 12L18.5 18"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    """
  end

  defp next_year_icon(assigns) do
    ~H"""
    <svg class="size-4 text-foreground-softer" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M12.5 6L18.5 12L12.5 18"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <path
        d="M5.5 6L11.5 12L5.50005 18"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    """
  end

  attr :part, :string, required: true
  attr :disabled, :boolean, required: true
  attr :label, :string, required: true
  slot :inner_block, required: true

  defp navigation_button(assigns) do
    ~H"""
    <button
      type="button"
      data-part={@part}
      disabled={@disabled}
      class={[
        "[&:not([hidden])]:flex items-center justify-center rounded-base",
        "[&:not([disabled])]:hover:bg-accent",
        "[&[disabled]]:opacity-50",
        "border border-base",
        "[&:not([disabled])]:shadow-xs p-1.5",
        "aspect-square"
      ]}
      aria-label={@label}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  attr :time, :map, required: true
  attr :styles, :map, required: true
  attr :disabled, :boolean, default: false
  attr :show_seconds, :boolean, default: false
  attr :time_format, :string, required: true

  defp time_picker(assigns) do
    ~H"""
    <div
      class={[
        "flex gap-x-2 [&>span]:text-foreground-softest px-4 py-3 border-t border-base items-center"
      ]}
      data-show-seconds={@show_seconds}
    >
      <input
        type="number"
        disabled={@disabled}
        aria-role="spinbutton"
        aria-valuenow={@time.hour}
        aria-valuetext={@time.hour}
        aria-label="Hour"
        aria-valuemin="0"
        aria-valuemax="23"
        autocomplete="off"
        autocorrect="off"
        autocapitalize="off"
        spellcheck="false"
        data-1p-ignore
        data-part="hour-input"
        min="0"
        max="23"
        value={@time.hour}
        class={@styles[:time_input]}
      />
      <span class="text-foreground-softest text-sm">:</span>
      <input
        type="number"
        disabled={@disabled}
        aria-role="spinbutton"
        aria-valuenow={@time.minute}
        aria-valuetext={@time.minute}
        aria-label="Minute"
        aria-valuemin="0"
        aria-valuemax="59"
        autocomplete="off"
        autocorrect="off"
        autocapitalize="off"
        spellcheck="false"
        data-1p-ignore
        data-part="minute-input"
        min="0"
        max="59"
        value={@time.minute}
        class={@styles[:time_input]}
      />
      <span class="text-foreground-softest text-sm hidden in-data-show-seconds:block">:</span>
      <input
        type="number"
        disabled={@disabled}
        aria-role="spinbutton"
        aria-valuenow={@time.second}
        aria-valuetext={@time.second}
        aria-label="Second"
        aria-valuemin="0"
        aria-valuemax="59"
        autocomplete="off"
        autocorrect="off"
        autocapitalize="off"
        spellcheck="false"
        data-1p-ignore
        data-part="second-input"
        min="0"
        max="59"
        value={@time.second}
        class={[@styles[:time_input], "hidden in-data-show-seconds:block"]}
      />
      <select
        :if={@time_format == "12"}
        disabled={@disabled}
        data-part="am-pm-select"
        aria-label="AM/PM"
        aria-valuenow={@time.period}
        aria-valuetext={@time.period}
        autocomplete="off"
        autocorrect="off"
        autocapitalize="off"
        spellcheck="false"
        data-1p-ignore
        class={[@styles[:time_input], "shrink"]}
      >
        <option value="am" selected={@time.period == "am"}>AM</option>
        <option value="pm" selected={@time.period == "pm"}>PM</option>
      </select>
    </div>
    """
  end

  defp confirmation(assigns) do
    ~H"""
    <div class="flex gap-x-4 items-center justify-end px-4 py-3 *:flex-1 border-t border-base">
      <.button type="button" size="sm" data-part="cancel-button">Cancel</.button>
      <.button
        disabled
        type="button"
        size="sm"
        variant="solid"
        color="primary"
        data-part="apply-button"
        class="transition-opacity duration-200 disabled:opacity-50"
      >
        Apply
      </.button>
    </div>
    """
  end

  attr :size, :string, required: true
  attr :styles, :map, required: true

  defp calendar_icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      class={merge([@styles[:calendar_icon], @styles[:calendar_icon_size][@size]])}
      viewBox="0 0 24 24"
    >
      <path
        fill="currentColor"
        d="M3 8.8c0-1.68 0-2.52.33-3.16a3 3 0 0 1 1.3-1.31C5.29 4 6.13 4 7.8 4h8.4c1.68 0 2.52 0 3.16.33a3 3 0 0 1 1.31 1.3c.33.65.33 1.49.33 3.17V10H3z"
        opacity=".12"
      />
      <path
        stroke="currentColor"
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M21 10H3m13-8v4M8 2v4m-.2 16h8.4c1.68 0 2.52 0 3.16-.33a3 3 0 0 0 1.31-1.3c.33-.65.33-1.49.33-3.17V8.8c0-1.68 0-2.52-.33-3.16a3 3 0 0 0-1.3-1.31C18.71 4 17.87 4 16.2 4H7.8c-1.68 0-2.52 0-3.16.33a3 3 0 0 0-1.31 1.3C3 6.29 3 7.13 3 8.8v8.4c0 1.68 0 2.52.33 3.16a3 3 0 0 0 1.3 1.31c.65.33 1.49.33 3.17.33"
      />
    </svg>
    """
  end

  defp normalize_value(nil), do: nil
  defp normalize_value([]), do: []
  defp normalize_value([value]), do: parse_value(value)

  defp normalize_value(values) when is_list(values) do
    values
    |> Enum.map(&parse_value/1)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_value(value), do: parse_value(value)

  defp parse_value(nil), do: nil
  defp parse_value(%Date{} = date), do: date
  defp parse_value(%DateTime{} = datetime), do: datetime
  defp parse_value(%NaiveDateTime{} = naive_datetime), do: naive_datetime

  defp parse_value(value) when is_binary(value) do
    cond do
      # Try parsing as Date first (for date-only strings like "2025-02-10")
      match?({:ok, _}, Date.from_iso8601(value)) ->
        {:ok, parsed_date} = Date.from_iso8601(value)
        parsed_date

      # Try parsing as DateTime (for datetime strings like "2025-02-10T12:01:30Z")
      match?({:ok, _, _}, DateTime.from_iso8601(value)) ->
        {:ok, parsed_datetime, _} = DateTime.from_iso8601(value)
        parsed_datetime

      # Try parsing as NaiveDateTime (for naive datetime strings like "2025-02-10T12:01:30")
      match?({:ok, _}, NaiveDateTime.from_iso8601(value)) ->
        {:ok, parsed_naive_datetime} = NaiveDateTime.from_iso8601(value)
        parsed_naive_datetime

      # If all parsing attempts fail, return nil for invalid values
      true ->
        nil
    end
  end

  defp parse_value(_), do: nil

  # Serialize disabled dates into a single unified format
  # Converts all patterns (dates, ranges, atoms, tuples) into a flat JSON array.
  # Consider use 
  defp serialize_disabled_dates([]), do: nil

  defp serialize_disabled_dates(disabled_dates) do
    items =
      disabled_dates
      |> Enum.flat_map(fn
        # Date structs -> ISO string
        %Date{} = date ->
          [~s("#{Date.to_iso8601(date)}")]

        # Date ranges -> expand to individual ISO strings
        %Date.Range{} = range ->
          range |> Enum.to_list() |> Enum.map(&~s("#{Date.to_iso8601(&1)}"))

        # Shortcut patterns
        :weekends ->
          [~s("weekends")]

        :weekdays ->
          [~s("weekdays")]

        # Day of month pattern -> "day:N"
        {:day, day} ->
          [~s("day:#{day}")]

        # Weekday pattern -> "weekday:N" (1=Monday, 7=Sunday)
        {:weekday, weekday} ->
          [~s("weekday:#{weekday}")]

        # ISO week pattern -> "week:N"
        {:week, week} ->
          [~s("week:#{week}")]

        # Month-day pattern -> "month_day:M:D"
        {:month_day, month, day} ->
          [~s("month_day:#{month}:#{day}")]

        # Month pattern -> "month:N"
        {:month, month} ->
          [~s("month:#{month}")]

        # Year pattern -> "year:N"
        {:year, year} ->
          [~s("year:#{year}")]

        # Ignore unknown items
        _ ->
          []
      end)

    if Enum.empty?(items) do
      nil
    else
      "[#{Enum.join(items, ",")}]"
    end
  end

  defp assign_time_values(%{time_picker: true, value: %{hour: hour, minute: minute, second: second}} = assigns) do
    {hour, period} =
      if assigns.time_format == "12" do
        cond do
          hour == 0 -> {12, "am"}
          hour == 12 -> {12, "pm"}
          hour > 12 -> {hour - 12, "pm"}
          true -> {hour, "am"}
        end
      else
        {hour, nil}
      end

    time = %{
      hour: pad_time(hour),
      minute: pad_time(minute),
      second: pad_time(second),
      period: period
    }

    assign(assigns, :time, time)
  end

  defp assign_time_values(%{time_picker: true, value: _, time_format: time_format} = assigns) do
    default_hour = if time_format == "12", do: "12", else: "00"
    time = %{hour: default_hour, minute: "00", second: "00", period: "am"}
    assign(assigns, :time, time)
  end

  defp assign_time_values(assigns), do: assigns

  defp pad_time(number), do: String.pad_leading("#{number}", 2, "0")

  defp find_initial_date(assigns) do
    today = Date.utc_today()
    bounds = %{min: parse_date(assigns[:min]), max: parse_date(assigns[:max])}

    candidate_dates =
      if assigns[:range] do
        [assigns[:start_value], assigns[:end_value], today]
      else
        [assigns[:value], today]
      end

    candidate_dates
    |> Enum.map(&parse_date/1)
    |> Enum.concat([bounds.min, bounds.max])
    |> Enum.reject(&is_nil/1)
    |> Enum.find(&(!is_date_disabled?(&1, bounds.min, bounds.max))) || today
  end

  defp parse_date(value)
  defp parse_date(nil), do: nil
  defp parse_date(%Date{} = date), do: date
  defp parse_date([first | _]), do: parse_date(first)

  defp parse_date(value) do
    case parse_value(value) do
      %Date{} = date -> date
      %DateTime{} = datetime -> DateTime.to_date(datetime)
      %NaiveDateTime{} = naive_datetime -> NaiveDateTime.to_date(naive_datetime)
      _ -> nil
    end
  end

  defp is_date_disabled?(date, min_date, max_date) do
    cond do
      min_date && Date.compare(date, min_date) == :lt -> true
      max_date && Date.compare(date, max_date) == :gt -> true
      true -> false
    end
  end

  # Check if date is disabled by custom disabled_dates list
  defp is_date_disabled_by_custom?(date, disabled_dates) when is_list(disabled_dates) do
    Enum.any?(disabled_dates, fn item ->
      case item do
        # Check against specific dates
        %Date{} = disabled_date ->
          Date.compare(date, disabled_date) == :eq

        # Check against date ranges
        %Date.Range{} = range ->
          date in range

        # Check against weekends pattern
        :weekends ->
          Date.day_of_week(date) in [6, 7]

        # Check against weekdays pattern
        :weekdays ->
          Date.day_of_week(date) in [1, 2, 3, 4, 5]

        # Check against day of month pattern (e.g., {:day, 15} disables 15th of every month)
        {:day, day} ->
          date.day == day

        # Check against weekday pattern (1=Monday, 7=Sunday)
        {:weekday, weekday} ->
          Date.day_of_week(date) == weekday

        # Check against ISO week pattern
        {:week, week} ->
          {_year, date_week} = :calendar.iso_week_number(Date.to_erl(date))
          date_week == week

        # Check against month-day pattern (recurring annual dates)
        {:month_day, month, day} ->
          date.month == month and date.day == day

        # Check against month pattern (any year)
        {:month, month} ->
          date.month == month

        # Check against year pattern (all dates in that year)
        {:year, year} ->
          date.year == year

        # Ignore unknown patterns
        _ ->
          false
      end
    end)
  end

  defp is_date_disabled_by_custom?(_, _), do: false

  defp prepare_calendar_days(assigns) do
    %{current_date: current_date, week_start: week_start} = assigns
    min_date = parse_date(assigns.min)
    max_date = parse_date(assigns.max)
    today = Date.utc_today()

    first_of_month = Date.beginning_of_month(current_date)
    days_before = rem(Date.day_of_week(first_of_month) - week_start + 7, 7)
    start_date = Date.add(first_of_month, -days_before)

    start_date
    |> Date.range(Date.add(start_date, 41))
    |> Enum.map(fn date ->
      range_state = if assigns.range, do: get_range_state(date, assigns.selected_dates), else: %{}

      disabled? =
        is_date_disabled?(date, min_date, max_date) ||
          is_date_disabled_by_custom?(date, assigns.disabled_dates) ||
          assigns.disabled

      %{
        date: date,
        selected?: date in assigns.selected_dates,
        disabled?: disabled?,
        other_month?: date.month != current_date.month,
        today?: Date.compare(date, today) == :eq,
        weekend?: Date.day_of_week(date) in [6, 7],
        weekday?: Date.day_of_week(date) not in [6, 7],
        range_start?: range_state[:is_start],
        range_end?: range_state[:is_end],
        in_range?: range_state[:is_in_range]
      }
    end)
  end

  defp format_date(value, format)
  defp format_date(nil, _format), do: nil
  defp format_date([], _format), do: nil
  defp format_date([date], format), do: format_single_date(date, format)
  defp format_date([_ | _] = dates, _format), do: "#{length(dates)} dates selected"
  defp format_date(date, format), do: format_single_date(date, format)

  defp format_single_date(date, format) do
    Calendar.strftime(date, format)
  end

  defp format_range_dates(start_date, end_date, format)
       when not is_nil(start_date) and not is_nil(end_date),
       do: "#{format_date(start_date, format)} - #{format_date(end_date, format)}"

  defp format_range_dates(date, nil, format) when not is_nil(date),
    do: format_date(date, format)

  defp format_range_dates(_, _, _), do: nil

  defp get_range_state(date, selected_dates) do
    case selected_dates |> Enum.take(2) |> Enum.map(&parse_date/1) |> Enum.reject(&is_nil/1) do
      [start_date, end_date] -> get_range_position(date, start_date, end_date)
      [single_date] -> if date == single_date, do: %{is_start: true}, else: %{}
      _ -> %{}
    end
  end

  defp get_range_position(date, start_date, end_date) do
    cond do
      date == start_date ->
        %{is_start: true}

      date == end_date ->
        %{is_end: true}

      Date.compare(date, start_date) == :gt && Date.compare(date, end_date) == :lt ->
        %{is_in_range: true}

      true ->
        %{}
    end
  end

  defp normalize_dates(dates) do
    dates
    |> List.wrap()
    |> List.flatten()
    |> Enum.map(&parse_date/1)
    |> Enum.reject(&is_nil/1)
  end

  defp is_navigation_disabled?(current_date, min, max, direction) do
    bounds = %{min: parse_date(min), max: parse_date(max)}
    target_date = get_navigation_target_date(current_date, direction)
    is_date_disabled?(target_date, bounds.min, bounds.max)
  end

  defp get_navigation_target_date(date, direction) do
    case direction do
      :prev_month -> date |> Date.beginning_of_month() |> Date.add(-1)
      :next_month -> date |> Date.end_of_month() |> Date.add(1)
      :prev_year -> %{date | year: date.year - 1} |> Date.end_of_month()
      :next_year -> %{date | year: date.year + 1} |> Date.beginning_of_month()
    end
  end

  defp get_ordered_weekdays(week_start) do
    weekdays = ~w(Sun Mon Tue Wed Thu Fri Sat)
    {first, rest} = Enum.split(weekdays, week_start)
    rest ++ first
  end
end
