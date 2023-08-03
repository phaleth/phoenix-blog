defmodule PhoenixBlogWeb.PostController do
  use PhoenixBlogWeb, :controller

  plug :require_user_owns_post when action in [:edit, :update, :delete]

  alias PhoenixBlog.Comments
  alias PhoenixBlog.Comments.Comment
  alias PhoenixBlog.Posts
  alias PhoenixBlog.Posts.Post

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{tags: []})
    render(conn, :new, changeset: changeset, tag_options: tag_options())
  end

  def create(conn, %{"post" => post_params}) do
    tags = Map.get(post_params, "tag_ids", []) |> Enum.map(&Posts.get_tag!/1)

    case Posts.create_post(post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new,
          changeset: changeset,
          tag_options: tag_options(Enum.map(tags, & &1.id))
        )
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)

    comment_changeset = Comments.change_comment(%Comment{})

    render(conn, :show, post: post, comment_changeset: comment_changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)

    render(conn, :edit,
      post: post,
      changeset: changeset,
      tag_options: tag_options(Enum.map(post.tags, & &1.id))
    )
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)
    tags = Map.get(post_params, "tag_ids", []) |> Enum.map(&Posts.get_tag!/1)

    case Posts.update_post(post, post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          post: post,
          changeset: changeset,
          tag_options: tag_options(Enum.map(tags, & &1.id))
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end

  def search(conn, params) do
    search_term = Map.get(params, "search_term", "")

    posts =
      case search_term do
        "" -> Posts.list_posts()
        _ -> Posts.filter_posts(search_term)
      end

    render(conn, :index, posts: posts)
  end

  defp require_user_owns_post(conn, _params) do
    post_id = String.to_integer(conn.path_params["id"])
    post = Posts.get_post!(post_id)

    if conn.assigns[:current_user].id == post.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You can only edit or delete your own posts.")
      |> redirect(to: ~p"/posts/#{post_id}")
      |> halt()
    end
  end

  defp tag_options(selected_ids \\ []) do
    Posts.list_tags()
    |> Enum.map(fn tag ->
      [key: tag.name, value: tag.id, selected: tag.id in selected_ids]
    end)
  end
end
