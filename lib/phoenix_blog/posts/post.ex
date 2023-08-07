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
    many_to_many :tags, PhoenixBlog.Posts.Tag, join_through: "posts_tags", on_replace: :delete
    has_one :cover_image, PhoenixBlog.Posts.CoverImage

    timestamps()
  end

  @doc false
  def changeset(post, attrs, tags \\ []) do
    post
    |> cast(attrs, [:title, :content, :visible, :published_on, :user_id])
    # |> validate_change( TODO )
    |> cast_assoc(:cover_image)
    |> validate_required([:title, :content, :visible, :user_id])
    |> foreign_key_constraint(:user_id)
    |> put_assoc(:tags, tags)
  end
end
