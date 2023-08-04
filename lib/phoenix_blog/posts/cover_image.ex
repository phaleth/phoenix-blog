defmodule PhoenixBlog.Posts.CoverImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cover_images" do
    field :url, :string
    belongs_to :post, PhoenixBlog.Posts.Post

    timestamps()
  end

  @doc false
  def changeset(cover_image, attrs) do
    cover_image
    |> cast(attrs, [:url, :post_id])
    |> validate_required([:url])
  end
end
