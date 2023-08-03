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
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> PhoenixBlog.Posts.create_tag()

    tag
  end
end
