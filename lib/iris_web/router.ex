# credo:disable-for-this-file Credo.Check.Refactor.ModuleDependencies
defmodule IrisWeb.Router do
  use IrisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {IrisWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IrisWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/invite/user/:id", InviteUserLive
    live "/invite/passkey/:id", InvitePasskeyLive
  end

  # Admin routes
  scope "/admin", IrisWeb do
    pipe_through :browser

    get "/", AdminController, :index
    post "/user_invites", AdminController, :create_user_invite
    get "/user_invites/:id", AdminController, :show_user_invite
    post "/user_invites/invalidate_all", AdminController, :invalidate_all_user_invites

    # Users routes
    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit
    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", IrisWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:iris, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: IrisWeb.Telemetry, ecto_repos: [Iris.Repo]
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
