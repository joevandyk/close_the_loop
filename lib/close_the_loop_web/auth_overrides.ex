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
  end

  override Components.Banner do
    # Extra safety: if any page renders the banner, hide it.
    set :root_class, "hidden"
    set :href_url, nil
    set :image_url, nil
    set :dark_image_url, nil
    set :text, nil
  end
end
