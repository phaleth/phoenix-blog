defmodule PhoenixBlogWeb.PostControllerTest do
  use PhoenixBlogWeb.ConnCase

  import PhoenixBlog.PostsFixtures
  import PhoenixBlog.AccountsFixtures

  @create_attrs %{content: "some content", title: "some title"}
  @update_attrs %{
    content: "some updated content",
    title: "some updated title"
  }
  @invalid_attrs %{content: nil, title: nil}

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Listing Posts"
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/posts/new")

      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "Auth user redirects to show when data is valid", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> post(~p"/posts", post: Map.merge(%{user_id: user.id}, @create_attrs))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> post(~p"/posts", post: Map.merge(%{user_id: user.id}, @invalid_attrs))

      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, post: post, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/posts/#{post}/edit")

      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "doesnt renders form when not owner", %{conn: conn, post: post} do
      user = user_fixture()

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/posts/#{post}/edit")

      assert redirected_to(conn, 302) =~ "/posts/#{post.id}"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when data is valid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "redirects when user doesnt own post", %{conn: conn, post: post} do
      user = user_fixture()
      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "You can only edit or delete your own posts."
    end

    test "renders errors when data is invalid", %{conn: conn, post: post, user: user} do
      conn =
        conn
        |> log_in_user(user)
        |> put(~p"/posts/#{post}", post: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "unauth user cant deletes chosen post", %{conn: conn, post: post} do
      conn = delete(conn, ~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "login user deletes chosen post", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/posts/#{post}")
      end
    end

    test "login user cant delete post doesnt own", %{conn: conn, post: post} do
      user = user_fixture()
      conn = conn |> log_in_user(user) |> delete(~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts/#{post.id}"
    end
  end

  describe "search posts" do
    test "search for posts - non-matching", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(title: "some title", user_id: user.id)
      conn = get(conn, ~p"/search", search_term: "Non-Matching")
      refute html_response(conn, 200) =~ post.title
    end

    test "search for posts - exact match", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(title: "some title", user_id: user.id)
      conn = get(conn, ~p"/search", search_term: "some title")
      assert html_response(conn, 200) =~ post.title
    end

    test "search for posts - partial match", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(title: "some title", user_id: user.id)
      conn = get(conn, ~p"/search", search_term: "itl")
      assert html_response(conn, 200) =~ post.title
    end
  end

  defp create_post(_) do
    user = user_fixture()
    post = post_fixture(user_id: user.id)
    %{post: post, user: user}
  end
end
