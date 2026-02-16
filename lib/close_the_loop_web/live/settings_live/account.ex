defmodule CloseTheLoopWeb.SettingsLive.Account do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    profile_form =
      to_form(%{"name" => user.name || ""}, as: :profile)

    email_form =
      to_form(%{"email" => to_string(user.email), "current_password" => ""}, as: :email)

    password_form =
      to_form(
        %{"current_password" => "", "password" => "", "password_confirmation" => ""},
        as: :password
      )

    {:ok,
     socket
     |> assign(:profile_form, profile_form)
     |> assign(:email_form, email_form)
     |> assign(:password_form, password_form)
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
              <dd class="font-medium">{@current_user.name || "—"}</dd>
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
  def handle_event("save_profile", %{"profile" => %{"name" => name}}, socket) do
    user = socket.assigns.current_user
    name = name |> to_string() |> String.trim()

    attrs = %{name: if(name == "", do: nil, else: name)}
    socket = assign(socket, :profile_form, to_form(%{"name" => name}, as: :profile))

    case CloseTheLoop.Accounts.update_user_profile(user, attrs, actor: user) do
      {:ok, %User{} = user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:profile_form, to_form(%{"name" => user.name || ""}, as: :profile))
         |> assign(:profile_error, nil)
         |> put_flash(:info, "Profile updated.")}

      {:error, err} ->
        {:noreply, assign(socket, :profile_error, Exception.message(err))}
    end
  end

  @impl true
  def handle_event(
        "change_email",
        %{"email" => %{"email" => email, "current_password" => current_password}},
        socket
      ) do
    user = socket.assigns.current_user
    email = email |> to_string() |> String.trim()

    socket =
      assign(
        socket,
        :email_form,
        to_form(%{"email" => email, "current_password" => ""}, as: :email)
      )

    with true <- email != "" || {:error, "Email is required"},
         {:ok, %User{} = user} <-
           CloseTheLoop.Accounts.change_user_email(
             user,
             %{email: email, current_password: current_password},
             actor: user
           ) do
      {:noreply,
       socket
       |> assign(:current_user, user)
       |> assign(
         :email_form,
         to_form(%{"email" => to_string(user.email), "current_password" => ""}, as: :email)
       )
       |> assign(:email_error, nil)
       |> put_flash(:info, "Email updated.")}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, assign(socket, :email_error, msg)}

      {:error, err} ->
        {:noreply, assign(socket, :email_error, error_message(err))}

      other ->
        {:noreply, assign(socket, :email_error, "Failed to update email: #{inspect(other)}")}
    end
  end

  @impl true
  def handle_event(
        "change_password",
        %{
          "password" => %{
            "current_password" => current_password,
            "password" => password,
            "password_confirmation" => password_confirmation
          }
        },
        socket
      ) do
    user = socket.assigns.current_user

    socket =
      assign(
        socket,
        :password_form,
        to_form(
          %{"current_password" => "", "password" => "", "password_confirmation" => ""},
          as: :password
        )
      )

    case CloseTheLoop.Accounts.change_user_password(
           user,
           %{
             current_password: current_password,
             password: password,
             password_confirmation: password_confirmation
           },
           actor: user
         ) do
      {:ok, %User{} = user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:password_error, nil)
         |> put_flash(:info, "Password updated.")}

      {:error, err} ->
        {:noreply, assign(socket, :password_error, error_message(err))}
    end
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
