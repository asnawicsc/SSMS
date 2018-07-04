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

      get "/",                              PageController,         :index
    resources "/parameters",                ParameterController
      get "/system_config/:institution_id", ParameterController,    :system_config
    resources "/institutions",              InstitutionController
      get "/institutions/:id/select",       InstitutionController,  :select
    resources "/users",                     UserController
      get "/login",                         UserController,         :login
      post "/authenticate",                 UserController,         :authenticate
      post "/create_user",                  UserController,         :create_user
      get "/logout",                        UserController,         :logout
    resources "/students",                  StudentController
    resources "/levels",                    LevelController
    resources "/semesters",                 SemesterController
    resources "/classes",                   ClassController
      get "/classes/:id/students",          ClassController,        :students
      get "/add_to_class_semester",         ClassController,        :add_to_class_semester
    resources "/student_classes",           StudentClassController

  end

  # Other scopes may use custom stacks.
  # scope "/api", SchoolWeb do
  #   pipe_through :api
  # end
end
