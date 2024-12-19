defmodule AppsignalPhoenixExampleWeb.Router do
  use AppsignalPhoenixExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppsignalPhoenixExampleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppsignalPhoenixExampleWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/slow", PageController, :slow
    get "/error", PageController, :error
    live "/live", DemoLive
  end

  forward("/api", Absinthe.Plug, schema: AppsignalPhoenixExampleWeb.Schema)

  if Mix.env() == :dev do
    forward("/graphiql", Absinthe.Plug.GraphiQL, schema: AppsignalPhoenixExampleWeb.Schema)
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppsignalPhoenixExampleWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:appsignal_phoenix_example, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppsignalPhoenixExampleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
