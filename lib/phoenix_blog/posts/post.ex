defmodule PhoenixBlog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :title, :string
    field :published_on, :date
    field :visible, :boolean

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :visible, :published_on])
    # |> validate_change( TODO )
    |> validate_required([:title, :content])
  end
end
