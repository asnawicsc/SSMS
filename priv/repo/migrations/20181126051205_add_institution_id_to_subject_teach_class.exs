defmodule School.Repo.Migrations.AddInstitutionIdToSubjectTeachClass do
  use Ecto.Migration

  def change do
    alter table("subject_teach_class") do
      add(:institution_id, :integer)
    end
  end
end

#       %{b_cert: "CC25122", count: 2},
# %{b_cert: "BX99543", count: 2},
# %{b_cert: "A14662", count: 2},
# %{b_cert: "BP53232", count: 2},
# %{b_cert: "BQ39723", count: 2},
# %{b_cert: "BY04201", count: 2},
# %{b_cert: "BN43267", count: 2},
# %{b_cert: "BC93622", count: 2}
