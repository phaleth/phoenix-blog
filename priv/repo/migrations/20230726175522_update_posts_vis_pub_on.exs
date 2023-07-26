defmodule PhoenixBlog.Repo.Migrations.UpdatePostsVisPubOn do
  use Ecto.Migration

  def up do
    alter table(:posts) do
      remove :subtitle
      add :published_on, :date
      add :visible, :boolean, default: true
    end
  end

  def down do
    alter table(:posts) do
      add :subtitle, :string
      remove :published_on
      remove :visible
    end
  end
end
