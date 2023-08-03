defmodule PhoenixBlog.Repo.Migrations.AddInitialUserAssociatePostsComments do
  use Ecto.Migration
  import PhoenixBlog.Accounts

  def change do
    {:ok, migrated_user} =
      PhoenixBlog.Accounts.register_user(%{
        username: "migrated_user",
        email: "migrated_user@here.com",
        password: "password"
      })

    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all), null: false, default: migrated_user.id
    end

    alter table(:comments) do
      add :user_id, references(:users, on_delete: :delete_all), null: false, default: migrated_user.id
    end
  end
end
