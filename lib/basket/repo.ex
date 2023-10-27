defmodule Basket.Repo do
  use Ecto.Repo,
    otp_app: :basket,
    adapter: Ecto.Adapters.Postgres
end
