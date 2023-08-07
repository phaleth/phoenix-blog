defmodule PhoenixBlogWeb.PageControllerTest do
  use PhoenixBlogWeb.ConnCase
  import PhoenixBlog.PostsFixtures
  import PhoenixBlog.AccountsFixtures

  test "GET /", %{conn: conn} do
    user = user_fixture()
    post_fixture(user_id: user.id)
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Featured post"
  end
end
