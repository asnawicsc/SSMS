defmodule SchoolWeb.Router do
  use SchoolWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(School.EmptySubdomain)
    plug(School.LoggingUser)
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
    get("/", PageController, :index_splash)
    get("/validate_code", ApiController, :code)
    get("/fb_login", ApiController, :fb_login)
    get("/parent_login", ParentController, :login)
    get("/parents_corner", ParentController, :parents_corner)
    get("/contacts_us", PageController, :contacts_us)
    post("/match_parents_ic", ParentController, :match_parents_ic)
    get("/redirect_from_li6", PageController, :redirect_from_li6)
    post("/delete_duplicate_icno", ParentController, :delete_duplicate_icno)
  end

  # Other scopes may use custom stacks.

  scope "/api", SchoolWeb do
    pipe_through(:api)

    get("/webhook_get", ApiController, :webhook_get)
    get("/google_oauth", GoogleController, :open_google_oauth)
    get("/callback", GoogleController, :callback)
  end

  scope "/pdf", SchoolWeb do
    # Use the default browser stack
    pipe_through([:browser])
    post("/class_analysis", PdfController, :class_analysis)
    post("/class_listing_teacher", PdfController, :class_listing_teacher)
    get("/student_transfer_pdf/:semester_id", PdfController, :student_transfer_pdf)

    post("/standard_listing", PdfController, :standard_listing)
    post("/exam_result_standard", PdfController, :exam_result_standard)
    post("/mark_sheet_listing", PdfController, :mark_sheet_listing)

    post("/class_ranking", PdfController, :class_ranking)
    post("/standard_ranking", PdfController, :standard_ranking)

    post("/student_class_listing", PdfController, :student_class_listing)
    post("/student_class_listing_jpn", PdfController, :student_class_listing_jpn)
    post("/student_class_listing_parent", PdfController, :student_class_listing_parent)
    post("/teacher_listing", PdfController, :teacher_listing)
    post("/exam_result_analysis_class", PdfController, :exam_result_analysis_class)

    post(
      "/exam_result_analysis_class_standard",
      PdfController,
      :exam_result_analysis_class_standard
    )

    post(
      "/class_assessment",
      PdfController,
      :class_assessment
    )

    post(
      "/head_count_listing",
      PdfController,
      :head_count_listing
    )

    get("/student_list_by_co", PdfController, :student_list_by_co)

    post("/height_weight_report_show", PdfController, :height_weight_report_show)

    post("/parent_listing", PdfController, :parent_listing)

    post("/display_student_certificate", PdfController, :display_student_certificate)
    post("/holiday_listing", PdfController, :holiday_listing)
  end

  scope "/", SchoolWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/class_transfer", ClassController, :class_transfer)
    get("/submit_class_transfer", ClassController, :submit_class_transfer)
    get("/mark_sheet_listing", ClassController, :mark_sheet_listing)
    get("/mark_analyse_by_grade", ClassController, :mark_analyse_by_grade)
    get("/class_analysis", ClassController, :class_analysis)
    get("/height_weight_report", ClassController, :height_weight_report)
    get("/create_class", ClassController, :create_class)
    get("/dashboard", PageController, :dashboard)
    get("/operations", PageController, :operations)
    get("/library/books", PageController, :books)
    get("/library/lib_access", PageController, :lib_access)
    get("/library/lib_register", PageController, :lib_register)

    post("/library/books/uploads", PageController, :upload_books)
    post("/library/book/update_book", PageController, :update_book)
    get("/library/book/student_cards", PageController, :student_cards)
    post("/library/book/update_template", PageController, :update_template)
    post("/library/book/generate_student_card", PageController, :generate_student_card)
    post("/library/book/preview_template", PageController, :preview_template)
    get("/library/loans/new", PageController, :new_loan)
    get("/library/returns", PageController, :return)
    get("/library/loan_report", PageController, :loan_report)

    post("/library/book/history_data", PageController, :history_data)
    post("/library/book/outstanding", PageController, :outstanding)
    get("/library/outstanding_all", PageController, :outstanding_all)
    post("/upload_timetable", ClassController, :upload_timetable)

    post("/pre_upload_timetable", ClassController, :pre_upload_timetable)
    resources("/examperiod", ExamPeriodController)

    get(
      "/show_exam_period/:exam_name/semester/:semester_id",
      ExamPeriodController,
      :show_exam_period
    )

    get(
      "/show_exam_grade/:exam_name/semester/:semester_id",
      ExamGradeController,
      :show_exam_grade
    )

    get(
      "/default_grade/:exam_master_id",
      ExamGradeController,
      :default_grade
    )

    get(
      "/add_grade/:exam_master_id",
      ExamGradeController,
      :add_grade
    )

    post(
      "/add_exam_grade",
      ExamGradeController,
      :add_exam_grade
    )

    get("/submit_exam_period", ExamPeriodController, :submit_exam_period)

    resources("/parameters", ParameterController)
    get("/parameters_view/:institution_id", ParameterController, :parameters_view)
    get("/system_config/:institution_id", ParameterController, :system_config)
    resources("/institutions", InstitutionController)
    get("/institutions/:id/select", InstitutionController, :select)
    get("/institutions/:id/upload", InstitutionController, :upload)
    post("/institutions/:id/pre_upload", InstitutionController, :pre_upload)
    resources("/users", UserController)
    get("/login", UserController, :login)
    get("/user_info/:id", UserController, :user_info)
    post("/authenticate", UserController, :authenticate)
    post("/create_user", UserController, :create_user)
    get("/register_new_user", UserController, :register_new_user)
    get("/logout", UserController, :logout)
    resources("/students", StudentController)

    post("/update_changes/:student_id", StudentController, :update_changes)
    post("/upload_students", StudentController, :pre_upload_students)
    post("/upload_teachers", TeacherController, :pre_upload_teachers)
    post("/upload_parents", ParentController, :pre_upload_parents)
    post("/upload_class", ClassController, :pre_upload_class)
    post("/generate_semester", SemesterController, :pre_generate_semester)

    post("/generate_absent", AbsentController, :pre_generate_absent)

    post("/generate_holiday", HolidayController, :pre_generate_holiday)

    post("/generate_exam_record", HistoryExamController, :pre_generate_exam_record)

    post("/pre_generate_student_class", StudentController, :pre_generate_student_class)

    post("/upload_teachers_final", TeacherController, :upload_teachers)
    post("/upload_students_final", StudentController, :upload_students)
    post("/upload_parent_final", ParentController, :upload_parents)
    post("/upload_class_final", ClassController, :upload_class)

    post("/upload_holiday_final", HolidayController, :upload_holiday)

    post("/upload_generate_student_class", StudentController, :upload_generate_student_class)

    post("/upload_semester_final", SemesterController, :upload_semester)

    post("/upload_history_exam_record", HistoryExamController, :upload_exam_record)

    post("/upload_absent_final", AbsentController, :upload_absent)

    get("/submit_student_transfer", StudentController, :submit_student_transfer)
    get("/students_transfer", StudentController, :students_transfer)
    get("/height_weight/:class_id", StudentController, :height_weight)
    get("/height_weight_class/:class_id", StudentController, :height_weight_class)
    get("/student_certificate", StudentController, :student_certificate)
    get("/student_lists/:user_id", StudentController, :student_lists)
    get("/height_weight_semester/:class_id", StudentController, :height_weight_semester)
    get("/edit_height_weight/:student_id/:semester_id", StudentController, :edit_height_weight)
    get("/submit_height_weight", StudentController, :submit_height_weight)

    resources("/levels", LevelController)
    resources("/semesters", SemesterController)
    get("/classes/enroll_students", ClassController, :enroll_students)
    resources("/classes", ClassController)
    get("/classes/:id/students", ClassController, :students)

    post("/create_monitor", ClassController, :create_monitor)

    get("/edit_monitor/:class_id", ClassController, :edit_monitor)

    post("/edit_monitor", ClassController, :edit_monitor)

    post("/generate_edit_monitor", ClassController, :generate_edit_monitor)

    get("/class_monitor/:class_id", ClassController, :class_monitor)
    get("/classes/:id/sync_library_membership", ClassController, :sync_library_membership)
    get("/:id/student_sync_library_membership", ClassController, :student_sync_library_membership)
    get("/sync_library_membership_all", ClassController, :sync_library_membership_all)
    get("/add_to_class_semester", ClassController, :add_to_class_semester)
    resources("/student_classes", StudentClassController)
    get("/attendance/report", AttendanceController, :attendance_report)
    resources("/attendance", AttendanceController)
    get("/mark_attendance/:class_id", AttendanceController, :mark_attendance)
    get("/add_to_class_attendance", AttendanceController, :add_to_class_attendance)
    get("/add_to_class_absent", AttendanceController, :add_to_class_absent)
    get("/record_attendance", AttendanceController, :record_attendance)

    resources("/teacher", TeacherController)
    get("/e_discipline", TeacherController, :e_discipline)
    get("/teacher_attendances", TeacherController, :teacher_attendances)
    get("/mark_teacher_attendance", TeacherController, :mark_teacher_attendance)
    get("/submit_teacher_attendance", TeacherController, :submit_teacher_attendance)
    post("/upload_teachers", TeacherController, :upload_teachers)
    get("/teacher_listing", TeacherController, :teacher_listing)
    resources("/subject", SubjectController)
    get("/subject/:id/assign_class", SubjectController, :assign_class)
    post("/upload_subjects", SubjectController, :upload_subjects)
    resources("/parent", ParentController)
    post("/upload_parents", ParentController, :upload_parents)

    get("/create_clerk", UserController, :create_clerk)

    resources("/timetable", TimetableController)
    get("/timetable/teacher/:user_id/list", TimetableController, :teacher_timetable_list)
    get("/timetable/teacher/:user_id/sync_to_gcal", TimetableController, :sync_to_gcal)
    get("/timetable/teacher/:user_id", TimetableController, :teacher_timetable)
    get("/timetable/class/:class_id", TimetableController, :class_timetable)
    get("/timetable/edit_event/:period_id", PeriodController, :edit_event)
    get("/timetable/delete_event/:id/:class_id", PeriodController, :delete)
    get("/generated_timetable/:id", TimetableController, :generated_timetable)
    get("/generated_timetable/:id", TimetableController, :generated_timetable)
    resources("/period", PeriodController)
    get("/create_period/:subject_id/:class_id", PeriodController, :get_create_period)
    post("/create_period", PeriodController, :create_period)
    post("/update_period/:id", PeriodController, :update_period)
    resources("/day", DayController)
    resources("/grade", GradeController)
    resources("/exam_master", ExamMasterController)
    resources("/time_period", TimePeriodController)

    get("/attendance/class/:class_id", AttendanceController, :class_attendance)

    get("/print_timetable/:panel", PdfController, :print_timetable)

    get("/exam/marking/:id/:c_id/:s_id", ExamController, :marking)
    get("/cocurriculum/marking/:id/:semester_id", CoCurriculumController, :marking)
    post("/generate_student_image", StudentController, :generate_student_image)

    resources("/exam", ExamController)
    get("/exam", ExamController, :index)
    get("/generate_exam", ExamController, :generate_exam)
    post("/mark", ExamController, :mark)
    post("/create_mark", ExamController, :create_mark)
    post("/update_mark", ExamController, :update_mark)
    get("/new_exam", ExamController, :new_exam)
    post("/create_exam", ExamController, :create_exam)
    post("/rank", ExamController, :rank)
    resources("/absent", AbsentController)
    resources("/labels", LabelController)
    post("/exam_ranking", ExamController, :exam_ranking)
    get("/generate_ranking", ExamController, :generate_ranking)

    get("/rank_exam/:id", ExamController, :rank_exam)

    resources("/head_counts", HeadCountController)

    get("/generate_head_count/:id", HeadCountController, :generate_head_count)
    post("/head_count_create", HeadCountController, :head_count_create)

    post("/create_head_count", HeadCountController, :create_head_count)

    post("/update_head_count_mark", HeadCountController, :update_head_count_mark)
    get("/head_count_subject/:id", HeadCountController, :head_count_subject)
    post("/head_count_subject_create", HeadCountController, :head_count_subject_create)

    get("/print_students/:id", StudentController, :print_students)

    get("/report_card/:exam_name/:exam_id/:id/:rank", ExamController, :report_card)
    get("/all_report_card", ExamController, :all_report_card)
    post("/all_report_card", ExamController, :all_report_card)
    get("/show_guardian/", ParentController, :guardian_listing)
    get("/show_guardian/:id/:student_no", ParentController, :show_guardian)
    resources("/exam_mark", ExamMarkController)
    get("/generate_mark_analyse/:id", ExamController, :generate_mark_analyse)
    post("/mark_analyse", ExamController, :mark_analyse)
    get("/default_grade", GradeController, :default_grade)
    get("/default_day", DayController, :default_day)
    resources("/teacher_period", TeacherPeriodController)
    post("/create_teacher_period", TeacherPeriodController, :create_teacher_period)

    get("/teacher_timetable", TeacherController, :teacher_timetable)
    resources("/co_grade", CoGradeController)
    get("/default_co_grade", CoGradeController, :default_co_grade)
    resources("/school_job", SchoolJobController)

    resources("/cocurriculum_job", CoCurriculumJobController)
    resources("/hem_job", HemJobController)
    resources("/absent_reason", AbsentReasonController)
    get("/teacher_setting", TeacherController, :teacher_setting)

    get("/school_job", TeacherController, :school_job)

    resources("/teacher_school_job", TeacherSchoolJobController)
    resources("/teacher_co_curriculum_job", TeacherCoCurriculumJobController)
    resources("/teacher_hem_job", TeacherHemJobController)

    resources("/teacher_absent_reason", TeacherAbsentReasonController)

    post("/create_teacher_school_job", TeacherSchoolJobController, :create_teacher_school_job)
    post("/contact_us_feedback", ContactUsController, :contact_us_feedback)
    resources("/contact_us", ContactUsController)
    get("/contact_us", PageController, :contact_us)

    post(
      "/create_teacher_cocurriculum_job",
      TeacherCoCurriculumJobController,
      :create_teacher_cocurriculum_job
    )

    post(
      "/generate_teacher_image",
      TeacherController,
      :generate_teacher_image
    )

    post("/create_teacher_hem_job", TeacherHemJobController, :create_teacher_hem_job)

    get("/standard_setting", SubjectController, :standard_setting)

    resources("/project_nilam", ProjectNilamController)
    resources("/jauhari", JauhariController)
    resources("/rakan", RakanController)
    get("/nilam_setting", ProjectNilamController, :nilam_setting)
    resources("/standard_subject", StandardSubjectController)

    post("/create_standard_subject", StandardSubjectController, :create_standard_subject)
    get("/new_standard_subject", SubjectController, :new_standard_subject)

    get("/create_new_test", SubjectController, :create_new_test)

    get("/class_setting", ClassController, :class_setting)
    get("/class_setting/:class_id", ClassController, :chosen_class_setting)
    get("/class_setting/:class_id/modify_timetable", ClassController, :modify_timetable)
    get("/show_student_info/:student_id", ClassController, :show_student_info)

    post("/create_student_co", CoCurriculumController, :create_student_co)
    get("/co_curriculum/enroll_students", CoCurriculumController, :enroll_students)
    get("/co_mark", CoCurriculumController, :co_mark)
    post("/create_co_mark", CoCurriculumController, :create_co_mark)
    post("/edit_co_mark", CoCurriculumController, :edit_co_mark)
    get("/headcount_report", HeadCountController, :headcount_report)

    get(
      "/student_report_by_cocurriculum",
      CoCurriculumController,
      :student_report_by_cocurriculum
    )

    resources("/subject_teach_class", SubjectTeachClassController)
    post("/create_class_subject_teach", SubjectTeachClassController, :create_class_subject_teach)
    post("/edit_class", ClassController, :edit_class)
    post("/edit_class_subject_teach", SubjectTeachClassController, :edit_class_subject_teach)

    post("/edit_project_nilam", ProjectNilamController, :edit_project_nilam)
    post("/create_class_period", ClassController, :create_class_period)

    get("/mark_sheet", ExamController, :mark_sheet)
    get("/exam_result_class", ExamController, :exam_result_class)
    get("/exam_result_standard", ExamController, :exam_result_standard)
    get("/exam_result_analysis_standard", ExamController, :exam_result_analysis_standard)
    get("/exam_result_analysis_class", ExamController, :exam_result_analysis_class)
    get("/generate_attendance_report", AttendanceController, :generate_attendance_report)
    resources("/cocurriculum", CoCurriculumController)
    resources("/student_cocurriculum", StudentCocurriculumController)
    get("/co_curriculum_setting", CoCurriculumController, :co_curriculum_setting)

    get("/co_mark", CoCurriculumController, :co_mark)
    post("/create_co_mark", CoCurriculumController, :create_co_mark)
    get("/student_listing_by_class", ClassController, :student_listing_by_class)
    get("/holiday_report", HolidayController, :holiday_report)
    resources("/holiday", HolidayController)
    resources("/comment", CommentController)
    resources("/student_comment", StudentCommentController)
    get("/list_class_comment", StudentCommentController, :list_class_comment)
    get("/student_comments", StudentCommentController, :student_comments)
    get("/mark_comment", StudentCommentController, :mark_comment)
    get("/mark_comments/:id", StudentCommentController, :mark_comments)
    post("/create_student_comment", StudentCommentController, :create_student_comment)
    resources("/user_access", UserAccessController)
    get("/user_access_pass/:id", UserAccessController, :user_access_pass)
    resources("/role", RoleController)
    get("/exam_report/:class_id/:exam_id", ExamController, :exam_report)

    get("/list_report", ExamController, :list_report)
    get("/list_report_history", ExamController, :list_report_history)
    get("/list_institutions", InstitutionController, :list_institutions)

    get("/report_nav", ExamController, :report_nav)
    get("/parent_listing", ParentController, :parent_listing)

    get("/admin_dashboard", PageController, :admin_dashboard)
    get("/clerk_dashboard", PageController, :clerk_dashboard)
    get("/support_dashboard", PageController, :support_dashboard)
    get("/monitor_dashboard/:class_id", PageController, :monitor_dashboard)
    get("/login_teacher", TeacherController, :login_teacher)
    get("/create_teacher_login/:id", TeacherController, :create_teacher_login)

    get("/edit_teacher_login/:id", TeacherController, :edit_teacher_login)

    post("/edit_teacher_access", TeacherController, :edit_teacher_access)
    get("/delete_teacher_login/:id", TeacherController, :delete_teacher_login)

    resources("/sync_list", SyncListController)
    get("/apply_color", PageController, :apply_color)
    get("/create_semesters", SemesterController, :create_semesters)
    post("/create_semesters_data", SemesterController, :create_semesters_data)
    resources("/exam_grade", ExamGradeController)
    resources("/batches", BatchController)
    resources("/segak", SegakController)
    get("/create_segak", SegakController, :create_segak)
    get("/segak/marking/:class_id/:semester_id", SegakController, :segak_mark)
    post("/create_segak_mark", SegakController, :create_segak_mark)
    post("/edit_segak_mark", SegakController, :edit_segak_mark)
    get("/edit_co_rank/:id/:semester_id", CoCurriculumController, :edit_co_rank)
    post("/create_rank_student_co", CoCurriculumController, :create_rank_student_co)
    post("/edit_rank_student_co", CoCurriculumController, :edit_rank_student_co)
    resources("/list_rank", ListRankController)
    get("/default_rank", ListRankController, :default_rank)
    post("/default_standard", LevelController, :default_standard)
    get("/assign_lib_access", UserController, :assign_lib_access)
    resources("/history_exam", HistoryExamController)
    get("/exam_history_checklist", HistoryExamController, :exam_history_checklist)
    get("/history_exam_result_class", HistoryExamController, :history_exam_result_class)
    post("/history_exam_report_class", HistoryExamController, :history_exam_report_class)
    resources("/absent_history", AbsentHistoryController)
    get("/history_absent", AbsentHistoryController, :history_absent)

    get(
      "/generate_history_exam/:exam_id/semester/:semester_id",
      HistoryExamController,
      :generate_history_exam
    )

    post("/pre_upload_absent_history", AbsentHistoryController, :pre_upload_absent_history)

    post("/upload_history_absent", AbsentHistoryController, :upload_history_absent)
    post("/history_absent_class", AbsentHistoryController, :history_absent_class)

    get(
      "/generate_head_count_mark/subject_id/:subject_id/class_id/:class_id",
      HeadCountController,
      :generate_head_count_mark
    )

    resources("/teacher_attendance", TeacherAttendanceController)

    resources("/announcements", AnnouncementController)
    get("/announcements/:id/broadcast", AnnouncementController, :broadcast)
    resources("/edisciplines", EdisciplineController)
    get("/ediscipline_form", EdisciplineController, :ediscipline_form)
    get("/msg_details", EdisciplineController, :msg_details)
    get("/show_message_details/:msg_id", EdisciplineController, :show_message_details)
    get("/update_summary", EdisciplineController, :update_summary)
    get("/change_semester", UserController, :change_semester)
    post("/get_change_semester", UserController, :get_change_semester)

    get("/default_rules_break", RulesBreakController, :default_rules_break)
    resources("/rules_break", RulesBreakController)

    resources("/assessment_subject", AssessmentSubjectController)

    get("/generate_assessment_subject", AssessmentSubjectController, :generate_assessment_subject)
    post("/create_assessment_subject", AssessmentSubjectController, :create_assessment_subject)

    get("/assign_level", AssessmentSubjectController, :assign_level)

    get(
      "/generate_rules_break/:assessment_id/:class_id/:subject_id",
      AssessmentSubjectController,
      :generate_rules_break
    )

    post("/create_rules_break", AssessmentSubjectController, :create_rules_break)

    post("/edit_rules_break", AssessmentSubjectController, :edit_rules_break)

    resources("/assessment_mark", AssessmentMarkController)

    get(
      "/assessment_report",
      AssessmentMarkController,
      :assessment_report
    )

    resources("/mark_sheet_history", MarkSheetHistoryController)

    get(
      "/history_report_card",
      ExamController,
      :history_report_card
    )

    post(
      "/pre_upload_mark_sheet_history",
      MarkSheetHistorysController,
      :pre_upload_mark_sheet_history
    )

    post(
      "/upload_mark_sheet_history",
      MarkSheetHistorysController,
      :upload_mark_sheet_history
    )

    get(
      "/class_teaching/:id",
      ClassController,
      :class_teaching
    )

    get(
      "/user_login_report",
      PdfController,
      :user_login_report
    )

    post(
      "/csv_student_class",
      StudentController,
      :csv_student_class
    )

    resources("/mark_sheet_historys", MarkSheetHistorysController)

    post(
      "/history_report_card_class",
      MarkSheetHistorysController,
      :history_report_card_class
    )

    resources("/ehehomeworks", EhomeworkController)
    get("/ehomework/:class_id", EhomeworkController, :ehomework)
    get("/show_ehomework_calendar/class/:class_id", EhomeworkController, :show_ehomework_calendar)
    get("/view_homework/class/:class_id/end_date/:end_date", EhomeworkController, :view_homework)
    get("/update_ehomework/:ehomework_id", EhomeworkController, :update_ehomework)
    get("/*path", PageController, :no_page_found)
  end
end
