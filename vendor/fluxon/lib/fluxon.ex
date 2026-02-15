defmodule Fluxon do
  @moduledoc """

  To use Fluxon components in your LiveView or View modules, add the following to your module:

  ```elixir
  use Fluxon
  ```

  This will import all available components. You can customize which components to import
  using the following options:

  * `:only` - List of components to import. Only the specified components will be imported.
    ```elixir
    use Fluxon, only: [:button, :input, :modal]
    ```

  * `:except` - List of components to exclude. All components except the specified ones will be imported.
    ```elixir
    use Fluxon, except: [:table, :tabs]
    ```
  """

  alias Phoenix.LiveView.{JS, Socket}

  import Phoenix.LiveView, only: [push_event: 3]

  @core_components_conflicts [:input, :button, :error, :table]
  @component_mapping %{
    accordion: Fluxon.Components.Accordion,
    alert: Fluxon.Components.Alert,
    autocomplete: Fluxon.Components.Autocomplete,
    badge: Fluxon.Components.Badge,
    button: Fluxon.Components.Button,
    checkbox: Fluxon.Components.Checkbox,
    datepicker: Fluxon.Components.DatePicker,
    dropdown: Fluxon.Components.Dropdown,
    error: {Fluxon.Components.Form, [error: 1]},
    input: Fluxon.Components.Input,
    label: {Fluxon.Components.Form, [label: 1]},
    loading: Fluxon.Components.Loading,
    modal: Fluxon.Components.Modal,
    navlist: Fluxon.Components.Navlist,
    popover: Fluxon.Components.Popover,
    radio: Fluxon.Components.Radio,
    select: Fluxon.Components.Select,
    separator: Fluxon.Components.Separator,
    sheet: Fluxon.Components.Sheet,
    switch: Fluxon.Components.Switch,
    table: Fluxon.Components.Table,
    tabs: Fluxon.Components.Tabs,
    textarea: Fluxon.Components.Textarea,
    tooltip: Fluxon.Components.Tooltip
  }

  defmacro __using__(opts) do
    only = Keyword.get(opts, :only, [])
    except = Keyword.get(opts, :except, [])
    avoid_conflicts = Keyword.get(opts, :avoid_conflicts, false)

    except = if avoid_conflicts, do: @core_components_conflicts ++ except, else: except

    imports =
      @component_mapping
      |> filter_components(only, except)
      |> Enum.map(fn
        {_key, {mod, funcs}} -> quote do: import(unquote(mod), only: unquote(funcs))
        {_key, mod} -> quote do: import(unquote(mod))
      end)

    quote do
      (unquote_splicing(imports))
    end
  end

  defp filter_components(components, [], except) do
    Enum.reject(components, fn {key, _value} -> key in except end)
  end

  defp filter_components(components, only, except) do
    components
    |> Enum.filter(fn {key, _value} -> key in only end)
    |> Enum.reject(fn {key, _value} -> key in except end)
  end

  @doc ~S'''
  Opens a dialog component (modal, sheet).

  ## Example

  ```heex
  <.button phx-click={Fluxon.open_dialog("my-modal")}>Open modal</.button>
  <.modal id="my-modal"></.modal>
  ```
  '''
  def open_dialog(id) do
    JS.dispatch("fluxon:dialog:open", to: "##{id}")
  end

  @doc ~S'''
  Closes a dialog component (modal, sheet).

  ## Parameters

    * `id` - The ID of the dialog element to close.

  ## Example

  ```heex
  <.button phx-click={Fluxon.close_dialog("my-modal")}>Close modal</.button>
  <.modal id="my-modal"></.modal>
  ```
  '''
  def close_dialog(id) do
    JS.dispatch("fluxon:dialog:close", to: "##{id}")
  end

  @doc ~S'''
  Closes a dialog via push event.

  ## Parameters

    * `socket` - The `Phoenix.LiveView.Socket` struct.
    * `id` - The ID of the dialog element to close.

  ## Example

  ```elixir
  def handle_event("close_dialog", _, socket) do
    {:noreply, Fluxon.close_dialog(socket, "my-dialog")}
  end
  ```
  '''

  def close_dialog(%Socket{} = socket, id) do
    push_event(socket, "fluxon:dialog:close", %{id: "##{id}"})
  end

  def close_dialog(%JS{} = js, id) do
    JS.set_attribute(js, {"data-open", "false"}, to: "##{id}")
  end

  @doc ~S'''
  Opens a dialog via push event.

  ## Parameters

    * `socket` - The `Phoenix.LiveView.Socket` struct.
    * `id` - The ID of the dialog element to open.

  ## Example

  ```elixir
  def handle_event("open_dialog", _, socket) do
    {:noreply, Fluxon.open_dialog(socket, "my-dialog")}
  end
  ```
  '''
  def open_dialog(%Socket{} = socket, id) do
    push_event(socket, "fluxon:dialog:open", %{id: "##{id}"})
  end

  def open_dialog(%JS{} = js, id) do
    JS.set_attribute(js, {"data-open", "true"}, to: "##{id}")
  end

  @doc ~S'''
  Opens a popover component.

  ## Example

  ```heex
  <.button phx-click={Fluxon.open_popover("my-popover")}>Open popover</.button>
  <.popover id="my-popover"></.popover>
  ```
  '''
  def open_popover(js \\ %JS{}, id) do
    JS.dispatch(js, "fluxon:popover:open", to: "##{id}")
  end

  @doc ~S'''
  Closes a popover component.

  ## Parameters

    * `id` - The ID of the popover element to close.

  ## Example

  ```heex
  <.button phx-click={Fluxon.close_popover("my-popover")}>Close popover</.button>
  <.popover id="my-popover"></.popover>
  ```
  '''
  def close_popover(js \\ %JS{}, id) do
    JS.dispatch(js, "fluxon:popover:close", to: "##{id}")
  end
end
