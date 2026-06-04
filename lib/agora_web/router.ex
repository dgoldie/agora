defmodule AgoraWeb.Router do
  use AgoraWeb, :router

  import AgoraWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AgoraWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/stripe", AgoraWeb do
    pipe_through :api

    post "/webhooks", StripeWebhookController, :handle
  end

  ## Public marketplace routes
  live_session :public,
    on_mount: [{AgoraWeb.UserAuth, :mount_current_scope}] do
    scope "/", AgoraWeb do
      pipe_through :browser

      live "/", HomeLive
      live "/listings", ListingLive.Index
      live "/listings/:id", ListingLive.Show
    end
  end

  ## Authenticated seller/buyer routes
  live_session :require_authenticated_user,
    on_mount: [{AgoraWeb.UserAuth, :require_authenticated_user}] do
    scope "/", AgoraWeb do
      pipe_through [:browser, :require_authenticated_user]

      live "/listings/new", ListingLive.New
      live "/my/listings", SellerLive.Dashboard
      live "/my/orders", BuyerLive.Orders
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AgoraWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:agora, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AgoraWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

  end

  ## Authentication routes

  scope "/", AgoraWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
  end

  scope "/", AgoraWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
  end

  scope "/", AgoraWeb do
    pipe_through [:browser]

    get "/users/log-in", UserSessionController, :new
    get "/users/log-in/:token", UserSessionController, :confirm
    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
