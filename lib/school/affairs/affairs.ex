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
end
