defmodule CloseTheLoopWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  # These overrides remove Ash branding and make auth pages sit nicely inside
  # our custom LiveView layout (`CloseTheLoopWeb.Layouts.auth/1`).

  alias AshAuthentication.Phoenix.{
    Components,
    ConfirmLive,
    MagicSignInLive,
    ResetLive,
    SignInLive
  }

  override SignInLive do
    # The router applies our layout; avoid full-screen + background here.
    set :root_class, "w-full"
  end

  override ResetLive do
    set :root_class, "w-full"
  end

  override ConfirmLive do
    set :root_class, "w-full"
  end

  override MagicSignInLive do
    set :root_class, "w-full"
  end

  override Components.SignIn do
    # Completely remove the vendor banner (the DaisyUI override points at ash-hq.org).
    set :show_banner, false

    # Render as a Fluxon-styled card (layout handles centering).
    set :root_class,
        "overflow-hidden relative w-full border border-base rounded-base shadow-base bg-base p-6 sm:p-8"

    set :strategy_class, ""
    set :authentication_error_container_class, "text-center"
    set :authentication_error_text_class, "text-sm text-danger"
    set :strategy_display_order, :forms_first
  end

  override Components.Banner do
    # Extra safety: if any page renders the banner, hide it.
    set :root_class, "hidden"
    set :href_url, nil
    set :image_url, nil
    set :dark_image_url, nil
    set :text, nil
  end

  # The default AshAuthentication components are unstyled without DaisyUI.
  # These overrides apply Fluxon token classes for inputs/buttons.

  @fluxon_button_class "relative isolate inline-flex items-center justify-center whitespace-nowrap text-sm font-medium no-underline rounded-base outline-hidden shrink-0 border focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus transition-[box-shadow] duration-100 disabled:opacity-70 disabled:shadow-none disabled:pointer-events-none shadow-base border-[color-mix(in_oklab,black_10%,transparent)] before:absolute before:inset-0 before:border before:border-white/12 before:mask-b-from-0% before:rounded-[calc(var(--radius-base)-1px)] before:pointer-events-none bg-primary text-foreground-primary hover:bg-[color-mix(in_oklab,var(--primary),white_10%)] h-10 px-3.5 py-2.5 gap-x-2.5 w-full"

  override Components.HorizontalRule do
    set :root_class, "relative flex items-center my-6"
    set :hr_outer_class, "w-full border-t border-base"
    set :hr_inner_class, nil
    set :text_outer_class, "absolute left-1/2 -translate-x-1/2 bg-base px-3"
    set :text_inner_class, "text-xs text-foreground-softer"
    set :text, "OR"
  end

  override Components.Password do
    set :root_class, "flex flex-col gap-y-6"
    set :interstitial_class, "flex items-center justify-between"

    set :toggler_class, "text-sm text-foreground-softer hover:text-foreground font-medium"

    set :sign_in_toggle_text, "Already have an account?"
    set :register_toggle_text, "Need an account?"
    set :reset_toggle_text, "Forgot your password?"
    set :show_first, :sign_in
    set :hide_class, "hidden"
    set :register_form_module, AshAuthentication.Phoenix.Components.Password.RegisterForm
    set :sign_in_form_module, AshAuthentication.Phoenix.Components.Password.SignInForm
    set :reset_form_module, AshAuthentication.Phoenix.Components.Password.ResetForm
  end

  override Components.Password.SignInForm do
    set :root_class, nil
    set :label_class, "text-center text-2xl/10 font-bold text-foreground mb-2"
    set :form_class, "flex flex-col gap-y-6"
    set :slot_class, nil
    set :button_text, "Sign in"
    set :disable_button_text, "Signing in..."
  end

  override Components.Password.RegisterForm do
    set :root_class, nil
    set :label_class, "text-center text-2xl/10 font-bold text-foreground mb-2"
    set :form_class, "flex flex-col gap-y-6"
    set :slot_class, nil
    set :button_text, "Create account"
    set :disable_button_text, "Creating account..."
  end

  override Components.Password.ResetForm do
    set :root_class, nil
    set :label_class, "text-center text-2xl/10 font-bold text-foreground mb-2"
    set :form_class, "flex flex-col gap-y-6"
    set :slot_class, nil
    set :button_text, "Email reset link"
    set :disable_button_text, "Sending..."

    set :reset_flash_text,
        "If this user exists in our system, you will be contacted with password reset instructions shortly."
  end

  override Components.Password.Input do
    set :field_class, "w-full flex flex-col gap-y-2"
    set :label_class, "font-medium text-foreground text-sm"

    set :input_class,
        "w-full bg-transparent bg-none outline-hidden placeholder:text-foreground-softest sm:text-sm border border-input rounded-base px-3 h-9 bg-input text-foreground shadow-base focus-visible:border-focus focus-visible:ring-3 focus-visible:ring-focus transition-[box-shadow] duration-100"

    set :input_class_with_error,
        "w-full bg-transparent bg-none outline-hidden placeholder:text-foreground-softest sm:text-sm border border-danger rounded-base px-3 h-9 bg-input text-foreground shadow-base focus-visible:border-focus-danger focus-visible:ring-3 focus-visible:ring-focus-danger transition-[box-shadow] duration-100"

    set :submit_class, @fluxon_button_class

    set :password_input_label, "Password"
    set :password_confirmation_input_label, "Password confirmation"
    set :identity_input_label, "Email"
    set :identity_input_placeholder, "Enter your email..."
    set :error_ul, "text-danger text-sm mt-1"
    set :error_li, nil
    set :input_debounce, 350

    set :remember_me_class, "flex items-center gap-2"
    set :remember_me_input_label, "Remember me"
    set :checkbox_class, "rounded border-input"
    set :checkbox_label_class, "text-sm font-medium text-foreground"
  end
end
