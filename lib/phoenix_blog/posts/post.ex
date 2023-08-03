defmodule PhoenixBlog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field(:content, :string)
    field(:title, :string)
    field(:published_on, :utc_datetime)
    field(:visible, :boolean, default: true)
    has_many :comments, PhoenixBlog.Comments.Comment
    belongs_to :user, PhoenixBlog.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :visible, :published_on, :user_id])
    # |> validate_change( TODO )
    |> validate_required([:title, :content, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
