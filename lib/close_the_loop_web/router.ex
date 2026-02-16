defmodule CloseTheLoopWeb.Router do
  use CloseTheLoopWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers
  import Oban.Web.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CloseTheLoopWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  pipeline :webhook do
    # No session/CSRF for external webhooks (Twilio posts form-encoded data).
    plug :accepts, ["xml", "html"]
  end

  scope "/webhooks/twilio", CloseTheLoopWeb do
    pipe_through :webhook

    post "/sms", TwilioWebhookController, :sms
  end

  scope "/", CloseTheLoopWeb do
    pipe_through :browser

    oban_dashboard("/app/oban",
      logo_path: "/app",
      on_mount: [
        {CloseTheLoopWeb.LiveUserAuth, :current_user},
        {CloseTheLoopWeb.LiveUserAuth, :live_user_required}
      ]
    )

    ash_authentication_live_session :authenticated_routes, layout: false do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {CloseTheLoopWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {CloseTheLoopWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {CloseTheLoopWeb.LiveUserAuth, :live_no_user}

      live "/app/onboarding", OnboardingLive, :index

      # Org selection / switcher landing page (org is in URL elsewhere).
      live "/app", OrgPickerLive.Index, :index

      live "/app/organizations/new", OrganizationsLive.New, :new

      live "/app/:org_id", DashboardLive.Index, :index

      live "/app/:org_id/issues", IssuesLive.Index, :index

      live "/app/:org_id/issues/:id", IssuesLive.Show, :show

      live "/app/:org_id/reports", ReportsLive.Index, :index

      live "/app/:org_id/reports/new", ReportsLive.New, :new

      live "/app/:org_id/reports/:id", ReportsLive.Show, :show

      live "/app/:org_id/settings/locations", LocationsLive.Index, :index

      live "/app/:org_id/settings", SettingsLive.Index, :index

      live "/app/:org_id/settings/organization", SettingsLive.Organization, :index
      live "/app/:org_id/settings/account", SettingsLive.Account, :index
      live "/app/:org_id/settings/inbox", SettingsLive.Inbox, :index

      live "/app/:org_id/settings/issue-categories", IssueCategoriesLive.Index, :index
    end

    # Printable poster (HTML -> browser "Save as PDF")
    get "/app/:org_id/settings/locations/:id/poster", LocationPosterController, :show
  end

  scope "/", CloseTheLoopWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/how-it-works", PageController, :how_it_works
    get "/pricing", PageController, :pricing
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms

    live_session :reporter, layout: false do
      live "/r/:tenant/:location_id", ReporterLive.New, :new
    end

    auth_routes AuthController, CloseTheLoop.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  layout: {CloseTheLoopWeb.Layouts, :auth},
                  on_mount: [{CloseTheLoopWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    CloseTheLoopWeb.AuthOverrides,
                    Elixir.AshAuthentication.Phoenix.Overrides.Default
                  ]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                layout: {CloseTheLoopWeb.Layouts, :auth},
                overrides: [
                  CloseTheLoopWeb.AuthOverrides,
                  Elixir.AshAuthentication.Phoenix.Overrides.Default
                ]

    # Remove this if you do not use the confirmation strategy
    confirm_route CloseTheLoop.Accounts.User, :confirm_new_user,
      auth_routes_prefix: "/auth",
      layout: {CloseTheLoopWeb.Layouts, :auth},
      overrides: [
        CloseTheLoopWeb.AuthOverrides,
        Elixir.AshAuthentication.Phoenix.Overrides.Default
      ]

    # Remove this if you do not use the magic link strategy.
    magic_sign_in_route(CloseTheLoop.Accounts.User, :magic_link,
      auth_routes_prefix: "/auth",
      layout: {CloseTheLoopWeb.Layouts, :auth},
      overrides: [
        CloseTheLoopWeb.AuthOverrides,
        Elixir.AshAuthentication.Phoenix.Overrides.Default
      ]
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", CloseTheLoopWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:close_the_loop, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CloseTheLoopWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
