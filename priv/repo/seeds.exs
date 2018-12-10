# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     School.Repo.insert!(%School.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias School.Settings
alias School.Settings.UserAccess
alias School.Settings.Institution
alias School.Settings.User
alias School.Repo
import Ecto.Query

# user = Settings.get_user!(1)

# Settings.update_user(user, role: "Admin")
Settings.create_user_access(%{user_id: 1, institution_id: 1})
