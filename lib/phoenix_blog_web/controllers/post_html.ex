defmodule PhoenixBlogWeb.PostHTML do
  use PhoenixBlogWeb, :html

  embed_templates "post_html/*"

  @doc """
  Renders a post form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :current_user, PhoenixBlog.Accounts.User, required: true
  attr :tag_options, :list

  def post_form(assigns)
end
