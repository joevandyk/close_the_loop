defmodule CloseTheLoopWeb.SettingsLive.Account do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:profile_form, profile_form(user))
     |> assign(:email_form, email_form(user))
     |> assign(:password_form, password_form(user))
     |> assign(:profile_error, nil)
     |> assign(:email_error, nil)
     |> assign(:password_error, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_user={@current_user}
      current_scope={@current_scope}
      org={@current_org}
    >
      <div class="max-w-4xl mx-auto space-y-8">
        <div class="flex items-start justify-between gap-4">
          <div>
            <h1 class="text-2xl font-semibold">Account</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              Manage your profile and sign-in details.
            </p>
          </div>

          <.button navigate={~p"/app/settings"} variant="ghost">Back</.button>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Account details</h2>

          <dl class="mt-4 space-y-3 text-sm">
            <div class="flex items-center justify-between gap-4">
              <dt class="text-foreground-soft">Name</dt>
              <dd class="font-medium">
                {@current_user.name || "—"}
              </dd>
            </div>
            <div class="flex items-center justify-between gap-4">
              <dt class="text-foreground-soft">Email</dt>
              <dd class="font-medium">{@current_user.email}</dd>
            </div>
            <div class="flex items-center justify-between gap-4">
              <dt class="text-foreground-soft">Role</dt>
              <dd class="font-medium">{@current_role || :staff}</dd>
            </div>
          </dl>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Update profile</h2>

          <.form
            for={@profile_form}
            id="user-profile-form"
            phx-change="validate"
            phx-submit="save_profile"
            class="mt-4 space-y-3"
          >
            <.input
              field={@profile_form[:name]}
              type="text"
              label="Name"
              placeholder="Jane Doe"
            />

            <%= if @profile_error do %>
              <.alert color="danger" hide_close>{@profile_error}</.alert>
            <% end %>

            <.button
              type="submit"
              variant="solid"
              color="primary"
              class="w-full"
              phx-disable-with="Saving..."
            >
              Save name
            </.button>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Change email</h2>

          <.form
            for={@email_form}
            id="user-email-form"
            phx-change="validate"
            phx-submit="change_email"
            class="mt-4 space-y-3"
          >
            <.input
              field={@email_form[:email]}
              type="email"
              label="Email"
              autocomplete="email"
              required
            />

            <.input
              field={@email_form[:current_password]}
              type="password"
              label="Current password"
              autocomplete="current-password"
              required
            />

            <%= if @email_error do %>
              <.alert color="danger" hide_close>{@email_error}</.alert>
            <% end %>

            <.button
              type="submit"
              variant="solid"
              color="primary"
              class="w-full"
              phx-disable-with="Saving..."
            >
              Update email
            </.button>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Change password</h2>

          <.form
            for={@password_form}
            id="user-password-form"
            phx-change="validate"
            phx-submit="change_password"
            class="mt-4 space-y-3"
          >
            <.input
              field={@password_form[:current_password]}
              type="password"
              label="Current password"
              autocomplete="current-password"
              required
            />

            <.input
              field={@password_form[:password]}
              type="password"
              label="New password"
              autocomplete="new-password"
              required
            />

            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Confirm new password"
              autocomplete="new-password"
              required
            />

            <%= if @password_error do %>
              <.alert color="danger" hide_close>{@password_error}</.alert>
            <% end %>

            <.button
              type="submit"
              variant="solid"
              color="primary"
              class="w-full"
              phx-disable-with="Saving..."
            >
              Update password
            </.button>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Sign out</h2>
          <p class="mt-2 text-sm text-foreground-soft">End your session on this device.</p>

          <div class="mt-4">
            <.button href={~p"/sign-out"} variant="outline" class="w-full">
              Sign out
            </.button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"profile" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.profile_form, params)
    {:noreply, socket |> assign(:profile_form, form) |> assign(:profile_error, nil)}
  end

  def handle_event("validate", %{"email" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.email_form, params)
    {:noreply, socket |> assign(:email_form, form) |> assign(:email_error, nil)}
  end

  def handle_event("validate", %{"password" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.password_form, params)
    {:noreply, socket |> assign(:password_form, form) |> assign(:password_error, nil)}
  end

  def handle_event("save_profile", %{"profile" => params}, socket) when is_map(params) do
    case AshPhoenix.Form.submit(socket.assigns.profile_form, params: params) do
      {:ok, %User{} = user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:profile_form, profile_form(user))
         |> assign(:profile_error, nil)
         |> put_flash(:info, "Profile updated.")}

      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, assign(socket, :profile_form, form)}

      {:error, err} ->
        {:noreply, assign(socket, :profile_error, error_message(err))}
    end
  end

  @impl true
  def handle_event(
        "change_email",
        %{"email" => params},
        socket
      )
      when is_map(params) do
    case AshPhoenix.Form.submit(socket.assigns.email_form, params: params) do
      {:ok, %User{} = user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:email_form, email_form(user))
         |> assign(:email_error, nil)
         |> put_flash(:info, "Email updated.")}

      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, assign(socket, :email_form, form)}

      {:error, err} ->
        {:noreply, assign(socket, :email_error, error_message(err))}
    end
  end

  @impl true
  def handle_event(
        "change_password",
        %{"password" => params},
        socket
      )
      when is_map(params) do
    case AshPhoenix.Form.submit(socket.assigns.password_form, params: params) do
      {:ok, %User{} = user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:password_form, password_form(user))
         |> assign(:password_error, nil)
         |> put_flash(:info, "Password updated.")}

      {:error, %Phoenix.HTML.Form{} = form} ->
        {:noreply, assign(socket, :password_form, form)}

      {:error, err} ->
        {:noreply, assign(socket, :password_error, error_message(err))}
    end
  end

  defp profile_form(user) do
    AshPhoenix.Form.for_update(user, :update_profile,
      as: "profile",
      id: "profile",
      actor: user,
      params: %{"name" => user.name}
    )
    |> to_form()
  end

  defp email_form(user) do
    AshPhoenix.Form.for_update(user, :change_email,
      as: "email",
      id: "email",
      actor: user,
      params: %{"email" => to_string(user.email), "current_password" => ""}
    )
    |> to_form()
  end

  defp password_form(user) do
    AshPhoenix.Form.for_update(user, :change_password,
      as: "password",
      id: "password",
      actor: user,
      params: %{"current_password" => "", "password" => "", "password_confirmation" => ""}
    )
    |> to_form()
  end

  defp error_message(%Ash.Error.Invalid{errors: errors}) when is_list(errors) do
    case Enum.find(
           errors,
           &match?(%Ash.Error.Changes.InvalidChanges{fields: [:current_password]}, &1)
         ) do
      %Ash.Error.Changes.InvalidChanges{message: message} when is_binary(message) ->
        message

      _ ->
        "Please check your input and try again."
    end
  end

  defp error_message(_err) do
    "Something went wrong. Please try again."
  end
end
