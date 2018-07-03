defmodule SchoolWeb.Router do
  use SchoolWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SchoolWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/parameters", ParameterController
    resources "/institutions", InstitutionController
    resources "/users", UserController
    get "/login", UserController, :login
    post "/authenticate", UserController, :authenticate
     get "/logout", UserController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", SchoolWeb do
  #   pipe_through :api
  # end
end
