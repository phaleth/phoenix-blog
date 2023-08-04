defmodule PhoenixBlog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoenixBlog.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        title: "some title",
        visible: Enum.random([true, false]),
        published_on: DateTime.utc_now()
      })
      |> PhoenixBlog.Posts.create_post()

    post
  end

  @doc """
  Generate a cover_image.
  """
  def cover_image_fixture(attrs \\ %{}) do
    {:ok, cover_image} =
      attrs
      |> Enum.into(%{
        url: "some url"
      })
      |> PhoenixBlog.Posts.create_cover_image()

    cover_image
  end
end
