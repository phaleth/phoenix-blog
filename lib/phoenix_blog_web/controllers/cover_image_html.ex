defmodule PhoenixBlogWeb.CoverImageHTML do
  use PhoenixBlogWeb, :html

  embed_templates "cover_image_html/*"

  @doc """
  Renders a cover_image form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def cover_image_form(assigns)
end
