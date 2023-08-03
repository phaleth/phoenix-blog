defmodule PhoenixBlog.PostsTest do
  use PhoenixBlog.DataCase

  alias PhoenixBlog.Posts
  alias PhoenixBlog.Comments

  describe "posts" do
    alias PhoenixBlog.Posts.Post

    import PhoenixBlog.PostsFixtures
    import PhoenixBlog.CommentsFixtures
    import PhoenixBlog.AccountsFixtures

    @invalid_attrs %{content: nil, title: nil}

    test "list_posts/0 returns all posts" do
      user = user_fixture()
      post = post_fixture(visible: true, published_on: nil, user_id: user.id)
      assert Repo.preload(Posts.list_posts(), :tags) == [post]
    end

    test "list_posts/0 returns all posts except visible" do
      user = user_fixture()
      post = post_fixture(visible: true, published_on: nil, user_id: user.id)
      _post2 = post_fixture(visible: false, user_id: user.id)
      assert Repo.preload(Posts.list_posts(), :tags) == [post]
    end

    test "list_posts/0 returns posts displayed as from newest -> oldest" do
      user = user_fixture()

      past =
        post_fixture(
          user_id: user.id,
          visible: true,
          published_on: DateTime.utc_now() |> DateTime.add(-1, :day)
        )

      present =
        post_fixture(
          user_id: user.id,
          visible: true,
          published_on: DateTime.utc_now() |> DateTime.add(-1, :minute)
        )

      _future =
        post_fixture(
          user_id: user.id,
          visible: true,
          published_on: DateTime.utc_now() |> DateTime.add(1, :day)
        )

      assert Repo.preload(Posts.list_posts(), :tags) == [present, past]
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      assert Repo.preload(Posts.get_post!(post.id), :tags) ==
               Repo.preload(post, [:user, comments: [:user]])
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()

      valid_attrs = %{content: "some content", title: "some title", user_id: user.id}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.content == "some content"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      update_attrs = %{
        content: "some updated content",
        title: "some updated title"
      }

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.content == "some updated content"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)

      preloaded =
        from(p in Post, preload: [:user, :tags, comments: [:user]])
        |> Repo.get!(post.id)

      assert preloaded == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "delete_post/1 deletes the post and associated comments" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(post_id: post.id, user_id: user.id)
      assert {:ok, %Post{}} = Posts.delete_post(post)

      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
      assert_raise Ecto.NoResultsError, fn -> Comments.get_comment!(comment.id) end
    end

    test "change_post/1 returns a post changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end

    test "create_post/1 with valid data creates and bunch of content then delete_post/1" do
      user = user_fixture()
      some_content = Enum.to_list(1..1_000) |> Enum.join(", ")
      valid_attrs = %{content: some_content, title: "some title", user_id: user.id}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.content == some_content
      assert post.title == "some title"
      assert {:ok, %Post{}} = Posts.delete_post(post)
    end

    test "filter_posts/1 filters posts by partial and case-insensitive title" do
      user = user_fixture()
      post = post_fixture(title: "Title", user_id: user.id)

      # non-matching
      assert Repo.preload(Posts.filter_posts("Non-Matching"), :tags) == []
      # exact match
      assert Repo.preload(Posts.filter_posts("Title"), :tags) == [post]
      # partial match end
      assert Repo.preload(Posts.filter_posts("tle"), :tags) == [post]
      # partial match front
      assert Repo.preload(Posts.filter_posts("Titl"), :tags) == [post]
      # partial match middle
      assert Repo.preload(Posts.filter_posts("itl"), :tags) == [post]
      # case insensitive lower
      assert Repo.preload(Posts.filter_posts("title"), :tags) == [post]
      # case insensitive upper
      assert Repo.preload(Posts.filter_posts("TITLE"), :tags) == [post]
      # case insensitive and partial match
      assert Repo.preload(Posts.filter_posts("ITL"), :tags) == [post]
      # empty
      assert Repo.preload(Posts.filter_posts(""), :tags) == [post]
    end
  end

  describe "tags" do
    alias PhoenixBlog.Posts.Tag

    import PhoenixBlog.TagsFixtures

    @invalid_attrs %{name: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Posts.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Posts.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Tag{} = tag} = Posts.create_tag(valid_attrs)
      assert tag.name == "some name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Tag{} = tag} = Posts.update_tag(tag, update_attrs)
      assert tag.name == "some updated name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_tag(tag, @invalid_attrs)
      assert tag == Posts.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Posts.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Posts.change_tag(tag)
    end
  end
end
