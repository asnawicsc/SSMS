defmodule School.Affairs.Period do
  use Ecto.Schema
  import Ecto.Changeset

  schema "period" do
    field(:day, :string)
    field(:end_time, :time)
    field(:start_time, :time)
    # field(:subject_id, :integer)
    field(:teacher_id, :integer)
    field(:class_id, :integer)
    field(:recurring_frequency, :string)
    field(:recurring_until, :utc_datetime)
    field(:timetable_id, :integer)
    field(:start_datetime, :utc_datetime)
    field(:end_datetime, :utc_datetime)
    field(:google_event_id, :binary)
    field(:master_period_id, :integer)
    belongs_to(:subject, School.Affairs.Subject)
    timestamps()
  end

  @doc false
  def changeset(period, attrs) do
    period
    |> cast(attrs, [
      :master_period_id,
      :google_event_id,
      :recurring_frequency,
      :recurring_until,
      :timetable_id,
      :start_datetime,
      :end_datetime,
      :class_id,
      :start_time,
      :end_time,
      :day,
      :subject_id,
      :teacher_id
    ])
    |> unique_constraint(:start_datetime, name: :index_all_s_c)
  end
end
