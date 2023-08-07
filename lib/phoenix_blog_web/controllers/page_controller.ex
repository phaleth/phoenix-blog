defmodule PhoenixBlogWeb.PageController do
  use PhoenixBlogWeb, :controller
  alias PhoenixBlog.Posts

  def home(conn, _params) do
    render(conn, :home, post: Posts.random_post(), posts: Posts.three_list_posts())
  end
end
