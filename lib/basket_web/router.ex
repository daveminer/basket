defmodule BasketWeb.Router do
  use BasketWeb, :router
  use Pow.Phoenix.Router
  use PowAssent.Phoenix.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowEmailConfirmation, PowPersistentSession, PowAssent]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BasketWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{"content-security-policy" => "default-src 'self' data:"}
  end

  pipeline :news_page do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BasketWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self' data:; img-src data: https://editorial-assets.benzinga.com https://thearorareport.com https://www.benzinga.com; script-src 'self' https://platform.twitter.com; style-src 'self'; frame-src 'self' https://platform.twitter.com;"
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug Pow.Plug.RequireAuthenticated, error_handler: BasketWeb.UnauthenticatedHandler
  end

  scope "/" do
    pipe_through :browser

    pow_session_routes()
    pow_extension_routes()
    pow_assent_routes()
  end

  scope "/", BasketWeb.PowInvitation, as: "pow_invitation" do
    pipe_through :browser

    resources "/invitations", InvitationController, only: [:new, :create, :edit]
    post "/invitations/:id/edit", InvitationController, :update
  end

  scope "/", BasketWeb do
    pipe_through [:browser, :authenticated]

    live "/", Live.Overview

    resources "/settings", SettingsController, only: [:index, :update]
  end

  scope "/", BasketWeb do
    # Routes in this scope have no authentication; deferring to a reverse
    # proxy or similar to deny traffic; allowing local traffic through by default.
    post "/sentiment/new/callback", SentimentController, :callback
  end

  scope "/", BasketWeb do
    pipe_through [:news_page, :authenticated]

    get "/news/:ticker", NewsController, :index
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:basket, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BasketWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
