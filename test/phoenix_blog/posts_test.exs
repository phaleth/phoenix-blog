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
      assert Posts.list_posts() == [post]
    end

    test "list_posts/0 returns all posts except visible" do
      user = user_fixture()
      post = post_fixture(visible: true, published_on: nil, user_id: user.id)
      _post2 = post_fixture(visible: false, user_id: user.id)
      assert Posts.list_posts() == [post]
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

      assert Posts.list_posts() == [present, past]
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      assert Posts.get_post!(post.id) == Repo.preload(post, :comments)
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
      assert Repo.preload(post, :comments) == Posts.get_post!(post.id)
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
      assert Posts.filter_posts("Non-Matching") == []
      # exact match
      assert Posts.filter_posts("Title") == [post]
      # partial match end
      assert Posts.filter_posts("tle") == [post]
      # partial match front
      assert Posts.filter_posts("Titl") == [post]
      # partial match middle
      assert Posts.filter_posts("itl") == [post]
      # case insensitive lower
      assert Posts.filter_posts("title") == [post]
      # case insensitive upper
      assert Posts.filter_posts("TITLE") == [post]
      # case insensitive and partial match
      assert Posts.filter_posts("ITL") == [post]
      # empty
      assert Posts.filter_posts("") == [post]
    end
  end
end
