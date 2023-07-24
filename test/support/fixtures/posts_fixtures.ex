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
        subtitle: "some subtitle",
        title: "some title"
      })
      |> PhoenixBlog.Posts.create_post()

    post
  end
end
