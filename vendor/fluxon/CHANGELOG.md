# Changelog

## v2.3.1 (2025-11-14)

### Bug Fixes

- **Popover & Tabs**: Fixed an issue where clicking links inside popovers containing tabs would trigger an aria-hidden accessibility warning.
- **Modal & Sheet**: Fixed an issue where nested modals would both close when clicking the "X (close)" button on the inner modal and body overflow would remain locked after closing all modals.
- Fixed an issue where dialog close events were being logged to the console.

## v2.3.0 (2025-10-28)

### New

- **DatePicker**: Added `disabled_dates` attribute for flexible date disabling beyond min/max constraints. Supports disabling specific dates, date ranges, and pattern-based matching including weekends, weekdays, day of month, ISO weeks, recurring annual dates, entire months, and years.

  ```heex
  <.date_picker
    name="availability"
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

## v2.2.1 (2025-10-26)

### Bug Fixes

- **Loading**: Fixed an issue where multiple loading components on the same page caused duplicate ID errors in SVG animations. Each loading component instance now generates unique animation IDs.

## v2.2.0 (2025-10-22)

### Enhancements

- **DatePicker**: Added `granularity` attribute with support for `day`, `month`, and `year` modes. The calendar now renders month or year grids when using non-day granularity, with automatic date normalization and display format adjustments.
- **Select & Autocomplete**: Improved rendering of multi-level nested optgroups with proper visual indentation for deeply nested option groups.
- **Checkbox & Switch**: Added `checked_value` and `unchecked_value` attributes to support custom form values. Components now allow specifying what values are submitted when checked or unchecked (e.g., `"1"`/`"0"`, `"yes"`/`"no"`). Defaults to `"true"`/`"false"` for backward compatibility.

### Bug Fixes

- **Theme**: Fixed an issue where semantic color backgrounds were semi-transparent, causing underlying UI elements to show through when used as positioned overlays. Alert and other semantic components now use solid backgrounds.
- **Input**: Fixed an issue where hidden inputs were visually rendering as text inputs. Hidden inputs now render without any additional markup or styling.

### Breaking Changes

- **Select**: The native select now only renders a placeholder option when the `placeholder` attribute is explicitly provided. Previously, an empty placeholder option was always included even when no placeholder was specified. To maintain the previous behavior of always showing an empty option, pass `placeholder=""` (empty string) to the native select component.

## v2.1.0 (2025-08-31)

### New

- **Usage Rules**: Added support for [usage_rules](https://github.com/ash-project/usage_rules).

### Enhancements

- **Button**: Improved icon spacing consistency across all button sizes for better visual alignment.

### Bug Fixes

- **DatePicker**: Fixed time input spinner arrows appearing in Firefox which caused broken state when interacting with them. The spinners are now hidden consistently across all browsers.
- **Dropdown, Select, Tooltip, Popover, DatePicker, Autocomplete**: Fixed an issue where floating elements would appear in the wrong position when used inside modals or sheets, especially after scrolling.

### Breaking Changes

- **DatePicker**: The time input fields (`time-hour`, `time-minute`, `time-second`) are no longer submitted with the form data. If you were relying on these separate time fields in your form submissions, you'll need to update your code to use the main datetime field instead.

## v2.0.0 (2025-08-19)

### Theming

This release introduces a theming system for **Fluxon UI** built on semantic colors and design tokens, replacing hardcoded color values with a token-based architecture that adapts to light and dark modes.

The Fluxon UI theming system is based on CSS custom properties (design tokens) that provide semantic meaning to colors. Instead of using specific TailwindCSS color names like `blue-500` or `red-600`, Fluxon UI components now use semantic colors (`primary`, `info`, `success`, `warning`, `danger`) that convey intent and meaning. This approach utilizes meaningful color names that convey purpose instead of specific hues, backed by CSS custom properties for colors, backgrounds and borders. The design system integrates with TailwindCSS, utilizing its utility-first approach while providing semantic theming capabilities across all Fluxon UI components.

**Theme Customization**

The theming system supports customization through CSS custom properties. When you override theme tokens, all Fluxon UI components automatically adapt to use the new colors, borders, shadows, and other design elements:

```css
:root {
  /* Custom primary color - purple theme */
  --primary: light-dark(#7c3aed, #a855f7);

  /* Custom background colors */
  --background-base: light-dark(#fafafa, #0a0a0a);

  /* Custom semantic colors */
  --success: #10b981;
  --warning: #f59e0b;
}
```

### New

- **Button**: Added a new `surface` variant, which provides a bordered, subtle background ideal for contained secondary actions.
- **Button**: Added icon-only sizes (`icon-xs`, `icon-sm`, `icon-md`, `icon`, `icon-lg`, `icon-xl`) for creating square buttons with centered icons.
- **Button**: New `button_group` component to visually group multiple buttons together.
- **Badge**: Introduced a full set of variants: `solid`, `soft`, `surface` (default), `outline`, `dashed`, and `ghost`.
- **Badge**: Added more sizing options with new `xs`, `sm` (default), `md`, `lg`, and `xl` sizes.
- **Checkbox**: Added support for the indeterminate state, which displays a dash icon to indicate that the checkbox is neither checked nor unchecked.
- **Switch**: Added support for the `rest` attribute, allowing additional HTML attributes to be passed directly to the underlying input element.
- **Select**: Added support for multiple affix slots (`inner_prefix`, `inner_suffix`, `outer_prefix`, `outer_suffix`).
- **Select**: Added `xs` size.
- **Autocomplete**: Added support for multiple affix slots (`inner_prefix`, `inner_suffix`, `outer_prefix`, `outer_suffix`).
- **Autocomplete**: Added `xs` and `xl` sizes.
- **Input**: Added support for multiple affix slots (`inner_prefix`, `inner_suffix`, `outer_prefix`, `outer_suffix`).
- **Input**: Added `xs` size.
- **Input**: New `input_group` component to visually group multiple inputs together.
- **DatePicker**: Added support for multiple affix slots (`inner_prefix`, `inner_suffix`, `outer_prefix`, `outer_suffix`).
- **DatePicker**: Added `xs` size.
- **Tabs**: Added size support with `xs`, `sm`, and `md` (default) options.
- **Popover**: Added programmatic control support with `Fluxon.open_popover/1` and `Fluxon.close_popover/1` functions for client-side popover management.
- **Form Components**: Added support for the `form` attribute on all form components (Autocomplete, Checkbox, Radio, Select, Switch), allowing form inputs to be associated with forms anywhere in the document.

### Enhancements

- **Form Components & Tabs**: Adjusted default height sizes to be more compact. The default `md` size is now 36px (previously 40px) while maintaining a 4px linear scale across all sizes.
- **Button**: The component now automatically renders as a link (`<a>`) if `href`, `navigate`, or `patch` attributes are provided.
- **Button**: Added support for the `disabled` attribute on link buttons. When a button with `href`, `navigate`, or `patch` is disabled it becomes non-interactive, preventing navigation or patching actions.
- **Modal & Sheet**: Fixed an issue where dialogs were pushing down page content instead of overlaying it. Dialogs now properly use fixed positioning to prevent layout shifts.

### Breaking Changes

- **Alert**: The `variant` attribute has been removed to standardize on the `color` attribute. Alerts now use `color` to define their appearance, accepting `primary`, `danger`, `warning`, `success`, and `info`.
- **Button**: Variants have been updated for consistency. `variant="primary"` is now `variant="solid" color="primary"`, and `variant="secondary"` is now `variant="soft" color="primary"`.
- **Badge**: The `pill` variant is replaced by `class="rounded-full"`, and the `flat` variant is now `soft`. The default variant has been renamed to `surface`.
- **Badge**: Direct support for all TailwindCSS colors has been removed. Badges now use a semantic color palette: `primary`, `danger`, `warning`, `success`, and `info`. For custom colors, you can use the `class` attribute to apply custom background, text, and border styles.
- **Forms**: The default size `base` has been renamed to `md` across all form components (`Select`, `Switch`, `Autocomplete`, `Input`, `DatePicker`) to ensure consistent sizing options.
- **Input**: The `inner_prefix` and `inner_suffix` slots no longer require manual padding adjustments. The component now handles this automatically.
- **Switch**: The `color` attribute now only accepts semantic colors: `primary`, `danger`, `success`, `warning`, and `info`.

## v1.2.0 (2025-07-03)

### New

- **Gettext**: Added built-in support for translating validation errors across all form components. You can now configure a translation function to handle Phoenix validation error messages with Gettext or custom translation logic. See the [Error Translation guide](guides/intro/gettext.md) for setup instructions.

## v1.1.4 (2025-06-13)

### Bug Fixes

- **Select**: Fixed an issue where the search input would lose focus after making a selection in multiple selection mode with search enabled ([#82](https://github.com/fluxonui/fluxon/issues/82))

## v1.1.3 (2025-06-12)

### Enhancements

- **Select**: Added server-side search support. The Select component now supports server-side filtering by setting the `on_search` attribute to a LiveView event name.
- **Dropdown**: Added better dark mode support for highlighted dropdown items ([#78](https://github.com/fluxonui/fluxon/issues/78))
- **Accordion**: Added support for additional HTML attributes to be applied to the accordion container and accordion item. ([#72](https://github.com/fluxonui/fluxon/issues/72))

### Bug Fixes

- **DatePicker**: Fixed an issue where datetime strings were not properly parsed when provided as values to the DatePicker component ([#71](https://github.com/fluxonui/fluxon/issues/71))
- **DatePicker**: Fixed an issue in the DatePicker component where selecting a date in the datetime picker caused subtle visual jitter ([#63](https://github.com/fluxonui/fluxon/issues/63))

## v1.1.2 (2025-05-12)

### Enhancements

- **DatePicker**: Prevent the time inputs from displaying spin buttons in Firefox ([#70](https://github.com/fluxonui/fluxon/issues/70))

## v1.1.1 (2025-04-17)

### Bug Fixes

- **DatePicker**: Fixed an issue in the DatePicker component where calendar grid cells were expanding to an incorrect height in Safari. Fix [#63](https://github.com/fluxonui/fluxon/issues/63).

## v1.1.0 (2025-04-14)

### Tailwind CSS v4

Components have been updated to support Tailwind CSS v4. This involved refactoring internal utility classes and state variant syntax to align with the latest version. As a result, this release is fully compatible with Phoenix 1.8. For more details on setup, see the [installation guide](https://fluxonui.com/getting-started/installation).

### Enhancements

- **DatePicker**: The toggle button now defaults to `w-full`, ensuring it expands to the full width of its container for a more consistent layout.
- **Dropdown**: Menu items (buttons and links) now correctly apply `cursor-pointer` by default, enhancing visual feedback for interactivity.
- **Dropdown**: Icons within menu items no longer apply a default text color. They now inherit color directly from the parent item, simplifying style customization and ensuring visual consistency.
- **Autocomplete**: Added a new `debounce` attribute to the Autocomplete component. This integer attribute, defaulting to 200 milliseconds, controls the delay before triggering the `on_search` event for server-side searches.

### Bug Fixes

- **Autocomplete**: Fixed an issue where the autocomplete's clear button did not properly clear the input value.

### Deprecations

- The `skip_conflicts: true` option for component imports is now deprecated. Please use the `:only` and `:except` options for more explicit control over imported components. Refer to the [installation guide](https://fluxonui.com/getting-started/installation#component-conflicts) for updated usage.

## v1.0.25 (2025-03-31)

### Enhancements

- **Select, Autocomplete, DatePicker**: The positioning of the floating elements has been changed from `absolute` to `fixed`. This prevents listbox from being clipped by parent elements with `overflow: hidden`.
- **Modal, Sheet**: The components now prevent unintended closure when dragging from inside to outside the dialog. This enhancement improves usability by allowing users to interact with dialog content, such as text selection, without accidentally closing the dialog when the mouse is released outside its boundaries.

## v1.0.24 (2025-03-26)

### Bug Fixes

- **Select**: Fixed an issue where the select component was emitting duplicate "change" events when in searchable mode.

## v1.0.23 (2025-03-25)

### Enhancements

- **Autocomplete**: Added support for clearing the autocomplete selection with a new clear button. The `clearable` attribute can now be used to enable this feature. When enabled, a clear button appears next to the input field when a selection is made. Clicking the button clears the current selection.
- **Dropdown**: Added support for disabled dropdown items. The Dropdown component now respects `disabled`, `data-disabled`, and `aria-disabled` attributes on menu items. Keyboard navigation and mouse interactions will skip over disabled items.
- **Autocomplete, Select**: Added support for custom header and footer content in the Select and Autocomplete components. Users can now include additional elements like action buttons or filters at the top and bottom of the listbox using the new `:header` and `:footer` slots. These slots accept a `class` attribute for custom styling.
- **Select**: The "Clear selection" button is now keyboard accessible with `tabindex="0"`, allowing users to interact with it using keyboard navigation.

## v1.0.22 (2025-03-13)

### Enhancements

- **Autocomplete**: Search event payload now includes the input element's ID. This enhancement allows developers to more easily identify which specific autocomplete instance triggered a search event in multi-input scenarios. The `id` property is now available in the event payload alongside the existing `query` property when handling autocomplete search events.
- **Dropdown**: Added automatic closing of the dropdown menu when a menu item is clicked. This behavior improves usability by closing the menu after a selection is made, particularly useful for button-type menu items that don't trigger page navigation.

### Bug Fixes

- **Autocomplete, DatePicker**: Fixed an issue where the fields were triggering premature validations during phx-change events. It now prevents validation from occurring before user interaction with the field. Fix [#51](https://github.com/fluxonui/fluxon/issues/51).
- **Autocomplete**: Fixed an issue where the component's selection state was not properly cleared when the input was emptied. Now, when the input value is cleared (e.g., using Cmd+Backspace), the component correctly resets its internal selection state. This ensures that the component's state remains consistent with the empty input, preventing potential conflicts between the displayed value and the internal selection.
- **DatePicker**: Fixed an issue where changing the field value via LiveView did not update the DatePicker selection. The component now synchronizes correctly with LiveView updates, ensuring accurate highlighting in the calendar. Fix [#54](https://github.com/fluxonui/fluxon/issues/54).
- **DatePicker**: Fixed an issue where the AM/PM select was not correctly updating to "PM" when a time after 12:00 PM was set.
