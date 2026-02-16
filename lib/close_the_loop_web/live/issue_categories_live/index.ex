defmodule CloseTheLoopWeb.IssueCategoriesLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Feedback.IssueCategory
  alias CloseTheLoop.Tenants
  alias CloseTheLoop.Tenants.Organization
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    org = socket.assigns.current_org
    tenant = socket.assigns.current_tenant

    with true <- match?(%Organization{}, org) || {:error, :missing_org},
         true <- is_binary(tenant) || {:error, :missing_tenant},
         :ok <- Categories.ensure_defaults(tenant),
         {:ok, categories} <- list_categories(tenant) do
      {:ok,
       socket
       |> assign(:org, org)
       |> assign(:tenant, tenant)
       |> assign(:categories, categories)
       |> assign(
         :ai_form,
         to_form(
           %{
             "business_context" => org.ai_business_context || "",
             "categorization_instructions" => org.ai_categorization_instructions || ""
           },
           as: :ai
         )
       )
       |> assign(:ai_saved?, false)
       |> assign(:ai_save_error, nil)
       |> assign(:editing_category, nil)
       |> assign(
         :edit_form,
         to_form(
           %{
             "label" => "",
             "description" => "",
             "ai_guidance" => "",
             "ai_include_keywords" => "",
             "ai_exclude_keywords" => "",
             "ai_examples" => ""
           },
           as: :edit
         )
       )
       |> assign(:category_form, to_form(%{"key" => "", "label" => ""}, as: :category))
       |> assign(:error, nil)}
    else
      _ ->
        {:ok, put_flash(socket, :error, "Failed to load categories")}
    end
  end

  defp list_categories(tenant) do
    FeedbackDomain.list_issue_categories(
      tenant: tenant,
      query: [sort: [active: :desc, key: :asc]]
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto space-y-8">
        <div class="flex items-start justify-between gap-4">
          <div>
            <h1 class="text-2xl font-semibold">Issue categories</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              These categories are used by AI auto-classification and shown in your issues.
            </p>
          </div>

          <.button navigate={~p"/app/settings"} variant="ghost">Back</.button>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">AI categorization guidance</h2>
          <p class="mt-2 text-sm text-foreground-soft">
            AI uses this information plus your category definitions to auto-classify incoming reports.
            Add context that a new employee might not know yet (your facilities, terminology, edge cases).
          </p>

          <.form
            for={@ai_form}
            id="ai-settings-form"
            phx-submit="save_ai_settings"
            class="mt-4 space-y-4"
          >
            <.textarea
              id="ai_business_context"
              field={@ai_form[:business_context]}
              label="Business context (optional)"
              rows={4}
              placeholder="We run a gym with locker rooms, pool, sauna, and hot tub. Members frequently report issues about showers, HVAC, and cleanliness."
            />

            <.textarea
              id="ai_categorization_instructions"
              field={@ai_form[:categorization_instructions]}
              label="Categorization rules (optional)"
              rows={4}
              placeholder="If a report mentions water temperature, leaks, toilets, drains, or showers -> plumbing. If it's about lighting, outlets, breakers -> electrical. If uncertain, choose other."
            />

            <div class="flex items-center justify-between gap-3">
              <div
                id="ai-settings-status"
                data-state={ai_settings_state(@ai_saved?, @ai_save_error)}
                class="min-h-5"
              >
                <%= if @ai_saved? do %>
                  <span class="inline-flex items-center gap-1 text-xs font-medium text-emerald-700">
                    <.icon name="hero-check-circle-mini" class="size-4" /> Saved
                  </span>
                <% end %>

                <%= if @ai_save_error do %>
                  <span class="text-xs font-medium text-danger">
                    {@ai_save_error}
                  </span>
                <% end %>
              </div>

              <.button
                id="save-ai-settings-button"
                type="submit"
                variant="solid"
                color="primary"
                phx-disable-with="Saving..."
              >
                Save AI settings
              </.button>
            </div>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Add category</h2>

          <.form
            for={@category_form}
            id="category-create-form"
            phx-submit="create"
            class="mt-4 grid gap-4 sm:grid-cols-3"
          >
            <div class="sm:col-span-1">
              <.input
                id="category_key"
                field={@category_form[:key]}
                type="text"
                label="Key"
                class="font-mono"
                placeholder="plumbing"
                required
              />
              <div class="mt-1 text-xs text-zinc-500">
                Lowercase letters/numbers/underscore only.
              </div>
            </div>

            <.input
              id="category_label"
              field={@category_form[:label]}
              type="text"
              label="Label"
              class="sm:col-span-2"
              placeholder="Plumbing"
              required
            />

            <div class="sm:col-span-3 flex items-center justify-between gap-3">
              <%= if @error do %>
                <.alert color="danger" hide_close>{@error}</.alert>
              <% else %>
                <div />
              <% end %>

              <.button type="submit" variant="solid" color="primary">Add</.button>
            </div>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <div class="flex items-center justify-between gap-4">
            <h2 class="text-sm font-semibold">Your categories</h2>
            <span class="text-xs text-zinc-500">
              Tenant: <span class="font-mono">{@tenant}</span>
            </span>
          </div>

          <div class="mt-4 overflow-x-auto">
            <.table>
              <.table_head>
                <:col>Key</:col>
                <:col>Label</:col>
                <:col>Status</:col>
                <:col class="text-right">
                  <span class="sr-only">Actions</span>
                </:col>
              </.table_head>

              <.table_body>
                <.table_row :for={cat <- @categories} id={"category-#{cat.id}"}>
                  <:cell class="font-mono text-sm">{cat.key}</:cell>
                  <:cell class="font-medium">{cat.label}</:cell>
                  <:cell>
                    <%= if cat.active do %>
                      <.badge color="success">Active</.badge>
                    <% else %>
                      <.badge variant="ghost" color="primary">Inactive</.badge>
                    <% end %>
                  </:cell>
                  <:cell class="text-right">
                    <div class="flex justify-end gap-2">
                      <.button
                        type="button"
                        size="sm"
                        variant="outline"
                        phx-click={
                          Fluxon.open_dialog("edit-category-modal")
                          |> JS.push("edit_category", value: %{id: cat.id})
                        }
                      >
                        Edit
                      </.button>
                      <.button
                        type="button"
                        size="sm"
                        variant="outline"
                        phx-click="toggle_active"
                        phx-value-id={cat.id}
                      >
                        {if cat.active, do: "Deactivate", else: "Activate"}
                      </.button>
                      <.button
                        type="button"
                        size="sm"
                        variant="ghost"
                        color="danger"
                        phx-click="delete"
                        phx-value-id={cat.id}
                      >
                        Delete
                      </.button>
                    </div>
                  </:cell>
                </.table_row>
              </.table_body>
            </.table>

            <div :if={@categories == []} class="py-10 text-center text-sm text-foreground-soft">
              No categories yet.
            </div>
          </div>
        </div>
      </div>

      <.modal
        id="edit-category-modal"
        class="w-[min(44rem,calc(100vw-2rem))]"
        on_close={JS.push("reset_edit_category")}
      >
        <div class="p-6 space-y-5">
          <div class="space-y-1">
            <h2 class="text-lg font-semibold">Edit category</h2>
            <p class="text-sm text-foreground-soft">
              This information is used by AI auto-classification. Keep it short, specific, and full of your real-world terms.
            </p>
          </div>

          <%= if @editing_category do %>
            <.form
              for={@edit_form}
              id="edit-category-form"
              phx-submit="save_category"
              class="space-y-4"
            >
              <div class="text-xs text-foreground-soft">
                Key: <span class="font-mono text-foreground">{@editing_category.key}</span>
              </div>

              <.input
                id="edit_category_label"
                field={@edit_form[:label]}
                type="text"
                label="Label"
                required
              />

              <.input
                id="edit_category_description"
                field={@edit_form[:description]}
                type="text"
                label="Description (optional)"
                placeholder="Problems with showers, toilets, drains, leaks, water heaters."
              />

              <.textarea
                id="edit_category_ai_guidance"
                field={@edit_form[:ai_guidance]}
                label="AI guidance (optional)"
                rows={4}
                placeholder="Use this category when the issue is about water flow/pressure/temperature, leaks, clogs, toilets, drains, sinks, showers."
              />

              <.textarea
                id="edit_category_ai_include_keywords"
                field={@edit_form[:ai_include_keywords]}
                label="Include keywords (optional)"
                rows={3}
                placeholder="shower\nsink\ntoilet\ndrain\nleak\nclog\nhot water\ncold water"
              />

              <.textarea
                id="edit_category_ai_exclude_keywords"
                field={@edit_form[:ai_exclude_keywords]}
                label="Exclude keywords (optional)"
                rows={3}
                placeholder="light\nbreaker\noutlet\npower\nwifi\ninternet"
              />

              <.textarea
                id="edit_category_ai_examples"
                field={@edit_form[:ai_examples]}
                label="Examples (optional)"
                rows={5}
                placeholder="Cold water in men's showers\nToilet overflowing near pool\nDrain in sauna backing up"
              />

              <div class="flex justify-end gap-2">
                <.button
                  type="button"
                  variant="ghost"
                  phx-click={Fluxon.close_dialog("edit-category-modal")}
                >
                  Cancel
                </.button>
                <.button type="submit" variant="solid" color="primary" phx-disable-with="Saving...">
                  Save category
                </.button>
              </div>
            </.form>
          <% else %>
            <div class="flex items-center justify-center py-10">
              <.loading class="size-7" />
            </div>
          <% end %>
        </div>
      </.modal>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("create", %{"category" => %{"key" => key, "label" => label}}, socket) do
    tenant = socket.assigns.tenant
    user = socket.assigns.current_user
    key = key |> to_string() |> String.trim() |> String.downcase()
    label = label |> to_string() |> String.trim()

    socket =
      assign(socket, :category_form, to_form(%{"key" => key, "label" => label}, as: :category))

    with true <- key != "" || {:error, "Key is required"},
         true <-
           Regex.match?(~r/^[a-z0-9_]+$/, key) || {:error, "Key must be lowercase/underscore"},
         true <- label != "" || {:error, "Label is required"},
         {:ok, _cat} <-
           FeedbackDomain.create_issue_category(%{key: key, label: label, active: true},
             tenant: tenant,
             actor: user
           ),
         {:ok, categories} <- list_categories(tenant) do
      {:noreply,
       socket
       |> assign(:categories, categories)
       |> assign(:category_form, to_form(%{"key" => "", "label" => ""}, as: :category))
       |> assign(:error, nil)
       |> put_flash(:info, "Category added.")}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, assign(socket, :error, msg)}

      {:error, err} ->
        {:noreply, assign(socket, :error, Exception.message(err))}

      other ->
        {:noreply, assign(socket, :error, "Failed to add: #{inspect(other)}")}
    end
  end

  @impl true
  def handle_event("save_ai_settings", %{"ai" => params}, socket) when is_map(params) do
    org = socket.assigns.org
    user = socket.assigns.current_user
    socket = assign(socket, :ai_form, to_form(params, as: :ai))

    business =
      params
      |> Map.get("business_context")
      |> to_string()
      |> String.trim()

    instructions =
      params
      |> Map.get("categorization_instructions")
      |> to_string()
      |> String.trim()

    attrs = %{
      ai_business_context: if(business == "", do: nil, else: business),
      ai_categorization_instructions: if(instructions == "", do: nil, else: instructions)
    }

    case Tenants.update_organization(org, attrs, actor: user) do
      {:ok, %Organization{} = org} ->
        {:noreply,
         socket
         |> assign(:org, org)
         |> assign(
           :ai_form,
           to_form(
             %{
               "business_context" => org.ai_business_context || "",
               "categorization_instructions" => org.ai_categorization_instructions || ""
             },
             as: :ai
           )
         )
         |> assign(:ai_saved?, true)
         |> assign(:ai_save_error, nil)
         |> put_flash(:info, "AI settings saved.")}

      {:error, err} ->
        {:noreply,
         socket
         |> assign(:ai_saved?, false)
         |> assign(:ai_save_error, "Failed to save AI settings")
         |> put_flash(:error, "Failed to save AI settings: #{inspect(err)}")}
    end
  end

  @impl true
  def handle_event("edit_category", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant

    case FeedbackDomain.get_issue_category_by_id(id, tenant: tenant) do
      {:ok, %IssueCategory{} = cat} ->
        {:noreply,
         socket
         |> assign(:editing_category, cat)
         |> assign(
           :edit_form,
           to_form(
             %{
               "label" => cat.label || "",
               "description" => cat.description || "",
               "ai_guidance" => cat.ai_guidance || "",
               "ai_include_keywords" => cat.ai_include_keywords || "",
               "ai_exclude_keywords" => cat.ai_exclude_keywords || "",
               "ai_examples" => cat.ai_examples || ""
             },
             as: :edit
           )
         )}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to load category")}
    end
  end

  @impl true
  def handle_event("reset_edit_category", _params, socket) do
    {:noreply,
     socket
     |> assign(:editing_category, nil)
     |> assign(
       :edit_form,
       to_form(
         %{
           "label" => "",
           "description" => "",
           "ai_guidance" => "",
           "ai_include_keywords" => "",
           "ai_exclude_keywords" => "",
           "ai_examples" => ""
         },
         as: :edit
       )
     )}
  end

  @impl true
  def handle_event("save_category", %{"edit" => edit_params}, socket) when is_map(edit_params) do
    tenant = socket.assigns.tenant
    cat = socket.assigns.editing_category
    user = socket.assigns.current_user
    socket = assign(socket, :edit_form, to_form(edit_params, as: :edit))

    label = edit_params |> Map.get("label", "") |> to_string() |> String.trim()
    description = Map.get(edit_params, "description", "")
    ai_guidance = Map.get(edit_params, "ai_guidance", "")
    ai_include_keywords = Map.get(edit_params, "ai_include_keywords", "")
    ai_exclude_keywords = Map.get(edit_params, "ai_exclude_keywords", "")
    ai_examples = Map.get(edit_params, "ai_examples", "")

    attrs = %{
      label: label,
      description: blank_to_nil(description),
      ai_guidance: blank_to_nil(ai_guidance),
      ai_include_keywords: blank_to_nil(ai_include_keywords),
      ai_exclude_keywords: blank_to_nil(ai_exclude_keywords),
      ai_examples: blank_to_nil(ai_examples)
    }

    with true <- label != "" || {:error, "Label is required"},
         {:ok, %IssueCategory{}} <-
           FeedbackDomain.update_issue_category(cat, attrs, tenant: tenant, actor: user),
         {:ok, categories} <- list_categories(tenant) do
      {:noreply,
       socket
       |> assign(:categories, categories)
       |> put_flash(:info, "Category updated.")
       |> Fluxon.close_dialog("edit-category-modal")}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, put_flash(socket, :error, msg)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to save category: #{inspect(err)}")}

      other ->
        {:noreply, put_flash(socket, :error, "Failed to save category: #{inspect(other)}")}
    end
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    user = socket.assigns.current_user

    with {:ok, %IssueCategory{} = cat} <-
           FeedbackDomain.get_issue_category_by_id(id, tenant: tenant) do
      active_keys = Categories.active_keys_strict(tenant)

      if cat.active and length(active_keys) <= 1 do
        {:noreply, put_flash(socket, :error, "Keep at least one category active.")}
      else
        with {:ok, %IssueCategory{} = cat} <-
               FeedbackDomain.update_issue_category(cat, %{active: not cat.active},
                 tenant: tenant,
                 actor: user
               ),
             {:ok, categories} <- list_categories(tenant) do
          msg = if(cat.active, do: "Category activated.", else: "Category deactivated.")
          {:noreply, socket |> assign(:categories, categories) |> put_flash(:info, msg)}
        else
          _ ->
            {:noreply, put_flash(socket, :error, "Failed to update category")}
        end
      end
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Failed to update category")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant
    user = socket.assigns.current_user

    with {:ok, %IssueCategory{} = cat} <-
           FeedbackDomain.get_issue_category_by_id(id, tenant: tenant),
         :ok <- FeedbackDomain.destroy_issue_category(cat, tenant: tenant, actor: user),
         {:ok, categories} <- list_categories(tenant) do
      {:noreply, assign(socket, :categories, categories)}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Failed to delete category")}
    end
  end

  defp blank_to_nil(val) do
    val = val |> to_string() |> String.trim()
    if val == "", do: nil, else: val
  end

  defp ai_settings_state(true, _err), do: "saved"
  defp ai_settings_state(_saved, err) when is_binary(err) and err != "", do: "error"
  defp ai_settings_state(_saved, _err), do: "idle"
end
