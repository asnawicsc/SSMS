defmodule School.Affairs do
  @moduledoc """
  The Affairs context.
  """

  import Ecto.Query, warn: false
  alias School.Repo

  alias School.Affairs.Student
  require IEx

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

  def list_semesters(institution_id) do
    Repo.all(
      from(s in Semester, where: s.institution_id == ^institution_id, order_by: [s.start_date])
    )
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
    Repo.all(
      from(
        c in Class,
        left_join: l in Level,
        on: l.id == c.level_id,
        where: c.institution_id == ^institution_id and c.is_delete == 0,
        select: %{
          id: c.id,
          name: c.name,
          remarks: c.remarks,
          level_id: l.name,
          teacher_id: c.teacher_id,
          standard_id: l.id,
          is_delete: c.is_delete
        }
      )
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

  def list_teacher(inst_id) do
    Repo.all(from(t in Teacher, where: t.institution_id == ^inst_id))
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

  def list_subject(inst_id) do
    Repo.all(from(s in Subject, where: s.institution_id == ^inst_id))
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

  def list_parent(inst_id) do
    Repo.all(from(p in Parent, where: p.institution_id == ^inst_id))
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
  def update_teacher_co_curriculum_job(
        %TeacherCoCurriculumJob{} = teacher_co_curriculum_job,
        attrs
      ) do
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

  alias School.Affairs.CoCurriculum

  @doc """
  Returns the list of cocurriculum.

  ## Examples

      iex> list_cocurriculum()
      [%CoCurriculum{}, ...]

  """
  def list_cocurriculum do
    Repo.all(CoCurriculum)
  end

  def list_cocurriculum(inst_id) do
    Repo.all(
      from(
        c in CoCurriculum,
        left_join: t in Teacher,
        on: t.id == c.teacher_id,
        where: c.institution_id == ^inst_id,
        select: %{
          id: c.id,
          code: c.code,
          description: c.description,
          teacher_id: t.name,
          category: c.category,
          sub_category: c.sub_category
        }
      )
    )
  end

  @doc """
  Gets a single co_curriculum.

  Raises `Ecto.NoResultsError` if the Co curriculum does not exist.

  ## Examples

      iex> get_co_curriculum!(123)
      %CoCurriculum{}

      iex> get_co_curriculum!(456)
      ** (Ecto.NoResultsError)

  """
  def get_co_curriculum!(id), do: Repo.get!(CoCurriculum, id)

  @doc """
  Creates a co_curriculum.

  ## Examples

      iex> create_co_curriculum(%{field: value})
      {:ok, %CoCurriculum{}}

      iex> create_co_curriculum(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_co_curriculum(attrs \\ %{}) do
    %CoCurriculum{}
    |> CoCurriculum.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a co_curriculum.

  ## Examples

      iex> update_co_curriculum(co_curriculum, %{field: new_value})
      {:ok, %CoCurriculum{}}

      iex> update_co_curriculum(co_curriculum, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_co_curriculum(%CoCurriculum{} = co_curriculum, attrs) do
    co_curriculum
    |> CoCurriculum.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CoCurriculum.

  ## Examples

      iex> delete_co_curriculum(co_curriculum)
      {:ok, %CoCurriculum{}}

      iex> delete_co_curriculum(co_curriculum)
      {:error, %Ecto.Changeset{}}

  """
  def delete_co_curriculum(%CoCurriculum{} = co_curriculum) do
    Repo.delete(co_curriculum)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking co_curriculum changes.

  ## Examples

      iex> change_co_curriculum(co_curriculum)
      %Ecto.Changeset{source: %CoCurriculum{}}

  """
  def change_co_curriculum(%CoCurriculum{} = co_curriculum) do
    CoCurriculum.changeset(co_curriculum, %{})
  end

  alias School.Affairs.StudentCocurriculum

  @doc """
  Returns the list of student_cocurriculum.

  ## Examples

      iex> list_student_cocurriculum()
      [%StudentCocurriculum{}, ...]

  """
  def list_student_cocurriculum do
    Repo.all(StudentCocurriculum)
  end

  def list_student_cocurriculum(coco_id, semester_id) do
    a =
      Repo.all(
        from(
          sc in StudentCocurriculum,
          left_join: s in Student,
          on: s.id == sc.student_id,
          where: sc.cocurriculum_id == ^coco_id and sc.semester_id == ^semester_id,
          select: %{name: s.name, id: s.id}
        )
      )

    if a == [] do
      [%{name: "no students", id: 0}]
    else
      a
    end
  end

  @doc """
  Gets a single student_cocurriculum.

  Raises `Ecto.NoResultsError` if the Student cocurriculum does not exist.

  ## Examples

      iex> get_student_cocurriculum!(123)
      %StudentCocurriculum{}

      iex> get_student_cocurriculum!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student_cocurriculum!(id), do: Repo.get!(StudentCocurriculum, id)

  @doc """
  Creates a student_cocurriculum.

  ## Examples

      iex> create_student_cocurriculum(%{field: value})
      {:ok, %StudentCocurriculum{}}

      iex> create_student_cocurriculum(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student_cocurriculum(attrs \\ %{}) do
    %StudentCocurriculum{}
    |> StudentCocurriculum.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a student_cocurriculum.

  ## Examples

      iex> update_student_cocurriculum(student_cocurriculum, %{field: new_value})
      {:ok, %StudentCocurriculum{}}

      iex> update_student_cocurriculum(student_cocurriculum, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student_cocurriculum(%StudentCocurriculum{} = student_cocurriculum, attrs) do
    student_cocurriculum
    |> StudentCocurriculum.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a StudentCocurriculum.

  ## Examples

      iex> delete_student_cocurriculum(student_cocurriculum)
      {:ok, %StudentCocurriculum{}}

      iex> delete_student_cocurriculum(student_cocurriculum)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student_cocurriculum(%StudentCocurriculum{} = student_cocurriculum) do
    Repo.delete(student_cocurriculum)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student_cocurriculum changes.

  ## Examples

      iex> change_student_cocurriculum(student_cocurriculum)
      %Ecto.Changeset{source: %StudentCocurriculum{}}

  """
  def change_student_cocurriculum(%StudentCocurriculum{} = student_cocurriculum) do
    StudentCocurriculum.changeset(student_cocurriculum, %{})
  end

  alias School.Affairs.Holiday

  @doc """
  Returns the list of holiday.

  ## Examples

      iex> list_holiday()
      [%Holiday{}, ...]

  """
  def list_holiday do
    Repo.all(Holiday)
  end

  @doc """
  Gets a single holiday.

  Raises `Ecto.NoResultsError` if the Holiday does not exist.

  ## Examples

      iex> get_holiday!(123)
      %Holiday{}

      iex> get_holiday!(456)
      ** (Ecto.NoResultsError)

  """
  def get_holiday!(id), do: Repo.get!(Holiday, id)

  @doc """
  Creates a holiday.

  ## Examples

      iex> create_holiday(%{field: value})
      {:ok, %Holiday{}}

      iex> create_holiday(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_holiday(attrs \\ %{}) do
    %Holiday{}
    |> Holiday.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a holiday.

  ## Examples

      iex> update_holiday(holiday, %{field: new_value})
      {:ok, %Holiday{}}

      iex> update_holiday(holiday, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_holiday(%Holiday{} = holiday, attrs) do
    holiday
    |> Holiday.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Holiday.

  ## Examples

      iex> delete_holiday(holiday)
      {:ok, %Holiday{}}

      iex> delete_holiday(holiday)
      {:error, %Ecto.Changeset{}}

  """
  def delete_holiday(%Holiday{} = holiday) do
    Repo.delete(holiday)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking holiday changes.

  ## Examples

      iex> change_holiday(holiday)
      %Ecto.Changeset{source: %Holiday{}}

  """
  def change_holiday(%Holiday{} = holiday) do
    Holiday.changeset(holiday, %{})
  end

  alias School.Affairs.Comment

  @doc """
  Returns the list of comment.

  ## Examples

      iex> list_comment()
      [%Comment{}, ...]

  """
  def list_comment do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{source: %Comment{}}

  """
  def change_comment(%Comment{} = comment) do
    Comment.changeset(comment, %{})
  end

  alias School.Affairs.StudentComment

  @doc """
  Returns the list of student_comment.

  ## Examples

      iex> list_student_comment()
      [%StudentComment{}, ...]

  """
  def list_student_comment do
    Repo.all(StudentComment)
  end

  @doc """
  Gets a single student_comment.

  Raises `Ecto.NoResultsError` if the Student comment does not exist.

  ## Examples

      iex> get_student_comment!(123)
      %StudentComment{}

      iex> get_student_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student_comment!(id), do: Repo.get!(StudentComment, id)

  @doc """
  Creates a student_comment.

  ## Examples

      iex> create_student_comment(%{field: value})
      {:ok, %StudentComment{}}

      iex> create_student_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student_comment(attrs \\ %{}) do
    %StudentComment{}
    |> StudentComment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a student_comment.

  ## Examples

      iex> update_student_comment(student_comment, %{field: new_value})
      {:ok, %StudentComment{}}

      iex> update_student_comment(student_comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student_comment(%StudentComment{} = student_comment, attrs) do
    student_comment
    |> StudentComment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a StudentComment.

  ## Examples

      iex> delete_student_comment(student_comment)
      {:ok, %StudentComment{}}

      iex> delete_student_comment(student_comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student_comment(%StudentComment{} = student_comment) do
    Repo.delete(student_comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student_comment changes.

  ## Examples

      iex> change_student_comment(student_comment)
      %Ecto.Changeset{source: %StudentComment{}}

  """
  def change_student_comment(%StudentComment{} = student_comment) do
    StudentComment.changeset(student_comment, %{})
  end

  alias School.Affairs.ExamPeriod

  @doc """
  Returns the list of examperiod.

  ## Examples

      iex> list_examperiod()
      [%ExamPeriod{}, ...]

  """
  def list_examperiod do
    Repo.all(ExamPeriod)
  end

  @doc """
  Gets a single exam_period.

  Raises `Ecto.NoResultsError` if the Exam period does not exist.

  ## Examples

      iex> get_exam_period!(123)
      %ExamPeriod{}

      iex> get_exam_period!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exam_period!(id), do: Repo.get!(ExamPeriod, id)

  @doc """
  Creates a exam_period.

  ## Examples

      iex> create_exam_period(%{field: value})
      {:ok, %ExamPeriod{}}

      iex> create_exam_period(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exam_period(attrs \\ %{}) do
    %ExamPeriod{}
    |> ExamPeriod.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exam_period.

  ## Examples

      iex> update_exam_period(exam_period, %{field: new_value})
      {:ok, %ExamPeriod{}}

      iex> update_exam_period(exam_period, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exam_period(%ExamPeriod{} = exam_period, attrs) do
    exam_period
    |> ExamPeriod.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ExamPeriod.

  ## Examples

      iex> delete_exam_period(exam_period)
      {:ok, %ExamPeriod{}}

      iex> delete_exam_period(exam_period)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exam_period(%ExamPeriod{} = exam_period) do
    Repo.delete(exam_period)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exam_period changes.

  ## Examples

      iex> change_exam_period(exam_period)
      %Ecto.Changeset{source: %ExamPeriod{}}

  """
  def change_exam_period(%ExamPeriod{} = exam_period) do
    ExamPeriod.changeset(exam_period, %{})
  end

  def has_calendar?(teacher_id, semester_id) do
    result =
      Repo.all(
        from(t in Timetable, where: t.teacher_id == ^teacher_id and t.semester_id == ^semester_id)
      )

    if result == [] do
      {:no, 0}
    else
      {:yes, hd(result).id}
    end
  end

  def initialize_calendar(institution_id, semester_id, teacher_id) do
    # create a calendar

    {:ok, timetable} =
      case School.Affairs.has_calendar?(teacher_id, semester_id) do
        {:yes, timetable_id} ->
          timetable = Repo.get(Timetable, timetable_id)
          {:ok, timetable}

        {:no, timetable_id} ->
          {:ok, timetable} =
            Timetable.changeset(%Timetable{}, %{
              teacher_id: teacher_id,
              institution_id: institution_id,
              semester_id: semester_id
            })
            |> Repo.insert()
      end

    {:ok, timetable}
  end

  def get_teacher(user_id) do
    user = Repo.get(School.Settings.User, user_id)

    teacher = Repo.get_by(Teacher, email: user.email)

    if teacher == nil do
      {:error, "no teacher assigned"}
    else
      {:ok, teacher}
    end
  end

  def get_user_role(user_id) do
    user = Repo.get(School.Settings.User, user_id)
    user.role
  end

  def get_exam_list_by_date(start_date, end_date, institution_id) do
    s_date =
      start_date
      |> String.split(" ")
      |> List.to_tuple()
      |> elem(0)
      |> String.split("/")
      |> List.to_tuple()

    s_time =
      start_date
      |> String.split(" ")
      |> List.to_tuple()
      |> elem(1)
      |> String.split(":")
      |> List.to_tuple()

    e_date =
      end_date
      |> String.split(" ")
      |> List.to_tuple()
      |> elem(0)
      |> String.split("/")
      |> List.to_tuple()

    e_time =
      end_date
      |> String.split(" ")
      |> List.to_tuple()
      |> elem(1)
      |> String.split(":")
      |> List.to_tuple()

    {:ok, start_datetime} =
      NaiveDateTime.new(
        String.to_integer(elem(s_date, 0)),
        String.to_integer(elem(s_date, 1)),
        String.to_integer(elem(s_date, 2)),
        String.to_integer(elem(s_time, 0)) - 8,
        String.to_integer(elem(s_time, 1)),
        0
      )

    {:ok, end_datetime} =
      NaiveDateTime.new(
        String.to_integer(elem(e_date, 0)),
        String.to_integer(elem(e_date, 1)),
        String.to_integer(elem(e_date, 2)),
        String.to_integer(elem(e_time, 0)) - 8,
        String.to_integer(elem(e_time, 1)),
        0
      )

    lists =
      Repo.all(
        from(
          e in ExamPeriod,
          left_join: ex in Exam,
          on: ex.id == e.exam_id,
          left_join: s in Subject,
          on: s.id == ex.subject_id,
          left_join: em in ExamMaster,
          on: em.id == ex.exam_master_id,
          where:
            e.start_date >= ^start_datetime and e.end_date <= ^end_datetime and
              e.institution_id == ^institution_id,
          select: %{
            exam_name: em.name,
            subject: s.description,
            start_date: e.start_date,
            end_date: e.end_date
          }
        )
      )

    lists =
      for list <- lists do
        title = Enum.join([list.exam_name, list.subject], "-")
        new_list = Map.put(list, :title, title)
        new_list = Map.put(new_list, :description, "")
        new_list = Map.delete(new_list, :exam_name)
        new_list = Map.delete(new_list, :subject)
        new_list
      end

    lists
  end

  def exam_period_list(institution_id) do
    lists =
      Repo.all(
        from(
          e in Exam,
          left_join: em in ExamMaster,
          on: e.exam_master_id == em.id,
          left_join: ep in ExamPeriod,
          on: ep.exam_id == e.id,
          left_join: s in Subject,
          on: s.id == e.subject_id,
          where: em.institution_id == ^institution_id,
          select: %{
            exam_name: em.name,
            subject: s.description,
            start_date: ep.start_date,
            end_date: ep.end_date
          }
        )
      )

    lists =
      for list <- lists do
        title = Enum.join([list.exam_name, list.subject], "-")
        new_list = Map.put(list, :title, title)
        new_list = Map.put(new_list, :description, "")
        new_list = Map.delete(new_list, :exam_name)
        new_list = Map.delete(new_list, :subject)
        new_list
      end

    lists
  end

  def teacher_period_list(teacher_id) do
    a =
      Repo.all(
        from(
          p in School.Affairs.Period,
          left_join: tt in School.Affairs.Timetable,
          on: p.timetable_id == tt.id,
          left_join: s in School.Affairs.Subject,
          on: s.id == p.subject_id,
          left_join: c in School.Affairs.Class,
          on: c.id == p.class_id,
          left_join: t in School.Affairs.Teacher,
          on: t.id == p.teacher_id,
          where: tt.teacher_id == ^teacher_id,
          select: %{
            period_id: p.id,
            subject: s.timetable_description,
            class: c.name,
            start_datetime: p.start_datetime,
            end_datetime: p.end_datetime,
            teacher: t.name,
            google_event_id: p.google_event_id,
            updated_at: p.updated_at,
            color: s.color
          }
        )
      )
      |> Enum.reject(fn x -> x.class == nil end)
      |> Enum.map(fn x ->
        %{
          start: my_time(x.start_datetime),
          end: my_time(x.end_datetime),
          title: "#{x.subject} - #{x.class}",
          description: x.teacher,
          period_id: x.period_id,
          google_event_id: x.google_event_id,
          updated_at: x.updated_at,
          color: x.color
        }
      end)

    a
  end

  def class_period_list(class_id) do
    a =
      Repo.all(
        from(
          p in School.Affairs.Period,
          left_join: tt in School.Affairs.Timetable,
          on: p.timetable_id == tt.id,
          left_join: s in School.Affairs.Subject,
          on: s.id == p.subject_id,
          left_join: c in School.Affairs.Class,
          on: c.id == p.class_id,
          left_join: t in School.Affairs.Teacher,
          on: t.id == p.teacher_id,
          where: p.class_id == ^class_id,
          select: %{
            period_id: p.id,
            subject: s.timetable_code,
            class: c.name,
            start_datetime: p.start_datetime,
            end_datetime: p.end_datetime,
            teacher: t.name,
            google_event_id: p.google_event_id,
            updated_at: p.updated_at,
            color: s.color
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          start: my_time(x.start_datetime),
          end: my_time(x.end_datetime),
          title: "#{x.subject} - #{x.teacher}",
          description: x.teacher,
          period_id: x.period_id,
          google_event_id: x.google_event_id,
          updated_at: x.updated_at,
          color: x.color
        }
      end)

    a
  end

  def all_attandence(class_id) do
    a =
      Repo.all(
        from(
          p in School.Affairs.Holiday,
          where:
            p.institution_id == ^@conn.private.plug_session["institution_id"] and
              p.semester_id == ^@conn.private.plug_session["semester_id"],
          select: %{
            start: p.date,
            title: p.description
          }
        )
      )

    # |> Enum.map(fn x ->
    #   %{
    #     start: my_time(x.start_datetime),
    #     end: my_time(x.end_datetime),
    #     title: x.subject <> " - " <> x.teacher,
    #     description: x.teacher,
    #     period_id: x.period_id,
    #     google_event_id: x.google_event_id,
    #     updated_at: x.updated_at,
    #     color: x.color
    #   }
    # end)

    a
  end

  def teacher_period_list(teacher_id, period_ids) do
    a =
      Repo.all(
        from(
          p in School.Affairs.Period,
          left_join: tt in School.Affairs.Timetable,
          on: p.timetable_id == tt.id,
          left_join: s in School.Affairs.Subject,
          on: s.id == p.subject_id,
          left_join: c in School.Affairs.Class,
          on: c.id == p.class_id,
          left_join: t in School.Affairs.Teacher,
          on: t.id == p.teacher_id,
          where: tt.teacher_id == ^teacher_id and p.id in ^period_ids,
          select: %{
            period_id: p.id,
            subject: s.description,
            class: c.name,
            start_datetime: p.start_datetime,
            end_datetime: p.end_datetime,
            teacher: t.name,
            google_event_id: p.google_event_id,
            updated_at: p.updated_at
          }
        )
      )
      |> Enum.map(fn x ->
        %{
          start: my_time(x.start_datetime),
          end: my_time(x.end_datetime),
          title: x.subject <> " - " <> x.class,
          description: x.teacher,
          period_id: x.period_id,
          google_event_id: x.google_event_id,
          updated_at: x.updated_at
        }
      end)

    a
  end

  def get_inst_id(conn) do
    conn.private.plug_session["institution_id"]
  end

  def get_semester_id(conn) do
    conn.private.plug_session["semester_id"]
  end

  def get_periods(institution_id) do
    Repo.all(
      from(
        s in Subject,
        left_join: p in Period,
        on: p.subject_id == s.id,
        left_join: c in Class,
        on: c.id == p.class_id,
        left_join: t in Teacher,
        on: t.id == p.teacher_id,
        where: s.institution_id == ^institution_id,
        select: %{
          period_id: p.id,
          subject: s.description,
          class: c.name,
          start_datetime: p.start_datetime,
          end_datetime: p.end_datetime,
          teacher: t.name,
          timetable_id: p.timetable_id
        }
      )
    )
    |> Enum.reject(fn x -> x.class == nil end)
    |> Enum.map(fn x ->
      %{
        start_datetime: my_time(x.start_datetime),
        end_datetime: my_time(x.end_datetime),
        id: x.period_id,
        title: x.subject <> " - " <> x.class,
        class: x.class,
        subject: x.subject,
        teacher: x.teacher,
        timetable_id: x.timetable_id
      }
    end)
  end

  def my_time(time) do
    if time == nil do
      nil
    else
      time
    end
  end

  def get_student_list(class_id, semester_id) do
    Repo.all(
      from(
        s in StudentClass,
        left_join: ss in Student,
        on: s.sudent_id == ss.id,
        where: s.class_id == ^class_id and s.semester_id == ^semester_id,
        select: %{name: ss.name, id: ss.id}
      )
    )
  end

  alias School.Affairs.SyncList

  @doc """
  Returns the list of sync_list.

  ## Examples

      iex> list_sync_list()
      [%SyncList{}, ...]

  """
  def list_sync_list do
    Repo.all(SyncList)
  end

  @doc """
  Gets a single sync_list.

  Raises `Ecto.NoResultsError` if the Sync list does not exist.

  ## Examples

      iex> get_sync_list!(123)
      %SyncList{}

      iex> get_sync_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sync_list!(id), do: Repo.get!(SyncList, id)

  @doc """
  Creates a sync_list.

  ## Examples

      iex> create_sync_list(%{field: value})
      {:ok, %SyncList{}}

      iex> create_sync_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sync_list(attrs \\ %{}) do
    %SyncList{}
    |> SyncList.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sync_list.

  ## Examples

      iex> update_sync_list(sync_list, %{field: new_value})
      {:ok, %SyncList{}}

      iex> update_sync_list(sync_list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sync_list(%SyncList{} = sync_list, attrs) do
    sync_list
    |> SyncList.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SyncList.

  ## Examples

      iex> delete_sync_list(sync_list)
      {:ok, %SyncList{}}

      iex> delete_sync_list(sync_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sync_list(%SyncList{} = sync_list) do
    Repo.delete(sync_list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sync_list changes.

  ## Examples

      iex> change_sync_list(sync_list)
      %Ecto.Changeset{source: %SyncList{}}

  """
  def change_sync_list(%SyncList{} = sync_list) do
    SyncList.changeset(sync_list, %{})
  end

  alias School.Affairs.ExamGrade

  @doc """
  Returns the list of exam_grade.

  ## Examples

      iex> list_exam_grade()
      [%ExamGrade{}, ...]

  """
  def list_exam_grade do
    Repo.all(ExamGrade)
  end

  @doc """
  Gets a single exam_grade.

  Raises `Ecto.NoResultsError` if the Exam grade does not exist.

  ## Examples

      iex> get_exam_grade!(123)
      %ExamGrade{}

      iex> get_exam_grade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exam_grade!(id), do: Repo.get!(ExamGrade, id)

  @doc """
  Creates a exam_grade.

  ## Examples

      iex> create_exam_grade(%{field: value})
      {:ok, %ExamGrade{}}

      iex> create_exam_grade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exam_grade(attrs \\ %{}) do
    %ExamGrade{}
    |> ExamGrade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exam_grade.

  ## Examples

      iex> update_exam_grade(exam_grade, %{field: new_value})
      {:ok, %ExamGrade{}}

      iex> update_exam_grade(exam_grade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exam_grade(%ExamGrade{} = exam_grade, attrs) do
    exam_grade
    |> ExamGrade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ExamGrade.

  ## Examples

      iex> delete_exam_grade(exam_grade)
      {:ok, %ExamGrade{}}

      iex> delete_exam_grade(exam_grade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exam_grade(%ExamGrade{} = exam_grade) do
    Repo.delete(exam_grade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exam_grade changes.

  ## Examples

      iex> change_exam_grade(exam_grade)
      %Ecto.Changeset{source: %ExamGrade{}}

  """
  def change_exam_grade(%ExamGrade{} = exam_grade) do
    ExamGrade.changeset(exam_grade, %{})
  end

  alias School.Affairs.Segak

  @doc """
  Returns the list of segak.

  ## Examples

      iex> list_segak()
      [%Segak{}, ...]

  """
  def list_segak do
    Repo.all(Segak)
  end

  @doc """
  Gets a single segak.

  Raises `Ecto.NoResultsError` if the Segak does not exist.

  ## Examples

      iex> get_segak!(123)
      %Segak{}

      iex> get_segak!(456)
      ** (Ecto.NoResultsError)

  """
  def get_segak!(id), do: Repo.get!(Segak, id)

  @doc """
  Creates a segak.

  ## Examples

      iex> create_segak(%{field: value})
      {:ok, %Segak{}}

      iex> create_segak(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_segak(attrs \\ %{}) do
    %Segak{}
    |> Segak.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a segak.

  ## Examples

      iex> update_segak(segak, %{field: new_value})
      {:ok, %Segak{}}

      iex> update_segak(segak, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_segak(%Segak{} = segak, attrs) do
    segak
    |> Segak.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Segak.

  ## Examples

      iex> delete_segak(segak)
      {:ok, %Segak{}}

      iex> delete_segak(segak)
      {:error, %Ecto.Changeset{}}

  """
  def delete_segak(%Segak{} = segak) do
    Repo.delete(segak)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking segak changes.

  ## Examples

      iex> change_segak(segak)
      %Ecto.Changeset{source: %Segak{}}

  """
  def change_segak(%Segak{} = segak) do
    Segak.changeset(segak, %{})
  end

  alias School.Affairs.ListRank

  @doc """
  Returns the list of list_rank.

  ## Examples

      iex> list_list_rank()
      [%ListRank{}, ...]

  """
  def list_list_rank do
    Repo.all(ListRank)
  end

  @doc """
  Gets a single list_rank.

  Raises `Ecto.NoResultsError` if the List rank does not exist.

  ## Examples

      iex> get_list_rank!(123)
      %ListRank{}

      iex> get_list_rank!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list_rank!(id), do: Repo.get!(ListRank, id)

  @doc """
  Creates a list_rank.

  ## Examples

      iex> create_list_rank(%{field: value})
      {:ok, %ListRank{}}

      iex> create_list_rank(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list_rank(attrs \\ %{}) do
    %ListRank{}
    |> ListRank.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a list_rank.

  ## Examples

      iex> update_list_rank(list_rank, %{field: new_value})
      {:ok, %ListRank{}}

      iex> update_list_rank(list_rank, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list_rank(%ListRank{} = list_rank, attrs) do
    list_rank
    |> ListRank.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ListRank.

  ## Examples

      iex> delete_list_rank(list_rank)
      {:ok, %ListRank{}}

      iex> delete_list_rank(list_rank)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list_rank(%ListRank{} = list_rank) do
    Repo.delete(list_rank)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list_rank changes.

  ## Examples

      iex> change_list_rank(list_rank)
      %Ecto.Changeset{source: %ListRank{}}

  """
  def change_list_rank(%ListRank{} = list_rank) do
    ListRank.changeset(list_rank, %{})
  end

  alias School.Affairs.Announcement

  @doc """
  Returns the list of announcements.

  ## Examples

      iex> list_announcements()
      [%Announcement{}, ...]

  """
  def list_announcements do
    Repo.all(Announcement)
  end

  def list_announcements(inst_id) do
    Repo.all(from(a in Announcement, where: a.institution_id == ^inst_id))
  end

  @doc """
  Gets a single announcement.

  Raises `Ecto.NoResultsError` if the Announcement does not exist.

  ## Examples

      iex> get_announcement!(123)
      %Announcement{}

      iex> get_announcement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_announcement!(id), do: Repo.get!(Announcement, id)

  @doc """
  Creates a announcement.

  ## Examples

      iex> create_announcement(%{field: value})
      {:ok, %Announcement{}}

      iex> create_announcement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_announcement(attrs \\ %{}) do
    %Announcement{}
    |> Announcement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a announcement.

  ## Examples

      iex> update_announcement(announcement, %{field: new_value})
      {:ok, %Announcement{}}

      iex> update_announcement(announcement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_announcement(%Announcement{} = announcement, attrs) do
    announcement
    |> Announcement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Announcement.

  ## Examples

      iex> delete_announcement(announcement)
      {:ok, %Announcement{}}

      iex> delete_announcement(announcement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking announcement changes.

  ## Examples

      iex> change_announcement(announcement)
      %Ecto.Changeset{source: %Announcement{}}

  """
  def change_announcement(%Announcement{} = announcement) do
    Announcement.changeset(announcement, %{})
  end

  alias School.Affairs.Ediscipline

  @doc """
  Returns the list of edisciplines.

  ## Examples

      iex> list_edisciplines()
      [%Ediscipline{}, ...]

  """
  def list_edisciplines do
    Repo.all(Ediscipline)
  end

  @doc """
  Gets a single ediscipline.

  Raises `Ecto.NoResultsError` if the Ediscipline does not exist.

  ## Examples

      iex> get_ediscipline!(123)
      %Ediscipline{}

      iex> get_ediscipline!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ediscipline!(id), do: Repo.get!(Ediscipline, id)

  @doc """
  Creates a ediscipline.

  ## Examples

      iex> create_ediscipline(%{field: value})
      {:ok, %Ediscipline{}}

      iex> create_ediscipline(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ediscipline(attrs \\ %{}) do
    %Ediscipline{}
    |> Ediscipline.changeset(attrs)
    |> Repo.insert()
  end

  @doc """

  Updates a ediscipline.

  ## Examples

      iex> update_ediscipline(ediscipline, %{field: new_value})
      {:ok, %Ediscipline{}}

      iex> update_ediscipline(ediscipline, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ediscipline(%Ediscipline{} = ediscipline, attrs) do
    ediscipline
    |> Ediscipline.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Ediscipline.

  ## Examples

      iex> delete_ediscipline(ediscipline)
      {:ok, %Ediscipline{}}

      iex> delete_ediscipline(ediscipline)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ediscipline(%Ediscipline{} = ediscipline) do
    Repo.delete(ediscipline)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ediscipline changes.

  ## Examples

      iex> change_ediscipline(ediscipline)
      %Ecto.Changeset{source: %Ediscipline{}}

  """
  def change_ediscipline(%Ediscipline{} = ediscipline) do
    Ediscipline.changeset(ediscipline, %{})
  end

  alias School.Affairs.HistoryExam

  @doc """
  Returns the list of history_exam.

  ## Examples

      iex> list_history_exam()
      [%HistoryExam{}, ...]

  """
  def list_history_exam do
    Repo.all(HistoryExam)
  end

  @doc """
  Gets a single history_exam.

  Raises `Ecto.NoResultsError` if the History exam does not exist.

  ## Examples

      iex> get_history_exam!(123)
      %HistoryExam{}

      iex> get_history_exam!(456)
      ** (Ecto.NoResultsError)

  """
  def get_history_exam!(id), do: Repo.get!(HistoryExam, id)

  @doc """
  Creates a history_exam.

  ## Examples

      iex> create_history_exam(%{field: value})
      {:ok, %HistoryExam{}}

      iex> create_history_exam(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_history_exam(attrs \\ %{}) do
    %HistoryExam{}
    |> HistoryExam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a history_exam.
  ## Examples

      iex> update_history_exam(history_exam, %{field: new_value})
      {:ok, %HistoryExam{}}

      iex> update_history_exam(history_exam, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_history_exam(%HistoryExam{} = history_exam, attrs) do
    history_exam
    |> HistoryExam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a HistoryExam.

  ## Examples

      iex> delete_history_exam(history_exam)
      {:ok, %HistoryExam{}}

      iex> delete_history_exam(history_exam)
      {:error, %Ecto.Changeset{}}

  """
  def delete_history_exam(%HistoryExam{} = history_exam) do
    Repo.delete(history_exam)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking history_exam changes.

  ## Examples

      iex> change_history_exam(history_exam)
      %Ecto.Changeset{source: %HistoryExam{}}

  """
  def change_history_exam(%HistoryExam{} = history_exam) do
    HistoryExam.changeset(history_exam, %{})
  end

  alias School.Affairs.AbsentHistory

  @doc """
  Returns the list of absent_history.

  ## Examples

      iex> list_absent_history()
      [%AbsentHistory{}, ...]

  """
  def list_absent_history do
    Repo.all(AbsentHistory)
  end

  @doc """
  Gets a single absent_history.

  Raises `Ecto.NoResultsError` if the Absent history does not exist.

  ## Examples

      iex> get_absent_history!(123)
      %AbsentHistory{}

      iex> get_absent_history!(456)
      ** (Ecto.NoResultsError)

  """
  def get_absent_history!(id), do: Repo.get!(AbsentHistory, id)

  @doc """
  Creates a absent_history.

  ## Examples

      iex> create_absent_history(%{field: value})
      {:ok, %AbsentHistory{}}

      iex> create_absent_history(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_absent_history(attrs \\ %{}) do
    %AbsentHistory{}
    |> AbsentHistory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a absent_history.

  ## Examples

      iex> update_absent_history(absent_history, %{field: new_value})
      {:ok, %AbsentHistory{}}

      iex> update_absent_history(absent_history, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_absent_history(%AbsentHistory{} = absent_history, attrs) do
    absent_history
    |> AbsentHistory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AbsentHistory.

  ## Examples

      iex> delete_absent_history(absent_history)
      {:ok, %AbsentHistory{}}

      iex> delete_absent_history(absent_history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_absent_history(%AbsentHistory{} = absent_history) do
    Repo.delete(absent_history)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking absent_history changes.

  ## Examples

      iex> change_absent_history(absent_history)
      %Ecto.Changeset{source: %AbsentHistory{}}

  """
  def change_absent_history(%AbsentHistory{} = absent_history) do
    AbsentHistory.changeset(absent_history, %{})
  end

  alias School.Affairs.Ehomework

  @doc """
  Returns the list of ehehomeworks.

  ## Examples

      iex> list_ehehomeworks()
      [%Ehomework{}, ...]

  """
  def list_ehehomeworks do
    Repo.all(Ehomework)
  end

  @doc """
  Gets a single ehomework.

  Raises `Ecto.NoResultsError` if the Ehomework does not exist.

  ## Examples

      iex> get_ehomework!(123)
      %Ehomework{}

      iex> get_ehomework!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ehomework!(id), do: Repo.get!(Ehomework, id)

  @doc """
  Creates a ehomework.

  ## Examples

      iex> create_ehomework(%{field: value})
      {:ok, %Ehomework{}}

      iex> create_ehomework(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ehomework(attrs \\ %{}) do
    %Ehomework{}
    |> Ehomework.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ehomework.

  ## Examples

      iex> update_ehomework(ehomework, %{field: new_value})
      {:ok, %Ehomework{}}

      iex> update_ehomework(ehomework, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ehomework(%Ehomework{} = ehomework, attrs) do
    ehomework
    |> Ehomework.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Ehomework.

  ## Examples

      iex> delete_ehomework(ehomework)
      {:ok, %Ehomework{}}

      iex> delete_ehomework(ehomework)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ehomework(%Ehomework{} = ehomework) do
    Repo.delete(ehomework)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ehomework changes.

  ## Examples

      iex> change_ehomework(ehomework)
      %Ecto.Changeset{source: %Ehomework{}}

  """
  def change_ehomework(%Ehomework{} = ehomework) do
    Ehomework.changeset(ehomework, %{})
  end

  alias School.Affairs.TeacherAttendance

  @doc """
  Returns the list of teacher_attendance.

  ## Examples

      iex> list_teacher_attendance()
      [%TeacherAttendance{}, ...]

  """
  def list_teacher_attendance do
    Repo.all(TeacherAttendance)
  end

  @doc """
  Gets a single teacher_attendance.

  Raises `Ecto.NoResultsError` if the Teacher attendance does not exist.

  ## Examples

      iex> get_teacher_attendance!(123)
      %TeacherAttendance{}

      iex> get_teacher_attendance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher_attendance!(id), do: Repo.get!(TeacherAttendance, id)

  @doc """
  Creates a teacher_attendance.

  ## Examples

      iex> create_teacher_attendance(%{field: value})
      {:ok, %TeacherAttendance{}}

      iex> create_teacher_attendance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher_attendance(attrs \\ %{}) do
    %TeacherAttendance{}
    |> TeacherAttendance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teacher_attendance.

  ## Examples

      iex> update_teacher_attendance(teacher_attendance, %{field: new_value})
      {:ok, %TeacherAttendance{}}

      iex> update_teacher_attendance(teacher_attendance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher_attendance(%TeacherAttendance{} = teacher_attendance, attrs) do
    teacher_attendance
    |> TeacherAttendance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeacherAttendance.

  ## Examples

      iex> delete_teacher_attendance(teacher_attendance)
      {:ok, %TeacherAttendance{}}

      iex> delete_teacher_attendance(teacher_attendance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher_attendance(%TeacherAttendance{} = teacher_attendance) do
    Repo.delete(teacher_attendance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher_attendance changes.

  ## Examples

      iex> change_teacher_attendance(teacher_attendance)
      %Ecto.Changeset{source: %TeacherAttendance{}}

  """
  def change_teacher_attendance(%TeacherAttendance{} = teacher_attendance) do
    TeacherAttendance.changeset(teacher_attendance, %{})
  end

  alias School.Affairs.RulesBreak

  @doc """
  Returns the list of rules_break.

  ## Examples

      iex> list_rules_break()
      [%RulesBreak{}, ...]

  """
  def list_rules_break do
    Repo.all(RulesBreak)
  end

  @doc """
  Gets a single rules_break.

  Raises `Ecto.NoResultsError` if the Rules break does not exist.

  ## Examples

      iex> get_rules_break!(123)
      %RulesBreak{}

      iex> get_rules_break!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rules_break!(id), do: Repo.get!(RulesBreak, id)

  @doc """
  Creates a rules_break.

  ## Examples

      iex> create_rules_break(%{field: value})
      {:ok, %RulesBreak{}}

      iex> create_rules_break(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rules_break(attrs \\ %{}) do
    %RulesBreak{}
    |> RulesBreak.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rules_break.

  ## Examples

      iex> update_rules_break(rules_break, %{field: new_value})
      {:ok, %RulesBreak{}}

      iex> update_rules_break(rules_break, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rules_break(%RulesBreak{} = rules_break, attrs) do
    rules_break
    |> RulesBreak.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RulesBreak.

  ## Examples

      iex> delete_rules_break(rules_break)
      {:ok, %RulesBreak{}}

      iex> delete_rules_break(rules_break)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rules_break(%RulesBreak{} = rules_break) do
    Repo.delete(rules_break)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rules_break changes.

  ## Examples

      iex> change_rules_break(rules_break)
      %Ecto.Changeset{source: %RulesBreak{}}

  """
  def change_rules_break(%RulesBreak{} = rules_break) do
    RulesBreak.changeset(rules_break, %{})
  end

  alias School.Affairs.AssessmentSubject

  @doc """
  Returns the list of assessment_subject.

  ## Examples

      iex> list_assessment_subject()
      [%AssessmentSubject{}, ...]

  """
  def list_assessment_subject do
    Repo.all(AssessmentSubject)
  end

  @doc """
  Gets a single assessment_subject.

  Raises `Ecto.NoResultsError` if the Assessment subject does not exist.

  ## Examples

      iex> get_assessment_subject!(123)
      %AssessmentSubject{}

      iex> get_assessment_subject!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assessment_subject!(id), do: Repo.get!(AssessmentSubject, id)

  @doc """
  Creates a assessment_subject.

  ## Examples

      iex> create_assessment_subject(%{field: value})
      {:ok, %AssessmentSubject{}}

      iex> create_assessment_subject(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assessment_subject(attrs \\ %{}) do
    %AssessmentSubject{}
    |> AssessmentSubject.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a assessment_subject.

  ## Examples

      iex> update_assessment_subject(assessment_subject, %{field: new_value})
      {:ok, %AssessmentSubject{}}

      iex> update_assessment_subject(assessment_subject, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_assessment_subject(%AssessmentSubject{} = assessment_subject, attrs) do
    assessment_subject
    |> AssessmentSubject.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AssessmentSubject.

  ## Examples

      iex> delete_assessment_subject(assessment_subject)
      {:ok, %AssessmentSubject{}}

      iex> delete_assessment_subject(assessment_subject)
      {:error, %Ecto.Changeset{}}

  """
  def delete_assessment_subject(%AssessmentSubject{} = assessment_subject) do
    Repo.delete(assessment_subject)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking assessment_subject changes.

  ## Examples

      iex> change_assessment_subject(assessment_subject)
      %Ecto.Changeset{source: %AssessmentSubject{}}

  """
  def change_assessment_subject(%AssessmentSubject{} = assessment_subject) do
    AssessmentSubject.changeset(assessment_subject, %{})
  end

  alias School.Affairs.AssessmentMark

  @doc """
  Returns the list of assessment_mark.

  ## Examples

      iex> list_assessment_mark()
      [%AssessmentMark{}, ...]

  """
  def list_assessment_mark do
    Repo.all(AssessmentMark)
  end

  @doc """
  Gets a single assessment_mark.

  Raises `Ecto.NoResultsError` if the Assessment mark does not exist.

  ## Examples

      iex> get_assessment_mark!(123)
      %AssessmentMark{}

      iex> get_assessment_mark!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assessment_mark!(id), do: Repo.get!(AssessmentMark, id)

  @doc """
  Creates a assessment_mark.

  ## Examples

      iex> create_assessment_mark(%{field: value})
      {:ok, %AssessmentMark{}}

      iex> create_assessment_mark(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assessment_mark(attrs \\ %{}) do
    %AssessmentMark{}
    |> AssessmentMark.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a assessment_mark.

  ## Examples

      iex> update_assessment_mark(assessment_mark, %{field: new_value})
      {:ok, %AssessmentMark{}}

      iex> update_assessment_mark(assessment_mark, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_assessment_mark(%AssessmentMark{} = assessment_mark, attrs) do
    assessment_mark
    |> AssessmentMark.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AssessmentMark.

  ## Examples

      iex> delete_assessment_mark(assessment_mark)
      {:ok, %AssessmentMark{}}

      iex> delete_assessment_mark(assessment_mark)
      {:error, %Ecto.Changeset{}}

  """
  def delete_assessment_mark(%AssessmentMark{} = assessment_mark) do
    Repo.delete(assessment_mark)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking assessment_mark changes.

  ## Examples

      iex> change_assessment_mark(assessment_mark)
      %Ecto.Changeset{source: %AssessmentMark{}}

  """
  def change_assessment_mark(%AssessmentMark{} = assessment_mark) do
    AssessmentMark.changeset(assessment_mark, %{})
  end

  alias School.Affairs.MarkSheetHistory

  @doc """
  Returns the list of mark_sheet_history.

  ## Examples

      iex> list_mark_sheet_history()
      [%MarkSheetHistory{}, ...]

  """
  def list_mark_sheet_history do
    Repo.all(MarkSheetHistory)
  end

  @doc """
  Gets a single mark_sheet_history.

  Raises `Ecto.NoResultsError` if the Mark sheet history does not exist.

  ## Examples

      iex> get_mark_sheet_history!(123)
      %MarkSheetHistory{}

      iex> get_mark_sheet_history!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mark_sheet_history!(id), do: Repo.get!(MarkSheetHistory, id)

  @doc """
  Creates a mark_sheet_history.

  ## Examples

      iex> create_mark_sheet_history(%{field: value})
      {:ok, %MarkSheetHistory{}}

      iex> create_mark_sheet_history(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mark_sheet_history(attrs \\ %{}) do
    %MarkSheetHistory{}
    |> MarkSheetHistory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mark_sheet_history.

  ## Examples

      iex> update_mark_sheet_history(mark_sheet_history, %{field: new_value})
      {:ok, %MarkSheetHistory{}}

      iex> update_mark_sheet_history(mark_sheet_history, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mark_sheet_history(%MarkSheetHistory{} = mark_sheet_history, attrs) do
    mark_sheet_history
    |> MarkSheetHistory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MarkSheetHistory.

  ## Examples

      iex> delete_mark_sheet_history(mark_sheet_history)
      {:ok, %MarkSheetHistory{}}

      iex> delete_mark_sheet_history(mark_sheet_history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mark_sheet_history(%MarkSheetHistory{} = mark_sheet_history) do
    Repo.delete(mark_sheet_history)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mark_sheet_history changes.

  ## Examples

      iex> change_mark_sheet_history(mark_sheet_history)
      %Ecto.Changeset{source: %MarkSheetHistory{}}

  """
  def change_mark_sheet_history(%MarkSheetHistory{} = mark_sheet_history) do
    MarkSheetHistory.changeset(mark_sheet_history, %{})
  end

  alias School.Affairs.MarkSheetHistorys

  @doc """
  Returns the list of mark_sheet_historys.

  ## Examples

      iex> list_mark_sheet_historys()
      [%MarkSheetHistorys{}, ...]

  """
  def list_mark_sheet_historys do
    Repo.all(MarkSheetHistorys)
  end

  @doc """
  Gets a single mark_sheet_historys.

  Raises `Ecto.NoResultsError` if the Mark sheet historys does not exist.

  ## Examples

      iex> get_mark_sheet_historys!(123)
      %MarkSheetHistorys{}

      iex> get_mark_sheet_historys!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mark_sheet_historys!(id), do: Repo.get!(MarkSheetHistorys, id)

  @doc """
  Creates a mark_sheet_historys.

  ## Examples

      iex> create_mark_sheet_historys(%{field: value})
      {:ok, %MarkSheetHistorys{}}

      iex> create_mark_sheet_historys(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mark_sheet_historys(attrs \\ %{}) do
    %MarkSheetHistorys{}
    |> MarkSheetHistorys.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mark_sheet_historys.

  ## Examples

      iex> update_mark_sheet_historys(mark_sheet_historys, %{field: new_value})
      {:ok, %MarkSheetHistorys{}}

      iex> update_mark_sheet_historys(mark_sheet_historys, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mark_sheet_historys(%MarkSheetHistorys{} = mark_sheet_historys, attrs) do
    mark_sheet_historys
    |> MarkSheetHistorys.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MarkSheetHistorys.

  ## Examples

      iex> delete_mark_sheet_historys(mark_sheet_historys)
      {:ok, %MarkSheetHistorys{}}

      iex> delete_mark_sheet_historys(mark_sheet_historys)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mark_sheet_historys(%MarkSheetHistorys{} = mark_sheet_historys) do
    Repo.delete(mark_sheet_historys)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mark_sheet_historys changes.

  ## Examples

      iex> change_mark_sheet_historys(mark_sheet_historys)
      %Ecto.Changeset{source: %MarkSheetHistorys{}}

  """
  def change_mark_sheet_historys(%MarkSheetHistorys{} = mark_sheet_historys) do
    MarkSheetHistorys.changeset(mark_sheet_historys, %{})
  end

  alias School.Affairs.MarkSheetTemp

  @doc """
  Returns the list of mark_sheet_temp.

  ## Examples

      iex> list_mark_sheet_temp()
      [%MarkSheetTemp{}, ...]

  """
  def list_mark_sheet_temp do
    Repo.all(MarkSheetTemp)
  end

  @doc """
  Gets a single mark_sheet_temp.

  Raises `Ecto.NoResultsError` if the Mark sheet temp does not exist.

  ## Examples

      iex> get_mark_sheet_temp!(123)
      %MarkSheetTemp{}

      iex> get_mark_sheet_temp!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mark_sheet_temp!(id), do: Repo.get!(MarkSheetTemp, id)

  @doc """
  Creates a mark_sheet_temp.

  ## Examples

      iex> create_mark_sheet_temp(%{field: value})
      {:ok, %MarkSheetTemp{}}

      iex> create_mark_sheet_temp(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mark_sheet_temp(attrs \\ %{}) do
    %MarkSheetTemp{}
    |> MarkSheetTemp.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mark_sheet_temp.

  ## Examples

      iex> update_mark_sheet_temp(mark_sheet_temp, %{field: new_value})
      {:ok, %MarkSheetTemp{}}

      iex> update_mark_sheet_temp(mark_sheet_temp, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mark_sheet_temp(%MarkSheetTemp{} = mark_sheet_temp, attrs) do
    mark_sheet_temp
    |> MarkSheetTemp.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MarkSheetTemp.

  ## Examples

      iex> delete_mark_sheet_temp(mark_sheet_temp)
      {:ok, %MarkSheetTemp{}}

      iex> delete_mark_sheet_temp(mark_sheet_temp)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mark_sheet_temp(%MarkSheetTemp{} = mark_sheet_temp) do
    Repo.delete(mark_sheet_temp)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mark_sheet_temp changes.

  ## Examples

      iex> change_mark_sheet_temp(mark_sheet_temp)
      %Ecto.Changeset{source: %MarkSheetTemp{}}

  """
  def change_mark_sheet_temp(%MarkSheetTemp{} = mark_sheet_temp) do
    MarkSheetTemp.changeset(mark_sheet_temp, %{})
  end

  alias School.Affairs.ShiftMaster

  @doc """
  Returns the list of shift_master.

  ## Examples

      iex> list_shift_master()
      [%ShiftMaster{}, ...]

  """
  def list_shift_master do
    Repo.all(ShiftMaster)
  end

  @doc """
  Gets a single shift_master.

  Raises `Ecto.NoResultsError` if the Shift master does not exist.

  ## Examples

      iex> get_shift_master!(123)
      %ShiftMaster{}

      iex> get_shift_master!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shift_master!(id), do: Repo.get!(ShiftMaster, id)

  @doc """
  Creates a shift_master.

  ## Examples

      iex> create_shift_master(%{field: value})
      {:ok, %ShiftMaster{}}

      iex> create_shift_master(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift_master(attrs \\ %{}) do
    %ShiftMaster{}
    |> ShiftMaster.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shift_master.

  ## Examples

      iex> update_shift_master(shift_master, %{field: new_value})
      {:ok, %ShiftMaster{}}

      iex> update_shift_master(shift_master, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift_master(%ShiftMaster{} = shift_master, attrs) do
    shift_master
    |> ShiftMaster.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ShiftMaster.

  ## Examples

      iex> delete_shift_master(shift_master)
      {:ok, %ShiftMaster{}}

      iex> delete_shift_master(shift_master)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift_master(%ShiftMaster{} = shift_master) do
    Repo.delete(shift_master)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shift_master changes.

  ## Examples

      iex> change_shift_master(shift_master)
      %Ecto.Changeset{source: %ShiftMaster{}}

  """
  def change_shift_master(%ShiftMaster{} = shift_master) do
    ShiftMaster.changeset(shift_master, %{})
  end

  alias School.Affairs.Shift

  @doc """
  Returns the list of shift.

  ## Examples

      iex> list_shift()
      [%Shift{}, ...]

  """
  def list_shift do
    Repo.all(Shift)
  end

  @doc """
  Gets a single shift.

  Raises `Ecto.NoResultsError` if the Shift does not exist.

  ## Examples

      iex> get_shift!(123)
      %Shift{}

      iex> get_shift!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shift!(id), do: Repo.get!(Shift, id)

  @doc """
  Creates a shift.

  ## Examples

      iex> create_shift(%{field: value})
      {:ok, %Shift{}}

      iex> create_shift(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift(attrs \\ %{}) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shift.

  ## Examples

      iex> update_shift(shift, %{field: new_value})
      {:ok, %Shift{}}

      iex> update_shift(shift, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift(%Shift{} = shift, attrs) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Shift.

  ## Examples

      iex> delete_shift(shift)
      {:ok, %Shift{}}

      iex> delete_shift(shift)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift(%Shift{} = shift) do
    Repo.delete(shift)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shift changes.

  ## Examples

      iex> change_shift(shift)
      %Ecto.Changeset{source: %Shift{}}

  """
  def change_shift(%Shift{} = shift) do
    Shift.changeset(shift, %{})
  end

  alias School.Affairs.TeacherAbsent

  @doc """
  Returns the list of teacher_absent.

  ## Examples

      iex> list_teacher_absent()
      [%TeacherAbsent{}, ...]

  """
  def list_teacher_absent do
    Repo.all(TeacherAbsent)
  end

  @doc """
  Gets a single teacher_absent.

  Raises `Ecto.NoResultsError` if the Teacher absent does not exist.

  ## Examples

      iex> get_teacher_absent!(123)
      %TeacherAbsent{}

      iex> get_teacher_absent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher_absent!(id), do: Repo.get!(TeacherAbsent, id)

  @doc """
  Creates a teacher_absent.

  ## Examples

      iex> create_teacher_absent(%{field: value})
      {:ok, %TeacherAbsent{}}

      iex> create_teacher_absent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher_absent(attrs \\ %{}) do
    %TeacherAbsent{}
    |> TeacherAbsent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a teacher_absent.

  ## Examples

      iex> update_teacher_absent(teacher_absent, %{field: new_value})
      {:ok, %TeacherAbsent{}}

      iex> update_teacher_absent(teacher_absent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher_absent(%TeacherAbsent{} = teacher_absent, attrs) do
    teacher_absent
    |> TeacherAbsent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeacherAbsent.

  ## Examples

      iex> delete_teacher_absent(teacher_absent)
      {:ok, %TeacherAbsent{}}

      iex> delete_teacher_absent(teacher_absent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher_absent(%TeacherAbsent{} = teacher_absent) do
    Repo.delete(teacher_absent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher_absent changes.

  ## Examples

      iex> change_teacher_absent(teacher_absent)
      %Ecto.Changeset{source: %TeacherAbsent{}}

  """
  def change_teacher_absent(%TeacherAbsent{} = teacher_absent) do
    TeacherAbsent.changeset(teacher_absent, %{})
  end

  alias School.Affairs.ExamAttendance

  @doc """
  Returns the list of exam_attendance.

  ## Examples

      iex> list_exam_attendance()
      [%ExamAttendance{}, ...]

  """
  def list_exam_attendance do
    Repo.all(ExamAttendance)
  end

  @doc """
  Gets a single exam_attendance.

  Raises `Ecto.NoResultsError` if the Exam attendance does not exist.

  ## Examples

      iex> get_exam_attendance!(123)
      %ExamAttendance{}

      iex> get_exam_attendance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exam_attendance!(id), do: Repo.get!(ExamAttendance, id)

  @doc """
  Creates a exam_attendance.

  ## Examples

      iex> create_exam_attendance(%{field: value})
      {:ok, %ExamAttendance{}}

      iex> create_exam_attendance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exam_attendance(attrs \\ %{}) do
    %ExamAttendance{}
    |> ExamAttendance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exam_attendance.

  ## Examples

      iex> update_exam_attendance(exam_attendance, %{field: new_value})
      {:ok, %ExamAttendance{}}

      iex> update_exam_attendance(exam_attendance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exam_attendance(%ExamAttendance{} = exam_attendance, attrs) do
    exam_attendance
    |> ExamAttendance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ExamAttendance.

  ## Examples

      iex> delete_exam_attendance(exam_attendance)
      {:ok, %ExamAttendance{}}

      iex> delete_exam_attendance(exam_attendance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exam_attendance(%ExamAttendance{} = exam_attendance) do
    Repo.delete(exam_attendance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exam_attendance changes.

  ## Examples

      iex> change_exam_attendance(exam_attendance)
      %Ecto.Changeset{source: %ExamAttendance{}}

  """
  def change_exam_attendance(%ExamAttendance{} = exam_attendance) do
    ExamAttendance.changeset(exam_attendance, %{})
  end

  alias School.Affairs.Student_coco_achievement

  @doc """
  Returns the list of student_coco_achievements.

  ## Examples

      iex> list_student_coco_achievements()
      [%Student_coco_achievement{}, ...]

  """
  def list_student_coco_achievements do
    Repo.all(Student_coco_achievement)
  end

  @doc """
  Gets a single student_coco_achievement.

  Raises `Ecto.NoResultsError` if the Student coco achievement does not exist.

  ## Examples

      iex> get_student_coco_achievement!(123)
      %Student_coco_achievement{}

      iex> get_student_coco_achievement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student_coco_achievement!(id), do: Repo.get!(Student_coco_achievement, id)

  @doc """
  Creates a student_coco_achievement.

  ## Examples

      iex> create_student_coco_achievement(%{field: value})
      {:ok, %Student_coco_achievement{}}

      iex> create_student_coco_achievement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student_coco_achievement(attrs \\ %{}) do
    %Student_coco_achievement{}
    |> Student_coco_achievement.changeset(attrs)
    |> Repo.insert()
  end

  def update_student_coco_achievement(
        %Student_coco_achievement{} = student_coco_achievement,
        attrs
      ) do
    student_coco_achievement
    |> Student_coco_achievement.changeset(attrs)
    |> Repo.update()
  end

  alias School.Affairs.StudentMarkNilam

  @doc """
  Returns the list of student_mark_nilam.

  ## Examples

      iex> list_student_mark_nilam()
      [%StudentMarkNilam{}, ...]

  """
  def list_student_mark_nilam do
    Repo.all(StudentMarkNilam)
  end

  @doc """
  Gets a single student_mark_nilam.

  Raises `Ecto.NoResultsError` if the Student mark nilam does not exist.

  ## Examples

      iex> get_student_mark_nilam!(123)
      %StudentMarkNilam{}

      iex> get_student_mark_nilam!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student_mark_nilam!(id), do: Repo.get!(StudentMarkNilam, id)

  @doc """
  Creates a student_mark_nilam.

  ## Examples

      iex> create_student_mark_nilam(%{field: value})
      {:ok, %StudentMarkNilam{}}

      iex> create_student_mark_nilam(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student_mark_nilam(attrs \\ %{}) do
    %StudentMarkNilam{}
    |> StudentMarkNilam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a student_coco_achievement.

  ## Examples

      iex> update_student_coco_achievement(student_coco_achievement, %{field: new_value})
      {:ok, %Student_coco_achievement{}}

      iex> update_student_coco_achievement(student_coco_achievement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_student_mark_nilam(%StudentMarkNilam{} = student_mark_nilam, attrs) do
    student_mark_nilam
    |> StudentMarkNilam.changeset(attrs)
    |> Repo.update()
  end

  @doc """

  Deletes a Student_coco_achievement.

  ## Examples

      iex> delete_student_coco_achievement(student_coco_achievement)
      {:ok, %Student_coco_achievement{}}

      iex> delete_student_coco_achievement(student_coco_achievement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student_coco_achievement(%Student_coco_achievement{} = student_coco_achievement) do
    Repo.delete(student_coco_achievement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student_coco_achievement changes.

  ## Examples

      iex> change_student_coco_achievement(student_coco_achievement)
      %Ecto.Changeset{source: %Student_coco_achievement{}}

  """
  def change_student_coco_achievement(%Student_coco_achievement{} = student_coco_achievement) do
    Student_coco_achievement.changeset(student_coco_achievement, %{})
  end

  alias School.Affairs.Coco_Rank

  def change_coco__rank(%Coco_Rank{} = coco__rank) do
    Coco_Rank.changeset(coco__rank, %{})
  end

  @doc """
  Returns the list of coco_ranks.

  ## Examples

      iex> list_coco_ranks()
      [%Coco_Rank{}, ...]

  """
  def list_coco_ranks do
    Repo.all(Coco_Rank)
  end

  @doc """
  Gets a single coco__rank.

  Raises `Ecto.NoResultsError` if the Coco  rank does not exist.

  ## Examples

      iex> get_coco__rank!(123)
      %Coco_Rank{}

      iex> get_coco__rank!(456)
      ** (Ecto.NoResultsError)

  """
  def get_coco__rank!(id), do: Repo.get!(Coco_Rank, id)

  @doc """
  Creates a coco__rank.

  ## Examples

      iex> create_coco__rank(%{field: value})
      {:ok, %Coco_Rank{}}

      iex> create_coco__rank(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coco__rank(attrs \\ %{}) do
    %Coco_Rank{}
    |> Coco_Rank.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a coco__rank.

  ## Examples

      iex> update_coco__rank(coco__rank, %{field: new_value})
      {:ok, %Coco_Rank{}}

      iex> update_coco__rank(coco__rank, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_coco__rank(%Coco_Rank{} = coco__rank, attrs) do
    coco__rank
    |> Coco_Rank.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Coco_Rank.

  ## Examples

      iex> delete_coco__rank(coco__rank)
      {:ok, %Coco_Rank{}}

      iex> delete_coco__rank(coco__rank)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coco__rank(%Coco_Rank{} = coco__rank) do
    Repo.delete(coco__rank)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coco__rank changes.

  ## Examples

      iex> change_coco__rank(coco__rank)
      %Ecto.Changeset{source: %Coco_Rank{}}

  """

  def delete_student_mark_nilam(%StudentMarkNilam{} = student_mark_nilam) do
    Repo.delete(student_mark_nilam)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student_mark_nilam changes.

  ## Examples

      iex> change_student_mark_nilam(student_mark_nilam)
      %Ecto.Changeset{source: %StudentMarkNilam{}}

  """
  def change_student_mark_nilam(%StudentMarkNilam{} = student_mark_nilam) do
    StudentMarkNilam.changeset(student_mark_nilam, %{})
  end

  def update_timetbl() do
    periods = Repo.all(Period)

    for period <- periods do
      timetable = Repo.get(Timetable, period.timetable_id)

      a = update_timetable(timetable, %{teacher_id: period.teacher_id})
      IO.inspect(a)
    end
  end

  def update_sbt() do
    sbt_data =
      Repo.all(
        from(
          p in Period,
          left_join: t in Teacher,
          on: t.id == p.teacher_id,
          left_join: s in Subject,
          on: s.id == p.subject_id,
          left_join: c in Class,
          on: c.id == p.class_id,
          select: %{
            sid: s.id,
            tid: t.id,
            cid: c.id,
            subject: s.description,
            teacher: t.name,
            class: c.name
          }
        )
      )
      |> Enum.uniq()

    for sbt <- sbt_data do
      res =
        Repo.all(
          from(
            s in SubjectTeachClass,
            where: s.subject_id == ^sbt.sid and s.class_id == ^sbt.cid
          )
        )

      if res |> Enum.count() == 1 do
        result = hd(res)

        a = SubjectTeachClass.changeset(result, %{teacher_id: sbt.tid}) |> Repo.update!()
        IO.inspect(a)
      else
      end
    end
  end

  def subject_mark(student, marks, subject_code) do
    data =
      marks
      |> Enum.filter(fn x ->
        x.stuid == Integer.to_string(student.student_id) and x.subject == subject_code
      end)

    subject = Repo.get_by(Subject, code: subject_code, institution_id: student.institution_id)

    if data != [] do
      a = data |> hd

      if a.s1g == "TH" do
        "TH"
      else
        if subject.with_mark == 0 do
          a.s1g
        else
          a.s1m
        end
      end
    else
      ""
    end
  end
end
