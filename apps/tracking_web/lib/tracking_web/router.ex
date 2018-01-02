defmodule TrackingWeb.Router do
  use TrackingWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end


  scope "/", TrackingWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end


  scope "/shipping", TrackingWeb do
    pipe_through :browser

    scope "/clerks" do
      get "/cargoes", CargoController, :show
      resources "/", ClerkController, only: [:index]
    end

    scope "/opsmanagers" do
      get "/events", HandlingEventController, :show
      resources "/", OpsManagerController, only: [:index]
    end
  end

  scope "/elm", TrackingWeb do
    pipe_through :browser

    get "/", ElmPageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Stage1Web do
  #   pipe_through :api
  # end
end
