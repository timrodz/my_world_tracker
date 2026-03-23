defmodule WorldTrackerWeb.Router do
  use WorldTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WorldTrackerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WorldTrackerWeb do
    pipe_through :browser

    live "/", DashboardLive, :index

    live "/data_sources", DataSourceLive.Index, :index
    live "/data_sources/new", DataSourceLive.Form, :new
    live "/data_sources/:id", DataSourceLive.Show, :show
    live "/data_sources/:id/edit", DataSourceLive.Form, :edit

    live "/tickers", TickerLive.Index, :index
    live "/tickers/new", TickerLive.Form, :new
    live "/tickers/:id", TickerLive.Show, :show
    live "/tickers/:id/edit", TickerLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", WorldTrackerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:world_tracker, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WorldTrackerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
