defmodule PhoenixBlogWeb.PostHTML do
  use PhoenixBlogWeb, :html

  embed_templates "post_html/*"

  @doc """
  Renders a post form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def post_form(assigns)

  @doc """
  Renders a comment form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :post_id, :integer, required: true

  def comment_form(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} action={~p"/comments/"}>
      <.error :if={@changeset.action}>
        Oops, something went wrong! Please check the errors below.
      </.error>
      <.input field={f[:post_id]} type="hidden" value={@post_id} />
      <.input field={f[:content]} type="text" label="Content" />
      <:actions>
        <.button>Save Comment</.button>
      </:actions>
    </.simple_form>
    """
  end
end
