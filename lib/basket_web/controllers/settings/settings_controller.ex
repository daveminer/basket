defmodule BasketWeb.SettingsController do
  use BasketWeb, :controller

  alias Basket.Repo

  def index(conn, _params) do
    conn =
      if user = Pow.Plug.current_user(conn) do
        user = Repo.preload(user, [:clubs, :offices])
        assign(conn, :current_user, user)
      else
        conn
      end

    render(assign(conn, :form, %{}), "index.html")
  end
end
