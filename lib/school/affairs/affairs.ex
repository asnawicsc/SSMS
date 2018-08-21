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
end
