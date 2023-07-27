defmodule PhoenixBlogWeb.CommentHTML do
  use PhoenixBlogWeb, :html

  embed_templates "comment_html/*"

  @doc """
  Renders a comment form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def comment_form(assigns)
end
