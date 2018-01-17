defmodule TrackingWeb.Router do
  use TrackingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # In Stage 1, these types of request come from the Elm client
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TrackingWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end


  # The tracking application

  scope "/tracking", TrackingWeb do
    pipe_through :browser

    ## The following scopes are organized by application user

    scope "/clerks" do
      get "/cargoes", CargoController, :show
      resources "/", ClerkController, only: [:index]
    end

    scope "/opsmanagers" do
      get "/events", HandlingEventController, :show
      resources "/", OpsManagerController, only: [:index]
    end
    # The next scope handles JSON requests and responsex
    scope "/api" do
      pipe_through :api
      get "/cargoes", CargoController, :show
      get "/events", HandlingEventController, :show
    end
  end


  # Special scope for loading the Elm version of the Tracking application

  scope "/elm", TrackingWeb do
    pipe_through :browser

    get "/", ElmPageController, :index
  end

end
