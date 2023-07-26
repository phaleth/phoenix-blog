# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhoenixBlog.Repo.insert!(%PhoenixBlog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Enum.map(1..100, fn i ->
  PhoenixBlog.Posts.create_post(%{
    title: "title #{i}",
    content: "content",
    published_on: DateTime.utc_now()
  })
end)
