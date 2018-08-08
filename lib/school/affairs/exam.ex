defmodule School.Affairs.Exam do
  use Ecto.Schema
  import Ecto.Changeset


  schema "exam" do
    field :exam_master_id, :integer
    field :subject_id, :integer

    timestamps()
  end

  @doc false
  def changeset(exam, attrs) do
    exam
    |> cast(attrs, [:subject_id, :exam_master_id])
    |> validate_required([:subject_id, :exam_master_id])
  end
end
