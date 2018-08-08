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

    resources "/teacher", TeacherController
     post("/upload_teachers", TeacherController, :upload_teachers)
    resources "/subject", SubjectController
    post("/upload_subjects", SubjectController, :upload_subjects)
     resources "/parent", ParentController
     post("/upload_parents", ParentController, :upload_parents)

    resources "/timetable", TimetableController
     get("/generated_timetable/:id", TimetableController, :generated_timetable)
    resources "/period", PeriodController
        post("/create_period", PeriodController, :create_period)
         post("/update_period/:id", PeriodController, :update_period)
    resources "/day", DayController
    resources "/grade", GradeController
resources "/exam_master", ExamMasterController
resources "/time_period", TimePeriodController


        resources "/exam", ExamController
            get("/generate_exam/:id", ExamController, :generate_exam)
                   post("/mark", ExamController, :mark)
  post("/create_mark", ExamController, :create_mark)
  post("/update_mark", ExamController, :update_mark)
   get("/new_exam", ExamController, :new_exam)
   post("/create_exam", ExamController, :create_exam)
    get("/rank/:id", ExamController, :rank)
    resources("/absent", AbsentController)
    resources("/labels", LabelController)
     post("/exam_ranking", ExamController, :exam_ranking)
          get("/generate_ranking", ExamController, :generate_ranking)

get("/report_card/:exam_name/:id", ExamController, :report_card)
      resources "/exam_mark", ExamMarkController

  end

  # Other scopes may use custom stacks.
  # scope "/api", SchoolWeb do
  #   pipe_through :api
  # end
end
