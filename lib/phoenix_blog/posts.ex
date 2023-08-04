defmodule PhoenixBlog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias PhoenixBlog.Repo

  alias PhoenixBlog.Posts.Post
  alias PhoenixBlog.Posts.Tag

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    now = DateTime.utc_now()

    from(p in Post,
      where: p.visible == true,
      where: is_nil(p.published_on) or p.published_on < ^now,
      order_by: [desc: p.published_on]
    )
    |> Repo.all()
  end

  def filter_posts(search_term) do
    search_term = "%#{search_term}%"

    from(p in Post,
      where: ilike(p.title, ^search_term),
      order_by: [desc: p.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    from(p in Post, preload: [:user, :tags, :cover_image, comments: [:user]])
    |> Repo.get!(id)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}, tags \\ []) do
    %Post{}
    |> Post.changeset(attrs, tags)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs, tags \\ []) do
    post
    |> Repo.preload(:cover_image)
    |> Post.changeset(attrs, tags)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}, tags \\ []) do
    Post.changeset(post, attrs)
  end

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end

  alias PhoenixBlog.Posts.CoverImage

  @doc """
  Returns the list of cover_images.

  ## Examples

      iex> list_cover_images()
      [%CoverImage{}, ...]

  """
  def list_cover_images do
    Repo.all(CoverImage)
  end

  @doc """
  Gets a single cover_image.

  Raises `Ecto.NoResultsError` if the Cover image does not exist.

  ## Examples

      iex> get_cover_image!(123)
      %CoverImage{}

      iex> get_cover_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cover_image!(id), do: Repo.get!(CoverImage, id)

  @doc """
  Creates a cover_image.

  ## Examples

      iex> create_cover_image(%{field: value})
      {:ok, %CoverImage{}}

      iex> create_cover_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cover_image(attrs \\ %{}) do
    %CoverImage{}
    |> CoverImage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cover_image.

  ## Examples

      iex> update_cover_image(cover_image, %{field: new_value})
      {:ok, %CoverImage{}}

      iex> update_cover_image(cover_image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cover_image(%CoverImage{} = cover_image, attrs) do
    cover_image
    |> CoverImage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cover_image.

  ## Examples

      iex> delete_cover_image(cover_image)
      {:ok, %CoverImage{}}

      iex> delete_cover_image(cover_image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cover_image(%CoverImage{} = cover_image) do
    Repo.delete(cover_image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cover_image changes.

  ## Examples

      iex> change_cover_image(cover_image)
      %Ecto.Changeset{data: %CoverImage{}}

  """
  def change_cover_image(%CoverImage{} = cover_image, attrs \\ %{}) do
    CoverImage.changeset(cover_image, attrs)
  end
end
