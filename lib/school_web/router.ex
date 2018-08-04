defmodule SchoolWeb.Router do
  use SchoolWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(School.SetLocale)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :splash_layout do
    plug(:put_layout, {SchoolWeb.LayoutView, :splash_page})
  end

  scope "/", SchoolWeb do
    # Use the default browser stack
    pipe_through([:browser, :splash_layout])
    get("/", PageController, :index)
  end

  scope "/", SchoolWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/dashboard", PageController, :dashboard)
    get("/operations", PageController, :operations)
    get("/library/books", PageController, :books)
    get("/library/loans/new", PageController, :new_loan)
    resources("/parameters", ParameterController)
    get("/system_config/:institution_id", ParameterController, :system_config)
    resources("/institutions", InstitutionController)
    get("/institutions/:id/select", InstitutionController, :select)
    resources("/users", UserController)
    get("/login", UserController, :login)
    post("/authenticate", UserController, :authenticate)
    post("/create_user", UserController, :create_user)
    get("/logout", UserController, :logout)
    resources("/students", StudentController)
    post("/upload_students", StudentController, :upload_students)
    resources("/levels", LevelController)
    resources("/semesters", SemesterController)
    resources("/classes", ClassController)
    get("/classes/:id/students", ClassController, :students)
    get("/add_to_class_semester", ClassController, :add_to_class_semester)
    resources("/student_classes", StudentClassController)
    get("/attendance/report", AttendanceController, :attendance_report)
    resources("/attendance", AttendanceController)
    get("/mark_attendance/:class_id", AttendanceController, :mark_attendance)
    get("/add_to_class_attendance", AttendanceController, :add_to_class_attendance)
    get("/add_to_class_absent", AttendanceController, :add_to_class_absent)

    resources("/absent", AbsentController)
    resources("/labels", LabelController)
  end

  # Other scopes may use custom stacks.
  # scope "/api", SchoolWeb do
  #   pipe_through :api
  # end
end
