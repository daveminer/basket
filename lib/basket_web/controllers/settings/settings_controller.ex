defmodule BasketWeb.SettingsController do
  use BasketWeb, :controller

  def index(conn, _params) do
    render(assign(conn, :form, %{}), "index.html")
  end
end
