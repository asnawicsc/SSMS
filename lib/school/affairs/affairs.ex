defmodule School.Affairs do
  @moduledoc """
  The Affairs context.
  """

  import Ecto.Query, warn: false
  alias School.Repo

  alias School.Affairs.Student

  @doc """
  Returns the list of students.

  ## Examples

      iex> list_students()
      [%Student{}, ...]

  """
  def list_students do
    Repo.all(Student)
  end

  @doc """
  Gets a single student.

  Raises `Ecto.NoResultsError` if the Student does not exist.

  ## Examples

      iex> get_student!(123)
      %Student{}

      iex> get_student!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student!(id), do: Repo.get!(Student, id)

  @doc """
  Creates a student.

  ## Examples

      iex> create_student(%{field: value})
      {:ok, %Student{}}

      iex> create_student(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student(attrs \\ %{}) do
    %Student{}
    |> Student.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a student.

  ## Examples

      iex> update_student(student, %{field: new_value})
      {:ok, %Student{}}

      iex> update_student(student, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student(%Student{} = student, attrs) do
    student
    |> Student.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Student.

  ## Examples

      iex> delete_student(student)
      {:ok, %Student{}}

      iex> delete_student(student)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student(%Student{} = student) do
    Repo.delete(student)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student changes.

  ## Examples

      iex> change_student(student)
      %Ecto.Changeset{source: %Student{}}

  """
  def change_student(%Student{} = student) do
    Student.changeset(student, %{})
  end

  alias School.Affairs.Level

  @doc """
  Returns the list of levels.

  ## Examples

      iex> list_levels()
      [%Level{}, ...]

  """
  def list_levels do
    Repo.all(Level)
  end

  @doc """
  Gets a single level.

  Raises `Ecto.NoResultsError` if the Level does not exist.

  ## Examples

      iex> get_level!(123)
      %Level{}

      iex> get_level!(456)
      ** (Ecto.NoResultsError)

  """
  def get_level!(id), do: Repo.get!(Level, id)

  @doc """
  Creates a level.

  ## Examples

      iex> create_level(%{field: value})
      {:ok, %Level{}}

      iex> create_level(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_level(attrs \\ %{}) do
    %Level{}
    |> Level.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a level.

  ## Examples

      iex> update_level(level, %{field: new_value})
      {:ok, %Level{}}

      iex> update_level(level, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_level(%Level{} = level, attrs) do
    level
    |> Level.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Level.

  ## Examples

      iex> delete_level(level)
      {:ok, %Level{}}

      iex> delete_level(level)
      {:error, %Ecto.Changeset{}}

  """
  def delete_level(%Level{} = level) do
    Repo.delete(level)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking level changes.

  ## Examples

      iex> change_level(level)
      %Ecto.Changeset{source: %Level{}}

  """
  def change_level(%Level{} = level) do
    Level.changeset(level, %{})
  end

  alias School.Affairs.Semester

  @doc """
  Returns the list of semesters.

  ## Examples

      iex> list_semesters()
      [%Semester{}, ...]

  """
  def list_semesters do
    Repo.all(Semester)
  end

  @doc """
  Gets a single semester.

  Raises `Ecto.NoResultsError` if the Semester does not exist.

  ## Examples

      iex> get_semester!(123)
      %Semester{}

      iex> get_semester!(456)
      ** (Ecto.NoResultsError)

  """
  def get_semester!(id), do: Repo.get!(Semester, id)

  @doc """
  Creates a semester.

  ## Examples

      iex> create_semester(%{field: value})
      {:ok, %Semester{}}

      iex> create_semester(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_semester(attrs \\ %{}) do
    %Semester{}
    |> Semester.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a semester.

  ## Examples

      iex> update_semester(semester, %{field: new_value})
      {:ok, %Semester{}}

      iex> update_semester(semester, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_semester(%Semester{} = semester, attrs) do
    semester
    |> Semester.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Semester.

  ## Examples

      iex> delete_semester(semester)
      {:ok, %Semester{}}

      iex> delete_semester(semester)
      {:error, %Ecto.Changeset{}}

  """
  def delete_semester(%Semester{} = semester) do
    Repo.delete(semester)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking semester changes.

  ## Examples

      iex> change_semester(semester)
      %Ecto.Changeset{source: %Semester{}}

  """
  def change_semester(%Semester{} = semester) do
    Semester.changeset(semester, %{})
  end

  alias School.Affairs.Class

  @doc """
  Returns the list of classes.

  ## Examples

      iex> list_classes()
      [%Class{}, ...]

  """
  def list_classes do
    Repo.all(Class)
  end

  def list_classes(institution_id) do
    Repo.all(from c in Class, left_join: l in Level, on: l.id == c.level_id, where: c.institution_id == ^institution_id,
      select: %{id: c.id, name: c.name, remarks: c.remarks, level_id: l.name}

      )
  end

  @doc """
  Gets a single class.

  Raises `Ecto.NoResultsError` if the Class does not exist.

  ## Examples

      iex> get_class!(123)
      %Class{}

      iex> get_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_class!(id), do: Repo.get!(Class, id)

  @doc """
  Creates a class.

  ## Examples

      iex> create_class(%{field: value})
      {:ok, %Class{}}

      iex> create_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_class(attrs \\ %{}) do
    %Class{}
    |> Class.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a class.

  ## Examples

      iex> update_class(class, %{field: new_value})
      {:ok, %Class{}}

      iex> update_class(class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_class(%Class{} = class, attrs) do
    class
    |> Class.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Class.

  ## Examples

      iex> delete_class(class)
      {:ok, %Class{}}

      iex> delete_class(class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_class(%Class{} = class) do
    Repo.delete(class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking class changes.

  ## Examples

      iex> change_class(class)
      %Ecto.Changeset{source: %Class{}}

  """
  def change_class(%Class{} = class) do
    Class.changeset(class, %{})
  end

  alias School.Affairs.StudentClass

  @doc """
  Returns the list of student_classes.

  ## Examples

      iex> list_student_classes()
      [%StudentClass{}, ...]

  """
  def list_student_classes do
    Repo.all(StudentClass)
  end

  @doc """
  Gets a single student_class.

  Raises `Ecto.NoResultsError` if the Student class does not exist.

  ## Examples

      iex> get_student_class!(123)
      %StudentClass{}

      iex> get_student_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student_class!(id), do: Repo.get!(StudentClass, id)

  @doc """
  Creates a student_class.

  ## Examples

      iex> create_student_class(%{field: value})
      {:ok, %StudentClass{}}

      iex> create_student_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student_class(attrs \\ %{}) do
    %StudentClass{}
    |> StudentClass.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a student_class.

  ## Examples

      iex> update_student_class(student_class, %{field: new_value})
      {:ok, %StudentClass{}}

      iex> update_student_class(student_class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student_class(%StudentClass{} = student_class, attrs) do
    student_class
    |> StudentClass.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a StudentClass.

  ## Examples

      iex> delete_student_class(student_class)
      {:ok, %StudentClass{}}

      iex> delete_student_class(student_class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student_class(%StudentClass{} = student_class) do
    Repo.delete(student_class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student_class changes.

  ## Examples

      iex> change_student_class(student_class)
      %Ecto.Changeset{source: %StudentClass{}}

  """
  def change_student_class(%StudentClass{} = student_class) do
    StudentClass.changeset(student_class, %{})
  end

  def inst_id(conn) do
     conn.private.plug_session["institution_id"]
  end

  alias School.Affairs.Attendance

  @doc """
  Returns the list of attendance.

  ## Examples

      iex> list_attendance()
      [%Attendance{}, ...]

  """
  def list_attendance do
    Repo.all(Attendance)
  end

  @doc """
  Gets a single attendance.

  Raises `Ecto.NoResultsError` if the Attendance does not exist.

  ## Examples

      iex> get_attendance!(123)
      %Attendance{}

      iex> get_attendance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_attendance!(id), do: Repo.get!(Attendance, id)

  @doc """
  Creates a attendance.

  ## Examples

      iex> create_attendance(%{field: value})
      {:ok, %Attendance{}}

      iex> create_attendance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_attendance(attrs \\ %{}) do
    %Attendance{}
    |> Attendance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a attendance.

  ## Examples

      iex> update_attendance(attendance, %{field: new_value})
      {:ok, %Attendance{}}

      iex> update_attendance(attendance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_attendance(%Attendance{} = attendance, attrs) do
    attendance
    |> Attendance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Attendance.

  ## Examples

      iex> delete_attendance(attendance)
      {:ok, %Attendance{}}

      iex> delete_attendance(attendance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_attendance(%Attendance{} = attendance) do
    Repo.delete(attendance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attendance changes.

  ## Examples

      iex> change_attendance(attendance)
      %Ecto.Changeset{source: %Attendance{}}

  """
  def change_attendance(%Attendance{} = attendance) do
    Attendance.changeset(attendance, %{})
  end

  alias School.Affairs.Absent

  @doc """
  Returns the list of absent.

  ## Examples

      iex> list_absent()
      [%Absent{}, ...]

  """
  def list_absent do
    Repo.all(Absent)
  end

  @doc """
  Gets a single absent.

  Raises `Ecto.NoResultsError` if the Absent does not exist.

  ## Examples

      iex> get_absent!(123)
      %Absent{}

      iex> get_absent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_absent!(id), do: Repo.get!(Absent, id)

  @doc """
  Creates a absent.

  ## Examples

      iex> create_absent(%{field: value})
      {:ok, %Absent{}}

      iex> create_absent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_absent(attrs \\ %{}) do
    %Absent{}
    |> Absent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a absent.

  ## Examples

      iex> update_absent(absent, %{field: new_value})
      {:ok, %Absent{}}

      iex> update_absent(absent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_absent(%Absent{} = absent, attrs) do
    absent
    |> Absent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Absent.

  ## Examples

      iex> delete_absent(absent)
      {:ok, %Absent{}}

      iex> delete_absent(absent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_absent(%Absent{} = absent) do
    Repo.delete(absent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking absent changes.

  ## Examples

      iex> change_absent(absent)
      %Ecto.Changeset{source: %Absent{}}

  """
  def change_absent(%Absent{} = absent) do
    Absent.changeset(absent, %{})
  end

  alias School.Affairs.Teacher

  @doc """
  Returns the list of teacher.

  ## Examples

      iex> list_teacher()
      [%Teacher{}, ...]

  """
  def list_teacher do
    Repo.all(Teacher)
  end

  @doc """
  Gets a single teacher.

  Raises `Ecto.NoResultsError` if the Teacher does not exist.

  ## Examples

      iex> get_teacher!(123)
      %Teacher{}

      iex> get_teacher!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher!(id), do: Repo.get!(Teacher, id)

  @doc """
  Creates a teacher.

  ## Examples

      iex> create_teacher(%{field: value})
      {:ok, %Teacher{}}

      iex> create_teacher(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher(attrs \\ %{}) do
    %Teacher{}
    |> Teacher.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teacher.

  ## Examples

      iex> update_teacher(teacher, %{field: new_value})
      {:ok, %Teacher{}}

      iex> update_teacher(teacher, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher(%Teacher{} = teacher, attrs) do
    teacher
    |> Teacher.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Teacher.

  ## Examples

      iex> delete_teacher(teacher)
      {:ok, %Teacher{}}

      iex> delete_teacher(teacher)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher(%Teacher{} = teacher) do
    Repo.delete(teacher)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher changes.

  ## Examples

      iex> change_teacher(teacher)
      %Ecto.Changeset{source: %Teacher{}}

  """
  def change_teacher(%Teacher{} = teacher) do
    Teacher.changeset(teacher, %{})
  end


  alias School.Affairs.Subject

  @doc """
  Returns the list of subject.

  ## Examples

      iex> list_subject()
      [%Subject{}, ...]

  """
  def list_subject do
    Repo.all(Subject)
  end

  @doc """
  Gets a single subject.

  Raises `Ecto.NoResultsError` if the Subject does not exist.

  ## Examples

      iex> get_subject!(123)
      %Subject{}

      iex> get_subject!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subject!(id), do: Repo.get!(Subject, id)

  @doc """
  Creates a subject.

  ## Examples

      iex> create_subject(%{field: value})
      {:ok, %Subject{}}

      iex> create_subject(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subject(attrs \\ %{}) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subject.

  ## Examples

      iex> update_subject(subject, %{field: new_value})
      {:ok, %Subject{}}

      iex> update_subject(subject, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subject(%Subject{} = subject, attrs) do
    subject
    |> Subject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Subject.

  ## Examples

      iex> delete_subject(subject)
      {:ok, %Subject{}}

      iex> delete_subject(subject)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subject(%Subject{} = subject) do
    Repo.delete(subject)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subject changes.

  ## Examples

      iex> change_subject(subject)
      %Ecto.Changeset{source: %Subject{}}

  """
  def change_subject(%Subject{} = subject) do
    Subject.changeset(subject, %{})
  end

  alias School.Affairs.Parent

  @doc """
  Returns the list of parent.

  ## Examples

      iex> list_parent()
      [%Parent{}, ...]

  """
  def list_parent do
    Repo.all(Parent)
  end

  @doc """
  Gets a single parent.

  Raises `Ecto.NoResultsError` if the Parent does not exist.

  ## Examples

      iex> get_parent!(123)
      %Parent{}

      iex> get_parent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_parent!(id), do: Repo.get!(Parent, id)

  @doc """
  Creates a parent.

  ## Examples

      iex> create_parent(%{field: value})
      {:ok, %Parent{}}

      iex> create_parent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_parent(attrs \\ %{}) do
    %Parent{}
    |> Parent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a parent.

  ## Examples

      iex> update_parent(parent, %{field: new_value})
      {:ok, %Parent{}}

      iex> update_parent(parent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_parent(%Parent{} = parent, attrs) do
    parent
    |> Parent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Parent.

  ## Examples

      iex> delete_parent(parent)
      {:ok, %Parent{}}

      iex> delete_parent(parent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_parent(%Parent{} = parent) do
    Repo.delete(parent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking parent changes.

  ## Examples

      iex> change_parent(parent)
      %Ecto.Changeset{source: %Parent{}}

  """
  def change_parent(%Parent{} = parent) do
    Parent.changeset(parent, %{})
  end

  alias School.Affairs.Timetable

  @doc """
  Returns the list of timetable.

  ## Examples

      iex> list_timetable()
      [%Timetable{}, ...]

  """
  def list_timetable do
    Repo.all(Timetable)
  end

  @doc """
  Gets a single timetable.

  Raises `Ecto.NoResultsError` if the Timetable does not exist.

  ## Examples

      iex> get_timetable!(123)
      %Timetable{}

      iex> get_timetable!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timetable!(id), do: Repo.get!(Timetable, id)

  @doc """
  Creates a timetable.

  ## Examples

      iex> create_timetable(%{field: value})
      {:ok, %Timetable{}}

      iex> create_timetable(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timetable(attrs \\ %{}) do
    %Timetable{}
    |> Timetable.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timetable.

  ## Examples

      iex> update_timetable(timetable, %{field: new_value})
      {:ok, %Timetable{}}

      iex> update_timetable(timetable, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timetable(%Timetable{} = timetable, attrs) do
    timetable
    |> Timetable.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Timetable.

  ## Examples

      iex> delete_timetable(timetable)
      {:ok, %Timetable{}}

      iex> delete_timetable(timetable)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timetable(%Timetable{} = timetable) do
    Repo.delete(timetable)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timetable changes.

  ## Examples

      iex> change_timetable(timetable)
      %Ecto.Changeset{source: %Timetable{}}

  """
  def change_timetable(%Timetable{} = timetable) do
    Timetable.changeset(timetable, %{})
  end

  alias School.Affairs.Period

  @doc """
  Returns the list of period.

  ## Examples

      iex> list_period()
      [%Period{}, ...]

  """
  def list_period do
    Repo.all(Period)
  end

  @doc """
  Gets a single period.

  Raises `Ecto.NoResultsError` if the Period does not exist.

  ## Examples

      iex> get_period!(123)
      %Period{}

      iex> get_period!(456)
      ** (Ecto.NoResultsError)

  """
  def get_period!(id), do: Repo.get!(Period, id)

  @doc """
  Creates a period.

  ## Examples

      iex> create_period(%{field: value})
      {:ok, %Period{}}

      iex> create_period(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_period(attrs \\ %{}) do
    %Period{}
    |> Period.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a period.

  ## Examples

      iex> update_period(period, %{field: new_value})
      {:ok, %Period{}}

      iex> update_period(period, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_period(%Period{} = period, attrs) do
    period
    |> Period.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Period.

  ## Examples

      iex> delete_period(period)
      {:ok, %Period{}}

      iex> delete_period(period)
      {:error, %Ecto.Changeset{}}

  """
  def delete_period(%Period{} = period) do
    Repo.delete(period)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking period changes.

  ## Examples

      iex> change_period(period)
      %Ecto.Changeset{source: %Period{}}

  """
  def change_period(%Period{} = period) do
    Period.changeset(period, %{})
  end

  alias School.Affairs.Day

  @doc """
  Returns the list of day.

  ## Examples

      iex> list_day()
      [%Day{}, ...]

  """
  def list_day do
    Repo.all(Day)
  end

  @doc """
  Gets a single day.

  Raises `Ecto.NoResultsError` if the Day does not exist.

  ## Examples

      iex> get_day!(123)
      %Day{}

      iex> get_day!(456)
      ** (Ecto.NoResultsError)

  """
  def get_day!(id), do: Repo.get!(Day, id)

  @doc """
  Creates a day.

  ## Examples

      iex> create_day(%{field: value})
      {:ok, %Day{}}

      iex> create_day(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_day(attrs \\ %{}) do
    %Day{}
    |> Day.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a day.

  ## Examples

      iex> update_day(day, %{field: new_value})
      {:ok, %Day{}}

      iex> update_day(day, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_day(%Day{} = day, attrs) do
    day
    |> Day.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Day.

  ## Examples

      iex> delete_day(day)
      {:ok, %Day{}}

      iex> delete_day(day)
      {:error, %Ecto.Changeset{}}

  """
  def delete_day(%Day{} = day) do
    Repo.delete(day)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking day changes.

  ## Examples

      iex> change_day(day)
      %Ecto.Changeset{source: %Day{}}

  """
  def change_day(%Day{} = day) do
    Day.changeset(day, %{})
  end

  alias School.Affairs.Grade

  @doc """
  Returns the list of grade.

  ## Examples

      iex> list_grade()
      [%Grade{}, ...]

  """
  def list_grade do
    Repo.all(Grade)
  end

  @doc """
  Gets a single grade.

  Raises `Ecto.NoResultsError` if the Grade does not exist.

  ## Examples

      iex> get_grade!(123)
      %Grade{}

      iex> get_grade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grade!(id), do: Repo.get!(Grade, id)

  @doc """
  Creates a grade.

  ## Examples

      iex> create_grade(%{field: value})
      {:ok, %Grade{}}

      iex> create_grade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grade(attrs \\ %{}) do
    %Grade{}
    |> Grade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grade.

  ## Examples

      iex> update_grade(grade, %{field: new_value})
      {:ok, %Grade{}}

      iex> update_grade(grade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grade(%Grade{} = grade, attrs) do
    grade
    |> Grade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Grade.

  ## Examples

      iex> delete_grade(grade)
      {:ok, %Grade{}}

      iex> delete_grade(grade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grade(%Grade{} = grade) do
    Repo.delete(grade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grade changes.

  ## Examples

      iex> change_grade(grade)
      %Ecto.Changeset{source: %Grade{}}

  """
  def change_grade(%Grade{} = grade) do
    Grade.changeset(grade, %{})
  end

  alias School.Affairs.Exam

  @doc """
  Returns the list of exam.

  ## Examples

      iex> list_exam()
      [%Exam{}, ...]

  """
  def list_exam do
    Repo.all(Exam)
  end

  @doc """
  Gets a single exam.

  Raises `Ecto.NoResultsError` if the Exam does not exist.

  ## Examples

      iex> get_exam!(123)
      %Exam{}

      iex> get_exam!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exam!(id), do: Repo.get!(Exam, id)

  @doc """
  Creates a exam.

  ## Examples

      iex> create_exam(%{field: value})
      {:ok, %Exam{}}

      iex> create_exam(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exam(attrs \\ %{}) do
    %Exam{}
    |> Exam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exam.

  ## Examples

      iex> update_exam(exam, %{field: new_value})
      {:ok, %Exam{}}

      iex> update_exam(exam, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exam(%Exam{} = exam, attrs) do
    exam
    |> Exam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Exam.

  ## Examples

      iex> delete_exam(exam)
      {:ok, %Exam{}}

      iex> delete_exam(exam)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exam(%Exam{} = exam) do
    Repo.delete(exam)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exam changes.

  ## Examples

      iex> change_exam(exam)
      %Ecto.Changeset{source: %Exam{}}

  """
  def change_exam(%Exam{} = exam) do
    Exam.changeset(exam, %{})
  end



  alias School.Affairs.ExamMaster

  @doc """
  Returns the list of exam_master.

  ## Examples

      iex> list_exam_master()
      [%ExamMaster{}, ...]

  """
  def list_exam_master do
    Repo.all(ExamMaster)
  end

  @doc """
  Gets a single exam_master.

  Raises `Ecto.NoResultsError` if the Exam master does not exist.

  ## Examples

      iex> get_exam_master!(123)
      %ExamMaster{}

      iex> get_exam_master!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exam_master!(id), do: Repo.get!(ExamMaster, id)

  @doc """
  Creates a exam_master.

  ## Examples

      iex> create_exam_master(%{field: value})
      {:ok, %ExamMaster{}}

      iex> create_exam_master(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exam_master(attrs \\ %{}) do
    %ExamMaster{}
    |> ExamMaster.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exam_master.

  ## Examples

      iex> update_exam_master(exam_master, %{field: new_value})
      {:ok, %ExamMaster{}}

      iex> update_exam_master(exam_master, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exam_master(%ExamMaster{} = exam_master, attrs) do
    exam_master
    |> ExamMaster.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ExamMaster.

  ## Examples

      iex> delete_exam_master(exam_master)
      {:ok, %ExamMaster{}}

      iex> delete_exam_master(exam_master)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exam_master(%ExamMaster{} = exam_master) do
    Repo.delete(exam_master)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exam_master changes.

  ## Examples

      iex> change_exam_master(exam_master)
      %Ecto.Changeset{source: %ExamMaster{}}

  """
  def change_exam_master(%ExamMaster{} = exam_master) do
    ExamMaster.changeset(exam_master, %{})
  end


  alias School.Affairs.ExamMark

  @doc """
  Returns the list of exam_mark.

  ## Examples

      iex> list_exam_mark()
      [%ExamMark{}, ...]

  """
  def list_exam_mark do
    Repo.all(ExamMark)
  end

  @doc """
  Gets a single exam_mark.

  Raises `Ecto.NoResultsError` if the Exam mark does not exist.

  ## Examples

      iex> get_exam_mark!(123)
      %ExamMark{}

      iex> get_exam_mark!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exam_mark!(id), do: Repo.get!(ExamMark, id)

  @doc """
  Creates a exam_mark.

  ## Examples

      iex> create_exam_mark(%{field: value})
      {:ok, %ExamMark{}}

      iex> create_exam_mark(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exam_mark(attrs \\ %{}) do
    %ExamMark{}
    |> ExamMark.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exam_mark.

  ## Examples

      iex> update_exam_mark(exam_mark, %{field: new_value})
      {:ok, %ExamMark{}}

      iex> update_exam_mark(exam_mark, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exam_mark(%ExamMark{} = exam_mark, attrs) do
    exam_mark
    |> ExamMark.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ExamMark.

  ## Examples

      iex> delete_exam_mark(exam_mark)
      {:ok, %ExamMark{}}

      iex> delete_exam_mark(exam_mark)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exam_mark(%ExamMark{} = exam_mark) do
    Repo.delete(exam_mark)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exam_mark changes.

  ## Examples

      iex> change_exam_mark(exam_mark)
      %Ecto.Changeset{source: %ExamMark{}}

  """
  def change_exam_mark(%ExamMark{} = exam_mark) do
    ExamMark.changeset(exam_mark, %{})
  end

  alias School.Affairs.TimePeriod

  @doc """
  Returns the list of time_period.

  ## Examples

      iex> list_time_period()
      [%TimePeriod{}, ...]

  """
  def list_time_period do
    Repo.all(TimePeriod)
  end

  @doc """
  Gets a single time_period.

  Raises `Ecto.NoResultsError` if the Time period does not exist.

  ## Examples

      iex> get_time_period!(123)
      %TimePeriod{}

      iex> get_time_period!(456)
      ** (Ecto.NoResultsError)

  """
  def get_time_period!(id), do: Repo.get!(TimePeriod, id)

  @doc """
  Creates a time_period.

  ## Examples

      iex> create_time_period(%{field: value})
      {:ok, %TimePeriod{}}

      iex> create_time_period(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_time_period(attrs \\ %{}) do
    %TimePeriod{}
    |> TimePeriod.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a time_period.

  ## Examples

      iex> update_time_period(time_period, %{field: new_value})
      {:ok, %TimePeriod{}}

      iex> update_time_period(time_period, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_time_period(%TimePeriod{} = time_period, attrs) do
    time_period
    |> TimePeriod.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TimePeriod.

  ## Examples

      iex> delete_time_period(time_period)
      {:ok, %TimePeriod{}}

      iex> delete_time_period(time_period)
      {:error, %Ecto.Changeset{}}

  """
  def delete_time_period(%TimePeriod{} = time_period) do
    Repo.delete(time_period)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking time_period changes.

  ## Examples

      iex> change_time_period(time_period)
      %Ecto.Changeset{source: %TimePeriod{}}

  """
  def change_time_period(%TimePeriod{} = time_period) do
    TimePeriod.changeset(time_period, %{})
  end




  alias School.Affairs.HeadCount

  @doc """
  Returns the list of head_counts.

  ## Examples

      iex> list_head_counts()
      [%HeadCount{}, ...]

  """
  def list_head_counts do
    Repo.all(HeadCount)
  end

  @doc """
  Gets a single head_count.

  Raises `Ecto.NoResultsError` if the Head count does not exist.

  ## Examples

      iex> get_head_count!(123)
      %HeadCount{}

      iex> get_head_count!(456)
      ** (Ecto.NoResultsError)

  """
  def get_head_count!(id), do: Repo.get!(HeadCount, id)

  @doc """
  Creates a head_count.

  ## Examples

      iex> create_head_count(%{field: value})
      {:ok, %HeadCount{}}

      iex> create_head_count(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_head_count(attrs \\ %{}) do
    %HeadCount{}
    |> HeadCount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a head_count.

  ## Examples

      iex> update_head_count(head_count, %{field: new_value})
      {:ok, %HeadCount{}}

      iex> update_head_count(head_count, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_head_count(%HeadCount{} = head_count, attrs) do
    head_count
    |> HeadCount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a HeadCount.

  ## Examples

      iex> delete_head_count(head_count)
      {:ok, %HeadCount{}}

      iex> delete_head_count(head_count)
      {:error, %Ecto.Changeset{}}

  """
  def delete_head_count(%HeadCount{} = head_count) do
    Repo.delete(head_count)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking head_count changes.

  ## Examples

      iex> change_head_count(head_count)
      %Ecto.Changeset{source: %HeadCount{}}

  """
  def change_head_count(%HeadCount{} = head_count) do
    HeadCount.changeset(head_count, %{})
  end

  alias School.Affairs.TeacherPeriod

  @doc """
  Returns the list of teacher_period.

  ## Examples

      iex> list_teacher_period()
      [%TeacherPeriod{}, ...]

  """
  def list_teacher_period do
    Repo.all(TeacherPeriod)
  end

  @doc """
  Gets a single teacher_period.

  Raises `Ecto.NoResultsError` if the Teacher period does not exist.

  ## Examples

      iex> get_teacher_period!(123)
      %TeacherPeriod{}

      iex> get_teacher_period!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher_period!(id), do: Repo.get!(TeacherPeriod, id)

  @doc """
  Creates a teacher_period.

  ## Examples

      iex> create_teacher_period(%{field: value})
      {:ok, %TeacherPeriod{}}

      iex> create_teacher_period(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher_period(attrs \\ %{}) do
    %TeacherPeriod{}
    |> TeacherPeriod.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teacher_period.

  ## Examples

      iex> update_teacher_period(teacher_period, %{field: new_value})
      {:ok, %TeacherPeriod{}}

      iex> update_teacher_period(teacher_period, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher_period(%TeacherPeriod{} = teacher_period, attrs) do
    teacher_period
    |> TeacherPeriod.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeacherPeriod.

  ## Examples

      iex> delete_teacher_period(teacher_period)
      {:ok, %TeacherPeriod{}}

      iex> delete_teacher_period(teacher_period)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher_period(%TeacherPeriod{} = teacher_period) do
    Repo.delete(teacher_period)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher_period changes.

  ## Examples

      iex> change_teacher_period(teacher_period)
      %Ecto.Changeset{source: %TeacherPeriod{}}

  """
  def change_teacher_period(%TeacherPeriod{} = teacher_period) do
    TeacherPeriod.changeset(teacher_period, %{})
  end

  alias School.Affairs.CoGrade

  @doc """
  Returns the list of co_grade.

  ## Examples

      iex> list_co_grade()
      [%CoGrade{}, ...]

  """
  def list_co_grade do
    Repo.all(CoGrade)
  end

  @doc """
  Gets a single co_grade.

  Raises `Ecto.NoResultsError` if the Co grade does not exist.

  ## Examples

      iex> get_co_grade!(123)
      %CoGrade{}

      iex> get_co_grade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_co_grade!(id), do: Repo.get!(CoGrade, id)

  @doc """
  Creates a co_grade.

  ## Examples

      iex> create_co_grade(%{field: value})
      {:ok, %CoGrade{}}

      iex> create_co_grade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_co_grade(attrs \\ %{}) do
    %CoGrade{}
    |> CoGrade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a co_grade.

  ## Examples

      iex> update_co_grade(co_grade, %{field: new_value})
      {:ok, %CoGrade{}}

      iex> update_co_grade(co_grade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_co_grade(%CoGrade{} = co_grade, attrs) do
    co_grade
    |> CoGrade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CoGrade.

  ## Examples

      iex> delete_co_grade(co_grade)
      {:ok, %CoGrade{}}

      iex> delete_co_grade(co_grade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_co_grade(%CoGrade{} = co_grade) do
    Repo.delete(co_grade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking co_grade changes.

  ## Examples

      iex> change_co_grade(co_grade)
      %Ecto.Changeset{source: %CoGrade{}}

  """
  def change_co_grade(%CoGrade{} = co_grade) do
    CoGrade.changeset(co_grade, %{})
  end

 

  alias School.Affairs.SchoolJob

  @doc """
  Returns the list of school_job.

  ## Examples

      iex> list_school_job()
      [%SchoolJob{}, ...]

  """
  def list_school_job do
    Repo.all(SchoolJob)
  end

  @doc """
  Gets a single school_job.

  Raises `Ecto.NoResultsError` if the School job does not exist.

  ## Examples

      iex> get_school_job!(123)
      %SchoolJob{}

      iex> get_school_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_school_job!(id), do: Repo.get!(SchoolJob, id)

  @doc """
  Creates a school_job.

  ## Examples

      iex> create_school_job(%{field: value})
      {:ok, %SchoolJob{}}

      iex> create_school_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_school_job(attrs \\ %{}) do
    %SchoolJob{}
    |> SchoolJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a school_job.

  ## Examples

      iex> update_school_job(school_job, %{field: new_value})
      {:ok, %SchoolJob{}}

      iex> update_school_job(school_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_school_job(%SchoolJob{} = school_job, attrs) do
    school_job
    |> SchoolJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SchoolJob.

  ## Examples

      iex> delete_school_job(school_job)
      {:ok, %SchoolJob{}}

      iex> delete_school_job(school_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_school_job(%SchoolJob{} = school_job) do
    Repo.delete(school_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking school_job changes.

  ## Examples

      iex> change_school_job(school_job)
      %Ecto.Changeset{source: %SchoolJob{}}

  """
  def change_school_job(%SchoolJob{} = school_job) do
    SchoolJob.changeset(school_job, %{})
  end

  alias School.Affairs.CoCurriculumJob

  @doc """
  Returns the list of cocurriculum_job.

  ## Examples

      iex> list_cocurriculum_job()
      [%CoCurriculumJob{}, ...]

  """
  def list_cocurriculum_job do
    Repo.all(CoCurriculumJob)
  end

  @doc """
  Gets a single co_curriculum_job.

  Raises `Ecto.NoResultsError` if the Co curriculum job does not exist.

  ## Examples

      iex> get_co_curriculum_job!(123)
      %CoCurriculumJob{}

      iex> get_co_curriculum_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_co_curriculum_job!(id), do: Repo.get!(CoCurriculumJob, id)

  @doc """
  Creates a co_curriculum_job.

  ## Examples

      iex> create_co_curriculum_job(%{field: value})
      {:ok, %CoCurriculumJob{}}

      iex> create_co_curriculum_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_co_curriculum_job(attrs \\ %{}) do
    %CoCurriculumJob{}
    |> CoCurriculumJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a co_curriculum_job.

  ## Examples

      iex> update_co_curriculum_job(co_curriculum_job, %{field: new_value})
      {:ok, %CoCurriculumJob{}}

      iex> update_co_curriculum_job(co_curriculum_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_co_curriculum_job(%CoCurriculumJob{} = co_curriculum_job, attrs) do
    co_curriculum_job
    |> CoCurriculumJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CoCurriculumJob.

  ## Examples

      iex> delete_co_curriculum_job(co_curriculum_job)
      {:ok, %CoCurriculumJob{}}

      iex> delete_co_curriculum_job(co_curriculum_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_co_curriculum_job(%CoCurriculumJob{} = co_curriculum_job) do
    Repo.delete(co_curriculum_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking co_curriculum_job changes.

  ## Examples

      iex> change_co_curriculum_job(co_curriculum_job)
      %Ecto.Changeset{source: %CoCurriculumJob{}}

  """
  def change_co_curriculum_job(%CoCurriculumJob{} = co_curriculum_job) do
    CoCurriculumJob.changeset(co_curriculum_job, %{})
  end

  alias School.Affairs.HemJob

  @doc """
  Returns the list of hem_job.

  ## Examples

      iex> list_hem_job()
      [%HemJob{}, ...]

  """
  def list_hem_job do
    Repo.all(HemJob)
  end

  @doc """
  Gets a single hem_job.

  Raises `Ecto.NoResultsError` if the Hem job does not exist.

  ## Examples

      iex> get_hem_job!(123)
      %HemJob{}

      iex> get_hem_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hem_job!(id), do: Repo.get!(HemJob, id)

  @doc """
  Creates a hem_job.

  ## Examples

      iex> create_hem_job(%{field: value})
      {:ok, %HemJob{}}

      iex> create_hem_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hem_job(attrs \\ %{}) do
    %HemJob{}
    |> HemJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hem_job.

  ## Examples

      iex> update_hem_job(hem_job, %{field: new_value})
      {:ok, %HemJob{}}

      iex> update_hem_job(hem_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hem_job(%HemJob{} = hem_job, attrs) do
    hem_job
    |> HemJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a HemJob.

  ## Examples

      iex> delete_hem_job(hem_job)
      {:ok, %HemJob{}}

      iex> delete_hem_job(hem_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hem_job(%HemJob{} = hem_job) do
    Repo.delete(hem_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hem_job changes.

  ## Examples

      iex> change_hem_job(hem_job)
      %Ecto.Changeset{source: %HemJob{}}

  """
  def change_hem_job(%HemJob{} = hem_job) do
    HemJob.changeset(hem_job, %{})
  end

  alias School.Affairs.AbsentReason

  @doc """
  Returns the list of absent_reason.

  ## Examples

      iex> list_absent_reason()
      [%AbsentReason{}, ...]

  """
  def list_absent_reason do
    Repo.all(AbsentReason)
  end

  @doc """
  Gets a single absent_reason.

  Raises `Ecto.NoResultsError` if the Absent reason does not exist.

  ## Examples

      iex> get_absent_reason!(123)
      %AbsentReason{}

      iex> get_absent_reason!(456)
      ** (Ecto.NoResultsError)

  """
  def get_absent_reason!(id), do: Repo.get!(AbsentReason, id)

  @doc """
  Creates a absent_reason.

  ## Examples

      iex> create_absent_reason(%{field: value})
      {:ok, %AbsentReason{}}

      iex> create_absent_reason(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_absent_reason(attrs \\ %{}) do
    %AbsentReason{}
    |> AbsentReason.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a absent_reason.

  ## Examples

      iex> update_absent_reason(absent_reason, %{field: new_value})
      {:ok, %AbsentReason{}}

      iex> update_absent_reason(absent_reason, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_absent_reason(%AbsentReason{} = absent_reason, attrs) do
    absent_reason
    |> AbsentReason.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AbsentReason.

  ## Examples

      iex> delete_absent_reason(absent_reason)
      {:ok, %AbsentReason{}}

      iex> delete_absent_reason(absent_reason)
      {:error, %Ecto.Changeset{}}

  """
  def delete_absent_reason(%AbsentReason{} = absent_reason) do
    Repo.delete(absent_reason)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking absent_reason changes.

  ## Examples

      iex> change_absent_reason(absent_reason)
      %Ecto.Changeset{source: %AbsentReason{}}

  """
  def change_absent_reason(%AbsentReason{} = absent_reason) do
    AbsentReason.changeset(absent_reason, %{})
  end

  alias School.Affairs.TeacherSchoolJob

  @doc """
  Returns the list of teacher_school_job.

  ## Examples

      iex> list_teacher_school_job()
      [%TeacherSchoolJob{}, ...]

  """
  def list_teacher_school_job do
    Repo.all(TeacherSchoolJob)
  end

  @doc """
  Gets a single teacher_school_job.

  Raises `Ecto.NoResultsError` if the Teacher school job does not exist.

  ## Examples

      iex> get_teacher_school_job!(123)
      %TeacherSchoolJob{}

      iex> get_teacher_school_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher_school_job!(id), do: Repo.get!(TeacherSchoolJob, id)

  @doc """
  Creates a teacher_school_job.

  ## Examples

      iex> create_teacher_school_job(%{field: value})
      {:ok, %TeacherSchoolJob{}}

      iex> create_teacher_school_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher_school_job(attrs \\ %{}) do
    %TeacherSchoolJob{}
    |> TeacherSchoolJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teacher_school_job.

  ## Examples

      iex> update_teacher_school_job(teacher_school_job, %{field: new_value})
      {:ok, %TeacherSchoolJob{}}

      iex> update_teacher_school_job(teacher_school_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher_school_job(%TeacherSchoolJob{} = teacher_school_job, attrs) do
    teacher_school_job
    |> TeacherSchoolJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeacherSchoolJob.

  ## Examples

      iex> delete_teacher_school_job(teacher_school_job)
      {:ok, %TeacherSchoolJob{}}

      iex> delete_teacher_school_job(teacher_school_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher_school_job(%TeacherSchoolJob{} = teacher_school_job) do
    Repo.delete(teacher_school_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher_school_job changes.

  ## Examples

      iex> change_teacher_school_job(teacher_school_job)
      %Ecto.Changeset{source: %TeacherSchoolJob{}}

  """
  def change_teacher_school_job(%TeacherSchoolJob{} = teacher_school_job) do
    TeacherSchoolJob.changeset(teacher_school_job, %{})
  end

  alias School.Affairs.TeacherCoCurriculumJob

  @doc """
  Returns the list of teacher_co_curriculum_job.

  ## Examples

      iex> list_teacher_co_curriculum_job()
      [%TeacherCoCurriculumJob{}, ...]

  """
  def list_teacher_co_curriculum_job do
    Repo.all(TeacherCoCurriculumJob)
  end

  @doc """
  Gets a single teacher_co_curriculum_job.

  Raises `Ecto.NoResultsError` if the Teacher co curriculum job does not exist.

  ## Examples

      iex> get_teacher_co_curriculum_job!(123)
      %TeacherCoCurriculumJob{}

      iex> get_teacher_co_curriculum_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher_co_curriculum_job!(id), do: Repo.get!(TeacherCoCurriculumJob, id)

  @doc """
  Creates a teacher_co_curriculum_job.

  ## Examples

      iex> create_teacher_co_curriculum_job(%{field: value})
      {:ok, %TeacherCoCurriculumJob{}}

      iex> create_teacher_co_curriculum_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher_co_curriculum_job(attrs \\ %{}) do
    %TeacherCoCurriculumJob{}
    |> TeacherCoCurriculumJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teacher_co_curriculum_job.

  ## Examples

      iex> update_teacher_co_curriculum_job(teacher_co_curriculum_job, %{field: new_value})
      {:ok, %TeacherCoCurriculumJob{}}

      iex> update_teacher_co_curriculum_job(teacher_co_curriculum_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher_co_curriculum_job(%TeacherCoCurriculumJob{} = teacher_co_curriculum_job, attrs) do
    teacher_co_curriculum_job
    |> TeacherCoCurriculumJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeacherCoCurriculumJob.

  ## Examples

      iex> delete_teacher_co_curriculum_job(teacher_co_curriculum_job)
      {:ok, %TeacherCoCurriculumJob{}}

      iex> delete_teacher_co_curriculum_job(teacher_co_curriculum_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher_co_curriculum_job(%TeacherCoCurriculumJob{} = teacher_co_curriculum_job) do
    Repo.delete(teacher_co_curriculum_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher_co_curriculum_job changes.

  ## Examples

      iex> change_teacher_co_curriculum_job(teacher_co_curriculum_job)
      %Ecto.Changeset{source: %TeacherCoCurriculumJob{}}

  """
  def change_teacher_co_curriculum_job(%TeacherCoCurriculumJob{} = teacher_co_curriculum_job) do
    TeacherCoCurriculumJob.changeset(teacher_co_curriculum_job, %{})
  end

  alias School.Affairs.TeacherHemJob

  @doc """
  Returns the list of teacher_hem_job.

  ## Examples

      iex> list_teacher_hem_job()
      [%TeacherHemJob{}, ...]

  """
  def list_teacher_hem_job do
    Repo.all(TeacherHemJob)
  end

  @doc """
  Gets a single teacher_hem_job.

  Raises `Ecto.NoResultsError` if the Teacher hem job does not exist.

  ## Examples

      iex> get_teacher_hem_job!(123)
      %TeacherHemJob{}

      iex> get_teacher_hem_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher_hem_job!(id), do: Repo.get!(TeacherHemJob, id)

  @doc """
  Creates a teacher_hem_job.

  ## Examples

      iex> create_teacher_hem_job(%{field: value})
      {:ok, %TeacherHemJob{}}

      iex> create_teacher_hem_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher_hem_job(attrs \\ %{}) do
    %TeacherHemJob{}
    |> TeacherHemJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teacher_hem_job.

  ## Examples

      iex> update_teacher_hem_job(teacher_hem_job, %{field: new_value})
      {:ok, %TeacherHemJob{}}

      iex> update_teacher_hem_job(teacher_hem_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher_hem_job(%TeacherHemJob{} = teacher_hem_job, attrs) do
    teacher_hem_job
    |> TeacherHemJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeacherHemJob.

  ## Examples

      iex> delete_teacher_hem_job(teacher_hem_job)
      {:ok, %TeacherHemJob{}}

      iex> delete_teacher_hem_job(teacher_hem_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher_hem_job(%TeacherHemJob{} = teacher_hem_job) do
    Repo.delete(teacher_hem_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher_hem_job changes.

  ## Examples

      iex> change_teacher_hem_job(teacher_hem_job)
      %Ecto.Changeset{source: %TeacherHemJob{}}

  """
  def change_teacher_hem_job(%TeacherHemJob{} = teacher_hem_job) do
    TeacherHemJob.changeset(teacher_hem_job, %{})
  end

  alias School.Affairs.TeacherAbsentReason

  @doc """
  Returns the list of teacher_absent_reason.

  ## Examples

      iex> list_teacher_absent_reason()
      [%TeacherAbsentReason{}, ...]

  """
  def list_teacher_absent_reason do
    Repo.all(TeacherAbsentReason)
  end

  @doc """
  Gets a single teacher_absent_reason.

  Raises `Ecto.NoResultsError` if the Teacher absent reason does not exist.

  ## Examples

      iex> get_teacher_absent_reason!(123)
      %TeacherAbsentReason{}

      iex> get_teacher_absent_reason!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher_absent_reason!(id), do: Repo.get!(TeacherAbsentReason, id)

  @doc """
  Creates a teacher_absent_reason.

  ## Examples

      iex> create_teacher_absent_reason(%{field: value})
      {:ok, %TeacherAbsentReason{}}

      iex> create_teacher_absent_reason(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher_absent_reason(attrs \\ %{}) do
    %TeacherAbsentReason{}
    |> TeacherAbsentReason.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teacher_absent_reason.

  ## Examples

      iex> update_teacher_absent_reason(teacher_absent_reason, %{field: new_value})
      {:ok, %TeacherAbsentReason{}}

      iex> update_teacher_absent_reason(teacher_absent_reason, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher_absent_reason(%TeacherAbsentReason{} = teacher_absent_reason, attrs) do
    teacher_absent_reason
    |> TeacherAbsentReason.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeacherAbsentReason.

  ## Examples

      iex> delete_teacher_absent_reason(teacher_absent_reason)
      {:ok, %TeacherAbsentReason{}}

      iex> delete_teacher_absent_reason(teacher_absent_reason)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher_absent_reason(%TeacherAbsentReason{} = teacher_absent_reason) do
    Repo.delete(teacher_absent_reason)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher_absent_reason changes.

  ## Examples

      iex> change_teacher_absent_reason(teacher_absent_reason)
      %Ecto.Changeset{source: %TeacherAbsentReason{}}

  """
  def change_teacher_absent_reason(%TeacherAbsentReason{} = teacher_absent_reason) do
    TeacherAbsentReason.changeset(teacher_absent_reason, %{})
  end

  alias School.Affairs.ProjectNilam

  @doc """
  Returns the list of project_nilam.

  ## Examples

      iex> list_project_nilam()
      [%ProjectNilam{}, ...]

  """
  def list_project_nilam do
    Repo.all(ProjectNilam)
  end

  @doc """
  Gets a single project_nilam.

  Raises `Ecto.NoResultsError` if the Project nilam does not exist.

  ## Examples

      iex> get_project_nilam!(123)
      %ProjectNilam{}

      iex> get_project_nilam!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_nilam!(id), do: Repo.get!(ProjectNilam, id)

  @doc """
  Creates a project_nilam.

  ## Examples

      iex> create_project_nilam(%{field: value})
      {:ok, %ProjectNilam{}}

      iex> create_project_nilam(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_nilam(attrs \\ %{}) do
    %ProjectNilam{}
    |> ProjectNilam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project_nilam.

  ## Examples

      iex> update_project_nilam(project_nilam, %{field: new_value})
      {:ok, %ProjectNilam{}}

      iex> update_project_nilam(project_nilam, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_nilam(%ProjectNilam{} = project_nilam, attrs) do
    project_nilam
    |> ProjectNilam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ProjectNilam.

  ## Examples

      iex> delete_project_nilam(project_nilam)
      {:ok, %ProjectNilam{}}

      iex> delete_project_nilam(project_nilam)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_nilam(%ProjectNilam{} = project_nilam) do
    Repo.delete(project_nilam)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project_nilam changes.

  ## Examples

      iex> change_project_nilam(project_nilam)
      %Ecto.Changeset{source: %ProjectNilam{}}

  """
  def change_project_nilam(%ProjectNilam{} = project_nilam) do
    ProjectNilam.changeset(project_nilam, %{})
  end

  alias School.Affairs.Jauhari

  @doc """
  Returns the list of jauhari.

  ## Examples

      iex> list_jauhari()
      [%Jauhari{}, ...]

  """
  def list_jauhari do
    Repo.all(Jauhari)
  end

  @doc """
  Gets a single jauhari.

  Raises `Ecto.NoResultsError` if the Jauhari does not exist.

  ## Examples

      iex> get_jauhari!(123)
      %Jauhari{}

      iex> get_jauhari!(456)
      ** (Ecto.NoResultsError)

  """
  def get_jauhari!(id), do: Repo.get!(Jauhari, id)

  @doc """
  Creates a jauhari.

  ## Examples

      iex> create_jauhari(%{field: value})
      {:ok, %Jauhari{}}

      iex> create_jauhari(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_jauhari(attrs \\ %{}) do
    %Jauhari{}
    |> Jauhari.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a jauhari.

  ## Examples

      iex> update_jauhari(jauhari, %{field: new_value})
      {:ok, %Jauhari{}}

      iex> update_jauhari(jauhari, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_jauhari(%Jauhari{} = jauhari, attrs) do
    jauhari
    |> Jauhari.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Jauhari.

  ## Examples

      iex> delete_jauhari(jauhari)
      {:ok, %Jauhari{}}

      iex> delete_jauhari(jauhari)
      {:error, %Ecto.Changeset{}}

  """
  def delete_jauhari(%Jauhari{} = jauhari) do
    Repo.delete(jauhari)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking jauhari changes.

  ## Examples

      iex> change_jauhari(jauhari)
      %Ecto.Changeset{source: %Jauhari{}}

  """
  def change_jauhari(%Jauhari{} = jauhari) do
    Jauhari.changeset(jauhari, %{})
  end

  alias School.Affairs.Rakan

  @doc """
  Returns the list of rakan.

  ## Examples

      iex> list_rakan()
      [%Rakan{}, ...]

  """
  def list_rakan do
    Repo.all(Rakan)
  end

  @doc """
  Gets a single rakan.

  Raises `Ecto.NoResultsError` if the Rakan does not exist.

  ## Examples

      iex> get_rakan!(123)
      %Rakan{}

      iex> get_rakan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rakan!(id), do: Repo.get!(Rakan, id)

  @doc """
  Creates a rakan.

  ## Examples

      iex> create_rakan(%{field: value})
      {:ok, %Rakan{}}

      iex> create_rakan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rakan(attrs \\ %{}) do
    %Rakan{}
    |> Rakan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rakan.

  ## Examples

      iex> update_rakan(rakan, %{field: new_value})
      {:ok, %Rakan{}}

      iex> update_rakan(rakan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rakan(%Rakan{} = rakan, attrs) do
    rakan
    |> Rakan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Rakan.

  ## Examples

      iex> delete_rakan(rakan)
      {:ok, %Rakan{}}

      iex> delete_rakan(rakan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rakan(%Rakan{} = rakan) do
    Repo.delete(rakan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rakan changes.

  ## Examples

      iex> change_rakan(rakan)
      %Ecto.Changeset{source: %Rakan{}}

  """
  def change_rakan(%Rakan{} = rakan) do
    Rakan.changeset(rakan, %{})
  end

  alias School.Affairs.StandardSubject

  @doc """
  Returns the list of standard_subject.

  ## Examples

      iex> list_standard_subject()
      [%StandardSubject{}, ...]

  """
  def list_standard_subject do
    Repo.all(StandardSubject)
  end

  @doc """
  Gets a single standard_subject.

  Raises `Ecto.NoResultsError` if the Standard subject does not exist.

  ## Examples

      iex> get_standard_subject!(123)
      %StandardSubject{}

      iex> get_standard_subject!(456)
      ** (Ecto.NoResultsError)

  """
  def get_standard_subject!(id), do: Repo.get!(StandardSubject, id)

  @doc """
  Creates a standard_subject.

  ## Examples

      iex> create_standard_subject(%{field: value})
      {:ok, %StandardSubject{}}

      iex> create_standard_subject(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_standard_subject(attrs \\ %{}) do
    %StandardSubject{}
    |> StandardSubject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a standard_subject.

  ## Examples

      iex> update_standard_subject(standard_subject, %{field: new_value})
      {:ok, %StandardSubject{}}

      iex> update_standard_subject(standard_subject, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_standard_subject(%StandardSubject{} = standard_subject, attrs) do
    standard_subject
    |> StandardSubject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a StandardSubject.

  ## Examples

      iex> delete_standard_subject(standard_subject)
      {:ok, %StandardSubject{}}

      iex> delete_standard_subject(standard_subject)
      {:error, %Ecto.Changeset{}}

  """
  def delete_standard_subject(%StandardSubject{} = standard_subject) do
    Repo.delete(standard_subject)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking standard_subject changes.

  ## Examples

      iex> change_standard_subject(standard_subject)
      %Ecto.Changeset{source: %StandardSubject{}}

  """
  def change_standard_subject(%StandardSubject{} = standard_subject) do
    StandardSubject.changeset(standard_subject, %{})
  end

  alias School.Affairs.SubjectTeachClass

  @doc """
  Returns the list of subject_teach_class.

  ## Examples

      iex> list_subject_teach_class()
      [%SubjectTeachClass{}, ...]

  """
  def list_subject_teach_class do
    Repo.all(SubjectTeachClass)
  end

  @doc """
  Gets a single subject_teach_class.

  Raises `Ecto.NoResultsError` if the Subject teach class does not exist.

  ## Examples

      iex> get_subject_teach_class!(123)
      %SubjectTeachClass{}

      iex> get_subject_teach_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subject_teach_class!(id), do: Repo.get!(SubjectTeachClass, id)

  @doc """
  Creates a subject_teach_class.

  ## Examples

      iex> create_subject_teach_class(%{field: value})
      {:ok, %SubjectTeachClass{}}

      iex> create_subject_teach_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subject_teach_class(attrs \\ %{}) do
    %SubjectTeachClass{}
    |> SubjectTeachClass.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subject_teach_class.

  ## Examples

      iex> update_subject_teach_class(subject_teach_class, %{field: new_value})
      {:ok, %SubjectTeachClass{}}

      iex> update_subject_teach_class(subject_teach_class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subject_teach_class(%SubjectTeachClass{} = subject_teach_class, attrs) do
    subject_teach_class
    |> SubjectTeachClass.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SubjectTeachClass.

  ## Examples

      iex> delete_subject_teach_class(subject_teach_class)
      {:ok, %SubjectTeachClass{}}

      iex> delete_subject_teach_class(subject_teach_class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subject_teach_class(%SubjectTeachClass{} = subject_teach_class) do
    Repo.delete(subject_teach_class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subject_teach_class changes.

  ## Examples

      iex> change_subject_teach_class(subject_teach_class)
      %Ecto.Changeset{source: %SubjectTeachClass{}}

  """
  def change_subject_teach_class(%SubjectTeachClass{} = subject_teach_class) do
    SubjectTeachClass.changeset(subject_teach_class, %{})
  end
end
