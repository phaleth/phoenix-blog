defmodule PhoenixBlogWeb.CommentControllerTest do
  use PhoenixBlogWeb.ConnCase

  import PhoenixBlog.CommentsFixtures
  import PhoenixBlog.PostsFixtures

  @create_attrs %{content: "some content"}
  @update_attrs %{content: "some updated content"}
  @invalid_attrs %{content: nil}

  describe "create comment" do
    test "redirects to post show page", %{conn: conn} do
      post = post_fixture()
      create_comment = Map.merge(@create_attrs, %{post_id: post.id})
      conn = post(conn, ~p"/comments", comment: create_comment)

      assert %{id: id} = redirected_params(conn)

      assert redirected_to(conn) == ~p"/posts/#{post.id}"

      conn = get(conn, ~p"/posts/#{post.id}")
      assert html_response(conn, 200) =~ "Post #{post.id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/comments", comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  describe "edit comment" do
    setup [:create_comment]

    test "renders form for editing chosen comment", %{conn: conn, comment: comment} do
      conn = get(conn, ~p"/comments/#{comment}/edit")
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "update comment" do
    setup [:create_comment]

    test "redirects when data is valid", %{conn: conn, comment: comment} do
      conn = put(conn, ~p"/comments/#{comment}", comment: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{comment.post_id}"

      conn = get(conn, ~p"/posts/#{comment.post_id}")
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, comment: comment} do
      conn = put(conn, ~p"/comments/#{comment}", comment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Comment"
    end
  end

  describe "delete comment" do
    setup [:create_comment]

    @tag :skip
    test "deletes chosen comment", %{conn: conn, comment: comment} do
      conn = delete(conn, ~p"/comments/#{comment}")
      assert redirected_to(conn) =~ ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/comments/#{comment}")
      end
    end
  end

  defp create_comment(_) do
    post = post_fixture()
    comment = comment_fixture(post_id: post.id)
    %{comment: comment}
  end
end
