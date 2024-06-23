defmodule PhoenixBlog.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_blog,
    adapter:
      if(Mix.env() in [:dev, :prod],
        do: Ecto.Adapters.SQLite3,
        else: Ecto.Adapters.Postgres
      )
end
