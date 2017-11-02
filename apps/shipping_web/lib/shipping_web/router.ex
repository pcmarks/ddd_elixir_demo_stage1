defmodule ShippingWeb.Router do
  use ShippingWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end


  scope "/", ShippingWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/customers", ShippingWeb do
    pipe_through :browser

    get "/cargoes", CargoController, :show
    resources "/", CustomerController, only: [:index, :show]
  end

  scope "/handlers", ShippingWeb do
    pipe_through :browser

    resources "/events", HandlingEventController, only: [:index, :new, :create]
    get "/", HandlerController, :index
  end

  scope "/elm", ShippingWeb do
    pipe_through :browser

    get "/", ElmPageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Stage1Web do
  #   pipe_through :api
  # end
end
